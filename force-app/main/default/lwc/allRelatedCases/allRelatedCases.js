import { LightningElement,api,wire } from 'lwc';
import fetchRelatedCases from '@salesforce/apex/AllRelatedCasesController.fetchRelatedCases';
const columns = [
    { label: 'Case', fieldName: 'caseIdUrl' ,type:'url',typeAttributes:{label: { fieldName: 'caseNumber' },tooltip: {fieldName: 'caseNumber'}},sortable: "true"},
    //{ label: 'Subject', fieldName: 'caseUrl', type: 'url',typeAttributes:{label: { fieldName: 'Subject' },tooltip: {fieldName: 'Subject'}},sortable: "true" },
    { label: 'Contact', fieldName: 'contactUrl', type: 'url',typeAttributes:{label: { fieldName: 'contactName' },tooltip: {fieldName: 'contactName'}},sortable: "true" },
    { label: 'Partner Account', fieldName: 'partnerAccUrl', type: 'url',typeAttributes:{label: { fieldName: 'partnerAccName' },tooltip: {fieldName: 'partnerAccName'}},sortable: "true" },
    { label: 'Status', fieldName: 'caseStatus',sortable: "true" },
    { label: 'Lender', fieldName: 'caseLender',sortable: "true" },
    { label: 'Loan Amount', fieldName: 'caseLoanAmount',sortable: "true" },
    { label: 'Personal Loan', fieldName: 'casePersonalLoan',sortable: "true" },
    //{ label: 'Priority', fieldName: 'Priority',sortable: "true" },
    { label: 'Date/Time Opened', fieldName: 'createdDate', type: 'date',typeAttributes: {day: "numeric",month: "numeric",year: "numeric",hour: '2-digit',minute: '2-digit'},sortable: "true" },
    { label: 'Last Modified', fieldName: 'modifiedDate', type: 'date',typeAttributes: {day: "numeric",month: "numeric",year: "numeric",hour: '2-digit',minute: '2-digit'},sortable: "true" },
    
    //{ label: 'Owner', fieldName: 'OwnerName',sortable: "true" }
];
export default class AllRelatedCases extends LightningElement {
    @api recordId;
    caseData;
    columns = columns;
    sortBy;
    sortDirection;
    totalCases;
    title;

    //fetching the related cases 
    @wire(fetchRelatedCases, {caseId : '$recordId'})
    wiredRelatedCases ({error, data}) {
        if (data) {
            this.totalCases = data.length;
            this.title = "All Related Cases ("+this.totalCases+")";
            this.caseData = data;

        } else if (error) {
            // TODO: Data handling
        }
    }

    //sorting functionality
    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }
    
    //sorting functionality
    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.caseData));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.caseData = parseData;
    }    
}