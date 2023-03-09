trigger SyncLiabilityToDrivaDB on Liability__c (after insert, after update) {
    // Skip change done by the API call   
    System.debug('Sync Liability');
    Boolean isFromBrowser = EntryURL.isFromBrowser();
    if(isFromBrowser && Trigger.isAfter && Trigger.New.size()>0 && SyncLiabilityToDrivaDBHelper.isFirstRun) {
        SyncLiabilityToDrivaDBHelper.isFirstRun = false;
        for(Liability__c data : Trigger.New) {
            System.Queueable job = new DrivaAPIQueue('/liability', 'POST', 'Liability__c', data.Id);
            System.enqueueJob(job);
           
        } 
    }
}