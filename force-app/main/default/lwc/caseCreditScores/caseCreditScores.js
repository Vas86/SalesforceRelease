/*************************** 
* @Name    CaseCreditScores.js
* @Author   vasu@driva.com.au
* @Date     29/07/2022
* @description Handles Case credit scores summarised view logic
******************************************************
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-----------------------------------------------------------------------
*  1.0              Vasu      29/07/2022          Initial Creation 

****************************** */
import { LightningElement,api,wire, track } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import bootstrap from '@salesforce/resourceUrl/bootstrap';
import getCaseCreditScoreDetails from '@salesforce/apex/CaseSummaryController.getCaseCreditScoreDetails';
export default class CaseCreditScores extends LightningElement {
    @api recordId;
    @track creditScores = [];
    @track isLoading = true;
    connectedCallback(){      
        Promise.all([
          loadStyle(this, bootstrap + '/bootstrap/bootstrap.css')
        ])  
    }
    @wire(getCaseCreditScoreDetails, { caseId: '$recordId'  })
    wiredCaseData({ error, data }) {
      if (data) {       
        console.log('Data 111', data);
        
        if(data.Comprehensive_Score__c){
            this.handleColor('Comprehensive :',data.Comprehensive_Score__c);
        }
        else{
            this.handleColor('Comprehensive :',0);
        }
        if(data.Veda_Score__c){
            this.handleColor('Veda Score :',data.Veda_Score__c);
        }
        else{
            this.handleColor('Veda Score :',0);
        }
        if(data.Equifax_One_Score__c){
            this.handleColor('One Score :',data.Equifax_One_Score__c);
        }
        else{
            this.handleColor('One Score :',0);
        }
      } else if (error) {
         console.error('Error:', error);
      }
    }
    handleColor(label,value){
        let creditObj = {
            name:null,value:null,class:null
        };
        creditObj.name = label;
        creditObj.value = value;
        if(value < 400){
            creditObj.class = 'icn-red';
        }
        else if(value >= 400 && value <600){
            creditObj.class = 'icn-yellow';
        }
        else{
            creditObj.class = 'icn-green';
        }
        this.creditScores.push(creditObj);
        console.log('creditObj : ',creditObj);
        console.log('this.creditScores : ',this.creditScores);
        this.isLoading = false;
    }
}