({
    doInitialization : function (component, event, helper) {
        var parentId=component.get("v.recordId");
        var action=component.get('c.getAllNotes');
        var existingNotesArray=[];
        var title="Notes";
        
        action.setParams({
            caseId : parentId
        });
        action.setCallback(this,function(response){     
            var state=response.getState();
            var responseLength=response.getReturnValue().length;
            if(state==="SUCCESS")
            {
                
                if(responseLength <= 10)
                {
                    component.set("v.notesCount",title + ' ' + '(' + response.getReturnValue().length + ')');
                    component.set("v.existingNotesList",response.getReturnValue());
                }
                else
                {
                    component.set("v.notesCount",title + ' ' + '(' + '10+' + ')');
                    
                    for(var i=0; i<10;i++)
                    {
                        existingNotesArray.push(response.getReturnValue()[i]);
                    }
                    component.set("v.existingNotesList",existingNotesArray);
                }
                
            }
            
        });
        $A.enqueueAction(action);
         //quick Text-Experiment
         var action1 = component.get('c.getAllQuickText');
         action1.setCallback(this, function(response){     
             var state = response.getState();
             if(state === "SUCCESS"){
                 component.set("v.options", response.getReturnValue());
             }
         });
         $A.enqueueAction(action1);

         var action2 = component.get('c.getAllUsers');
         action2.setCallback(this, function(response){     
             var state = response.getState();
             if(state === "SUCCESS"){
                 component.set("v.userOptions", response.getReturnValue());
             }
         });
         $A.enqueueAction(action2);
     },
     handleChange: function (component, event) {
         component.set("v.newNote", event.getParam("value").replace(/\n/g, "<br />"));
        },
    
        handleUserChange : function(component, event){
            component.set("v.selectedUsersList",event.getParam("value"));  
         //quick Text-Experiment
    },
    addNote: function(component, event, helper) {
        var isPublic=component.get("v.public");
        //var newNote=component.get("v.newNote");
        /*Internal notes not showing on feed*/
        var cmpNote = component.get("v.newNote");
        //var newNote = cmpNote.replace(/<br>/g, "&nbsp;");
        var newNote = cmpNote.replace(/<br>/g, "\n");
        /*Internal notes not showing on feed*/
        var currentCaseId = component.get("v.recordId"); 
        var currentUser = component.get("v.currentUser");
        var selectedUsers = component.get("v.selectedUsersList");
        console.log('selectedUsers '+selectedUsers);
        // Add note
        var action=component.get('c.addNewNote');
        
        action.setParams({
            createdBy : currentUser.Id,
            caseId : currentCaseId,
            isPublic: isPublic,
            content: newNote,
            usersIds : selectedUsers,
        });
        action.setCallback(this,function(response){     
            var state=response.getState();
            if (state === "SUCCESS" || state === "DRAFT") {
                component.set("v.newNote", '');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'New note created successfully',
                    type: 'success'
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        
        // Add feeditem
        var action=component.get('c.addFeeditem');
        
        var body;
        var userLink = `<a target='_blank' href='${window.location.origin}/lightning/r/User/${currentUser.Id}/view'>${currentUser.FirstName + ' ' + currentUser.LastName}</a>`;
        var body = `<p>${
            isPublic ? 'Public' : 'Private'
        } Note left by ${userLink}</p><p>Note content: ${newNote}</p>`;
        
        action.setParams({
            caseId : currentCaseId,
            body : body,
        });
        action.setCallback(this,function(response){     
            var state=response.getState();
            if(state==="SUCCESS")
            {
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },
    navigateToRelatedList: function(component,event,helper){
        var rlEvent = $A.get("e.force:navigateToRelatedList");
        rlEvent.setParams({
            "relatedListId": "Note__r",
            "parentRecordId": component.get("v.recordId")
        });
        rlEvent.fire();
    }
})