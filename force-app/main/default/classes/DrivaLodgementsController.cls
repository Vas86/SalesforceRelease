public class DrivaLodgementsController {
    @AuraEnabled
    public static String fetchLoanUuid(String caseId) {
        List<case> lstcase = [Select Id, Driva_UUID__c from case where Id =: caseId limit 1];
        String loanUuid;
        if(lstcase.size() > 0) {
            loanUuid = lstcase[0].Driva_UUID__c;
        }
        return loanUuid;
    }
    
    @AuraEnabled
    public static String fetchToken() {
        String jwtToken = JWT.sign();
        return jwtToken;
    }
    
    @AuraEnabled
    public static String fetchEnv() {
        String envName = 'desk';
        String host = System.URL.getSalesforceBaseUrl().getHost();
        if(host.contains('dev')){
            envName = 'desk-dev';
        }
        if(host.contains('staging')){
            envName = 'desk-staging';
        }
        if(host.contains('uat')){
            envName = 'desk-uat';
        }
        return envName;
    }    
}