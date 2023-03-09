/*************************** 
* @Name    loanQuoteRecalculate.js
* @Author   vasu@driva.com.au
* @Date     22/06/2022
* @description Handles LoanQuote Recalculations, Calculate Pricing and Retrieve Scores 
******************************************************
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-----------------------------------------------------------------------
*  1.0              Vasu      22/06/2022          Initial Creation 

****************************** */
import { LightningElement, api, track, wire } from 'lwc';
import getCaseDetails from '@salesforce/apex/LoanDetailController.getCaseDetails';
import recalculateAPI from "@salesforce/apexContinuation/LoanDetailController.recalculateAPI";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateRecord from '@salesforce/apex/LoanDetailController.updateRecord';
import checkValidCaseStatus from '@salesforce/apex/LoanDetailController.checkValidCaseStatus';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import calculatePricingAPI from '@salesforce/apexContinuation/LoanDetailController.calculatePricingAPI';
import retrieveScoreAPI from '@salesforce/apexContinuation/LoanDetailController.retrieveScoreAPI';
import { refreshApex } from '@salesforce/apex';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import USER_ID from '@salesforce/user/Id';

const FIELDS = [//'Driva_UUID__c',
    'Lender__c',
    'Loan_Type__c',
    'Loan_Amount__c',
    'Loan_Class__c',
    'Vehicle_Price__c',
    'Loan_Term__c',
    'Deposit_Calc__c',
    'Asset_Type__c',
    'Trade_in_Finance_owing__c',
    'Cash_Deposit__c',
    'Trade_in_Value__c',
   //'Total_deposit_calculated__c' ,
    'Monthly_repayment__c',
    'Vehicle_year__c',
    'Interest_rate__c',
    'Buying_a_Car_From__c',
    'Comparison_rate__c',
    'Previous_Loan_Term_Remaining__c',
    'Monthly_Fees__c',
    'Previous_Monthly_Repayment__c',
    'Origination_fee__c',
    'Trade_In__c',
    'Brokerage_fee__c',
    'New_Loan_Balloon__c',
    'Employment_Status__c',
    'Balloon_Payment__c',
    'Time_in_Current_Employment_Years__c',
    'Balloon_payment_percentage__c',
    'Time_in_Current_Employment_Months__c',
    'Business_ABN__c',
    'Previous_Employment_Duration_Years__c',
    'Business_GST__c',
    'Previous_Employment_Duration_Months__c',
    'Business_Duration__c',
    'Residency_Status__c',
    'Living_situation__c',
    'Employment_Industry_Continuation__c' , 
    
    ];
export default class LoanQuoteRecalculate extends LightningElement {
    @track wiredCaseList = [];
    @api recordId;
    @api objectApiName;
    isLoading = false;
    isSaveLoading = false;
    data;
    mode = 'readonly';
    userEmailAddress;
    oldData = new Map();
    @track formFields;
    fields = FIELDS;
    isModalOpen = false;
    @track changedFields = new Map();
    fieldToPayloadMapping = new Map(Object.entries({
        'Driva_UUID__c': 'loanuuid',
        //'Lender__c': 'lender',
        'Lender__c': 'displayName',
        'Vehicle_Price__c': 'assetPrice',//need to confirm--loan amount is vehicle price - deposit
        'Deposit_Calc__c': 'deposit',
        'Loan_Term__c': 'term',
        'Loan_Type__c': 'loanType',
        'Loan_Class__c': 'loanClass',
        'Asset_Type__c': 'assetType',
        'Trade_in_Finance_owing__c':'tradeInFinanceOwing',
        'Cash_Deposit__c':'cashDeposit',
        'Trade_in_Value__c':'tradeInValue',
      // 'Total_deposit_calculated__c':'depositCalculatedTotal',
        'Time_in_Current_Employment_Years__c': 'businessDurationYears',
        'Employment_Status__c': 'employmentStatus',
        'Time_in_Current_Employment_Months__c': 'employmentDurationMonths',
        'Previous_Employment_Duration_Years__c': 'previousEmploymentDurationYears',
        'Previous_Employment_Duration_Months__c': 'previousEmploymentDurationMonths',
        'Employment_Industry_Continuation__c': 'employmentIndustryContinuation',
        'Business_Duration__c': 'businessDuration',
        'Business_ABN__c': 'businessAbn',
        'Business_GST__c': 'businessGst',
        'Living_situation__c': 'livingSituation',
        'Residency_Status__c': 'residencyStatus',
        'Buying_a_Car_From__c': 'buyingThrough',
        'Vehicle_year__c': 'vehicleYear',
        //'userEmail':'Email'
        'Email_user__c':'Email'
    }));

    responseOtherFieldsObj = new Map(Object.entries({
        'Monthly_Fees__c': 'monthlyFees',
        'Brokerage_fee__c': 'brokerageFee',
        'Interest_rate__c': 'interestRate',
        'Origination_fee__c': 'originationFee',
        'Balloon_payment_percentage__c': 'balloonPayment',
        'Monthly_repayment__c': 'monthly',
        'Comparison_rate__c': 'comparisonRate'
        
    }));
    responseToFieldsMapping = new Map();
    responseMapping = new Map(Object.entries({
        //'equifaxScore': 'Master_Score__c',
        'equifaxScore': 'Comprehensive_Score__c',
        'vedaScore': 'Veda_Score__c',
        'equifaxOneScore':'Equifax_One_Score__c'
    }));
    //21-June-2022
    calculatePricingResponseMapping = new Map(Object.entries({
        
        'monthly' : 'Monthly_repayment__c',
        'brokerage' : 'Brokerage_fee__c',
        'origination' : 'Origination_fee__c' ,
        'monthlyFee' : 'Monthly_Fees__c',
        'rate' : 'Interest_rate__c',
        'comparison' : 'Comparison_rate__c',
        'balloon' : 'Balloon_payment_percentage__c',
        'Loan_Term__c':'term'
    }))
    //21-June-2022
    @wire(getRecord, {recordId: USER_ID, fields: [EMAIL_FIELD]}) 
    wireuser({error,data}) {
        if (error) {
        this.error = error ; 
        } else if (data) {
        this.userEmailAddress = data.fields.Email.value;
        console.log('OUTPUT : ',this.userEmailAddress);
        }
    }

    //fetching the case data
    @wire(getCaseDetails, { recordId: '$recordId' })
    wiredRecord(result) {
        if (result.error) {
            let message = 'Unknown error';
            if (Array.isArray(result.error.body)) {
                message = result.error.body.map(e => e.message).join(', ');
            } else if (typeof result.error.body.message === 'string') {
                message = result.error.body.message;
            }
            this.showErrorMsg(message);
        } else if (result.data) {            
            this.wiredCaseList = result;
            this.mode = 'view';
            this.oldData = new Map(Object.entries(result.data));
            this.fieldToPayloadMapping.forEach((fieldAliasName, fieldAPIName) => {
                this.responseToFieldsMapping.set(fieldAliasName, fieldAPIName);
            });
            this.responseOtherFieldsObj.forEach((fieldAliasName, fieldAPIName) => {
                this.responseToFieldsMapping.set(fieldAliasName, fieldAPIName);
            });
            //}
            this.data = result.data;  
            console.log('this.data : ',this.data);           
        }
        console.log('responseToFieldsMapping : ',this.responseToFieldsMapping);
    }
    
    //this method is used to submit the record form
    handleSubmit(event) {
        event.preventDefault(); // stop the form from submitting
        console.log('Inside Submit : ');
        refreshApex(this.wiredCaseList);
        this.isSaveLoading = true;
        setTimeout(() => {
                let livingSituationValue = this.data.Contact.Living_situation__c;
                let residencyStatusValue = this.data.Contact.Residency_Status__c;
                checkValidCaseStatus({
                    recordId: this.recordId
                }).then(response => {
                    this.isSaveLoading = false;
                    if (!response) {
                        this.mode = 'view';
                        this.showErrorMsg('Not Valid status to change Lender related Information for Recalculating Loan Rates');
                        return false;
                    } else {
                        this.formFields = event.detail.fields;
                        const fields = new Map(Object.entries(event.detail.fields));
                        this.isLoading = false;
                        this.isModalOpen = true;
                        this.mode = 'readonly';
                        let self = this;
                        this.fieldToPayloadMapping.forEach(function (fieldAliasName, fieldAPIName) {
                            
                            if (fields.has(fieldAPIName)) {
                                let fieldValue = fields.get(fieldAPIName);
                               if (fieldAPIName == "Loan_Term__c") {
                                    fieldValue = fieldValue.replace(" Months", "");
                                   
                                }
                                self.changedFields.set(fieldAPIName, fieldValue);
                            } else {
                                self.changedFields.set(fieldAPIName, null);
                            }
                            if(fieldAPIName == 'Driva_UUID__c'){
                                self.changedFields.set("Driva_UUID__c", self.data.Driva_UUID__c); 
                            } 

                            if(fieldAPIName == 'Employment_Status__c'){

                                self.changedFields.set("Employment_Status__c", self.data.Employment_Status__c); 

                            }
                            //deposit read-only
                           // if(fieldAPIName == 'Deposit__c'){

                               // self.changedFields.set("Deposit__c", self.data.Deposit__c); 
                                
                          //  }
                            if(fieldAPIName == 'Living_situation__c'){
                                self.changedFields.set("Living_situation__c", livingSituationValue);
                            }
                            if(fieldAPIName == 'Residency_Status__c'){
                                self.changedFields.set("Residency_Status__c", residencyStatusValue);
                            }
        
                        });
                            this.changedFields.set("Email", this.userEmailAddress);
                    }
                }).catch(error => {
                    console.log('error=> ', error);
                    this.isLoading = false;
                    this.mode = 'view';
                    this.showErrorMsg('Something is wrong.');
                    console.log('error : ',error);
                });
        }, 2000);
        
    }
    handlerRecalculateRates(event) {
        this.isLoading = true;
        if(this.formFields){
            recalculateAPI({
                payload:
                    JSON.stringify(Object.fromEntries(this.changedFields)) //UUID: this.data.Driva_UUID__c
            }).then(response => {
                console.log('response', response);
                if (response) {
                    let responseObj = JSON.parse(response);
                    if (responseObj.hasOwnProperty('data') ){ //&& responseObj.data.hasOwnProperty('isEligible')) {
                        this.mode = 'readonly';
                        const caseObjToUpdate = this.makeCaseObject(responseObj);
                        if (typeof caseObjToUpdate == 'object') {
                            this.doCaseUpdate(caseObjToUpdate);
                        }
                        /*if (!this.makeCaseObject(responseObj)) {
                            this.mode = 'view';
                            this.isModalOpen = false;
                            this.showErrorMsg('Record Id not yet in the case object.');
                        } else {
                            this.doCaseUpdate(this.makeCaseObject(responseObj));
                        }*/
                    } else {
                        this.mode = 'view';
                        this.isModalOpen = false;
                        this.showErrorMsg('We could not found Valid data.');
                    }
                } else {
                    this.mode = 'view';
                    this.isModalOpen = false;
                    this.showErrorMsg('We could not found Valid response.');
                }
    
            }).catch(error => {
                console.log('error=> ', error);
                this.isLoading = false;
                this.mode = 'view';
                this.showErrorMsg('Something is wrong.');
            });
        }
        
    }

    //this method is used to update the case without calculating the rates
    handlerDoNotRecalculateRates() {
        this.template.querySelector('lightning-record-form').submit(this.formFields);
        this.isModalOpen = false;
        this.mode = 'view';
        this.showSuccessMsg('Case has been succesfully updated.');
    }
    //handling the model
    closeModal() {
        this.isModalOpen = false;
        this.mode = 'view';
        this.changedFields = new Map();
    }
    //showing the error messages
    showErrorMsg(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message,
                variant: 'error',
            }),
        );
    }
    //showing the success message
    showSuccessMsg(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message,
                variant: 'success',
            }),
        );
    }
    //this method is used to update the case
    doCaseUpdate(caseObj) {
        updateRecord({ record: caseObj }).then(result => {
            if (result == 'Success') {
                this.isLoading = false;
                this.isModalOpen = false;
                this.mode = 'view';
                this.showSuccessMsg('Case has been succesfully updated.');
                getRecordNotifyChange([{ recordId: this.data.Id }]);
            }
        }).catch(error => {
            console.log('error=> ', error);
            this.mode = 'view';
            this.isLoading = false;
            this.isModalOpen = false;
            this.showErrorMsg('Something is wrong.');
        });
    }
    //this method is used to make the case object for updation
    makeCaseObject(responseObj) {
        let caseObj = {};
        let responseObjKeys = [];
         //21-june-2022
         let arr = ['Monthly_repayment__c','Brokerage_fee__c','Origination_fee__c','Loan_Term__c','Interest_rate__c','Comparison_rate__c','Balloon_payment_percentage__c','Monthly_Fees__c']; //21-June-2022
        console.log('this.responseToFieldsMapping : ',this.responseToFieldsMapping) ;  
         //21-june-2022 -dynamic update
         let isEmptyOrNot =  (responseObj.data.hasOwnProperty('code') && responseObj.data.code == 1000);  
        console.log('isEmptyOrNot : ',isEmptyOrNot);
        if(isEmptyOrNot){
            arr.forEach(element => {
                caseObj[element] = null;
                responseObjKeys.push(element);
            });
            console.log('caseObj : ',caseObj);
        }
         //21-june-2022 -dynamic update
        for (let [key, value] of Object.entries(responseObj.data)) {
            //dynamic update
            if (this.responseToFieldsMapping.has(key) && !(isEmptyOrNot && arr.includes(this.responseToFieldsMapping.get(key)) )) {
                //dynamic update
           // if (this.responseToFieldsMapping.has(key)) {
               // responseObjKeys.push(this.responseToFieldsMapping.get(key))
               responseObjKeys.push(this.responseToFieldsMapping.get(key));
                if (this.responseToFieldsMapping.get(key) == 'Loan_Term__c') {
                   value += "";
                }
                if (this.responseToFieldsMapping.get(key) == 'Balloon_payment_percentage__c') {
                    value += "%";
                }

                //21-june-2022-hardcoded
              /*  if(responseObj.data.hasOwnProperty('code') && responseObj.data.code == 1000){   
                      //21-June-2022
                     /* if (arr.includes(this.responseToFieldsMapping.get(key)) ) {
                        value = null;
                    }   
                    }*/
                    /* monthly,brokerage,origination,monthlyFee,comparison,balloon 
                    if(!responseObj.data.hasOwnProperty('rate')){
                        caseObj['Interest_rate__c'] = null;
                    }  
                    if(!responseObj.data.hasOwnProperty('monthly')){
                        caseObj['Monthly_repayment__c'] = null;
                    }  
                    if(!responseObj.data.hasOwnProperty('brokerage')){
                        caseObj['Brokerage_fee__c'] = null;
                    }  
                    if(!responseObj.data.hasOwnProperty('origination')){
                        caseObj['Origination_fee__c'] = null;
                    }  
                    if(!responseObj.data.hasOwnProperty('comparison')){
                        caseObj['Comparison_rate__c'] = null;
                    }  
                    if(!responseObj.data.hasOwnProperty('monthlyFee')){
                        caseObj['Monthly_Fees__c'] = null;
                    }  
                    if(!responseObj.data.hasOwnProperty('balloon')){
                        caseObj['Balloon_payment_percentage__c'] = null;
                    } 
                          
                }*/
                //21-june-2022-hard coded
                caseObj[this.responseToFieldsMapping.get(key)] = value;
            }
            
           
        }
        console.log('responseObjKeys : ',responseObjKeys);
        if(responseObjKeys.length > 0 ){
            let changeFieldsKeys = Object.keys(Object.fromEntries(this.changedFields));
            let difference = changeFieldsKeys.filter(x => responseObjKeys.indexOf(x) === -1);
            difference.forEach(obj => {
                caseObj[obj] = this.changedFields.get(obj);
        });
        if(caseObj.hasOwnProperty('Living_situation__c')){
            delete caseObj.Living_situation__c;
        }
        if(caseObj.hasOwnProperty('Residency_Status__c')){
            delete caseObj.Residency_Status__c;
        }
        if(caseObj.hasOwnProperty('email')){
            delete caseObj.email;
        }
        console.log('caseObj : ',caseObj);
        }
        else{
            this.handlerDoNotRecalculateRates();
            return false;
        }

        const iscaseObjEmpty = Object.keys(caseObj).length === 0;
        if (!iscaseObjEmpty) {
            caseObj['Id'] = this.data.Id;
            return caseObj;
        }

        return false;

    }
    //this method will make a call to Calculate Pricing API and showing toast messages acc to respone
    //AG-2992 Error Updates
    handleCalculatePricing(event){
        this.isSaveLoading = true;
        //dynamic update
        refreshApex(this.wiredCaseList);
        setTimeout(() => {
            //dynamic update
        let calculatePricePayloadObj = {"loanUuid":this.data.Driva_UUID__c,
                                        "email": this.userEmailAddress}//"status":this.data.status}//21-june-2022
        calculatePricingAPI({
            payload:JSON.stringify(calculatePricePayloadObj)
        }).then(response => {
            console.log('Result', response);
            try{
                const responseObj = JSON.parse(response);
                if( 'success' in responseObj && responseObj.success == true ){

                    this.isSaveLoading = false;
                    this.doCaseUpdate(this.makeCaseObjForCalculatePricing(responseObj)); //21-June-2022
                    //this.showSuccessMsg('Succesfully Calculated Pricing');
                }
                else if(('success' in responseObj && responseObj.success == false) || !('success' in responseObj)){
                    this.isSaveLoading = false;
                    this.showErrorMsg('Failed to Calculate Pricing. Please check with Admin');
                }
                setTimeout(()=>{ eval("$A.get('e.force:refreshView').fire();"); }, 5000);
            }
            catch(err){
                this.isSaveLoading = false;
                this.showErrorMsg('Failed to Calculate Pricing. Please check with Admin');               
            }            
        }).catch(error => {
            this.isSaveLoading = false;
            console.error('Error:', error);  
            this.showErrorMsg('Failed to Calculate Pricing. Please check with Admin');          
          });
          //dynamic update
        },2000);
        //dynamic update
    }
    //this method will make a call to Retrieve Score API and showing toast messages acc to respone
    handleRetrieveScore(event){
        this.isSaveLoading = true;
        retrieveScoreAPI({UUID :this.data.Driva_UUID__c}).then(response => {
            console.log('Result', response);
            try{
                const responseObj = JSON.parse(response);                
                if( 'success' in responseObj && responseObj.success == true ){
                    this.isSaveLoading = false;
                    this.doCaseUpdate(this.makeCaseObjForRetrieveScore(responseObj));
                }
                else if(('success' in responseObj && responseObj.success == 'false') || !('success' in responseObj)){
                    this.isSaveLoading = false;
                    //this.showErrorMsg('Credit scores last retrieved within 30 days. If you believe the customer score has changed, please reach out to product');
                    this.showErrorMsg(responseObj.error);
                }
            }
            catch(err){
                this.isSaveLoading = false;
                //this.showErrorMsg('Failed to Retrieve Score. Please check with Admin');
                this.showErrorMsg(responseObj.error);
            }
        }).catch(error => {
            this.isSaveLoading = false;
            console.error('Error:', error);
           // this.showErrorMsg('Credit scores last retrieved within 30 days. If you believe the customer score has changed, please reach out to product');
           this.showErrorMsg(responseObj.error);
            });
    }
    //this method will make a case object to update as per the response received from Retrieve Score API
    makeCaseObjForRetrieveScore(responseObj){
        let caseObj = {}
        for (let [key, value] of Object.entries(responseObj.data)){
            if (this.responseMapping.has(key)) {
                if(this.responseMapping.get(key) == 'Master_Score__c'){
                    value = parseFloat(value);
                }
                caseObj[this.responseMapping.get(key)] = value;
            }
        }
        const iscaseObjEmpty = Object.keys(caseObj).length === 0;
        if (!iscaseObjEmpty) {
            caseObj['Id'] = this.data.Id;
            return caseObj;
        }
        return false;
    }
    // case object for calculate pricing (21-June-2022)
    makeCaseObjForCalculatePricing(responseObj){
        let caseObj = {};
        for(let [key,value] of Object.entries(responseObj.data)){
            if(this.calculatePricingResponseMapping.has(key)){
                caseObj[this.calculatePricingResponseMapping.get(key)] = value;
            }
        }
        if(!responseObj.data.hasOwnProperty('rate')){
            caseObj['Interest_rate__c'] = null;
        }
        const iscaseObjEmpty = Object.keys(caseObj).length === 0;
        if (!iscaseObjEmpty) {
            caseObj['Id'] = this.data.Id;
            return caseObj;
        }
        return false;
    }
    //21-june-2022

    handleQuote(){
        window.open("/apex/QuoteEmailButton"+"?id="+this.recordId);
        
    }
}