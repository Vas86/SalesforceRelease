import { LightningElement,api,wire, track } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import bootstrap from '@salesforce/resourceUrl/bootstrap';
//import getCaseCreditScoreDetails from '@salesforce/apex/CaseSummaryController.getRelatedQuickLinks';
export default class relatedQuickLinks extends LightningElement {
    @api recordId;
    //@track creditScores = [];
    @track isLoading = true;
    connectedCallback(){      
        Promise.all([
          loadStyle(this, bootstrap + '/bootstrap/bootstrap.css')
        ])  
    }
}