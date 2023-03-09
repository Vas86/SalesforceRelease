trigger SyncAdditionalIncomeToDrivaDB on Additional_Income__c (after insert, after update) {
    //GET CUSTOM SETTING
    Trigger_Status__c TriggerStatus = Trigger_Status__c.getValues('SyncAdditionalIncomeToDrivaDB');
    IF(TriggerStatus!=null)
    {
        //CHECK IF TRIGGER IS ACTIVE OR NOT IN CUSTOM SETTING
        IF(TriggerStatus.IsActive__c)
        {
            // Skip change done by the API call   
            System.debug('Sync Additional Income');
            Boolean isFromBrowser = EntryURL.isFromBrowser();
            if(isFromBrowser && Trigger.isAfter && Trigger.New.size()>0 && SyncAdditionalIncomeToDrivaDBHelper.isFirstRun) {
                SyncAdditionalIncomeToDrivaDBHelper.isFirstRun = false;
                for(Additional_Income__c data : Trigger.New) {
                    System.Queueable job = new DrivaAPIQueue('/otherincome', 'POST', 'Additional_Income__c', data.Id);
                    System.enqueueJob(job);
                }
            }
        }
    }
}