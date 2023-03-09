public class DrivaAPI {
    @future(callout=true)
    public static void createUpdate(String endpoint, String reqBody) {

		Http http = new Http();
        HttpRequest request = new HttpRequest();

        // Use NamedCredentials & callout to get Bearer JWT
        string url = 'callout:Salesforce_Service/' + endpoint;

        request.setEndpoint(url);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(reqBody);
        request.setTimeout(30000);

        // Merge fields after setBody
        request.setHeader('Authorization', '{!$Credential.Password}');

        HttpResponse response = http.send(request);

        //check the response
        if (response.getStatusCode() == 200) {
            System.debug('Sync to Driva DB successed');
        } else {
            System.debug('Sync to Driva DB failed: ' + response);
        }
    }
    
    @future(callout=true)
    public static void deleteObject(String endpoint, String reqBody) {
        
		Http http = new Http();
        HttpRequest request = new HttpRequest();

        // Use NamedCredentials & callout to get Bearer JWT
        string url = 'callout:Salesforce_Service/' + endpoint;

        request.setEndpoint(url);
        request.setMethod('DELETE');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(reqBody);
        request.setTimeout(30000);

        // Merge fields after setBody
        request.setHeader('Authorization', '{!$Credential.Password}');

        HttpResponse response = http.send(request);
        //check the response
        if (response.getStatusCode() == 200) {
            System.debug('Delete object request to Driva DB successed');
        } else {
            System.debug('Delete object request to Driva DB failed: ' + response);
        }
    }
}