@isTest
public class s3downloadfileapexTest {
    
    static testMethod void fileDownload() {
        
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
        resume.File_Name__c = 'xyz\\.abc';
        resume.File_Type__c = 'image/jpeg';
        resume.Case__c = objcase.id;
        resume.Document_Type__c = 'Payslip One';   
        resume.Is_Deleted__c = true;
        resume.Expiration_Date__c = date.today().addDays(10);
        insert resume; 
        
        AmazonS3__c setting = new AmazonS3__c();
        setting.name='AmazonS3Credentials';
        setting.AmazonS3_Key__c = 'AKIAZQJDJDSPGNH35IWW';
        setting.AmazonS3_Secret__c = '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';
        setting.AmazonS3_BucketName__c = 'resonanttest2021';
        setting.AmazonS3_Host__c = 's3-us-west-2.amazonaws.com';
        insert setting;
        
        PageReference pageRef = Page.S3downloadfile; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(resume.Id));
        Test.setCurrentPage(pageRef);
        
        S3downloadfileapex obj = new S3downloadfileapex();
        obj.manageFile();
        obj.generateURL();
        //obj.backToRelatedListView();        
    }
    
}