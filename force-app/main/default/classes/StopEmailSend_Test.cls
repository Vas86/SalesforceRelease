/*
 * Description: - Test class for Trigger StopEmailSend
 * 
 * 
 */
@isTest
public class StopEmailSend_Test {
    
    @isTest 
    public static void testMethod1() {
        
        
       /* Case caseobj = new Case();
        caseobj.Origin = 'Email';
        caseobj.Status = 'Under Review';
        caseobj.Assessment_Quality__c = 'Low';
        insert caseobj;
        
        
        //Insert emailmessage for case
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = false;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Your application has been withdrawn';
        email.HtmlBody = 'Test email body';
        email.ParentId = caseobj.Id; 
        insert email;*/

        
    

        
        
        Case caseobj = new Case();
        caseobj.Origin = 'Email';
        caseobj.Status = 'Under Review';
        caseobj.Assessment_Quality__c = 'To be Assessed';
        insert caseobj;
        
        
        //Insert emailmessage for case
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = True;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Your application has been withdrawn';
        email.HtmlBody = 'Test email body';
        email.ParentId = caseobj.Id; 
        insert email;

        Case caseobj1 = new Case();
        caseobj1.Origin = 'Email';
        caseobj1.Status = 'Under Review';
        caseobj1.Assessment_Quality__c = 'low';
        insert caseobj1;
        
        
      
        
        
    }
    
    

}