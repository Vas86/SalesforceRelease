@isTest
public class DrivaAIApexControllerTest {

   @isTest
    public static void testMethod1() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Case objcase = new Case();
        objcase.Status = 'Received';
        objcase.Origin = 'Phone';
        //objcase.Contact.Id = c.Id;
        insert objcase;

        date dt = System.today();
        DrivaAIApexController uf = new DrivaAIApexController();
        Test.startTest();
        DrivaAIApexController.fetchLoanUuid(objcase.Id);   
        DrivaAIApexController.fetchToken();
        DrivaAIApexController.fetchEnv();
        DrivaAIApexController.updateCollapsable(objcase.Id,true);
        DrivaAIApexController.fetchCollapsable(objcase.Id);
       
        Test.stopTest();
       
        list<Case> con = [select Id from Case];
        System.assertEquals(1, con.size());
    }
    
}