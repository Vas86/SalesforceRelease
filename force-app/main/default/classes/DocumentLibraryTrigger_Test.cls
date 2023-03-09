@isTest public class DocumentLibraryTrigger_Test {
    
    //THIS IS FOR 200 RESPONSE CODE
    @isTest 
    public static void testMethod1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Trigger_Status__c setting = new Trigger_Status__c();
        setting.Name = 'DocumentLibraryTrigger';
        setting.IsActive__c = true;
        insert setting;
        
        Case c = new case();
        Insert c;
        Document_Library__c document = new Document_Library__c();
        document.Case__c = c.id;
        document.Document_Type__c = 'Credit File';
       
        Insert document;
        Set<Id> documentID = new Set <Id>{document.Id};
            DocumentLibraryTrigger_Handler.InsertPostCallout(documentID);
        DocumentLibraryTrigger_Handler.DeleteCallout(documentID);
        document.Is_Deleted__c = true;
        update document;
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            //System.assertEquals('http://example.com/example/test', req.getEndpoint());
            //System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    //THIS IS FOR 200 RESPONSE CODE
    @isTest 
    public static void testMethod2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
        Case c = new case();
        Insert c;
        Document_Library__c document = new Document_Library__c();
        document.Case__c = c.id;
        document.Document_Type__c = 'Credit File';
        
        Insert document;
        Set<Id> documentID = new Set <Id>{document.Id};
            DocumentLibraryTrigger_Handler.InsertPostCallout(documentID);
        DocumentLibraryTrigger_Handler.DeleteCallout(documentID);
        document.Is_Deleted__c = true;
        update document;
    }
    
    public class MockHttpResponseGenerator2 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            //System.assertEquals('http://example.com/example/test', req.getEndpoint());
            //System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(404);
            return res;
        }
    }
}