public with sharing class ProjectController {

    private static List<TodoItem__c> getAllProjects(){
        return [SELECT Id, Name, Status__c, Milestone__c, Milestone__r.Name, Milestone__r.Status__c, 
                       Milestone__r.Percentage_complete__c, Milestone__r.Project__c, Milestone__r.Project__r.Name, 
                       Milestone__r.Project__r.Status__c, Milestone__r.Project__r.Percentage_complete__c
                FROM TodoItem__c
                ORDER BY Milestone__r.Project__r.CreatedDate, Milestone__r.CreatedDate, CreatedDate];
    }

    private static TodoItem createTodoItem(TodoItem__c todoItem){
        TodoItem t = new TodoItem();

        t.id = todoItem.Id;
        t.name = todoItem.Name;
        t.status = todoItem.Status__c;
        t.label = t.name;
        t.checked = t.status.equals('Complete') ? true : false;

        return t;
    }

    private static Map<String, TodoItem> createTodoItemsMap(TodoItem__c todoItem){
        Map<String, TodoItem> todoItemsMap = new Map<String, TodoItem>();
        todoItemsMap.put(todoItem.Id, createTodoItem(todoItem));
        return todoItemsMap;
    }

    private static Milestone createMilestone(TodoItem__c todoItem, Map<String, TodoItem> todoItemsMap){
        Milestone m = new Milestone();

        m.id = todoItem.Milestone__c;
        m.name = todoItem.Milestone__r.Name;
        m.status = todoItem.Milestone__r.Status__c;
        m.percentageComplete = todoItem.Milestone__r.Percentage_complete__c;
        m.todoItemsMap = todoItemsMap;
        m.todoItems = todoItemsMap.values();
        m.label = '['+m.percentageComplete+'%] '+m.name;

        return m;
    }

    private static Map<String, Milestone> createMilestonesMap(TodoItem__c todoItem, Map<String, TodoItem> todoItemsMap){
        Map<String, Milestone> milestonesMap = new Map<String, Milestone>();
        milestonesMap.put(todoItem.Milestone__c, createMilestone(todoItem, todoItemsMap));
        return milestonesMap;
    }

    private static Project createProject(TodoItem__c todoItem){
        Map<String, Project> projectMap = new Map<String, Project>();
        Map<String, TodoItem> todoItemsMap = createTodoItemsMap(todoItem);
        Map<String, Milestone> milestonesMap = createMilestonesMap(todoItem, todoItemsMap);
        
        Project p = new Project();
        p.id = todoItem.Milestone__r.Project__c;
        p.name = todoItem.Milestone__r.Project__r.Name;
        p.status = todoItem.Milestone__r.Project__r.Status__c;
        p.percentageComplete = todoItem.Milestone__r.Project__r.Percentage_complete__c;
        p.milestonesMap = milestonesMap;
        p.milestones = milestonesMap.values();
        p.label = '['+p.percentageComplete+'%] '+p.name;

        return p;
    }

    private static List<Project> getAllProjectsAsJSON(){
        Map<String, Project> projectMap = new Map<String, Project>();

        for(TodoItem__c todoItem : getAllProjects()){
            Project project = projectMap.get(todoItem.Milestone__r.Project__c);

            if(project == null){
                projectMap.put(todoItem.Milestone__r.Project__c, createProject(todoItem));
            }
            else{
                if(project.milestonesMap != null){
                    Milestone milestone = project.milestonesMap.get(todoItem.Milestone__c);
                    
                    if(milestone != null){
                        project.milestonesMap.get(todoItem.Milestone__c).todoItemsMap.put(todoItem.Id, createTodoItem(todoItem));
                        project.milestonesMap.get(todoItem.Milestone__c).todoItems = project.milestonesMap.get(todoItem.Milestone__c).todoItemsMap.values();
                    }
                    else{
                        Map<String, TodoItem> todoItemsMap = createTodoItemsMap(todoItem);
                        milestone = createMilestone(todoItem, todoItemsMap);
                        project.milestonesMap.put(todoItem.Milestone__c, milestone);
                        project.milestones = project.milestonesMap.values();
                    }
                }
            }
        }
        
        return projectMap.values();
    }

    @AuraEnabled
    public static String getProjectsJSON() {
        return JSON.serialize(getAllProjectsAsJSON());
    }

    @AuraEnabled
    public static Project__c createProject(String name, String description, Date startDate, Date endDate) {
        Project__c project = new Project__c(Name = name, Description__c = description, Start_Date__c = startDate, End_Date__c = endDate);
        insert project;
        return project;
    }

    @AuraEnabled
    public static void updateProject(String projectId, String name, String description, Date startDate, Date endDate) {
        Project__c project = [SELECT Id FROM Project__c WHERE Id = :projectId];
        project.Name = name;
        project.Description__c = description;
        project.Start_Date__c = startDate;
        project.End_Date__c = endDate;
        update project;
    }

    @AuraEnabled
    public static void deleteProject(String projectId) {
        Project__c project = [SELECT Id FROM Project__c WHERE Id = :projectId];
        delete project;
    }

    private static TodoItem__c getTodoItem(String recordId){
        return [SELECT Id, Status__c FROM TodoItem__c WHERE Id =: recordId];
    }

    @AuraEnabled
    public static void updateTodoItemStatus(String recordId, Boolean checked){
        TodoItem__c t = getTodoItem(recordId);
        t.Status__c = checked ? 'Complete' : 'In Progress';

        update t;
    }

    @AuraEnabled
    public static void createNewTodoItem(String name, String milestoneId){
        insert new TodoItem__c(Name = name, Status__c = 'Not Started', Milestone__c = milestoneId);
    }

    @AuraEnabled
    public static void createNewMilestone(String name, String projectId){
        Milestone__c m =  new Milestone__c(Name = 'Milestone '+name, Status__c = 'Not Started', Project__c = projectId);
        insert m;

        createNewTodoItem(name, m.Id);
    }

    @AuraEnabled
    public static void createNewProject(String name){
        Project__c p = new Project__c(Name = name);
        insert p;

        createNewMilestone(name, p.Id);
    }


    public class Project{
        public String id {get; set;}
        public String label {get; set;}
        public String name {get; set;}
        public String status {get; set;}
        public Decimal percentageComplete {get; set;}
        public Map<String, Milestone> milestonesMap {get; set;}
        public List<Milestone> milestones {get; set;}
    }

    public class Milestone{
        public String id {get; set;}
        public String label {get; set;}
        public String name {get; set;}
        public String status {get; set;}
        public Decimal percentageComplete {get; set;}
        public Map<String, TodoItem> todoItemsMap {get; set;}
        public List<TodoItem> todoItems {get; set;}
    }

    public class TodoItem{
        public String id {get; set;}
        public String label {get; set;}
        public String name {get; set;}
        public String status {get; set;}
        public Boolean checked {get; set;}
    }
}