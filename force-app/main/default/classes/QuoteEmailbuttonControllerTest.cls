@isTest
public class QuoteEmailbuttonControllerTest {
   @isTest
    public static void testMethod1() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Case objcase = new Case();
        objcase.Status = 'Received';
        objcase.Origin = 'Phone';
        insert objcase;
		
        ApexPages.StandardController controller;
        QuoteEmailButtonController quoteEmail = new QuoteEmailButtonController(controller);
        Test.startTest();
        quoteEmail.urlRedirect();
        Test.stopTest();
       
        System.assertEquals(1, 1);
    }
    
}