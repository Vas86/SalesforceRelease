@isTest
private class SyncCaseToDrivaDBTest {
    @isTest 
    public static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Trigger_Status__c triggerstatus = new Trigger_Status__c();
        triggerstatus.name = 'SyncCaseToDrivaDB';
        triggerstatus.Trigger_Name__c = 'SyncCaseToDrivaDB';
        triggerstatus.IsActive__c = True;
        insert triggerstatus;
        
        Case c = new case();
        c.Status = 'Received';
        c.Driva_UUID__c='ABC123';
        c.Call_Experiment__c = 'Call 1 Made';
        c.Origin = 'Phone';
        
        // Perform test
        Test.startTest();
        EntryURL.isFromBrowser = true;
        Database.SaveResult result = Database.insert(c, false);
        EntryURL.isFromBrowser = false;
        Database.SaveResult result2 = Database.insert(c, false);
        Test.stopTest();
        
        System.assert(result.isSuccess());
        System.assert(!result2.isSuccess());
    }
}