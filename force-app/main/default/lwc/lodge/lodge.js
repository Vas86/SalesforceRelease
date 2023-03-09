/*************************** 
* @Name    lodge.js
* @Author   vasu@driva.com.au
* @Date     29/04/2022
* @description Handles FinanceOne API Pop up Lodgement logic
******************************************************
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-----------------------------------------------------------------------
*  1.0              Vasu      29/04/2022          Initial Creation 

****************************** */
import { LightningElement, api, wire, track } from 'lwc';
import getCaseDetail from '@salesforce/apex/LodgeController.getCaseDetail';
import callLodgeSelectAPI from "@salesforce/apexContinuation/LodgeController.callLodgeSelectAPI";
import callLodgeAPI from "@salesforce/apexContinuation/LodgeController.callLodgeAPI";
import { CloseActionScreenEvent } from 'lightning/actions';
import lodgeSelectUrl from '@salesforce/label/c.lodgeSelectUrl';
import FALLBACKACCOUNTID from '@salesforce/label/c.fallbackAccountId';// Need to create Custom Label
import Id from '@salesforce/user/Id';

export default class Lodge extends LightningElement {
    @api recordId;
    @track record;
    showContainer = false;
    showWarning = false;
    isLoading = true;
    isSuccess;
    sent = false;
    message;
    deepLink;
    lenderName;
    userId = Id;
    fallbackAccountId = FALLBACKACCOUNTID;
    @wire(getCaseDetail, { caseId: '$recordId'})
    wiredCase({ error, data }) {
        if (data) {
            this.record = data;
            this.callSelectApi();
        } else if (error) {
            console.log('error => ', error);
        }
    }
    callSelectApi(){
        callLodgeSelectAPI({ UUID : this.record.Driva_UUID__c}).then(response => {
            console.log('response=>', response);
            return JSON.parse(response);
        }).then(result => {
            console.log('result', JSON.stringify(result));
            if(!('success' in result)){
                this.showWarning = true;
                this.message = 'The current lender does not support API lodgements';
            }else{
               
                   
                if('sent' in result)
                    this.sent =result.sent; 
                   // this.message = 'The application has already been lodged';
                if('lenderName' in result)
                    this.lenderName = result.lenderName;
                if('lenderFeatures' in result && result.lenderFeatures.length == 0){
                    this.showWarning = true;
                    this.message = 'The current lender does not support API lodgements';
                }
                if('success' in result && result.success == false){
                    this.showWarning = true;
                    this.message = 'Failed to Lodge the Application. Please check with Admin';
                }
            }
            this.isLoading = false;
            this.showContainer = !this.showWarning ? true : false;
        }).catch(error =>{
            console.log('error=> ',error);
            this.isLoading = false;
            this.message = 'Something is wrong.';
        });
    }
    handleCancel(event) {
        // Add your cancel button implementation here
        this.dispatchEvent(new CloseActionScreenEvent());
        eval("$A.get('e.force:refreshView').fire();");
    }
    handleLodge(event) {
        this.callLodgeAPIUtility(this.userId);
    }
    callLodgeAPIUtility(userId){
        this.isLoading = true;
        callLodgeAPI({ UUID : this.record.Driva_UUID__c, userId,OwnerId: this.record.OwnerId}).then(response => {
            return JSON.parse(response);
        }).then(result => {
            console.log('result', JSON.stringify(result));
            this.message =  'Successfully lodged';
            if('deepLink' in result){
                //this.deepLink = '<a href="'+ result.deepLink + '" target="_blank"> '+ result.deepLink +' </a>';
                //Click here to view the lodgement in Finance One’s Portal
                this.deepLink = '<a href="'+ result.deepLink + '" target="_blank">'+ 'Click here to view the lodgement in '+ this.lenderName +'&#8217'+'s'+ '&nbsp'+ 'Portal</a>';
                //this.deepLink = '<a href="'+ result.deepLink + '" target="_blank">' + this.lenderName + ' LodgeURL</a>';
                this.isLoading = false;
            }else if(('success' in result && result.success == false) || !('success' in result)){
                if(result.message.includes('Salesforce userId')){
                    this.callLodgeAPIUtility(this.record.OwnerId);
                }else if(result.message.includes('Salesforce Case OwnerId')){
                    this.callLodgeAPIUtility(this.fallbackAccountId);
                }else{
                    this.showWarning = true;
                    this.message = 'message' in result ? result.message : 'Failed to Lodge the Application. Please check with Admin';
                    this.isLoading = false; 
                }
            }
        }).catch(error =>{
            console.log('error=> ',error);
            this.isLoading = false;
            this.message = 'Something is wrong.';
        });
        this.showContainer = false;
    }
}