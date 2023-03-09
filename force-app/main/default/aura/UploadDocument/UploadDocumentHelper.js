({
    //Start (28-06-2022) Now fetching tabs name from API callout
    //fetch picklist value from documnet type field 
    getDocList: function (component) {
        var currentCaseId = component.get("v.recordId");
        var action = component.get("c.fetchDocType");
        var action1 = component.get("c.documentsList");
        var uniqueDocs = [];
        /*AG-3200*/
        var dynamicDocs = [];
        /*AG-3200*/
        action1.setParams({
            caseId: currentCaseId
        });
        action1.setCallback(this, function (response) {

            console.log('state111' + response.getReturnValue());
            let documentLibDocs = response.getReturnValue();
            uniqueDocs = [...new Set(documentLibDocs)];
            console.log(uniqueDocs);

            /* const result = JSON.parse(response.getReturnValue());
             console.log('result ++ '+result);
             documentLibDocs = result; */
        });
        $A.enqueueAction(action1);
        action.setParams({
            caseId: currentCaseId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state' + state);
            if (state === "SUCCESS") {
                const result = JSON.parse(response.getReturnValue());
                //console.log('Result ==> '+ JSON.stringyfy(result));
                if (result.success) {
                    console.log('If2 called');
                    var docMap = new Map();
                    /*AG-3200*/
                    var docActionTypeMap = new Map(); //21-11-2022
                    /*AG-3200*/
                    var docList = [];
                    var documentsData = [];
                    docMap.set('Documents in Portal', '');
                    /*AG-3200*/
                    docActionTypeMap.set('Documents in Portal', { 'ActionType': null, 'Data': [] }); //21-11-2022
                    /* AG-3200 */
                    result.data.documents.filter(item => {

                        if (!docMap.has(item.docType)) {
                            console.log('If3 called');
                            docMap.set(item.docType, 'New ');
                            /*AG-3200*/
                            docActionTypeMap.set(item.docType, { 'ActionType': (item.hasOwnProperty('actionType') ? item.actionType : null), 'Data': (item.hasOwnProperty('data') ? item.data : []) }); //21-11-2022
                            /*AG-3200*/

                        }
                        documentsData.push(item);

                    });
                    console.log('docMap ' + docMap);
                    uniqueDocs.filter(item => {
                        if (!docMap.has(item)) {
                            docMap.set(item, 'Existing ');
                            docActionTypeMap.set(item, { 'ActionType': null, 'Data': [] }); //22-11-2022
                        }
                    })
                    if (!docMap.has('Sales Invoice')) {
                        docMap.set('Sales Invoice', 'New ');
                        docActionTypeMap.set('Sales Invoice', { 'ActionType': null, 'Data': [] }); //22-11-2022
                    }
                    if (!docMap.has('Other')) {
                        docMap.set('Other', 'New ');
                        docActionTypeMap.set('Other', { 'ActionType': null, 'Data': [] }); //22-11-2022
                    }
                    if (!docMap.has('Credit File')) {
                        docMap.set('Credit File', 'New ');
                        /*AG-3200*/
                        docActionTypeMap.set('Credit File', { 'ActionType': null, 'Data': [] }); //22-11-2022
                        /*AG-3200*/
                    }
                    if (!docMap.has('Privacy Policy')) {
                        docMap.set('Privacy Policy', 'New ');
                        /*AG-3200*/
                        docActionTypeMap.set('Privacy Policy', { 'ActionType': null, 'Data': [] }); //22-11-2022
                        /* AG-3200*/
                    }
                    /* if(!docList.includes('Other')){
                         docList.push('Other');
                     }*/
                    if (!docMap.has('Preliminary Assessment')) {
                        docMap.set('Preliminary Assessment', 'New ');
                        /*AG-3200*/
                        docActionTypeMap.set('Preliminary Assessment', { 'ActionType': null, 'Data': [] });
                        /* AG-3200*/
                    }

                    docMap.forEach((value, key) => {
                        docList.push({ key, value });
                    })
                    /*AG-3200*/
                    console.log('docActionTypeMap', docActionTypeMap);
                    let mappedArray = JSON.parse(JSON.stringify(docList)).map(item => {
                        console.log('item++' + item.key);
                        let obj = Object.assign({}, item);
                        objArr = [];
                        console.log('item=>', item.key);
                        obj.isDynamicField = docActionTypeMap.get(item.key).ActionType == 'DYNAMIC_FIELDS' ? true : false; // to view panels with above commented data comment this ternary operator and simply just add true
						
                        if (obj.isDynamicField) {
                            dynamicDocs.push(item.key);
                            // console.log('****',  docActionTypeMap.get(item.key));
                            for (var key in docActionTypeMap.get(item.key).Data) {
                                var str = '';
                                var panelHeader = '';
                                var value = docActionTypeMap.get(item.key).Data[key];
                                for (var k in value) {
                                    if (k == 'createdAt') {
                                        function pad(s) { return (s < 10) ? '0' + s : s; }
                                        var d = new Date(value[k]);
                                        panelHeader = 'Submitted' + ' ' + [pad(d.getDate()), pad(d.getMonth() + 1), d.getFullYear()].join('/');
                                    }
                                    else {
                                        const text = k;
                                        const result = text.replace(/([A-Z])/g, " $1");
                                        const finalResult = result.charAt(0).toUpperCase() + result.slice(1);
                                        str += finalResult + ': ' + value[k] + '<br/>';
                                    }
                                }
                                objArr.push({ panelHeading: panelHeader, panelBody: str });
                            }
                            console.log(objArr);
                            obj.dataArr = objArr;
                        }

                        return obj;
                    });

                    docList = mappedArray;
                    /* AG-3200 */


                    component.set("v.lstDocType", docList);
                    console.log('docList', docList);
                    //AG-3200
                    console.log(JSON.parse(JSON.stringify(docList)));
                    //AG-3200
                    component.set("v.documentsData", documentsData);
                    //component.set("v.documentsData", documentsList);   
                    component.set("v.showSpinner", false);
                    /*AG-3200*/
                    component.set("v.dynamicDocs", dynamicDocs); //22-11-2022
                    /*  AG-3200*/
                }
                else {
                    component.set("v.showSpinner", false);
                }

            }
            else if (state === "INCOMPLETE") {
                alert("Continuation action is INCOMPLETE");
                component.set("v.showSpinner", false);
            }
            else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    //End 

    awsInfoHelper: function (component, event, helper) {
        var action = component.get("c.awsInfoDetails");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var results = response.getReturnValue();
                //alert(JSON.stringify(results));
                component.set("v.AWSInfoList", results);
            }
        });
        $A.enqueueAction(action);
    },

    fetchFolderNameHelper: function (component, event, helper) {

        var currentCaseId = component.get("v.recordId");
        var action = component.get("c.fetchFolderNameFromCase");
        action.setParams({
            caseId: currentCaseId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var results = response.getReturnValue();
                //alert(JSON.stringify(results));
                component.set("v.folderName", results);
            }
        });
        $A.enqueueAction(action);
    },

    //get file info wrapper class list
    getFileURLList: function (component) {

        var currentDocTypeName = component.get("v.selTabname");
        var currentCaseId = component.get("v.recordId");
        var action = component.get("c.fetchFileURL");
        console.log('currentDocTypeName', currentDocTypeName);
        action.setParams({
            strDocType: currentDocTypeName,
            strCaseId: currentCaseId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.lstWrapper", response.getReturnValue());
                var lst = component.get("v.lstWrapper");
                //console.log('##1 Final URL = ' , lst);
                console.log(`##3 Final URL = ${lst[0].strFileLink}`);

            }
            else {
                alert("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },


    //create document record in sf
    createDoc: function (component, file) {


        var currentDocTypeName = component.get("v.selTabname");
        var currentCaseId = component.get("v.recordId");
        var fName = component.get("v.fileName");
        var action = component.get("c.createDocumentRecord");

        action.setParams({
            fileName: fName,
            contentType: file.type,
            parentId: currentCaseId,
            strDocType: currentDocTypeName
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            try {
                if (state === "SUCCESS") {
                    component.set("v.lstWrapper", response.getReturnValue());
                }
                else {
                    alert("Failed with state: " + state);
                }
            }
            catch (error) {
                console.log('Error==>' + error);
            }

        });
        $A.enqueueAction(action);
    },

    //getLoanUuid
    getLoanUuidHelper: function (component) {
        var action = component.get("c.getLoanUuid");
        var currentCaseId = component.get("v.recordId");
        action.setParams({
            caseId: currentCaseId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loanUuid", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },

    // Call desk api
    getFileHelper: function (component, helper, fileType, fileName) {
        var loanUuid = component.get("v.loanUuid");
        console.log("loanUuid: ", loanUuid);
        console.log("fileType: ", fileType);
        var action = component.get("c.callDeskAPI");
        action.setParams({
            endpoint: '/api/v2/external/' + fileType + '/' + loanUuid
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state  : ', state);
            if (state === "SUCCESS") {
                const result = JSON.parse(response.getReturnValue());
                if (result.success) {
                    // component.find('notifLib').showNotice({
                    //     "variant": "success",
                    //     "header": fileName+" is retrieved successfully",
                    //     "message": fileName+" is retrieved successfully",
                    //     closeCallback: function() {
                    //         helper.getFileURLList(component);
                    //         $A.get('e.force:refreshView').fire();
                    //     }
                    // });


                    // Set isNotificationVariant,isNotificationHeader, isNotificationMessage attribute 
                    component.set("v.isNotificationVariant", 'slds-modal__header slds-theme_success slds-theme_alert-texture');
                    component.set("v.isNotificationHeader", fileName + " is retrieved successfully");
                    component.set("v.isNotificationMessage", fileName + " is retrieved successfully");
                    component.set("v.isNotificationModalFooter", true);
                    // Set isNotifiModalOpen attribute to true
                    component.set("v.isNotificationModalOpen", true);

                } else {
                    // component.find('notifLib').showNotice({
                    //     "variant": "error",
                    //     "header": "Failed to retrieve " + fileName,
                    //     "message": result.error.message,
                    // });


                    // Set isNotificationVariant,isNotificationHeader, isNotificationMessage attribute 
                    component.set("v.isNotificationVariant", 'slds-modal__header slds-theme_error slds-theme_alert-texture');
                    component.set("v.isNotificationHeader", "Failed to retrieve " + fileName);
                    component.set("v.isNotificationMessage", '');
                    component.set("v.isNotificationModalFooter", false);
                    // Set isNotifiModalOpen attribute to true
                    component.set("v.isNotificationModalOpen", true);
                }
            }
            else if (state === "INCOMPLETE") {
                alert("Continuation action is INCOMPLETE");
            }
            else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    softDeleteFile: function (component) {
        var action = component.get("c.softDeleteDocument");
        var docId = component.get("v.removeFileId");
        //AG-2672
        var IdandName = docId.split('-');
        //AG-2672
        action.setParams({
            //docId : docId
            //AG-2672
            docId: IdandName[0],
            fileId: IdandName[1]
            //AG-2672

        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Called');
                this.getFileURLList(component);
                component.set("v.showModalSpinner", false);// Added by 10/2/23
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    /*documentFetch : function(component){
         var currentCaseId = component.get("v.recordId");
        
        return response.getReturnValue();
    }*/

})