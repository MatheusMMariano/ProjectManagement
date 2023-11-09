import { LightningElement, api, track } from 'lwc';
import { RefreshEvent } from "lightning/refresh";
import getProjectsJSON from '@salesforce/apex/ProjectController.getProjectsJSON';
import updateTodoItemStatus from '@salesforce/apex/ProjectController.updateTodoItemStatus';
import createNewTodoItem from '@salesforce/apex/ProjectController.createNewTodoItem';
import createNewMilestone from '@salesforce/apex/ProjectController.createNewMilestone';
import createNewProject from '@salesforce/apex/ProjectController.createNewProject';

export default class ProjectManagement extends LightningElement {
    @api numberOfProjectsToAppear;
    @track loading = true;
    @track projects = [];
    activeSections = [];

    connectedCallback() {
        this.getAllProjects();
    }

    getAllProjects(){
        getProjectsJSON().then(result => {
            try{
                this.projects = JSON.parse(result);
            }
            catch(e){
                console.log(e.message);
            }

            this.loading = false;
        });
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
    }

    updatePage(){
        this.loading = true;
        this.getAllProjects();
        this.dispatchEvent(new RefreshEvent());
    }

    handleCheckboxChange(event) {
        updateTodoItemStatus({
            recordId : event.target.dataset.id,
            checked : event.target.checked
        })
        .then(() => {
            this.updatePage();
        });
    }

    handleClickCreateNewTodoItem(event){
        this.template.querySelectorAll('lightning-input').forEach(function (element){
            if(element.value != '' && element.dataset.index == event.target.dataset.index){
                createNewTodoItem({
                    name : element.value,
                    milestoneId: event.target.dataset.index
                }).then(() =>{
                    this.updatePage();
                })
            }
        }, this);
    }

    handleClickCreateNewMilestone(event){
        this.template.querySelectorAll('lightning-input').forEach(function (element){
            if(element.value != '' && element.dataset.index == event.target.dataset.index){
                createNewMilestone({
                    name : element.value,
                    projectId: event.target.dataset.index
                }).then(() =>{
                    this.updatePage();
                })
            }
        }, this);
    }

    handleClickCreateNewProject(event){
        this.template.querySelectorAll('lightning-input').forEach(function (element){
            if(element.value != '' && element.dataset.index == 'project'){
                createNewProject({
                    name : element.value
                }).then(() =>{
                    this.updatePage();
                })
            }
        }, this);
    }
}