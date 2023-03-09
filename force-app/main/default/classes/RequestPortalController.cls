public class RequestPortalController {
    @TestVisible
    private static String continuationLabel;
    @TestVisible
    private static String continuationState;
    
    @AuraEnabled (continuation=true cacheable = true )
    public static Object fetchDocuments(){
        String url = System.Label.additionalDocsAPIUrl + 'list' ;
        System.debug('URL==>'+url);
        Continuation con = new Continuation(40);
        // Set callback method
        con.continuationMethod = 'processResponse';
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
       /* String jwtToken = JWT.sign();
        req.setHeader('Authorization', jwtToken);*/
      String jwtToken = JWT.sign();
        req.setHeader('Authorization', 'Bearer ' + jwtToken);
        String userId = userInfo.getUserId();
        req.setHeader('X-SalesForce-UserId' ,userId);
       //req.setHeader('Authorization','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2NTM4ODEzODZ9.rPitfwwWF9iIvCaod5-IAWCOlTxcY-YhC9LxBEP6798');
        if(Test.isRunningTest()){
            continuationLabel = con.addHttpRequest(req);
            continuationState = con.addHttpRequest(req);
            con.state = continuationState;
        }else{
            con.addHttpRequest(req);
        }
        // Return the continuation 
        return con;        
            }
    @AuraEnabled(continuation=true cacheable=true)
    public static Object submitRequestAPI(String payload,String caseId){
        system.debug('payload==>' +payload);
        system.debug(caseId);
        List<Case> caseRecord = new List<Case>([SELECT Id,Loan_ID__c from Case where Id =: caseId]);
        Integer loanId = 0;
        if(caseRecord.size() > 0 && caseRecord[0].Loan_ID__c != NULL ){
            loanId = caseRecord[0].Loan_ID__c.intValue(); 
        }        
        String url =  System.Label.additionalDocsAPIUrl + 'loan/' + loanId ;
        system.debug('URL==>'+url);
        Continuation con = new Continuation(40);
        // Set callback method
        con.continuationMethod = 'processResponse';
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
       	
        system.debug('===body request ==> ' + payload);
        req.setBody(payload);
        /*String jwtToken = JWT.sign();
        req.setHeader('Authorization', jwtToken);*/
        String jwtToken = JWT.sign();
        req.setHeader('Authorization', 'Bearer ' + jwtToken);
        String userId = userInfo.getUserId();
        system.debug('userid'+userId);
        req.setHeader('X-SalesForce-UserId' ,userId);
        req.setHeader('Accept' ,'application/json');

       // req.setHeader('Authorization','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2NTM4ODEzODZ9.rPitfwwWF9iIvCaod5-IAWCOlTxcY-YhC9LxBEP6798');
        system.debug('req=>'+ req);
        if(Test.isRunningTest()){
            continuationLabel = con.addHttpRequest(req);
            continuationState = con.addHttpRequest(req);
            con.state = continuationState;
        }else{
            con.addHttpRequest(req);
        }
        // Return the continuation
        return con;       
    }
    @AuraEnabled(continuation=true cacheable=true)
    public static Object createNewDocAPI(String payload){
        system.debug('payload==>' +payload);
        String url = System.Label.additionalDocsAPIUrl;
        system.debug('URL==>'+url);
       
        Continuation con = new Continuation(40);
        // Set callback method
        con.continuationMethod = 'processResponse';
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        system.debug('===body request ==> ' + payload);
        req.setBody(payload);
        /*String jwtToken = JWT.sign();
        req.setHeader('Authorization', jwtToken);*/
        String jwtToken = JWT.sign();
        req.setHeader('Authorization', 'Bearer ' + jwtToken);
        String userId = userInfo.getUserId();
        req.setHeader('X-SalesForce-UserId' ,userId);
       // req.setHeader('Authorization','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2NTM4ODEzODZ9.rPitfwwWF9iIvCaod5-IAWCOlTxcY-YhC9LxBEP6798');
        if(Test.isRunningTest()){
            continuationLabel = con.addHttpRequest(req);
            continuationState = con.addHttpRequest(req);
            con.state = continuationState;
        }else{
            con.addHttpRequest(req);
        }
        // Return the continuation
        return con;
        
        
    }  
	// Callback method
    @AuraEnabled
    public static Object processResponse(List<String> labels, Object state) {
        // Get the response by using the unique label
        HttpResponse response = Continuation.getResponse(labels[0]);
        system.debug('res => ' + response.getBody());
        // Set the result variable
        if(response != null) {
            if(response.getBody() != null) {
                return response.getBody();  
            }
        }
        return 'error';
    }	
}