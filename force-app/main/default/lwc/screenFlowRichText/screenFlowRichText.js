import { LightningElement, api, wire } from 'lwc';
//import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import fetchQuickText from '@salesforce/apex/DrivaNoteApex.fetchQuickText';
export default class ScreenFlowRichText extends LightningElement {
    @api fieldValue = " ";
    @api fieldLabel;
    @api required;
    @api fieldLength;
    @api visibleLines;
    @api recordId;
    @api validity;
    @api fieldName;
    @api idValue;
    @api fieldValueWithoutHtml;
    recordValue;

    allowedFormats = [
        'font',
        'size',
        'bold',
        'italic',
        'underline',
        'strike',
        'list',
        'indent',
        'align',
        'link',
        'image',
        'clean',
        'table',
        'header',
        'color',
        'background',
        'code',
        'code-block',
        'script',
        'blockquote',
        'direction',
    ];
    connectedCallback() {
        this.validity = true;
        console.log('ddddd', this.fieldValue);
        document.documentElement.style.setProperty('--rta-visiblelines', (this.visibleLines * 2) + 'em');
        if (this.idValue) {
            fetchQuickText({ Id: this.idValue })
                .then(result => {
                    this.recordValue = result;//.replace(/(?:\r\n|\r|\n)/g, '<p>&nbsp;</p>');
                    this.fieldValue = result;//.replace(/(?:\r\n|\r|\n)/g, '<p>&nbsp;</p>');
                    this.fieldValueWithoutHtml = result;
                }).catch(error => {
                    console.log('error=> ', error);
                });
        }

    }

    handleChange(event) {
        if ((event.target.value).length > this.fieldLength) {
            this.validity = false;
            this.errorMessage = "You have exceeded the max length";
        }
        else {
            this.validity = true;
            this.fieldValueWithoutHtml = event.target.value.replaceAll('<p>&nbsp;</p>', '\n');
            this.fieldValueWithoutHtml = this.fieldValueWithoutHtml.replaceAll('<p><br></p>', '');
            this.fieldValueWithoutHtml = this.fieldValueWithoutHtml.replace(/(<([^>]+)>)/ig, '');
            this.fieldValue = event.target.value;//.replaceAll('<p><br></p>', '');
        }
    }
}