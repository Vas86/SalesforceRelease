/**
*  Description : Upload File from Case record detail page to AWS S3
*  Author Name : Foram Rana (foram@resonantcloud.info)
*  Date : 13/12/2021

Description: Moved the component into lightning Record Form as tab on UI to upload and download documents accordingly. Refer: AG-2592 & AG-2802 
    Auther Name  : Vasu Velgoti
    Date: 23/08/2022
*
* @Test : FileUploadControllerTest
**/

public with sharing class FileUploadController {
    @TestVisible
    private static String continuationLabel;
    @TestVisible
    private static String continuationState;
    
    /*
  Description: Method use to return folder name based on case Id
  param1 : Case Id
  */
    @AuraEnabled
    public static String fetchFolderNameFromCase(String caseId) {        
        
        List<case> lstcase = [Select Id, Driva_UUID__c from case where Id =: caseId limit 1];
        String strfolderName;
        
        if(lstcase.size() > 0) {
            return lstcase[0].Id;
            
        }
        else{
            return null;
        }
    } 
    
    /*
  Description: Method use to return List of AWS credentails from custom setting
  */
    
    @AuraEnabled
    public static List<AmazonS3__c> awsInfoDetails() {        
        
        List<AmazonS3__c> awsInfoList = [Select id, AmazonS3_BucketName__c, AmazonS3_Host__c, AmazonS3_Key__c, Bucket_Region__c,
                                         AmazonS3_Secret__c, API_Version__c, Identity_Pool_Id__c from AmazonS3__c  limit 1];
        
        return awsInfoList;
    } 
    
    /*
  Description: Method use to return List of document type from document library object
  */
    //Start (28-6-2022) Calling out API to get tab names
    @AuraEnabled(continuation=true)
    public static Object fetchDocType(String caseId) {
        system.debug('caseid'+caseId);
        List<Case> caseRecord = new List<Case>([SELECT Id,Loan_ID__c from Case where Id =: caseId]);        
        Decimal loanId = 0;
        if(caseRecord.size() > 0 && caseRecord[0].Loan_ID__c != NULL){
            loanId = caseRecord[0].Loan_ID__c; 
        } 
        system.debug('loanId'+loanId);
        String url = System.Label.additionalDocsAPIUrl + 'loan/' + loanId ;
        System.debug('URL==>'+url);
        Continuation con = new Continuation(40);
        // Set callback method
        con.continuationMethod = 'processResponse';
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        String jwtToken = JWT.sign();
        req.setHeader('Authorization', 'Bearer ' + jwtToken);
        system.debug('token'+jwtToken);
        String userId = userInfo.getUserId();
        req.setHeader('X-SalesForce-UserId' ,userId);
        //req.setHeader('Authorization','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2NTM4ODEzODZ9.rPitfwwWF9iIvCaod5-IAWCOlTxcY-YhC9LxBEP6798');
        if(Test.isRunningTest()){
            continuationLabel = con.addHttpRequest(req);
            continuationState = con.addHttpRequest(req);
            con.state = continuationState;
        }else{
            con.addHttpRequest(req);
        }
        // Return the continuation 
        
        return con;  
        
        /*List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Document_Library__c.Document_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
           
           // System.debug('Values in Document_Type__c are: '+pickListValuesList);
        }  
        system.debug('values size before'+pickListValuesList.size());
        pickListValuesList.add(1,'Documents in Portal');
         System.debug('Values in Document_Type__c are: '+pickListValuesList);
        system.debug('values size after'+pickListValuesList.size());
        return pickListValuesList;*/
        
    }
    //End
    
    /*
    Description: Method use to return List of wrapper class and wrapper class contains all file info 
  */
    
    @AuraEnabled
    public static List<wrapper> fetchFileURL(String strDocType, String strCaseId) {
        
        List<wrapper> lstWrap = new List<wrapper>();
        List<String> lstFileURL = new List<String>();
        List<Document_Library__c> lstDoc = [SELECT Id, Name,File_Name__c, File_Type__c, Document_Type__c, File_Link__c,Is_Deleted__c,Removed_At__c,Removed_By__c,Soft_Delete__c
                                            FROM Document_Library__c 
                                            WHERE Document_Type__c =: strDocType and Case__c =: strCaseId ORDER BY CreatedDate];
        
        List<case> lstcase = [Select Id, Driva_UUID__c from case where Id =: strCaseId limit 1];
        String strFolderName;
        
        if(lstcase.size() > 0) {
            
            strFolderName = lstcase[0].Id;
        }
        
        for(Document_Library__c objDoc: lstDoc) {
            if(objDoc.File_Link__c != null) {
                
                //create wrapperclass object
                wrapper objwrp = new wrapper();
                objwrp.strFileName = objDoc.File_Name__c;
                
               // objwrp.docId = objDoc.Id;
                /*AG-3200*/
                objwrp.docId = objDoc.Id + '-' + objDoc.Name;
               /* AG-3200*/

                if(objDoc.Soft_Delete__c){
                    objwrp.removedBy = objDoc.Removed_By__c;
                    Datetime dt = objDoc.Removed_At__c;
                    Datetime myDateTime = Datetime.newInstance(dt.date(),dt.time());
                    objwrp.removedAt = myDateTime.format('h:mm a dd-MMM-yy');
                    objwrp.isSoftDelete = true;
                }
                      
                if(objDoc.File_Type__c == 'application/pdf') {
                    objwrp.isPDFFile = true;
                }                
                else if(objDoc.File_Type__c == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' || 
                        objDoc.File_Type__c == 'application/msword') {                    
                            objwrp.isDocFile = true;
                        }      
                else if(objDoc.File_Type__c == 'message/rfc822') {
                    objwrp.isEMLFile = true;
                }
                else if(objDoc.File_Type__c == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
                    objwrp.isExcelFile = true;
                }
                else if(objDoc.File_Type__c == 'text/html' || objDoc.File_Type__c == 'text/htm') {
                    objwrp.isHTMLFile = true;
                }
                else if(objDoc.File_Type__c == 'image/tiff' || objDoc.File_Type__c == 'image/tif') {
                    objwrp.isTIFFFile = true;
                }
                else if(objDoc.File_Type__c == 'application/json') {
                    objwrp.isJSONFile = true;
                }
                else if(objDoc.File_Type__c == 'text/xml') {
                    objwrp.isXMLFile = true;
                }
                else if(objDoc.File_Type__c == 'application/vnd.ms-excel.sheet.macroEnabled.12') {
                    objwrp.isXLSMFile = true;
                }
                String file = objDoc.File_Name__c;
                String url;
                //Custome Setting 
                Map<String, AmazonS3__c> s3Map = AmazonS3__c.getAll();
                String s3MapAccessKey = 'AmazonS3Credentials';
                String AccessKey = s3Map.get(s3MapAccessKey).AmazonS3_Key__c; //AWS key 
                AccessKey = AccessKey.deleteWhitespace();
                String SecretKey = s3Map.get(s3MapAccessKey).AmazonS3_Secret__c; //AmazonS3_Secret key
                SecretKey = SecretKey.deleteWhitespace();
                String BucketName = s3Map.get(s3MapAccessKey).AmazonS3_BucketName__c; //AWS bucket name
                String locationname = s3Map.get(s3MapAccessKey).AmazonS3_Host__c;  //location or region name
                
                String filename = EncodingUtil.urlEncode(file, 'UTF-8');
                Datetime now = DateTime.now();
                Datetime expireson = now.AddSeconds(7200); // Lifespan of the link
                Long Lexpires = expireson.getTime()/1000;        
                String stringtosign = 'GET\n\n\n'+Lexpires+'\n/'+BucketName+'/'+strFolderName+'/'+filename;
                
                System.debug('redirectToS3Key stringstosign: ' + stringtosign);
                
                String signingKey = EncodingUtil.base64Encode(Blob.valueOf(SecretKey));
                Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(stringtosign),blob.valueof(SecretKey)); 
                String signed= EncodingUtil.base64Encode(mac);     
                String codedsigned = EncodingUtil.urlEncode(signed,'UTF-8');
                url = 'https://'+BucketName+'.'+locationname+'/'+strFolderName+'/'+filename+'?AWSAccessKeyId='+AccessKey+'&Expires='+Lexpires+'&Signature='+codedsigned;
                objwrp.strFileLink = url;
                lstWrap.add(objwrp);
                //System.debug('@@ lstWrap = '+lstWrap);
            }
        }
        System.debug('@@  = '+lstWrap);
        return lstWrap;
    }
    
    @AuraEnabled
    public static void createDocumentRecord(String fileName, String contentType, String parentId, String strDocType) {
        Document_Library__c objDoc = new Document_Library__c();
        objDoc.File_Name__c = fileName;
        objDoc.File_Type__c = contentType;
        objDoc.Case__c = parentId;
        objDoc.Document_Type__c = strDocType;
        objDoc.Expiration_Date__c = Date.Today();   

        if(!Test.isRunningTest()){ 
           insert objDoc;
        }
    } 
    
    //Wrapper Class 
    public class wrapper{
        @AuraEnabled 
        public String strFileName;
        @AuraEnabled 
        public String strFileLink;
        @AuraEnabled 
        public Boolean isPDFFile;    
        @AuraEnabled 
        public Boolean isDocFile;    
        @AuraEnabled 
        public Boolean isEMLFile;
        @AuraEnabled 
        public Boolean isHEICFile;
        @AuraEnabled 
        public Boolean isHTMLFile;
        @AuraEnabled 
        public Boolean isTIFFFile;
        @AuraEnabled 
        public Boolean isJSONFile;
        @AuraEnabled 
        public Boolean isXMLFile;   
        @AuraEnabled 
        public Boolean isXLSMFile;   
        @AuraEnabled 
        public Boolean isExcelFile;    
        //Added 4-Aug-2022
        @AuraEnabled
        public String removedBy;
        @AuraEnabled 
        public String removedAt;
        @AuraEnabled
        public String docId;
        @AuraEnabled
        public Boolean isSoftDelete;
    }
    
    @AuraEnabled
    public static String getLoanUuid(String caseId) {        
        List<case> lstcase = [Select Id, Driva_UUID__c from case where Id =: caseId limit 1];
        String loanUuid;
        
        if(lstcase.size() > 0) {
            loanUuid = lstcase[0].Driva_UUID__c;
        }
        
        return loanUuid;
    }
    
    @AuraEnabled(continuation=true)
    public static Object callDeskAPI(String endpoint) {
        
        String result;
        String envName = 'desk';
        String host = System.URL.getSalesforceBaseUrl().getHost();
        if(host.contains('dev')){
            envName = 'desk-dev';
        }
        if(host.contains('staging')){
            envName = 'desk-staging';
        }
        if(host.contains('uat')){
            envName = 'desk-uat';
        }
        String url = 'https://'+envName+'.driva.com.au'+endpoint;
        String jwtToken = JWT.sign();
        System.debug('url: '+url);
        System.debug('jwtToken: '+jwtToken);
        Continuation con = new Continuation(40);
        // Set callback method
        con.continuationMethod='processResponse';
        // Set state
        con.state='Hello, World!';
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setHeader('Authorization', 'Bearer ' + jwtToken);
        // Add callout request to continuation
        con.addHttpRequest(req);
        // Return the continuation
        return con;
    }
    
    // Callback method
    @AuraEnabled
    public static Object processResponse(List<String> labels, Object state) {
        
        // Get the response by using the unique label
        HttpResponse response = Continuation.getResponse(labels[0]);        
        // Set the result variable
        if(response != null) {
            if(response.getBody()!= null) {
                system.debug('response.getBody() '+response.getBody() );
                return response.getBody();  
            }
        }
        return 'error';
    }

    @AuraEnabled 
    public static void softDeleteDocument(String docId){
        system.debug('docId+++'+docId);
        //Document_Library__c docLib = new Document_Library__c();
        //docLib = [SELECT Id,Removed_At__c,Removed_By__c,Soft_Delete__c from Document_Library__c where Id = : docId LIMIT 1];
        Document_Library__c updatedocLib = new Document_Library__c(Id = docId);
  
        updatedocLib.Soft_Delete__c = true;
        updatedocLib.Removed_By__c = userInfo.getName();
        updatedocLib.Removed_At__c = DateTime.now();
        UPDATE updatedocLib;
        
        syncDelete(docId); 
    }
    
    @AuraEnabled
    public static List<String> documentsList(String caseId){
        List<Document_Library__c> documentsList = new List<Document_Library__c>([SELECT case__c, Id,Document_Type__c FROM Document_Library__c where case__c =: caseId]); 
        List<String> docTypes = new List<String>();
        for(Document_Library__c doc:documentsList){
            docTypes.add(doc.Document_Type__c);
        }
        return docTypes;
    }

    @future(callout = true)
    public static void syncDelete(String docId){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        // Use NamedCredentials & callout to get Bearer JWT
        string url = 'callout:Salesforce_Service' + '/file/' + docId;
        system.debug('URl '+url);
        request.setEndpoint(url);
        request.setMethod('DELETE');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');        
        // Merge fields after setBody
        request.setHeader('Authorization', '{!$Credential.Password}');        
        request.setTimeout(120000);        
        HttpResponse response = http.send(request);

        //check the response
        if (response.getStatusCode() == 200) {
            System.debug('Sync to Driva DB successed');
            System.debug('Response body ' +response.getBody());
        } else {
            System.debug('Sync to Driva DB failed: ' + response);
        }
    }
}