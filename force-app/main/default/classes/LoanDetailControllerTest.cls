/*************************** 
* @Name         LoanDetailControllerTest 
* @Author       vasu@driva.com.au
* @Date         22/06/2022
* @description  Test class for  Loan Recalculations, Calculate pricing and Retrieving Scores
******************************************************
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-----------------------------------------------------------------------
*  1.0              Vasu      22/06/2022          Initial Creation 

****************************** */
@isTest
public class LoanDetailControllerTest {
    
    private static case createCaseRecord(){
        Case objcase = new Case();
        objcase.Status = 'Received';
        objcase.Origin = 'Phone';
        return objcase;
    }
	@isTest
    public static void getCaseDetailsUpdateRecordTest() {
        Case objcase = createCaseRecord();
        insert objcase;
        System.assert(objcase.Id != null);
        LoanDetailController.getCaseDetails(objcase.Id);
        objcase.Deposit__c = 400;
        LoanDetailController.updateRecord(objcase);
        System.assert(objcase.Deposit__c == 400);
        Boolean isValid = LoanDetailController.checkValidCaseStatus(objcase.Id);
        System.assert(isValid == false);
    }
    
    
    
    @isTest
    public static void recalculateAPITest(){
        
        String jsonString = '{"Driva_UUID__c":"2057dd86-77dc-4db7-a9fa-d1fec0fcabaa","Lender__c":"Firstmac","Vehicle_Price__c":28274,"Deposit__c":6000,"Loan_Term__c":"5","Loan_Type__c":"Purchase","Loan_Class__c":"Consumer","Asset_Type__c":"Car","Time_in_Current_Employment_Years__c":19,"Employment_Status__c":null,"Time_in_Current_Employment_Months__c":1,"Previous_Employment_Duration_Years__c":null,"Previous_Employment_Duration_Months__c":null,"Employment_Industry_Continuation__c":false,"Business_Duration__c":null,"Business_ABN__c":null,"Business_GST__c":null,"Living_situation__c":null,"Residency_Status__c":"Permanent resident","Buying_a_Car_From__c":"Dealership","Vehicle_year__c":"2017"}';
        Test.startTest();
        	LoanDetailController.recalculateAPI(jsonString);
        Test.stopTest();
		// Create a mock response
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"success":true,"data":{"publicId":"OlTG1D1duY","displayName":"Firstmac","isEligible":true,"isPublic":true,"monthlyFees":0,"brokerageFee":990,"interestRate":7.39,"originationFee":400,"balloonPayment":0,"monthly":473,"comparisonRate":9.36,"realComparisonRate":10.08,"term":5,"terminationFees":"$700 in year 1, then $500 (None in final year","keyFeature":"Great for first time borrowers","isSecured":1,"meta":{"logo":"https://jump-marketing-assets.s3-ap-southeast-2.amazonaws.com/driva-email/firstmacLogo.png","terminationFeesAmount":"$700 in year 1, then $500 (None in final year"},"optionId":8}}');
        Test.setContinuationResponse(LoanDetailController.continuationLabel, response);
        List<String> labels = new List<String>{LoanDetailController.continuationLabel};
		String result = (String)LoanDetailController.processResponse(labels, LoanDetailController.continuationState);
        System.assert(result == '{"success":true,"data":{"publicId":"OlTG1D1duY","displayName":"Firstmac","isEligible":true,"isPublic":true,"monthlyFees":0,"brokerageFee":990,"interestRate":7.39,"originationFee":400,"balloonPayment":0,"monthly":473,"comparisonRate":9.36,"realComparisonRate":10.08,"term":5,"terminationFees":"$700 in year 1, then $500 (None in final year","keyFeature":"Great for first time borrowers","isSecured":1,"meta":{"logo":"https://jump-marketing-assets.s3-ap-southeast-2.amazonaws.com/driva-email/firstmacLogo.png","terminationFeesAmount":"$700 in year 1, then $500 (None in final year"},"optionId":8}}');
		
    }
    @isTest 
    public static void calculatePricingAPITest(){
        String jsonString = '{"loanUuid":"2057dd86-77dc-4db7-a9fa-d1fec0fcabaa","email":"testcontact@yopmail.com"}';
        Test.startTest();
           LoanDetailController.calculatePricingAPI(jsonString); 
        Test.stopTest();
        // Create a mock response
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"success":true,"data":{"publicId":"OlTG1D1duY","displayName":"Firstmac","isEligible":true,"isPublic":true,"monthlyFees":0,"brokerageFee":990,"interestRate":7.39,"originationFee":400,"balloonPayment":0,"monthly":473,"comparisonRate":9.36,"realComparisonRate":10.08,"term":5,"terminationFees":"$700 in year 1, then $500 (None in final year","keyFeature":"Great for first time borrowers","isSecured":1,"meta":{"logo":"https://jump-marketing-assets.s3-ap-southeast-2.amazonaws.com/driva-email/firstmacLogo.png","terminationFeesAmount":"$700 in year 1, then $500 (None in final year"},"optionId":8}}');
        Test.setContinuationResponse(LoanDetailController.continuationLabel, response);
        List<String> labels = new List<String>{LoanDetailController.continuationLabel};
		String result = (String)LoanDetailController.processResponse(labels, LoanDetailController.continuationState);
        System.assert(result == '{"success":true,"data":{"publicId":"OlTG1D1duY","displayName":"Firstmac","isEligible":true,"isPublic":true,"monthlyFees":0,"brokerageFee":990,"interestRate":7.39,"originationFee":400,"balloonPayment":0,"monthly":473,"comparisonRate":9.36,"realComparisonRate":10.08,"term":5,"terminationFees":"$700 in year 1, then $500 (None in final year","keyFeature":"Great for first time borrowers","isSecured":1,"meta":{"logo":"https://jump-marketing-assets.s3-ap-southeast-2.amazonaws.com/driva-email/firstmacLogo.png","terminationFeesAmount":"$700 in year 1, then $500 (None in final year"},"optionId":8}}');
        
    }
    @isTest
    public static void retrieveScoreAPITest(){
        String UUID = '2057dd86-77dc-4db7-a9fa-d1fec0fcabaa';
        Test.startTest();
        LoanDetailController.retrieveScoreAPI(UUID); 
        Test.stopTest();
    }
}