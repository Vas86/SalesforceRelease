public class SendEmailSMSAlertsBatch implements Database.Batchable<sObject> {
    public Date currDate;
    public SendEmailSMSAlertsBatch(Date currentDate){
        currDate = currentDate;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){      
        return Database.getQueryLocator('SELECT Id,ContactEmail,ContactId,Need_To_Notify_Customer__c from Case where (Status = \'Under Review\' AND Assessment_Quality__c = \'To Be Assessed\' AND ContactId != NULL) AND (Under_Review_Date__c = YESTERDAY OR Need_To_Notify_Customer__c = True)');
    }
    
    public void execute(Database.BatchableContext BC, List<Case> scope){
        system.debug('scope+==> '+scope);
        //Date currDate = System.today();
        BusinessHours bHours;
        bHours = [SELECT Id FROM BusinessHours WHERE Name = 'Driva'];
        if(BusinessHours.isWithin(bHours.Id, currDate)){
            SendEmailSMSAlertsBatchHelper.sendEmailAndSMS(scope);
        }
        else{
            //update the notify customer field as true as customer will be alerted the next business day
            List<Case> updateCases = new List<Case>();
            for(Case caseObj : scope){
                Case caseRec = new Case(Id = caseObj.Id);
                caseRec.Need_To_Notify_Customer__c = true;
                updateCases.add(caseRec);
            }
            //Updating Case Notify Customer Field
                if(updateCases.size() > 0){
                    UPDATE updateCases;
                }
            system.debug('updateCases ++ '+updateCases);
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    
}