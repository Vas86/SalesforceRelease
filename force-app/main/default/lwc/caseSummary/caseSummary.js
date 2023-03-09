import { LightningElement, wire,api,track } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import bootstrap from '@salesforce/resourceUrl/bootstrap';
import getCaseDetails from '@salesforce/apex/CaseSummaryController.getCaseDetails';

export default class CaseSummary extends LightningElement {
    @api recordId;
    @track caseDetails = [];
    accName ;
    @track isLoading = true;
    connectedCallback(){      
        Promise.all([
          loadStyle(this, bootstrap + '/bootstrap/bootstrap.css')
        ])  
    }
    @wire(getCaseDetails, { caseId: '$recordId'  })
    wiredCaseData({ error, data }) {
      if (data) {
        let caseArr = [];
        caseArr.push(data);
        console.log('Data', data);
        console.log('this.caseDetails', this.caseDetails);
        if(data.AccountId){
          this.accName = data.Account.Name;    
        }
        let mappedArray = [...caseArr].map(item => {
          let obj = Object.assign({}, item);
          console.log('obj.hasOwnProperty',obj.hasOwnProperty('Personal_Loan__c'));
          obj.asset_type = obj.hasOwnProperty('Personal_Loan__c')? 'N/A' : obj.Asset_Type__c ;
          obj.vehicle_year = obj.hasOwnProperty('Personal_Loan__c')? 'N/A' : obj.Vehicle_year__c ;
          obj.buying_car = obj.hasOwnProperty('Personal_Loan__c')? 'N/A' : obj.Buying_a_Car_From__c;
          if(obj.hasOwnProperty('Partner_Account__r') && obj.hasOwnProperty('Source__c')){            
            obj.lead_source = ''+obj.Partner_Account__r.Name + ' / ' + ''+obj.Source__c;
          }
          else if(obj.hasOwnProperty('Partner_Account__r')){     
            obj.lead_source = obj.Partner_Account__r.Name;
          }
          else if(obj.hasOwnProperty('Source__c')){  
            obj.lead_source = obj.Source__c;
          }
          return obj;
        }); 
        this.caseDetails = mappedArray; 
        this.isLoading = false;
      } else if (error) {
         console.error('Error:', error);
      }
    }
}