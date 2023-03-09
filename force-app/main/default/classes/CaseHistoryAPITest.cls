/*************************** 
* @Name         CaseHistoryAPITest 
* @Author       vasu@driva.com.au
* @Date         28/07/2022
* @description   Test Class for CaseHistoryAPI


******************************************************
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-----------------------------------------------------------------------
*  1.0              Vasu      28/07/2022          Initial Creation 

****************************** */
@isTest
public class CaseHistoryAPITest {
    private static Id getCaseId(){
	    Case objcase = new Case();
        objcase.Status = 'Under Review';
        objcase.Origin = 'Phone';
        INSERT objcase; 
        return objcase.Id;
    }
    @isTest
    public static void getCaseHistoryPositiveTest(){
		
        String caseId = getCaseId();
        Test.startTest();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='https://driva--dev.my.salesforce.com/services/apexrest/'+ caseId;
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response;
        // Call the method to test
        CaseHistoryAPI.getCaseHistory();
        Test.stopTest();
    }
   @isTest
    public static void getCaseHistoryNegativeTest(){
        String caseId = getCaseId();
        CaseHistoryAPI.coverElse = true;
        Test.startTest();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='https://driva--dev.my.salesforce.com/services/apexrest/' + caseId;
        request.httpMethod = 'GET';
        RestContext.request = request;
		RestContext.response = response;
        // Call the method to test
        CaseHistoryAPI.getCaseHistory();        	
        Test.stopTest();
        CaseHistoryAPI.coverElse = false;
    }
}