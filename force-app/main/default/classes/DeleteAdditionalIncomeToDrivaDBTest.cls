@isTest 
public class DeleteAdditionalIncomeToDrivaDBTest {
    @isTest 
    public static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Additional_Income__c a = new Additional_Income__c();
        a.Income_Amount__c = 100;
        insert a;
        
        // Perform test
        Test.startTest();
        EntryURL.isFromBrowser = true;
        SyncAdditionalIncomeToDrivaDBHelper.isFirstRun = true;
		Database.DeleteResult result = Database.delete(a, false);
        EntryURL.isFromBrowser = false;
        SyncAdditionalIncomeToDrivaDBHelper.isFirstRun = true;
        Database.DeleteResult result2 = Database.delete(a, false);
        
        Test.stopTest();
        
        System.assert(result.isSuccess());
        System.assert(!result2.isSuccess());
    }
}