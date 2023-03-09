@isTest
public  class DrivaLenderQuotesControllerTest {
    @isTest
    public static void testMethod1() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Case objcase = new Case();
        objcase.Status = 'Received';
        objcase.Origin = 'Phone';
        //objcase.Contact.Id = c.Id;
        insert objcase;

        date dt = System.today();
        DrivaLenderQuotesController uf = new DrivaLenderQuotesController();
        Test.startTest();
        DrivaLenderQuotesController.fetchLoanUuid(objcase.Id);   
        DrivaLenderQuotesController.fetchToken();
        DrivaLenderQuotesController.fetchEnv();
        Test.stopTest();
       
        list<Case> con = [select Id from Case];
        System.assertEquals(1, con.size());
    }

}