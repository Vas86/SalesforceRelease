@isTest
public  class DrivaReferralsControllerTest {
    
        @isTest
        public static void testMethod1() {
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
            Case objcase = new Case();
            objcase.Status = 'Received';
            objcase.Origin = 'Phone';
            //objcase.Contact.Id = c.Id;
            insert objcase;
    
            date dt = System.today();
            DrivaReferralsController uf = new DrivaReferralsController();
            Test.startTest();
            DrivaReferralsController.fetchLoanUuid(objcase.Id);   
            DrivaReferralsController.fetchToken();
            DrivaReferralsController.fetchEnv();
            Test.stopTest();
           
            list<Case> con = [select Id from Case];
            System.assertEquals(1, con.size());
        }

    
}