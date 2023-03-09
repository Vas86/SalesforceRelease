@isTest
public class RequestPortalControllerTest {
    
    private static Case createCaseRecord(){
        Case objcase = new Case();
        objcase.Status = 'Received';
        objcase.Origin = 'Phone';
        objcase.Loan_ID__c = 95784;
        return objcase;
    }
    
	@isTest
    public static void fetchDocumentsTest(){
        Test.startTest();
        RequestPortalController.fetchDocuments();
        Test.stopTest();      
    }
    @isTest 
    public static void createNewDocAPITest(){
        String payload = '{"name": "Test document2","tooltip": "Test tooltip","category": "postApproval" }';
        Test.startTest();
        RequestPortalController.createNewDocAPI(payload);
        Test.stopTest();
  		//create mock response
  		HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"success": true,"correlationId": "923bdaed-06c6-4c5d-8a01-d1f6469b257c","data": {"id": 99, "name": "Test document1", "tooltip": "Test tooltip","label": "testDocument1","category": "postApproval", "type": 2}}');
  		Test.setContinuationResponse(RequestPortalController.continuationLabel, response);
        List<String> labels = new List<String>{RequestPortalController.continuationLabel};
		String result = (String)RequestPortalController.processResponse(labels, RequestPortalController.continuationState);    
        System.assert(result ==  '{"success": true,"correlationId": "923bdaed-06c6-4c5d-8a01-d1f6469b257c","data": {"id": 99, "name": "Test document1", "tooltip": "Test tooltip","label": "testDocument1","category": "postApproval", "type": 2}}');
    }
    @isTest 
    public static void submitRequestAPITest(){
        String payload = '{"documentIds":["37","38"]}';
        Case objcase = createCaseRecord();
        insert objcase;
        String caseId = objcase.Id;
        Test.startTest();
        RequestPortalController.submitRequestAPI(payload,caseId);
        Test.stopTest();
        //create mock response
  		HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"success":true,"correlationId":"4b860008-395a-4637-8655-0cda6d45a287"}');
  		Test.setContinuationResponse(RequestPortalController.continuationLabel, response);
        List<String> labels = new List<String>{RequestPortalController.continuationLabel};
		String result = (String)RequestPortalController.processResponse(labels, RequestPortalController.continuationState);    
        System.assert(result == '{"success":true,"correlationId":"4b860008-395a-4637-8655-0cda6d45a287"}');
    }
}