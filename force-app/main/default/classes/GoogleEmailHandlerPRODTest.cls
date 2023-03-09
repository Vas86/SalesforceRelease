@isTest
public class GoogleEmailHandlerPRODTest {
    @isTest public static void unit1(){
        Account testAccount = new Account(Name = 'GoogleEmail');
        insert testAccount;
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'testuse8888r@example.org', null, 'testuse8888r@example.org', 'en_US', 'GoogleEmail',
                                                     null, new Map<String, String>{'language' => 'en_US', 'sfdc_networkid' => 'test12'});
        GoogleEmailHandlerPROD obj = new GoogleEmailHandlerPROD();
        obj.createUser(null, sampleData);
    }
    
    @isTest public static void unit2(){
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'testuse8888r@example.org', null, 'testuse8888r@example.org', 'en_US', 'GoogleEmail',
                                                     null, new Map<String, String>{'language' => 'en_US'});
        GoogleEmailHandlerPROD obj = new GoogleEmailHandlerPROD();
        obj.createUser(null, sampleData);
    }
    
    @isTest public static void unit3(){
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'testuse8888r@example.org', null, 'testuse8888r@example.org', 'en_US', 'GoogleEmail',
                                                     null, new Map<String, String>{'language' => 'en_US', 'sfdc_networkid' => 'test'});
        GoogleEmailHandlerPROD obj = new GoogleEmailHandlerPROD();
        obj.updateUser(null, null, sampleData);
    }
}