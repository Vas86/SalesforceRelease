trigger SyncCaseToDrivaDB on Case (before insert,before update,after insert,after update) {
    
    //12-Aug-2022 Validation Rule- AG- 2909
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate) ){
        for(Case caseObj : trigger.new){
            if((caseObj.Status == 'Declined' || caseObj.Status == 'Withdrawn') && caseObj.Withdraw_Decline_Reason__c == null && !SyncCaseToDrivaDBHelper.skipValidation){
                caseObj.Withdraw_Decline_Reason__c.addError('Please specify the decline / withdraw reason!');
            }
        }
    }
    //Ends
    
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        //GET CUSTOM SETTING
        Trigger_Status__c TriggerStatus = Trigger_Status__c.getValues('SyncCaseToDrivaDB');
        IF(TriggerStatus!=null)
        {
            //CHECK IF TRIGGER IS ACTIVE OR NOT IN CUSTOM SETTING
            IF(TriggerStatus.IsActive__c)
            {
                Boolean isFromBrowser = EntryURL.isFromBrowser();
                if(isFromBrowser && Trigger.isAfter && Trigger.New.size()>0 && SyncCaseToDrivaDBHelper.isFirstRun && SyncCaseToDrivaDBHelper.callExternalAPI) {
                    if(trigger.isInsert){
                        SyncCaseToDrivaDBHelper.isFirstRun = false;
                    }
                    Set<String> caseIds = new Set<String>();  
                    //start-code to set selected fields in SF
                    
                    // Added on: 1/02/2023 start
                    Boolean flag = false;
                    List<String> fieldNames = new List<String>();
                    List<String> updatedFieldNames = new List<String>(); // Added on: 2/02/2023
                    List<syncToDrivaDB_DynamicFields__mdt> mtd = [Select syncFields__c, syncObject__c from
                                                                  syncToDrivaDB_DynamicFields__mdt WHERE syncObject__c = 'Case'];
                    if(mtd.size() > 0){
                        fieldNames = mtd[0].syncFields__c.split(',');
                    }
                    Boolean isUpdate = trigger.isUpdate;
                    // Added on: 1/02/2023 end    
                    // End-code to set selected fields in SF            
                    for(Case c : Trigger.New) {
                        //checking if UUID is empty before syncing to db
                        // Added on: 1/02/2023 start
                        if(isUpdate && ((!String.isBlank(c.Driva_UUID__c)) || c.Driva_UUID__c !=null)){
                            Case oldObjMap = trigger.oldMap.get(c.Id);
                            for(String caseField : fieldNames){
                                if(c.get(caseField) != oldObjMap.get(caseField) && caseField != 'LastModifiedDate'){
                                    updatedFieldNames.add(caseField); // Added on: 2/02/2023
                                    SyncCaseToDrivaDBHelper.isFirstRun = false;
                                    caseIds.add(c.Id);
                                    System.debug('**Update updatedFieldNames'+updatedFieldNames);
                                    flag = true;
                                }
                            }
                        }
                        // Added on: 1/02/2023 end-- commenting this to avoid sync when fileds are not updated
                        else if((!String.isBlank(c.Driva_UUID__c)) || c.Driva_UUID__c !=null){
                            caseIds.add(c.Id);
                            updatedFieldNames.addAll(fieldNames); // Added on: 2/02/2023
                            System.debug('**Insert updatedFieldNames=> ' + updatedFieldNames);
                            flag = true;
                        }
                    }
                    if(flag){// Added on: 1/02/2023
                        System.debug('********');
                        System.debug('Flag updatedFieldNames'+updatedFieldNames);
                        System.Queueable job = new DrivaAPIQueue('/case', 'POST', 'Case',caseIds, updatedFieldNames);
                        //System.Queueable job = new DrivaAPIQueue('/case', 'POST', 'Case', caseIds, updatedFieldNames);
                        System.enqueueJob(job);
                    }
                }
            }
        }
    }
}