@isTest
private class SyncContactToDrivaDBTest {
    @isTest 
    public static void testMethod1() {
        
         Trigger_Status__c triggerstatus = new Trigger_Status__c();
        triggerstatus.name = 'SyncContactToDrivaDB';
        triggerstatus.Trigger_Name__c = 'SyncContactToDrivaDB';
        triggerstatus.IsActive__c = True;
        insert triggerstatus;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Contact c = new contact();
        c.lastname='Test';
        
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