public class LodgeController {
    @AuraEnabled(cacheable = true)
    public static Case getCaseDetail(String caseId){
        return [Select Id, Lender__c,OwnerId, Driva_UUID__c From Case Where Id =: caseId limit 1];
    }
    
    @AuraEnabled(continuation=true cacheable=true)
    public static Object callLodgeSelectAPI(String UUID) {
        String url = System.Label.lodgeSelectUrl + UUID;
        String jwtToken = JWT.signService();
        Continuation con = new Continuation(40);
        con.state ='Hello, World!';
        // Set callback method
        con.continuationMethod = 'processResponse';
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setHeader('Authorization', 'Bearer ' + jwtToken);
        // Add callout request to continuation
        con.addHttpRequest(req);
        // Return the continuation
        return con;
    }
    @AuraEnabled(continuation = true cacheable = true)
    public static Object callLodgeAPI(String UUID,String userId,String OwnerId) {
        String url = System.Label.updateLodgeUrl + UUID;
        String jwtToken = JWT.signService();
       system.debug('case ownerId='+OwnerId);
        Continuation con = new Continuation(40);
        // Set callback method
        con.continuationMethod = 'processResponse';
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setBody('{"sent": true}');
        req.setHeader('Authorization', 'Bearer ' + jwtToken);
        req.setHeader('X-SalesForce-UserId', UserInfo.getUserId());
        system.debug('user Id debug'+UserInfo.getUserId());
        req.setHeader('X-SalesForce-OwnerId',OwnerId);
        system.debug('owner Id debug'+OwnerId);
        // Add callout request to continuation
        con.addHttpRequest(req);
        // Return the continuation
        return con;
    }
    
    // Callback method
    @AuraEnabled
    public static Object processResponse(List<String> labels, Object state) {
        // Get the response by using the unique label
        HttpResponse response = Continuation.getResponse(labels[0]);
        // Set the result variable
        if(response != null) {
            if(response.getBody() != null) {
                return response.getBody();  
            }
        }
        return 'error';
    }    
}