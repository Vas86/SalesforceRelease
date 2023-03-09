@isTest
public class SyncLiabilityToDrivaDBTest {
	@isTest 
    public static void testMethod1() {
        
        Liability__c lia = new Liability__c();
        lia.Original_Amount__c = 100;
        
        // Perform test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EntryURL.isFromBrowser = true;
        Database.SaveResult result = Database.insert(lia, false);
        EntryURL.isFromBrowser = false;
        Database.SaveResult result2 = Database.insert(lia, false);
        
        Test.stopTest();
        
        System.assert(result.isSuccess());
        System.assert(!result2.isSuccess());
    }
}