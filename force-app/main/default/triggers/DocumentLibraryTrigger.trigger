/*
* Created By : NRUPA VORA
* Date : 12/01/2022
* Description : When Document Library Inserts send post call out to driva with Document Library Id
*/
trigger DocumentLibraryTrigger on Document_Library__c (after Insert, after Update) {
    
    //GET CUSTOM SETTING
    Trigger_Status__c TriggerStatus = Trigger_Status__c.getValues('DocumentLibraryTrigger');
    IF(TriggerStatus!=null)
    {
        //CHECK IF TRIGGER IS ACTIVE OR NOT IN CUSTOM SETTING
        IF(TriggerStatus.IsActive__c)
        {
            IF(Trigger.isAfter && Trigger.isInsert){
                IF(Trigger.New.size()>0){
                    
                    //CREATE SET AND GET IDs FOR UPLOADED DOCUMENT LIBRARIES
                    set<Id> NewDocumentId = new set<Id>();
                    //Boolean isPA = false;
                    FOR(Document_Library__c document : Trigger.New){
                        NewDocumentId.add(document.Id);
                        /* if(document.Document_Type__c.equals('Preliminary Assessment')) {
                            isPA = true;
                        } */
                    }
                    
                    //SEND THIS SET TO HANDLER FUTURE METHIOD FOR POST CALLOUT
                    IF(NewDocumentId.size()>0){
                        DocumentLibraryTrigger_Handler.InsertPostCallout(NewDocumentId);
                    }
                    
                    System.debug('@@ Trigger called');
                    //UPDATE CASE SUB STATUS
                    
                   /* System.debug('isPA: ' + isPA);
                    if(!isPA) {
                        DocumentLibraryTrigger_Handler.updateCaseSubStatus(Trigger.New);
                    }*/
                }
            }
            
            IF(Trigger.isAfter && Trigger.isUpdate){
                IF(Trigger.New.size()>0){
                    
                    //CREATE SET AND GET IDs FOR UPLOADED DOCUMENT LIBRARIES
                    set<Id> UpdatedDocumentId = new set<Id>();
                    FOR(Document_Library__c document : Trigger.New){
                        UpdatedDocumentId.add(document.Id);
                    }
                    
                    //SEND THIS SET TO HANDLER FUTURE METHIOD FOR DELETE CALLOUT
                    IF(UpdatedDocumentId.size()>0){
                        DocumentLibraryTrigger_Handler.DeleteCallout(UpdatedDocumentId);
                    }
                }
            }
        }
    }
}