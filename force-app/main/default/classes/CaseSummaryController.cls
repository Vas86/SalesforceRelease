/*************************** 
* @Name    CaseSummaryController
* @Author   vasu@driva.com.au
* @Date     29/07/2022
* @description Handles Case summary and credit scores sumamrised view logic
******************************************************
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-----------------------------------------------------------------------
*  1.0              Vasu      29/07/2022          Initial Creation 
   2.0              Vasu      22/08/2022           Refer: AG-2592 ( Get Email from Contact into new Case field Contact_Email__c )
   3.0              Vasu      22/08/2022           Refer: AG- 2498 ( New field on Case : Approval_Expiration_Date__c ) 

****************************** */
public class CaseSummaryController {
    @AuraEnabled(cacheable = true)
    public static Case getCaseDetails(String caseId){
       return [SELECT Id,Account.Name,Loan_Amount__c,Vehicle_year__c,Lender__c,Buying_a_Car_From__c,Employment_Status__c,Asset_Type__c,Assessment_Quality__c,
       Relationship_Status__c,Lead_Source__c,Personal_Loan__c,Owner.Name,OwnerId,CaseNumber, ParentId, Status, Sub_Status__c, Pre_Approval__c, Priority, Credit_Agent__c,
        Settlement_Agent__c, Loan_Processor__c, Source__c, Additional_Information__c, Partner_Account__c,Partner_Account__r.Name, Follow_Up_Calls__c, Call_Experiment__c,
         Opt_Out__c, ContactMobile, Callback_Phone__c, Set_follow_up_date__c, Origin, Withdraw_Decline_Reason__c, Cars24_Potential_Withdraw__c,Estimated_Delivery_Date__c,
          Warranty_Financed__c, Help_Find_New_Car__c, Checkout_Date__c, Is_Finance_First__c, Incorrect_Handover__c, Ready_for_Rego__c, Go_For_Delivery__c, 
          Cars24_Invoice_Received__c, Insurance_Received__c, First_Time_Settlement__c,AccountId,ContactEmail,Approval_Expiration_Date__c,Contact_Email__c,Verification_Agent__c,Lender_Switch_Reason__c
        FROM Case where Id = : caseId LIMIT 1];
    }
    
    @AuraEnabled(cacheable = true)
    public static Case getCaseCreditScoreDetails(String caseId){
        return [SELECT Id,Comprehensive_Score__c,Veda_Score__c,Equifax_One_Score__c FROM Case where Id = : caseId LIMIT 1];
        
    }
    @AuraEnabled(cacheable = true)
    public static String getContactId(String caseId){
        String accId;
        String conEmail;
        List<Case> caseRecord = new List<Case>([SELECT Id,AccountId,ContactEmail FROM Case where Id = : caseId LIMIT 1]);
        if(caseRecord.size() > 0 ){
            accId = caseRecord[0].AccountId;
            conEmail = caseRecord[0].ContactEmail;
        }
        if(accId != NULL){
            List<Contact> contactRecords = new List<Contact>([SELECT Id from Contact where AccountId = : accId and Email = : conEmail ORDER BY CreatedDate DESC LIMIT 1]);
            if(contactRecords.size() > 0 ){
                return contactRecords[0].Id;
            }
            else{
                return null;
            }
        }
        return null;
        
    }


}