@isTest
public class SendEmailSMSAlertsBatchTest {
    @isTest
    static void test(){
        Contact conRec = new Contact();
        conRec.LastName = 'Test';
        conRec.Email = 'abc@testgmail.com';
        Insert conRec;
        
        Case objcase = new Case();
        objcase.Status = 'Under Review';
        objcase.Origin = 'Email';
        objcase.Need_To_Notify_Customer__c = true;
        objcase.Assessment_Quality__c = 'To Be Assessed';
        objcase.ContactId = conRec.Id;
        insert objcase;
          

        
        Test.startTest();
            SendEmailSMSAlertsBatch batchObj = new SendEmailSMSAlertsBatch(System.Today());
            Database.executeBatch(batchObj);
        Test.stopTest();
    }
    @isTest
    static void testElse(){
        Contact conRec = new Contact();
        conRec.LastName = 'Test';
        conRec.Email = 'abc@testgmail.com';
        Insert conRec;
        
        Case objcase = new Case();
        objcase.Status = 'Under Review';
        objcase.Origin = 'Email';
        objcase.Need_To_Notify_Customer__c = true;
        objcase.Assessment_Quality__c = 'To Be Assessed';
        objcase.ContactId = conRec.Id;
        insert objcase;
        Date satDate;
        for(Integer i = 0; i<6; i++){
            Date d = System.today().addDays(i);
            Datetime dt = (DateTime)d;
            String dayOfWeek = dt.format('EEEE'); //This returns - Monday, Tuesday, Wednesday, etc..
            if(dayOfWeek == 'Saturday'){
                satDate = d;
                break;
            }
        }
        Test.startTest();
            SendEmailSMSAlertsBatch batchObj = new SendEmailSMSAlertsBatch(satDate);
            Database.executeBatch(batchObj);
        Test.stopTest();
    }
   
    @isTest
    static void testSchedule(){
        Test.StartTest();
        ScheduleSendEmailSMSAlertBatch testsche = new ScheduleSendEmailSMSAlertBatch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}