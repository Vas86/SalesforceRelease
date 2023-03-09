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
    }
    
})