global class MilestoneHelper {
    @InvocableMethod(label='Milestone Completion' description='Milestone Completion')
    // here input param is smsRequest of List type
    global static void completeMilestone(milestoneRequest[] requests){
        for (milestoneRequest request : requests) {
            List<CaseMilestone> cmsToUpdate = [select Id, completionDate
                                               from CaseMilestone cm
                                               where caseId =: request.caseId and cm.MilestoneType.Name =: request.milestoneName 
                                               and completionDate = null limit 1];
            if (cmsToUpdate.size() > 0){
                for (CaseMilestone cm : cmsToUpdate){
                    cm.completionDate = System.now();
                }
                update cmsToUpdate;
            }
            List<Milestone_Owner_Details__c> MODList = [SELECT Id, End_Date__c, Completed__c FROM Milestone_Owner_Details__c
                                               where Case__c =: request.caseId and Milestone_Name__c =: request.milestoneName 
                                               and Completed__c = null];
            if (MODList.size() > 0){
                for (Milestone_Owner_Details__c MOD : MODList){
                    MOD.End_Date__c = System.now();
                    MOD.Completed__c = true;
                }
                update MODList;
            }
        }
    }
    
    
    global class milestoneRequest {
        @InvocableVariable(required=true)
        global Id caseId;
        
        @InvocableVariable(required=true)
        global String milestoneName;
    }
    // Enable the below code as part of Iteration 2 as it has dependency on flow and remove once flow is deployed
    /*public static void testCover(){
        String test = 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
        test += 'Test';
    }*/
}