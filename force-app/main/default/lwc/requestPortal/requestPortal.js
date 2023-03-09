import { LightningElement, wire, track, api } from 'lwc';
import fetchDocuments from '@salesforce/apexContinuation/RequestPortalController.fetchDocuments';
import bootstrap from '@salesforce/resourceUrl/bootstrap';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import submitRequestAPI from '@salesforce/apexContinuation/RequestPortalController.submitRequestAPI';
import createNewDocAPI from '@salesforce/apexContinuation/RequestPortalController.createNewDocAPI';
import fetchDocType from '@salesforce/apexContinuation/FileUploadController.fetchDocType';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const obj = {
    docName: null,
    docId: null,
};
export default class RequestPortal extends LightningElement {
    @api recordId;
    @track selectedDocumentId;
    @track otherDocuments;
    @track searchKey;
    @track allDocuments;
    @track filterDocuments;
    @track selectedDocs = [];
    @track isLoading = true;
    @track isModelOpen = false;

    @track newDocument;
    @track newDocumentDesc;
    @track existingDocumentDesc;
    @track newDocumentActionType = this.actionTypes[0].value;
    @track newDoc;
    @track isCheck = false;
    @track searchCategory;


    docDescription = {};
    selectedDocId = null;
    selectedDocName = null;
    selectedPreValue = null;
    isDDModelOpen = false;
    connectedCallback() {
        Promise.all([
            loadStyle(this, bootstrap + '/bootstrap/bootstrap.css')
        ])

        //Added 20/01/2023
        fetchDocType({caseId : this.recordId})
            .then(result => {
                let responseObj = JSON.parse(result);
                console.log('responseObj>>',responseObj);
                if (responseObj.hasOwnProperty('data')) {
                   this.otherDocuments = responseObj.data.documents;
                   console.log('this.otherDocuments**>>',this.otherDocuments);
                }
            })
            .catch(error => {
                console.error('Error:', error);
        });


        fetchDocuments()
            .then(result => {
                let responseObj = JSON.parse(result);
                if (responseObj.hasOwnProperty('data')) {
                    let mappedArray = JSON.parse(JSON.stringify(responseObj.data.documents)).map(item => {
                        let obj = Object.assign({}, item);
                        obj.isSelected = false;
                        obj.isDisplay = true;
                        return obj;
                    });

                    this.allDocuments = mappedArray;
                    this.filterDocuments = mappedArray;
                    this.isLoading = false;
                    console.log('this.filterDocuments : ', this.filterDocuments);
                }
                console.log('Result', responseObj.data.documents);

            })
            .catch(error => {
                console.error('Error:', error);
            });
        }

    

    //this method will search the requested documents
    handleSearch(event) {
        console.log('Search : ');
        if (event.target.name == "category") {
            this.searchCategory = event.target.value;
        }
        if (event.currentTarget.dataset.name == "search") {
            this.searchKey = event.target.value;
        }
        let mappedArray = JSON.parse(JSON.stringify(this.filterDocuments)).map(item => {
            let obj = Object.assign({}, item);
            let searchByName = true;
            let searchByCategory = true;
            if (this.searchKey && this.searchKey.length > 0) {
                console.log('this.searchKey : ', this.searchKey);
                searchByName = obj.name.toLowerCase().includes(this.searchKey.toLowerCase());
            }
            if (this.searchCategory && this.searchCategory.length > 0) {
                console.log('this.searchCategory && this.searchCategory.length > 0  : ');
                searchByCategory = obj.category.toLowerCase().includes(this.searchCategory.toLowerCase());
            }
            obj.isDisplay = searchByName && searchByCategory;
            return obj;

        });
        console.log('mappedArray : ', mappedArray);
        this.filterDocuments = JSON.parse(JSON.stringify(mappedArray));
    }

    //this method is pushing-deleting the documents from list depending on value of checkbox
    handleChecked(event) {
        let checkedDoc = event.target.value;
        let selectedId = event.currentTarget.dataset.id;
        this.selectedDocumentId = event.currentTarget.dataset.id;
        if (event.target.checked) {
            let selected = true;
            obj.docName = checkedDoc;
            obj.docId = selectedId;
            let newDocArr = JSON.parse(JSON.stringify(this.selectedDocs));
            newDocArr.push(JSON.parse(JSON.stringify(obj)));
            this.selectedDocs = newDocArr;
            this.handleSelectUnselect(selectedId, selected);
        }
        else {
            let newArray = this.selectedDocs.filter(item => {
                return item.docId != selectedId;
            });
            this.selectedDocs = newArray;
            let selected = false;
            this.handleSelectUnselect(selectedId, selected);
        }
    }

    //this method is displaying the selected documents on the 2nd card/panel
    get selectedDocument() {
        return this.selectedDocs;
    }

    //this method is maintaining the state of checkboxes
    handleSelectUnselect(selectedId, selected) {
        console.log('selected index==>', selectedId);
        console.log('selected ==>', selected);
        let filterTempArr = JSON.parse(JSON.stringify(this.filterDocuments));
        filterTempArr.filter(item => {
            if (item.id == selectedId) {
                item.isSelected = selected;
            }
        });
        this.filterDocuments = filterTempArr;

    }

    //this method is calling the Submit Request API
    handleSubmit() {
        console.log('===', JSON.stringify(this.selectedDocs));
        if (this.selectedDocs.length > 0) {
            this.isLoading = true;
            let documentIds = [];
            let documents = [];
            let desc = '';
            this.selectedDocs.filter(item => {
                documentIds.push(item.docId);
                desc = this.docDescription.hasOwnProperty(item.docId) ? this.docDescription[item.docId] : '';
                documents.push({ "documentId": item.docId, "description": desc });
            });
            let submitRequestPayloadObj = { documents };
            console.log('submitRequestPayloadObj : ', submitRequestPayloadObj);
            submitRequestAPI({ payload: JSON.stringify(submitRequestPayloadObj), caseId: this.recordId })
                .then(response => {
                    console.log('response : ', response);
                    try {
                        const responseObj = JSON.parse(response);
                        if ('success' in responseObj && responseObj.success == true) {
                            this.isLoading = false;
                            this.showMsgs('Documents Uploaded Successfully', 'success', 'Success');
                        }
                        else if (('success' in responseObj && responseObj.success == false) || !('success' in responseObj)) {
                            this.isLoading = false;
                            this.showMsgs(responseObj.message, 'error', 'Error');
                        }
                        this.selectedDocs = [];
                        this.restoreState();
                        this.filterDocuments = JSON.parse(JSON.stringify(this.allDocuments));
                    }
                    catch (err) {
                        this.isLoading = false;
                        console.error('Error:', err);
                        this.showMsgs('Failed to Submit Document. Please check with Admin', 'error', 'Error');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    this.isLoading = false;
                    this.showMsgs('Failed to Submit Document. Please check with Admin', 'error', 'Error');
                });
        }
        else {
            this.showMsgs('Select atleast 1 document to request', 'error', 'Error');
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

    //opening pop up for new document 
    handleNewDoc() {
        this.isModelOpen = true;
        this.isCheck = false;
        this.newDocument = null;
        this.newDocumentDesc = null;
        this.newDocumentActionType = this.actionTypes[0].value
    }

    //opening pop up for written request document
    handlePopUpEdit(event) {
        this.isDDModelOpen = true;
        //this.isCheck = false;
        this.selectedDocId = event.currentTarget.dataset.id;
        this.selectedDocName = event.currentTarget.dataset.name;
        
        //added 20-01-2023
        const obj = this.filterDocuments.find( item => item.id == this.selectedDocId);   
        const objdata = this.otherDocuments.find( item => item.id == this.selectedDocId);
        try{
            if(!this.docDescription.hasOwnProperty(this.selectedDocId)){
                if ( objdata != undefined && objdata.hasOwnProperty('description') && objdata.description != null) {
                    this.docDescription[this.selectedDocId] = objdata.description;
                    this.selectedPreValue = objdata.description;
                }else if ( objdata != undefined && objdata.hasOwnProperty('tooltip') && objdata.tooltip != null) {
                    this.docDescription[this.selectedDocId] = objdata.tooltip;
                    this.selectedPreValue = objdata.tooltip;
                }else if (obj.hasOwnProperty('description') && obj.description != null) {
                    this.docDescription[this.selectedDocId] = obj.description;
                    this.selectedPreValue = obj.description;
                }else if (obj.hasOwnProperty('tooltip') && obj.tooltip != null) {
                    this.docDescription[this.selectedDocId] = obj.tooltip;
                    this.selectedPreValue = obj.tooltip;
                }
        }else{
            this.selectedPreValue = this.docDescription[this.selectedDocId];
        }
        }catch(err){
            console.log(err);
        }
        
        



        //added 17-01-2023
        /*const obj = this.filterDocuments.find( item => item.id == this.selectedDocId);      
        if(!this.docDescription.hasOwnProperty(this.selectedDocId)){
                if (obj.hasOwnProperty('description') && obj.description != null) {
                    this.docDescription[this.selectedDocId] = obj.description;
                    this.selectedPreValue = obj.description;
                } else if (obj.hasOwnProperty('tooltip') && obj.tooltip != null) {
                    this.docDescription[this.selectedDocId] = obj.tooltip;
                    this.selectedPreValue = obj.tooltip;
                }
        }else{
            this.selectedPreValue = this.docDescription[this.selectedDocId];
        }*/
        
               
       
    }

    handleCancel() {
        this.isModelOpen = false;
        this.isDDModelOpen = false;
        this.docDescription[this.selectedDocId] = this.selectedPreValue;
    }

    handlePostApprove(event) {
        this.isCheck = event.target.checked;
    }

    get actionTypes() {
        return [
            { label: 'Upload a document', value: 'UPLOAD_DOCUMENT' },
            { label: 'Trigger Bank Statements', value: 'TRIGGER_BANKSTATEMENTS' },
            { label: 'Written request', value: 'DYNAMIC_FIELDS' },
        ];
    }

    handleActionType(event) {
        this.newDocumentActionType = event.detail.value
    }

    handleDocNameDesc(event) {
        console.log('vent.target.name ', event.target.name);
        console.log('this.selectedDocId ', this.selectedDocId);
        console.log('vent.target.value ', event.target.value);
        if (event.target.name == "Document Name") {
            this.newDocument = event.target.value;
        } else if (event.target.name == "doc_desc") {
            if (event.target.value) {
                this.docDescription[this.selectedDocId] = event.target.value;                
            }

        } else {
            this.newDocumentDesc = event.target.value;
        }
        if (!event.target.value) {
            event.target.setCustomValidity(event.currentTarget.dataset.errormsg);

        } else {
            event.target.setCustomValidity('');
        }
        event.target.reportValidity();
    }

    handleValidations() {
        let docName = this.template.querySelector('.docName');
        if (!this.newDocument) {
            docName.setCustomValidity('Enter document name to be added to document list and portal');
        } else {
            docName.setCustomValidity('');
        }
        docName.reportValidity();

        let docDesc = this.template.querySelector('.docDesc');
        if (!this.newDocumentDesc) {
            docDesc.setCustomValidity('Enter description to explain documents requirements to customer');
        } else {
            docDesc.setCustomValidity('');
        }
        docDesc.reportValidity();
    }

    handleCreate() {
        this.handleValidations();
        console.log('this.newDocument : ', this.newDocument);
        console.log('this.newDocumentDesc : ', this.newDocumentDesc);
        if (this.newDocument != null && this.newDocumentDesc != null) {
            this.isModelOpen = false;
            this.isLoading = true;

            //calling the Create New Document API
            let createNewPayloadObj = {
                "name": this.newDocument,
                "tooltip": this.newDocumentDesc,
                "category": this.isCheck == true ? "postApproval" : "lenderRequested",
                actionType: this.newDocumentActionType
            }
            createNewDocAPI({ payload: JSON.stringify(createNewPayloadObj) })
                .then(response => {
                    try {
                        const responseObj = JSON.parse(response);
                        console.log('responseObj : ', responseObj);
                        if ('success' in responseObj && responseObj.success == true) {
                            this.isLoading = false;
                            this.makeDocObj(responseObj);
                        }
                        else if (('success' in responseObj && responseObj.success == false) || !('success' in responseObj)) {
                            this.isLoading = false;
                            //this.isModelOpen = false;
                            this.showMsgs(responseObj.message, 'error', 'Error');
                        }
                        this.restoreState();
                        let mappedArray = JSON.parse(JSON.stringify(this.filterDocuments)).map(item => {
                            let obj = Object.assign({}, item);
                            obj.isDisplay = true;
                            return obj;
                        });
                        this.filterDocuments = mappedArray;

                    }
                    catch (err) {
                        this.isLoading = false;
                        this.showMsgs('Failed to Create New Document. Please check with Admin', 'error', 'Error');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    this.isLoading = false;
                    this.showMsgs('Failed to Create New Document. Please check with Admin', 'error', 'Error');
                });
        }
    }
    /* written request popup 
    handleContinue(){
        this.handleValidations();
        console.log('this.newDocument : ',this.newDocument);
        console.log('this.newDocumentDesc : ',this.newDocumentDesc);
        if(this.newDocument != null && this.newDocumentDesc != null){
            this.isModelOpen = false;
            this.isLoading = true;
            
            //calling the Create New Document API
            let createNewPayloadObj = {
                "name": this.newDocument,
                "tooltip": this.newDocumentDesc,
                "category": this.isCheck == true ? "postApproval" : "lenderRequested",
                actionType: this.newDocumentActionType
              }
            updateNewDocAPI({ payload: JSON.stringify(createNewPayloadObj) })
              .then(response => {
                try{
                    const responseObj = JSON.parse(response);       
                    console.log('responseObj : ',responseObj);         
                    if( 'success' in responseObj && responseObj.success == true ){
                        this.isLoading = false;
                        this.makeDocObj(responseObj);
                    }
                    else if(('success' in responseObj && responseObj.success == false) || !('success' in responseObj)){
                        this.isLoading = false;
                        //this.isModelOpen = false;
                        this.showMsgs(responseObj.message,'error','Error');
                    }
                    this.restoreState();
                    let mappedArray = JSON.parse(JSON.stringify(this.filterDocuments)).map(item => {
                        let obj = Object.assign({}, item);
                        obj.isDisplay = true;
                        return obj;
                      });
                    this.filterDocuments = mappedArray;
                    
                }
                catch(err){
                    this.isLoading = false;
                    this.showMsgs('Failed to Create New Document. Please check with Admin','error','Error');
                }
              })
              .catch(error => {
                console.error('Error:', error);
                this.isLoading = false;
                this.showMsgs('Failed to Create New Document. Please check with Admin','error','Error');
            });
        }
    }
    written request popup*/

    handleRemove(event) {
        let documentId = event.currentTarget.dataset.id;
        let newArray = this.selectedDocs.filter(item => {
            return item.docId != documentId;
        });
        this.selectedDocs = newArray;

        let filterDocTempArr = JSON.parse(JSON.stringify(this.filterDocuments));
        filterDocTempArr.filter(item => {
            if (item.id == documentId) {
                item.isSelected = false;
            }
        });
        this.filterDocuments = filterDocTempArr;
    }
    handleClose() {
        this.isModelOpen = false;
        this.isDDModelOpen = false;
        this.docDescription[this.selectedDocId] = this.selectedPreValue;
    }

    makeDocObj(responseObj) {
        let docObj = {}
        for (let [key, value] of Object.entries(responseObj.data)) {
            docObj[key] = value;
        }
        // docObj['isSelected'] = this.isCheck == true ? true : false ; 
        docObj['isSelected'] = true;
        console.log('docObj : ', docObj);
        //if(this.isCheck){
        obj.docName = responseObj.data.name;
        obj.docId = responseObj.data.id;
        let newArr = JSON.parse(JSON.stringify(this.selectedDocs));
        newArr.push(JSON.parse(JSON.stringify(obj)));
        this.selectedDocs = newArr;
        // }

        let newFilArr = JSON.parse(JSON.stringify(this.filterDocuments));
        newFilArr.push(JSON.parse(JSON.stringify(docObj)));
        this.filterDocuments = newFilArr;

        console.log('new all doc==>', this.allDocuments);
        console.log('new filter doc==>', this.filterDocuments);
        this.isModelOpen = false;
        this.showMsgs('Document Successfully Created', 'success', 'Success');
    }
    restoreState() {
        this.searchKey = "";
        this.searchCategory = "";
        this.template.querySelector('lightning-input[data-name="search"]').value = '';
        this.template.querySelector('select').value = "";

    }
    get documentDescription() {
        console.log('-->>',this.docDescription[this.selectedDocId]);
        return this.selectedDocId != null && this.docDescription.hasOwnProperty(this.selectedDocId) ? this.docDescription[this.selectedDocId] : '';
        //return this.selectedDocId != null && this.docDescription.hasOwnProperty(this.selectedDocId) ? this.docDescription[this.selectedDocId] : this.docDescription[this.selectedDocId];
    }
    handleDocumentSave() {
        let docDesc = this.template.querySelector('.doc-desc');
        if (!docDesc.value) {
            docDesc.setCustomValidity('Enter description to explain documents requirements to customer');
        } else {
            docDesc.setCustomValidity('');
        }
        var ddd = docDesc.reportValidity();
        console.log('ddd', ddd);
        this.isDDModelOpen = false;
    }
}