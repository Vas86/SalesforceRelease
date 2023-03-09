/*
* Description: - Trigger is used to stop sending email in Case based on Condition
* 
* Author:- Uttpal Chandra(uttpal@resonantcloud.info)
* 
* Trello:- https://trello.com/c/in1lbNiT/125-statusunder-review-agent-unable-to-send-email-unless-trigger-to-change-assessment-quality-is-populated
* 
* Date Feburary 2022
* 
* @See - StopEmailSend_Test
   
  Author:- Vasu Velgoti
  Date August 2022-- Modified code to handle validation errors for With drawn and decline Refer to AG-2909 (Decline/Withdrawn reason field should be mandatory when marking a case as Withdrawn or Declined)

* 
*/
trigger StopEmailSend on EmailMessage (before insert) {
    
    
 // if(System.label.Dr_StopEmailSend == 'True') // commented as System.label.Dr_StopEmailSend has current value set as False so it won't skip the validation rule on Email with subjects as mentioned in line 24 
   // { this if condition is added in line 38 
        Set<Id> setEmailRecIds = new Set <Id>(); 
        Set<Id> withdrawnUnsuccessEmail = new Set <Id>(); //12-Aug-2022
        
        for(EmailMessage objMsg : trigger.new) {  
            setEmailRecIds.add(objMsg.ParentId);  
            //12-Aug-2022 to skip the validation rule
            if(objMsg.Subject == 'Your application has been withdrawn' || objMsg.Subject == 'Unfortunately your application has been unsuccessful'){
                withdrawnUnsuccessEmail.add(objMsg.ParentId);
            }
        }
        
        System.debug('This is test ' +setEmailRecIds);
        if (setEmailRecIds.size() > 0) 
        { 
            List<Case> casesWithIsSkip = new List<Case> ();
            List<Case> caseRecords = [ SELECT Id,Status,Assessment_Quality__c,isSkip__c,Withdraw_Decline_Reason__c FROM Case WHERE Id IN: setEmailRecIds ]; //12-Aug-2022 New field added
            for (Case objCase : caseRecords ) 
            {  
                System.debug('This is test ' +objCase.Status);
                
                //AG-2941: Adding skipStopMailSend condition inside conditions check--skipped this validation when EmailMessage is inserted through the Batch Class
               if(System.label.Dr_StopEmailSend == 'False' && objCase.Status == 'Under Review' && objCase.Assessment_Quality__c == 'To be Assessed' && !SendEmailSMSAlertsBatchHelper.skipStopMailSend) 
               // if(System.label.Dr_StopEmailSend == 'False' && objCase.Status == 'Under Review' && objCase.Assessment_Quality__c == 'To be Assessed' )//if condition of system label added here
                { 
                    for(EmailMessage objMsg : trigger.new) { 
                        if(objMsg.Incoming  == false){
                            objMsg.addError('Change Assessment Quality to either:At verification, Verified, Low, medium or High to send Email');
                       }
                        
                        
                    }
                } 
                //trigger validation if withdrawn reason is empty and status=under review and subject is 'Your application has been withdrawn' or 'Unfortunately your application has been unsuccessful'
                else if(System.label.Dr_StopEmailSend == 'False' && objCase.Withdraw_Decline_Reason__c ==NULL ) //if condition of system label added here
                { 
                    for(EmailMessage objMsg : trigger.new) { 
                       
                        if(objMsg.Subject == 'Your application has been withdrawn' || objMsg.Subject == 'Unfortunately your application has been unsuccessful'){
                            objMsg.addError('Please specify the decline / withdraw reason!');
                        }
                        
                    }
                } 
                //12-Aug-2022 condition to skip the validation rule
                if(withdrawnUnsuccessEmail.contains(objCase.Id)){
                    SyncCaseToDrivaDBHelper.skipValidation = true;
                }
            } 
            
        }
  // }
}