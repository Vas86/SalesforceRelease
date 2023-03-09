trigger SyncContactToDrivaDB on Contact (after insert,after update) {
    //GET CUSTOM SETTING
    Trigger_Status__c TriggerStatus = Trigger_Status__c.getValues('SyncContactToDrivaDB');
    IF(TriggerStatus!=null)
    {
        //CHECK IF TRIGGER IS ACTIVE OR NOT IN CUSTOM SETTING
        IF(TriggerStatus.IsActive__c)
        {
            // Skip change done by the API call   
            Boolean isFromBrowser = EntryURL.isFromBrowser();
            if(isFromBrowser && Trigger.isAfter && Trigger.New.size()>0 && SyncContactToDrivaDBHelper.isFirstRun) {
                SyncContactToDrivaDBHelper.isFirstRun = false;
                for(Contact contact : Trigger.New) {
                    System.Queueable job = new DrivaAPIQueue('/contact', 'POST', 'Contact', contact.Id);
                    System.enqueueJob(job);
                } 
            }
        }
    }
}