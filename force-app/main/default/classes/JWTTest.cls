/*************************** 
* @Name          JWTTest.cls
* @Author        vasu@driva.com.au
* @Date          29/04/2022
* @description   Test class
******************************************************
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-----------------------------------------------------------------------
*  1.0              Vasu      29/04/2022          Test Class for JWT.cls
****************************** */
@isTest
public class JWTTest {

   @isTest
    public static void testMethod1() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        JWT uf = new JWT();
        Test.startTest();
        String str = JWT.sign();
        String str1=JWT.signService();
        Test.stopTest();
        
        System.assert(!String.isBlank(str));
        System.assert(!String.isBlank(str1));

    }
    
}