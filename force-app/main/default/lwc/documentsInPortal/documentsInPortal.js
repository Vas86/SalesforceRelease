import { LightningElement, api, track } from 'lwc';
import bootstrap from '@salesforce/resourceUrl/bootstrap';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import deleteDocumentsInPortalAPI from '@salesforce/apexContinuation/DocumentsInPortalController.deleteDocumentsInPortalAPI';

export default class DocumentsInPortal extends LightningElement {

  @track lenderDocuments = [];
  @track postApprovalDocuments = [];
  @track appSuppDocuments = [];
  @api documentsList;
  @api caseRecordId;
  isLoading = false;
  changeIcon = false;
  documentIds = [];
  documents = [];
  mandatoryDocs = ['Sales Invoice', 'Other', 'Credit File', 'Privacy Policy', 'Preliminary Assessment'];
  dataArr = [];
  headerToResponseMapping = new Map(Object.entries({
    'application': 'Application documents',
    'supporting': 'Application documents',
    'lenderRequested': 'Lender-requested documents',
    'postApproval': 'Post-approval documents',
    'other': 'Other'
  }));
  documentsWithCategory = [];
  connectedCallback() {

    Promise.all([
      loadStyle(this, bootstrap + '/bootstrap/bootstrap.css')
    ])
    console.log('documentsList : ', JSON.parse(JSON.stringify(this.documentsList)));
    //AG-3200
    'documentsList : ', JSON.parse(JSON.stringify(this.documentsList));
    //AG-3200
    this.modifyList();


  }
  modifyList() {
    let className;
    let allowDelete = false;
    let headerToDocNamesMapping = new Map();
    this.documentsList.filter(item => {
      let documents = [];
      let label = this.headerToResponseMapping.has(item.category) ? this.headerToResponseMapping.get(item.category) : '';
      if (label != '' && headerToDocNamesMapping.has(label)) {
        documents = [...headerToDocNamesMapping.get(label)];
      }
      //AG-3371
      let description = this.headerToResponseMapping.has(item.category) ? this.headerToResponseMapping.get(item.category) : '';
      if (description != '' && headerToDocNamesMapping.has(description)) {
        documents = [...headerToDocNamesMapping.get(description)];
      }
      //AG-3371
      if (item.isUploaded) {
        className = 'badge rounded-pill default-body ' + 'green-bkg';
      }
      else if (item.isLocked) {
        className = 'badge rounded-pill default-body ' + 'grey-bkg';
      }
      else if (item.isLocked == false && item.isUploaded == false) {
        className = 'badge rounded-pill default-body ' + 'red-bkg';
      }
      if (item.type == 2) {
        allowDelete = true;
        if (item.category == 'postApproval' && item.docType == 'Other')
          allowDelete = false;

      }
      documents.push({ name: item.name, docId: item.id, description: (item.description != null ? item.description : item.tooltip), color: className, enableDel: allowDelete, documentType: item.docType });
      headerToDocNamesMapping.set(label, documents);
      this.dataArr.push(item.docType);
    });
    let i = 0;
    this.mandatoryDocs.forEach(currentItem => {
      if (!this.dataArr.includes(currentItem)) {
        i += 1;
        let documents = [];
        let label = 'Other Documents'
        if (headerToDocNamesMapping.has(label)) {
          documents = [...headerToDocNamesMapping.get(label)];
        }
        documents.push({ name: currentItem, docId: 'temp ' + i + '', description: '', color: 'badge rounded-pill default-body light-grey-bkg', enableDel: false, documentType: currentItem });
        headerToDocNamesMapping.set(label, documents);
      }

    });

    let headerToDocNamesMappingSorted = new Map([...headerToDocNamesMapping.entries()].sort());
    headerToDocNamesMappingSorted.forEach((value, key) => {
      this.documentsWithCategory.push({ key, value });
    })

    return true;
  }
  handleUpdate() {
    // console.log('this.deleteDocumentsIds : ',this.documents);
    this.dispatchEvent(new CustomEvent('loadappevent'));
    //AG-3371
    // documentIds.push(item.docId);
    // desc = this.docDescription.hasOwnProperty(item.docId) ? this.docDescription[item.docId] : '';
    //documents.push({"documentId" : item.docId,  "description" : desc});
    //let deleteRequestPayloadObj = { documents};
    //AG-3371
    if (this.documentIds.length > 0) {
      // if(this.documents.length > 0 ){
      // deleteDocumentsInPortalAPI( { payload: JSON.stringify({documentIds : this.documentIds}), caseId : this.caseRecordId } )
      //  console.log('deleteRequestPayloadObj : ',deleteRequestPayloadObj);
      deleteDocumentsInPortalAPI({ payload: JSON.stringify({ documents: this.documentIds }), caseId: this.caseRecordId })
        .then(response => {
          this.isLoading = true;
          try {
            const responseObj = JSON.parse(response);
            if ('success' in responseObj && responseObj.success) {
              this.isLoading = false;
              this.showMsgs('Documents Deleted Successfully', 'success', 'Success');
              //window.location.reload();
              this.dispatchEvent(new CustomEvent('loadappevent'));
              this.isLoading = true;
            }
            else if ('success' in responseObj && responseObj.success == false || !('success' in responseObj)) {
              this.isLoading = false;
              this.showMsgs(responseObj.message, 'error', 'Error');
            }
          }
          catch (err) {
            console.log('err : ', err);
            this.isLoading = false;
            this.showMsgs('Failed to Delete Document. Please check with Admin', 'error', 'Error');
          }
        })
        .catch(error => {
          console.error('Error:', error);
          this.isLoading = false;
          this.showMsgs('Failed to Delete Document. Please check with Admin', 'error', 'Error');

        });
    }
    else {
      console.log('No Documents to delete');
    }
  }
  handleDelete(event) {

    let documentId = event.currentTarget.dataset.id;
    let documentDesc = event.currentTarget.dataset.desc;

    if (this.template.querySelector("[data-id='" + documentId + "']").classList.value.includes('glyphicon-plus')) {
      this.template.querySelector("[data-id='" + documentId + "']").classList.add('glyphicon-minus');
      this.template.querySelector("[data-id='" + documentId + "']").classList.remove('glyphicon-plus');
      let index = this.documentIds.indexOf(documentId);
      this.documentIds.splice(index, 1);
      this.documentIds = this.documentIds.filter(item => {
        return item.documentId != documentId;
      });
    }
    else {
      this.template.querySelector("[data-id='" + documentId + "']").classList.add('glyphicon-plus');
      this.template.querySelector("[data-id='" + documentId + "']").classList.remove('glyphicon-minus');
      if (!this.documentIds.includes(documentId))
        this.documentIds.push({ "documentId": documentId, "description": documentDesc });
    }
  }

  //this method is used to display toast messages
  showMsgs(message, varient, title) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message,
        variant: varient,
      }),
    );
  }

  @api
  refreshLWC(docListFromAura) {
    this.documentsList = docListFromAura;
    this.documentsWithCategory = [];
    let success = this.modifyList();
    if (success) {
      this.isLoading = false;
    }
  }
  // Added On 10-02/2023  || Start 
  handleSelect(event) {
    try {
      const selectEvent = new CustomEvent('selecteddocument', {
        detail: { docType: event.currentTarget.dataset.docType, docDescription: event.currentTarget.dataset.docDataValue },
      });
      this.dispatchEvent(selectEvent);
    } catch (error) {
      console.log(err);
    }
  }
  // Added On 10-02/2023  || End 

}