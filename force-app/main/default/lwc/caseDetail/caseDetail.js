/*************************** 
* @Name    caseDetail.js
* @Author   vasu@driva.com.au
* @Date     22/08/2022
* @description Handles Case and contact details via LWC Refer AG- 2592 for details
******************************************************
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-----------------------------------------------------------------------
*  1.0              Vasu      22/08/2022          Initial Creation 
    

****************************** */
import { LightningElement, wire,api,track } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
//import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
//import CASE_OBJECT from '@salesforce/schema/Case';
//import CONTACTMOBILE_FIELD from '@salesforce/schema/Case.ContactMobile';



const FIELDS = [
  'OwnerId',
  'Partner_Account__c',
  'CaseNumber', 
  'Source__c', 
  'Status'  ,
  'AccountId', 
  'Sub_Status__c' ,
  'ContactMobile', 
  'Pre_Approval__c',
  'Contact_Email__c',
  'Assessment_Quality__c', 
  'Address__c',
  'Set_follow_up_date__c', 
  'Callback_Phone__c', 
  'Call_Experiment__c', 
  'Credit_Agent__c',
  'Follow_Up_Calls__c', 
  'Verification_Agent__c',
  'Opt_Out__c', 
  'Settlement_Agent__c' ,
  'Withdraw_Decline_Reason__c', 
  'Loan_Processor__c' ,
  'Lender_Switch_Reason__c',
  'Cars24_Potential_Withdraw__c',
  'Purchase_Intent__c',
  'Additional_Information__c', 
  'Personal_Loan__c',
  
  'Parent.Id',

  'Lead_Score__c'
 
  
];


export default class caseDetail extends LightningElement {
 
 
  @api recordId;
  /* Expose schema objects/fields to the template. */
  //accountObject = CASE_OBJECT;

  @api objectApiName;
  @track caseDetails = [];
    fields = FIELDS;
   
  @track mode = 'view';
  @track isLoading = true;
   
    
    handleSubmit(event) {      
      const fields = event.detail.fields;
      this.template.querySelector('lightning-record-form').submit(fields);
     
  }
  /* Load Case.Subject and Case.ContactMobile for custom rendering */
//@wire(getRecord, { recordId: '$recordId', fields: [CONTACTMOBILE_FIELD] })
//record;
/** Get the Case.ContactMobile value. */
//get contactMobileValue() {
//return this.record.data ? getFieldValue(this.record.data, CONTACTMOBILE_FIELD) : '';
//}
 
}