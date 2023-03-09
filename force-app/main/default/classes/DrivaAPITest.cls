@isTest
public class DrivaAPITest {
    @isTest
    public static void testMethod1() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());  
        
        DrivaAPI uf = new DrivaAPI();
        Test.startTest();
        DrivaAPI.createUpdate('test', 'test');
        Integer callouts = Limits.getCallouts();
        DrivaAPI.deleteObject('test', 'test');  
        Integer callouts2 = Limits.getCallouts();
        Test.stopTest();
    }
    
}