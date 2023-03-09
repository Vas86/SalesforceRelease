/*************************** 
* @Name    settlementDetails.js
* @Author   vasu@driva.com.au
* @Date     22/08/2022
* @description Handles settlement details via LWC Refer AG- 2592 for details
******************************************************
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-----------------------------------------------------------------------
*  1.0              Vasu      22/08/2022          Initial Creation 

****************************** */
import { LightningElement,api } from 'lwc';
const FIELDSSETTLEMENTS=[
  'Not_proceeding_with_dealer_partner__c', 
  'Ready_for_Rego__c', 
  'Help_Find_New_Car__c', 
  'Go_For_Delivery__c', 
  'Insurance_Received__c', 
  'PL_settled__c',
  'CGU_insured__c', 
  'Checkout_Date__c',
  'Incorrect_Handover__c', 
  'Is_Finance_First__c',
  'Credit_Handback__c',
  'Estimated_Delivery_Date__c',
  'First_Time_Settlement__c', 
  'Delivery_Booked_Date__c',
  'Post_settlement_complete__c', 
  'Registeration_Date__c', 
  'Incorrect_Settlement__c',
  'Cars24_Invoice_Received__c',
  'Counter_offer__c',
 
  'Vehicle_Referral__c',
  'Successful_Vehicle_Referral__c', 
  'Approval_Expiration_Date__c',

  'Post_lodgement_lender_request__c'  

   ]
export default class SettlementDetails extends LightningElement {
    @api recordId;
  @api objectApiName;
  mode = 'view';
    fieldsForSettlements= FIELDSSETTLEMENTS;
    handleSubmit(event) {      
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-form').submit(fields);
        
    }
}