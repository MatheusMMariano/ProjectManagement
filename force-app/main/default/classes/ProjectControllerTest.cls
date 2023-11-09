@isTest
public with sharing class ProjectControllerTest {
    
    @isTest
    public static void createProject(){
        List<Project__c> projectsBefore = [SELECT Id FROM Project__c];
        List<Milestone__c> milestonesBefore = [SELECT Id FROM Milestone__c];
        List<TodoItem__c> todoItemsBefore = [SELECT Id FROM TodoItem__c];

        Test.startTest();
        ProjectController.createNewProject('Project 1');
        ProjectController.createNewProject('Project 2');
        ProjectController.createNewProject('Project 3');
        ProjectController.createNewProject('Project 4');
        Test.stopTest();

        List<Project__c> projectsAfter = [SELECT Id FROM Project__c];
        List<Milestone__c> milestonesAfter = [SELECT Id FROM Milestone__c];
        List<TodoItem__c> todoItemsAfter = [SELECT Id FROM TodoItem__c];

        System.assertEquals(0, projectsBefore.size());
        System.assertEquals(0, milestonesBefore.size());
        System.assertEquals(0, todoItemsBefore.size());

        System.assertEquals(4, projectsAfter.size());
        System.assertEquals(4, milestonesAfter.size());
        System.assertEquals(4, todoItemsAfter.size());
    }

    @isTest 
    public static void createMilestone(){
        List<Project__c> projectsBefore = [SELECT Id FROM Project__c];
        List<Milestone__c> milestonesBefore = [SELECT Id FROM Milestone__c];
        List<TodoItem__c> todoItemsBefore = [SELECT Id FROM TodoItem__c];

        Test.startTest();
        ProjectController.createNewProject('Project 1');
        Project__c p1 = [SELECT Id FROM Project__c WHERE Name = 'Project 1' LIMIT 1];

        ProjectController.createNewMilestone('Milestone 2', p1.Id);
        ProjectController.createNewMilestone('Milestone 3', p1.Id);
        ProjectController.createNewMilestone('Milestone 4', p1.Id);

        ProjectController.createNewProject('Project 2');
        Project__c p2 = [SELECT Id FROM Project__c WHERE Name = 'Project 2' LIMIT 1];
        ProjectController.createNewMilestone('Milestone 6', p2.Id);
        ProjectController.createNewMilestone('Milestone 7', p2.Id);
        Test.stopTest();

        List<Project__c> projectsAfter = [SELECT Id FROM Project__c];
        List<Milestone__c> milestonesAfter = [SELECT Id FROM Milestone__c];
        List<TodoItem__c> todoItemsAfter = [SELECT Id FROM TodoItem__c];

        System.assertEquals(0, projectsBefore.size());
        System.assertEquals(0, milestonesBefore.size());
        System.assertEquals(0, todoItemsBefore.size());

        System.assertEquals(2, projectsAfter.size());
        System.assertEquals(7, milestonesAfter.size());
        System.assertEquals(7, todoItemsAfter.size());
    }

    @isTest
    public static void createTodoItem(){
        List<Project__c> projectsBefore = [SELECT Id FROM Project__c];
        List<Milestone__c> milestonesBefore = [SELECT Id FROM Milestone__c];
        List<TodoItem__c> todoItemsBefore = [SELECT Id FROM TodoItem__c];

        Test.startTest();
        ProjectController.createNewProject('Project 1');
        Project__c p1 = [SELECT Id FROM Project__c WHERE Name = 'Project 1' LIMIT 1];
        Milestone__c m1 = [SELECT Id FROM Milestone__c WHERE Project__c =: p1.Id LIMIT 1];

        ProjectController.createNewTodoItem('To do Item 2', m1.Id);
        ProjectController.createNewTodoItem('To do Item 3', m1.Id);
        ProjectController.createNewTodoItem('To do Item 4', m1.Id);

        ProjectController.createNewProject('Project 2');
        ProjectController.createNewProject('Project 3');

        Project__c p3 = [SELECT Id FROM Project__c WHERE Name = 'Project 3' LIMIT 1];
        ProjectController.createNewMilestone('Milestone 4', p3.Id);
        Milestone__c m4 = [SELECT Id FROM Milestone__c WHERE Name = 'Milestone 4' LIMIT 1];
        ProjectController.createNewTodoItem('To do Item 8', m4.Id);
        Test.stopTest();

        List<Project__c> projectsAfter = [SELECT Id FROM Project__c];
        List<Milestone__c> milestonesAfter = [SELECT Id FROM Milestone__c];
        List<TodoItem__c> todoItemsAfter = [SELECT Id FROM TodoItem__c];

        System.assertEquals(0, projectsBefore.size());
        System.assertEquals(0, milestonesBefore.size());
        System.assertEquals(0, todoItemsBefore.size());

        System.assertEquals(3, projectsAfter.size());
        System.assertEquals(4, milestonesAfter.size());
        System.assertEquals(8, todoItemsAfter.size());
    }

    @isTest
    public static void updateTodoItemStatus(){
        Test.startTest();
        ProjectController.createNewProject('Project 1');
        Project__c p1Before = [SELECT Id, Status__c, Percentage_complete__c FROM Project__c WHERE Name = 'Project 1' LIMIT 1];
        Milestone__c m1Before = [SELECT Id, Status__c, Percentage_complete__c FROM Milestone__c WHERE Project__c =: p1Before.Id LIMIT 1];
        TodoItem__c t1Before = [SELECT Id, Status__c FROM TodoItem__c WHERE Milestone__c =: m1Before.Id LIMIT 1]; 
        t1Before.Status__c = 'In Progress';
        update t1Before;

        ProjectController.updateTodoItemStatus(t1Before.Id, true);
        
        Project__c p1After = [SELECT Id, Status__c, Percentage_complete__c FROM Project__c WHERE Name = 'Project 1' LIMIT 1];
        Milestone__c m1After = [SELECT Id, Status__c, Percentage_complete__c FROM Milestone__c WHERE Project__c =: p1Before.Id LIMIT 1];
        TodoItem__c t1After = [SELECT Id, Status__c FROM TodoItem__c WHERE Milestone__c =: m1Before.Id LIMIT 1];

        ProjectController.createNewTodoItem('To do Item 2', m1Before.Id);
        Project__c p1Current = [SELECT Id, Status__c, Percentage_complete__c FROM Project__c WHERE Name = 'Project 1' LIMIT 1];
        Milestone__c m1Current = [SELECT Id, Status__c, Percentage_complete__c FROM Milestone__c WHERE Project__c =: p1Before.Id LIMIT 1];
        TodoItem__c t2Current = [SELECT Id, Status__c FROM TodoItem__c WHERE Name = 'To do Item 2' LIMIT 1];
        Test.stopTest();

        System.assertEquals('Not Started', p1Before.Status__c);
        System.assertEquals(0, p1Before.Percentage_complete__c);
        System.assertEquals('Not Started', m1Before.Status__c);
        System.assertEquals(0, m1Before.Percentage_complete__c);
        System.assertEquals('In Progress', t1Before.Status__c);

        System.assertEquals('Complete', p1After.Status__c);
        System.assertEquals(100, p1After.Percentage_complete__c);
        System.assertEquals('Complete', m1After.Status__c);
        System.assertEquals(100, m1After.Percentage_complete__c);
        System.assertEquals('Complete', t1After.Status__c);

        System.assertEquals('In Progress', p1Current.Status__c);
        System.assertEquals(0, p1Current.Percentage_complete__c);
        System.assertEquals('In Progress', m1Current.Status__c);
        System.assertEquals(50, m1Current.Percentage_complete__c);
        System.assertEquals('Not Started', t2Current.Status__c);
    }

    @isTest
    public static void getProjectsJSON(){
        Test.startTest();
        ProjectController.createNewProject('Project 1');
        Project__c p1 = [SELECT Id FROM Project__c WHERE Name = 'Project 1' LIMIT 1];
        ProjectController.createNewMilestone('Milestone 2', p1.Id);
        Milestone__c m2 = [SELECT Id FROM Milestone__c WHERE Name = 'Milestone 2' LIMIT 1];
        ProjectController.createNewTodoItem('To do Item 3', m2.Id);

        ProjectController.createNewProject('Project 2');
        Test.stopTest();

        String json = ProjectController.getProjectsJSON();
        System.assert(!json.equals('') && json != null);
        System.assertEquals(6, json.countMatches('todoItemsMap'));
        System.assertEquals(2, json.countMatches('milestonesMap'));
        System.assertEquals(24, json.countMatches('name'));
    }
}