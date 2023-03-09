trigger SyncNoteToDrivaDB on Note__c (after insert, after update) {
    // Skip change done by the API call   
    Boolean isFromBrowser = EntryURL.isFromBrowser();
    if(isFromBrowser && Trigger.isAfter && Trigger.New.size()>0 && SyncNoteToDrivaDBHelper.isFirstRun) {
        SyncNoteToDrivaDBHelper.isFirstRun = false;
        for(Note__c nt : Trigger.New) {
            System.Queueable job = new DrivaAPIQueue('/note', 'POST', 'Note__c', nt.Id);
            System.enqueueJob(job);
        } 
    }
}