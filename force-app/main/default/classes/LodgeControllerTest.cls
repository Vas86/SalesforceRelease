/*************************** 
* @Name          LodgeControllerTest.cls
* @Author        vasu@driva.com.au
* @Date          29/04/2022
* @description   Test class
******************************************************
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-----------------------------------------------------------------------
*  1.0              Vasu      29/04/2022          Test Class for LodgeController.cls
****************************** */
@isTest 
public class LodgeControllerTest {
	@isTest 
    public static void unit1(){
        Case obj = new Case();
        obj.Status = 'New';
        obj.Origin = 'Phone';
        obj.Subject = 'Test';
        obj.Lender__c = 'Finance One';
        obj.Driva_UUID__c = '9cb40e48-774d-4f05-af6d-66f8f0066a80';
        //da761cc1-b79b-4b34-8f9d-fb7d13e5a0a0
        insert obj;
        LodgeController.getCaseDetail(obj.Id);
        LodgeController.callLodgeSelectAPI('');
        LodgeController.callLodgeAPI('','','');
        LodgeController.processResponse(new List<String>{'test'}, null);
    }
}