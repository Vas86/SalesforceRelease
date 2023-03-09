@isTest
public  class DrivaLodggementsControllerTest {
    
        @isTest
        public static void testMethod1() {
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
            Case objcase = new Case();
            objcase.Status = 'Received';
            objcase.Origin = 'Phone';
            //objcase.Contact.Id = c.Id;
            insert objcase;
    
            date dt = System.today();
            DrivaLodgementsController uf = new DrivaLodgementsController();
            Test.startTest();
            DrivaLodgementsController.fetchLoanUuid(objcase.Id);   
            DrivaLodgementsController.fetchToken();
            DrivaLodgementsController.fetchEnv();
            Test.stopTest();
           
            list<Case> con = [select Id from Case];
            System.assertEquals(1, con.size());
        }

    
}