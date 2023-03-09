/**
*	Description : Fetch the File link from AWS and Use on S3downloadfile VFP 
*	Author Name : Foram Rana (foram@resonantcloud.info)
*	Date : 13/12/2021
*
* @Test : S3downloadfileapexTest
**/

public class S3downloadfileapex {
    
    public String recid {get;set;}
    public String url {get;set;}
    public Boolean isPreview {get;set;} 
    public Boolean flag {get;set;} 
    public String strFolderName {get;set;}
    Document_Library__c objdoc;
    
    //constructor
    public s3downloadfileapex() {
        recid = Apexpages.currentPage().getParameters().get('id');  
        objdoc = [Select id, File_Name__c, Case__c from Document_Library__c where id =: recid];
    }
    
    public String manageFile() {
        
        
        System.debug('@@@ File_Name__c = '+objdoc.File_Name__c);
        String str = objdoc.File_Name__c;
        List<String> lstStr = str.split('\\.');
        
        if(lstStr.size() > 0) {            
            System.debug('@@@ isPreview = '+isPreview);
            System.debug('@@ lstStr = '+lstStr[1]);
            if(lstStr[1] == 'pdf' || lstStr[1] == 'sheet' || lstStr[1] == 'html' || lstStr[1] == 'htm' || 
              lstStr[1] == 'json' || lstStr[1] == 'xml') {

                if(isPreview == true) {
                    url = generateURL();
                    return url;
                }
                else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You can not Download this file'));
                }   
            }
            else{                
                
                if(isPreview == true) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You can not preview this file'));                    
                }
                else{
                    ApexPages.getMessages().clear();
                    
                    System.debug('@@@ in Png download');
                    
                    url = generateURL();
                    
                    System.debug('Pre Url : '+url);
                    return url;
                }       
            }          
        }
        return null;
    }
    
    
    public string generateURL() {
        //Download click
        String file = objdoc.File_Name__c;
        
        
        if(objdoc != null) {
            
            strFolderName = objdoc.Case__c;
        }
        
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
        return url  ;
    }
    
}