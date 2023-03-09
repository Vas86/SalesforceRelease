@isTest
public class DeleteLiabilityToDrivaDBTest {
	@isTest 
    public static void testMethod1() {
        
        Liability__c lia = new Liability__c();
        lia.Original_Amount__c = 100;
        insert lia;
        
        // Perform test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EntryURL.isFromBrowser = true;
        SyncLiabilityToDrivaDBHelper.isFirstRun = true;
        Database.DeleteResult result = Database.delete(lia, false);
        EntryURL.isFromBrowser = false;
        SyncLiabilityToDrivaDBHelper.isFirstRun = true;
        Database.DeleteResult result2 = Database.delete(lia, false);
        
        Test.stopTest();

        System.assert(result.isSuccess());
        System.assert(!result2.isSuccess());
    }
}