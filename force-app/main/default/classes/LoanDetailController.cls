/*************************** 
* @Name         LoanDetailController 
* @Author       vasu@driva.com.au
* @Date         22/06/2022
* @description  Handles Loan Recalculations, Calculate pricing and Retrieving Scores
******************************************************
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-----------------------------------------------------------------------
*  1.0              Vasu      22/06/2022          Initial Creation 

****************************** */
public with sharing class LoanDetailController {
    @TestVisible
    private static String continuationLabel;
    @TestVisible
    private static String continuationState;
    @AuraEnabled(Cacheable = true)
    public static Case getCaseDetails(String recordId){
        return [Select Id, Lender__c,
                Vehicle_Price__c,
                Deposit__c,
                Loan_Term__c,
                Loan_Type__c,
                Loan_Class__c,
                Asset_Type__c,
                Employment_Status__c,
                Contact.Residency_Status__c,
                Time_in_Current_Employment_Years__c,
                Time_in_Current_Employment_Months__c,
                Previous_Employment_Duration_Years__c,
                Previous_Employment_Duration_Months__c,
                Currently_on_Probation__c,
                Business_Duration__c,
                Business_ABN__c,
                Business_GST__c,
                Contact.Living_situation__c,
                Contact.Email,
                Buying_a_Car_From__c,
                Vehicle_year__c, Driva_UUID__c, Status,Trade_in_Value__c,Cash_Deposit__c,Trade_in_Finance_owing__c,Total_deposit_calculated__c From Case Where Id =: recordId limit 1];
    }
    
    @AuraEnabled(continuation=true cacheable=true)
    //public static Object recalculateAPI(String payload, String UUID) {
   public static Object recalculateAPI(String payload) {
         //String url = System.Label.recalculateAPIUrl + UUID;
       String url = System.Label.recalculateAPIUrl;
        String jwtToken = JWT.sign();
        Continuation con = new Continuation(40);
        // Set callback method
        con.continuationMethod = 'processResponse';
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        system.debug('===jwtToken  ==> ' + jwtToken);
        system.debug('===body request ==> ' + payload);
        req.setBody(payload);
        req.setHeader('Authorization', 'Bearer ' + jwtToken);
        // Add callout request to continuation
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
    //Start- Retrieve new scores and calculate pricing -Agent 2207 
    //calling the calculate price API
    @AuraEnabled(continuation=true cacheable=true)
    public static Object calculatePricingAPI(String payload){
        System.debug(payload);
        String url = System.Label.calculatePricingAPIUrl;
        String jwtToken = JWT.sign();
        Continuation con = new Continuation(40);
        // Set callback method
        con.continuationMethod = 'processResponse';
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        system.debug('===jwtToken  ==> ' + jwtToken);
        system.debug('===body request ==> ' + payload);
        req.setBody(payload);
        req.setHeader('Authorization', 'Bearer ' + jwtToken);
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
    //calling the retrieve score API 
    @AuraEnabled(continuation = true cacheable = true)
    public static Object retrieveScoreAPI(String UUID){
        String url = System.Label.retrieveScoreAPIUrl + UUID ;
        System.debug('URL==>'+url);
        String jwtToken = JWT.sign();
        Continuation con = new Continuation(40);
        // Set callback method
        con.continuationMethod = 'processResponse';
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + jwtToken);
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
     //End- Retrieve new scores and calculate pricing -Agent 2207 
     
   
    
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
    @AuraEnabled
    public static string updateRecord(Case record){
        System.debug('case record => ' + record);
        try {
            update record;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean checkValidCaseStatus(String recordId){
        Set<String> caseStatus = new Set<String>{'Quoted','Started','Awaiting Documents','Under Review','Lodged','Conditionally Approved','Approved','Settled','Withdrawn','Declined','Referred','Closed - No Contact'};
        List<Case> cases = [Select Id, Status From Case Where Id =: recordId AND Status IN :caseStatus limit 1];
        if(cases.size() > 0){
            return true;
        }else{
            return false;
        }
    }
}