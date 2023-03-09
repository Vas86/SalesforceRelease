/*
* Created By : NRUPA VORA
* Date : 12/01/2022
* Description : When Document Library Inserts send post call out to driva with Document Library Id
*/
public class DocumentLibraryTrigger_Handler {
    
    //METHOD CALLED FROM TRIGGER ON INSERTING DOCUMENT LIBRARY
    @future(callout=true)
    public static void InsertPostCallout(set<Id> NewDocumentIds){
        IF(NewDocumentIds.size()>0){
            List<Document_Library__c> DocumentList = [SELECT Id, Is_Deleted__c FROM Document_Library__c WHERE Id IN: NewDocumentIds];
            IF(DocumentList.size()>0){
                List<Error_Handler__c> Errors = new List<Error_Handler__c>();
                FOR(Document_Library__c Document : DocumentList){
                    
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    
                    // Use NamedCredentials & callout to get Bearer JWT
                    string url = 'callout:Salesforce_Service/file';
                    request.setEndpoint(url);

                    IF(Document.Is_Deleted__c){
                        request.setMethod('DELETE');
                    }
                    ELSE{
                        request.setMethod('POST');
                    }
                    request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                    request.setBody('{"Id":"'+Document.Id+'"}');
                    
                    // Merge fields after setBody
                    request.setHeader('Authorization', '{!$Credential.Password}');
                    
                    HttpResponse response = http.send(request);
                    System.debug('response :: '+response);
                    IF(response != null){
                        Integer StatusCode = response.getStatusCode();
                        String StatusMessage = response.getStatus();
                        System.debug('StatusCode '+StatusCode);
                        System.debug('StatusMessage '+StatusMessage);
                        IF(response.getStatusCode() != 200){
                            System.debug('creating new Error Handler');
                            Error_Handler__c Error = new Error_Handler__c();
                            Error.Response_Code__c = StatusCode;
                            Error.Response_Message__c = StatusMessage;
                            Error.Document_Library__c = Document.Id;
                            Errors.add(Error);
                        }
                    }
                }
                IF(Errors.size()>0){
                    INSERT Errors;
                }
            }
        }
    }
    
    //METHOD CALLED FROM TRIGER WHEN RECORD SOFT DELETE
    @future(callout=true)
    public static void DeleteCallout(set<Id> UpdatedDocumentId){
        IF(UpdatedDocumentId.size()>0){
            List<Document_Library__c> DocumentList = [SELECT Id, Is_Deleted__c FROM Document_Library__c WHERE Id IN: UpdatedDocumentId];
            IF(DocumentList.size()>0){
                List<Error_Handler__c> Errors = new List<Error_Handler__c>();
                FOR(Document_Library__c Document : DocumentList){
                    IF(Document.Is_Deleted__c){
            
                        Http http = new Http();
                        HttpRequest request = new HttpRequest();

                        // Use NamedCredentials & callout to get Bearer JWT
                        string url = 'callout:Salesforce_Service/file/' + Document.Id;
                        request.setEndpoint(url);
                        request.setMethod('DELETE');
                        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
              
                        request.setBody('{"Id":"'+Document.Id+'"}');

                        // Merge fields after setBody
                        request.setHeader('Authorization', '{!$Credential.Password}');
                        
                        HttpResponse response = http.send(request);
                        System.debug('response :: '+response);
                        IF(response != null){
                            Integer StatusCode = response.getStatusCode();
                            String StatusMessage = response.getStatus();
                            System.debug('StatusCode '+StatusCode);
                            System.debug('StatusMessage '+StatusMessage);
                            IF(response.getStatusCode() != 200){
                                System.debug('creating new Error Handler');
                                Error_Handler__c Error = new Error_Handler__c();
                                Error.Response_Code__c = StatusCode;
                                Error.Response_Message__c = StatusMessage;
                                Error.Document_Library__c = Document.Id;
                                Errors.add(Error);
                            }
                        }
                    }
                    IF(Errors.size()>0){
                        INSERT Errors;
                    }
                }
            }
        }
    }
    
    //update case sub status after document insert
    public static void updateCaseSubStatus(List<Document_Library__c> lstDoc) {
        
        System.debug('@@ in method');
        set<Id> caseIds = new set<Id>();
        
        for(Document_Library__c objDoc: lstDoc) {
            if(objDoc.Case__c != null) {
                caseIds.add(objDoc.Case__c);
            }            
        }
        
        if(caseIds.size() > 0) {
            system.debug('@@ in If');
            List<case> lstCase = [Select Id, Sub_Status__c from case where Id IN: caseIds];
            List<Case> updtlstcase = new List<Case>();
            
            System.debug('@@@ lstCase = '+lstCase);
            for(Case objCase: lstCase) {
                objCase.Sub_Status__c = 'Correspondence Received';
                updtlstcase.add(objCase);
            }
            System.debug('@@@ updtlstcase = '+updtlstcase);
            
            if(updtlstcase.size() > 0) {
                update updtlstcase;
            }
        }
    }
}