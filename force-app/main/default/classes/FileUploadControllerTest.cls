/**
*   Description : Test Class for FileUploadController
*   Author Name : Vasu Velgoti ( updated the Test class)
*   Date : 26/09/2022 
*
**/

@isTest
public class FileUploadControllerTest {
    
    @isTest
    public static void testMethod1() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account a = new account();
        a.name = 'Test';
        insert a;       
        
        Contact c = new contact();
        c.lastname='Test';
        insert c;
        
        Case objcase = new Case();
        objcase.Status = 'Received';
        objcase.Origin = 'Phone';
        //objcase.Contact.Id = c.Id;
        insert objcase;
        
        Document_Library__c resume = new Document_Library__c();
        resume.File_Name__c = 'xyz';
        resume.File_Type__c = 'image/jpeg';
        resume.Case__c = objcase.id;
        resume.Document_Type__c = 'Credit File';   
        resume.Is_Deleted__c = true;
        resume.Expiration_Date__c = date.today().addDays(10);
        resume.Case__c = objcase.Id;
        insert resume; 
        resume.Document_Type__c = 'Payslip One';  
        resume.File_Name__c = 'abc';
        update resume;
        
        
        AmazonS3__c setting = new AmazonS3__c();
        setting.name='AmazonS3Credentials';
        setting.AmazonS3_Key__c = 'AKIAZQJDJDSPGNH35IWW';
        setting.AmazonS3_Secret__c = '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';
        setting.AmazonS3_BucketName__c = 'resonanttest2021';
        setting.AmazonS3_Host__c = 's3-us-west-2.amazonaws.com';
        insert setting;
        
        List<String> testLabels= new List<String>(10);
        Object testState = 10;
        
        date dt = System.today();
       
        FileUploadController uf = new FileUploadController();
        FileUploadController.fetchDocType(objcase.Id);
         Test.startTest();
        FileUploadController.fetchFileURL('Payslip One', objcase.Id);
        FileUploadController.fetchFolderNameFromCase(objcase.Id);
        FileUploadController.getLoanUuid(objcase.Id);   
        FileUploadController.awsInfoDetails();
        //FileUploadController.getCreditFileNew(objcase.Id);
        FileUploadController.createDocumentRecord('test', 'image/jpeg', objcase.Id, 'Payslip One');
        FileUploadController.callDeskAPI('/privacyPolicy');
        FileUploadController.processResponse(testLabels, testState);
        //FileUploadController.softDeleteDocument(resume.Id,resume.Name);
         FileUploadController.softDeleteDocument(resume.Id);
        FileUploadController.documentsList(objcase.Id);
        //FileUploadController.SaveFile(objcase.Id, 'test', 'test', 'image/jpeg', 'Payslips');        
        //FileUploadController.calloutUploadS3File('attachmentBody','filename','application/pdf',setting.AmazonS3_Key__c, setting.AmazonS3_Secret__c, setting.AmazonS3_BucketName__c, setting.AmazonS3_Host__c);
        //FileUploadController.deleteFile(objcase.Id, 'test', 'Payslips');
        DrivaAPI.createUpdate('test', 'test');
        DrivaAPI.deleteObject('test', 'test');        
        Test.stopTest();
        
        list<Contact> con = [select Id from Contact];
        System.assertEquals(1, con.size());
    }
    
}