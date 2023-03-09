({
	doInit : function(component, event, helper) {
		helper.getLoanUuid(component);
        helper.getToken(component);
        helper.getEnv(component);
        //17-Aug-2022
        helper.getCollapsable(component);
	},
    //17-Aug-2022 
    handleOpenModel : function(component, event, helper){
        //component.set("v.openModel",true);
        var w = 1020;
    	var h = screen.height-120;
    	var left = (screen.width/2)-(w/2);
    	var top = 0;
        //helper.getLoanUuid(component);
        //helper.getToken(component);
        //helper.getEnv(component);
        var env = component.get('v.env');
        var loanUuid = component.get('v.loanUuid');
        //var token = component.get('v.token');
        var action = component.get("c.fetchToken");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue())
                var token = response.getReturnValue();
                //Open Pop-up Window with Visualforce Page
    			window.open('https://'+env+'.driva.com.au/externalAI/'+loanUuid+'?token='+token, 'Sales Contract', ' location=no, directories=no, status=no, menubar=no, scrollbars=yes, resizable=yes, copyhistory=no, width='+w+', height='+h+', top='+top+', left='+left);
               // window.open('https://'+env+'.driva.com.au/externalAI/'+loanUuid+'?token='+token, 'Sales Contract', 'toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=yes, resizable=yes, copyhistory=no, width='+w+', height='+h+', top='+top+', left='+left);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        	
    },
    //17-Aug-2022 
    handleCloseModel : function(component, event, helper){
        component.set("v.openModel",false);
    },
    //17-Aug-2022 
    handleCollapsed : function (component,event,helper){
        helper.updateCollapse(component);
        //AG-3039
        if(event.currentTarget.dataset.id == 'Open'){
            helper.getToken(component);
        }
         //AG-3039
    }
})