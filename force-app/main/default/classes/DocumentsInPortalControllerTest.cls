@isTest
public class DocumentsInPortalControllerTest {
	private static Case createCaseRecord(){
        Case objcase = new Case();
        objcase.Status = 'Received';
        objcase.Origin = 'Phone';
        objcase.Loan_ID__c = 110930;
        return objcase;
    }
    @isTest
    public static void deleteDocumentsInPortalAPITest(){
        Case objcase = createCaseRecord();
        String payload = '{"documentIds":["37","57"]}';
        Test.startTest();        
        DocumentsInPortalController.deleteDocumentsInPortalAPI(payload,objcase.Id);
        Test.stopTest();    
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"success": true,"correlationId": "6e090c5d-a399-4321-b6c6-98349b5454bb"}');
  		Test.setContinuationResponse(DocumentsInPortalController.continuationLabel, response);
        List<String> labels = new List<String>{DocumentsInPortalController.continuationLabel};
		String result = (String)DocumentsInPortalController.processResponse(labels, DocumentsInPortalController.continuationState);    
        System.assert(result ==  '{"success": true,"correlationId": "6e090c5d-a399-4321-b6c6-98349b5454bb"}');
    }
}