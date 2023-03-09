({
    getLoanUuid : function(component) {
        var action = component.get("c.fetchLoanUuid");
        var currentCaseId = component.get("v.recordId"); 
        action.setParams({
            caseId : currentCaseId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue())
                component.set("v.loanUuid", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    getToken : function(component) {
        var action = component.get("c.fetchToken");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue())
                component.set("v.token", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    getEnv : function(component) {
        var action = component.get("c.fetchEnv");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue())
                component.set("v.env", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    //17-Aug-2022 
    getCollapsable : function(component){
         var action = component.get("c.fetchCollapsable");
        var currentCaseId = component.get("v.recordId"); 
        action.setParams({
            caseId : currentCaseId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue())
                component.set("v.isCollapsed", (response.getReturnValue()));
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    
},
    //17-Aug-2022 
    updateCollapse :function(component){
        var action = component.get("c.updateCollapsable");
        var currentCaseId = component.get("v.recordId"); 
        var collapseVal = component.get("v.isCollapsed");
        action.setParams({
            caseId : currentCaseId,
            isCollapse : collapseVal
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue())
                component.set("v.isCollapsed", (response.getReturnValue()));
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    }
    
})