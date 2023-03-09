@isTest 
public class SyncAdditionalIncomeToDrivaDBTest {
    @isTest 
    public static void testMethod1() {
        
        Trigger_Status__c triggerstatus = new Trigger_Status__c();
        triggerstatus.name = 'SyncAdditionalIncomeToDrivaDB';
        triggerstatus.Trigger_Name__c = 'SyncAdditionalIncomeToDrivaDB';
        triggerstatus.IsActive__c = True;
        insert triggerstatus;
        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Additional_Income__c a = new Additional_Income__c();
        a.Income_Amount__c = 100;
        Additional_Income__c b = new Additional_Income__c();
        b.Income_Amount__c = 100;
        
        // Perform test
        Test.startTest();
        EntryURL.isFromBrowser = true;
        Database.SaveResult result = Database.insert(a, false);
        EntryURL.isFromBrowser = false;
        Database.SaveResult result2 = Database.insert(b, false);
        
        Test.stopTest();
        
        System.assert(result.isSuccess());
        System.assert(result2.isSuccess());
    }
}