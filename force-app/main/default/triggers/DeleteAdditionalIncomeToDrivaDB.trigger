trigger DeleteAdditionalIncomeToDrivaDB on Additional_Income__c (before Delete) {
    // Skip change done by the API call   
    System.debug('Sync Delete Additional Income');
    Boolean isFromBrowser = EntryURL.isFromBrowser();
    if(isFromBrowser && SyncAdditionalIncomeToDrivaDBHelper.isFirstRun) {
        SyncAdditionalIncomeToDrivaDBHelper.isFirstRun = false;
        for(Additional_Income__c data : Trigger.Old) {
            System.Queueable job = new DrivaAPIQueue('/otherincome', 'DELETE', 'Additional_Income__c', data);
            System.enqueueJob(job);
        }
    }
}