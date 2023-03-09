@isTest
public class SyncNoteToDrivaDBTest {
	@isTest 
    public static void testMethod1() {
        
        Note__c nt = new Note__c();
        nt.Public__c = true;
        nt.Content__c = 'test';
        
        // Perform test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EntryURL.isFromBrowser = true;
        Database.SaveResult result = Database.insert(nt, false);
        EntryURL.isFromBrowser = false;
        Database.SaveResult result2 = Database.insert(nt, false);
        
        Test.stopTest();
        
        System.assert(result.isSuccess());
        System.assert(!result2.isSuccess());
    }
}