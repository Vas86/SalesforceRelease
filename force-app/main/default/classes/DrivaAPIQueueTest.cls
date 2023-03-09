@isTest
public class DrivaAPIQueueTest {
    @isTest
    public static void testDrivaAPIQueueCanSyncUsingObjectId() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());  
        
        Case c = new case();
        c.Status = 'Received';
        c.Origin = 'Phone';
        insert c;
        
        Test.startTest();
        System.Queueable job = new DrivaAPIQueue('/test', 'test', 'Case', c.Id);
        System.enqueueJob(job);
        Test.stopTest();
        delete c;
    }

    @isTest
    public static void testDrivaAPIQueueCanSyncUsingObject() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());  
        
        Case c = new case();
        c.Status = 'Received';
        c.Origin = 'Phone';
        insert c;
        
        Test.startTest();
        System.Queueable job = new DrivaAPIQueue('/test', 'test', 'Case', c);
        System.enqueueJob(job);
        Test.stopTest();
        delete c;
    }   
    
    @isTest
    public static void testDrivaAPIQueueCanSyncUsingObjectIdList() {
        List<String> ids;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());  
        
        Case c1 = new case();
        c1.Status = 'Received1';
        c1.Origin = 'Phone1';
        insert c1;

        Case c2 = new case();
        c2.Status = 'Received2';
        c2.Origin = 'Phone2';
        insert c2;

        Set<String> caseIds = new Set<String>();
        caseIds.add(c1.Id);
        caseIds.add(c2.Id);
        
        Test.startTest();
       // System.Queueable job = new DrivaAPIQueue('/test', 'test', 'Case', caseIds);
        System.Queueable job = new DrivaAPIQueue('/test', 'test', 'Case', caseIds,ids);
        System.enqueueJob(job);
        Test.stopTest();
        delete c1;
        delete c2;
    }
}