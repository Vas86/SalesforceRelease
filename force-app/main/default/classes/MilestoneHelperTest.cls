@isTest
private class MilestoneHelperTest {
    @testSetup static void CaseCreation() {
        List<Account> accData = new list<Account>();
        Account acc1 = new Account(Name = 'Dealer'); // Created to get specific Entitlement_Account__c from Custom Settings
        Account acc2 = new Account(Name = 'CARS24'); // Created for Case.Partner_Account__c
        accData.add(acc1);
        accData.add(acc2);
        Insert accData;
        
        insert new Entitlement_Account__c(AccountId__c = accData[0].Id, Name = 'Dealer');
        
        List<SlaProcess> sla = [Select Id from SlaProcess where Name = 'VerificationDev26' AND IsActive = True];
        
        Entitlement entObject  = new Entitlement();
        entObject.SlaProcessId = sla[0].id;
        entObject.AccountId = accData[0].id;
        entObject.Name = 'SLA';
        entObject.StartDate = system.today();
        entObject.EndDate = system.today().addDays(10);
        insert entObject;
        
        Case caseRecord = new Case(Partner_Account__c = accData[1].Id, Status = 'Under Review',
                            Sub_Status__c = 'Requires Driva Action', Assessment_Quality__c = 'To Be Assessed');
        insert caseRecord;
    }
    
    @isTest static void completeMilestone_Test() {
        Case caseRecord = [select Id, Assessment_Quality__c FROM Case WHERE Assessment_Quality__c = 'To Be Assessed'];
        test.startTest();
            caseRecord.Assessment_Quality__c = 'At Verification';
            update caseRecord;
       // MilestoneHelper.testCover();
        test.stopTest();
        Integer caseMileStoneCount = [SELECT count() FROM CaseMilestone WHERE CaseId =: caseRecord.Id AND 
                                      MilestoneType.Name = 'Initial Verification' AND IsCompleted = true];
        Integer MODCount = [SELECT count() FROM Milestone_Owner_Details__c
                            where Case__c =: caseRecord.Id AND Completed__c = true AND Milestone_Name__c = 'Initial Verification'];
        
        Assert.areEqual(1, caseMileStoneCount, 'Initial Verification Milestone should be completed');
        Assert.areEqual(1, MODCount, 'Milestone Owner Details should be completed');
        
    }
}