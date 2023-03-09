trigger DeleteLiabilityToDrivaDB on Liability__c (before delete) {
    // Skip change done by the API call   
    System.debug('Sync Delete Liability');
    Boolean isFromBrowser = EntryURL.isFromBrowser();
    if(isFromBrowser && SyncLiabilityToDrivaDBHelper.isFirstRun) {
        SyncLiabilityToDrivaDBHelper.isFirstRun = false;
        for(Liability__c data : Trigger.Old) {
            System.debug('Delete Liability' + JSON.serialize(data));
            System.Queueable job = new DrivaAPIQueue('/liability', 'DELETE', 'Liability__c', data);
            System.enqueueJob(job);
        } 
    }
}