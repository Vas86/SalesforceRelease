/*************************** 
* @Name    CaseSummaryControllerTest
* @Author   vasu@driva.com.au
* @Date     29/07/2022
* @description Testclass to handle scenarios of  Case summary and credit scores sumamrised view logic
******************************************************
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-----------------------------------------------------------------------
*  1.0              Vasu      29/07/2022          Initial Creation 

****************************** */
@isTest
public class CaseSummaryControllerTest {
    private static String insertCase(){
        Case objcase = new Case();
        objcase.Status = 'Under Review';
        objcase.Origin = 'Phone';
        INSERT objcase; 
        return objcase.Id;
    }
    @isTest
    public static void testMethods(){
        String caseId = insertCase();
        CaseSummaryController.getCaseDetails(caseId);
        CaseSummaryController.getCaseCreditScoreDetails(caseId);
        CaseSummaryController.getContactId(caseId);
    }
}