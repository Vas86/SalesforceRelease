({
	handleCollapsed : function(component, event, helper) {
		 var collapseVal = component.get("v.isCollapsed");
        collapseVal = collapseVal ? false : true;
        component.set("v.isCollapsed",collapseVal);
	}
})