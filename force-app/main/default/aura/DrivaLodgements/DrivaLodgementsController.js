({
	doInit : function(component, event, helper) {
		helper.getLoanUuid(component);
        helper.getToken(component);
        helper.getEnv(component);
	}
})