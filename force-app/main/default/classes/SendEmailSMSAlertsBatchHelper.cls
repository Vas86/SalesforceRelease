public class SendEmailSMSAlertsBatchHelper {
    
    public static boolean skipStopMailSend = false;
    public static void sendEmailAndSMS(List<Case> caseRecords){
        //send mail and sms alerts
        List<Case> updateCases = new List<Case>();
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        List<smagicinteract__Converse_App_Task__c> smsMessages = new List<smagicinteract__Converse_App_Task__c>();
        List<smagicinteract__smsMagic__c> smschatterlist = new List<smagicinteract__smsMagic__c>();
        List<SMSTemplateWhenCaseInUR__mdt> smsTemp = SMSTemplateWhenCaseInUR__mdt.getAll().values();
        String smsTempName;
        if(smsTemp.size() > 0){
            smsTempName = smsTemp[0].Label;
        }
        List<Email_When_Case_In_UR__mdt> emailTemplate = Email_When_Case_In_UR__mdt.getAll().values();
        String emailName;
        if(emailTemplate.size() > 0 ){
            emailName = emailTemplate[0].Email_Developer_Name__c;
        }
        EmailTemplate emt = [SELECT Id,DeveloperName from EmailTemplate where DeveloperName =: emailName];
        System.debug('email template name'+emt.developerName);
        smagicinteract__SMS_Template__c smsTemplate=new smagicinteract__SMS_Template__c();
        if(!Test.isRunningTest()){
        smsTemplate = [SELECT Id,Name FROM smagicinteract__SMS_Template__c where Name =: smsTempName];
        }
        //System.debug('smstemplate name'+smsTemplate.Name);
       //EmailTemplate emt = [SELECT Id from EmailTemplate where DeveloperName = 'Email_When_Case_in_UR_and_To_Be_Assessed_1663209541064']; 
       // EmailTemplate emt = [SELECT Id from EmailTemplate where DeveloperName = 'Email_When_Case_in_UR_and_To_Be_Assessed_1663308011246']; // Prod template developerName
        
       // smagicinteract__SMS_Template__c smsTemplate = [SELECT Id,Name FROM smagicinteract__SMS_Template__c where Name = 'ST-00000031']; //Add SMSTemplateName in Dev
        //smagicinteract__SMS_Template__c smsTemplate = [SELECT Id,Name FROM smagicinteract__SMS_Template__c where Name = 'ST-00000033']; // Add SMSTemplateName different  in PROD
        for(Case caseObj : caseRecords){
            if(caseObj.ContactEmail != NULL){
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'contact@driva.com.au'];
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setToAddresses(new List<String>{caseObj.ContactEmail});
                //message.setSenderDisplayName('Driva');
                if(owea.size()>0){
                    message.setOrgWideEmailAddressId(owea.get(0).Id);  
                }
                
                message.setTemplateId(emt.id);
                message.setTargetObjectId(caseObj.ContactId);
                message.setTreatTargetObjectAsRecipient(false);
                message.setWhatId(caseObj.Id);
                emailMessages.add(message);
            }                
            if(!Test.isRunningTest()){
            smagicinteract__Converse_App_Task__c smsObj = new smagicinteract__Converse_App_Task__c();
            smsObj.Name = caseObj.Id;
            smsObj.case__c = caseObj.Id; //this field was not in the sandbox: DemoOrg
            smsObj.smagicinteract__Automation_Key_Reference__c = 'PA-000020';// sandbox id :PA-000020
            smsObj.smagicinteract__Contact__c = caseObj.ContactId;
            smsObj.smagicinteract__Template__c = smsTemplate.Id; //SMS Template ID            
            smsMessages.add(smsObj);
            }
            //post SMS text to chatter
           
            smagicinteract__smsMagic__c smschatter=new smagicinteract__smsMagic__c();
            smschatter.smagicinteract__Case__c=caseObj.Id;
            smschatter.smagicinteract__SMSText__c=smsTemplate.Name;// template text to post to chatter
            smschatterlist.add(smschatter);
             
            //updating the notify customer field as false 
            if(caseObj.Need_To_Notify_Customer__c){
                Case caseRec = new Case(Id = caseObj.Id);
                caseRec.Need_To_Notify_Customer__c = false;
                updateCases.add(caseRec);
            }
            
        }
        //Sending mails
        try {
            skipStopMailSend = true;
            Messaging.sendEmail(emailMessages);
            
            //Inserting SMSs 
            if(smsMessages.size() > 0){
                INSERT smsMessages;
            }
            
            //Updating Case Notify Customer Field
            if(updateCases.size() > 0){
                UPDATE updateCases;
            }
            
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
}