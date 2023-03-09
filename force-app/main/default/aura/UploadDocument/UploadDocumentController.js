({
    doInit: function (component, event, helper) {
        helper.getDocList(component);
        component.get("v.recordId");
        helper.awsInfoHelper(component, event, helper);
        helper.fetchFolderNameHelper(component, event, helper);

    },

    //Open Modal for Img
    openModel: function (component, event, helper) {
        component.set("v.isModalOpen", true);
        var imgId = event.target.id;
        console.log('Image Id==' + imgId);
        var img_src = document.getElementById(imgId).src;
        console.log('Image SrC==' + img_src);
        component.set("v.clickedIconURL", img_src);
        /*Popup on click on document-- Mock 
        let completeURL = window.location.origin + '/apex/showDocument?type=Image&url='+encodeURIComponent(img_src);
        let windowFeatures = 'menubar=no,resizable=yes,scrollbars=yes';
        windowFeatures  = 'width=' + screen.width;
        windowFeatures += ',height=' + screen.height;
        console.log( 'Complete URL is ' + completeURL );
        window.open( completeURL, "_blank", windowFeatures );
          Popup on click on document-- Mock     */
    },

    //Open Modal for PDF
    openModelForPDF: function (component, event, helper) {
        component.set("v.isPDFModalOpen", true);
        var imgId = event.target.id;
        var clickedFileName = event.target.dataset.id;
        console.log('clickedFileName ' + clickedFileName);
        component.set("v.clickedIconURL", imgId);
        component.set("v.clickedFileName", clickedFileName);
        //Popup on click on document-- Mock
    },
    //Open Modal for Img
    openModelNewWindow: function (component, event, helper) {
        var imgId = event.currentTarget.dataset.id;
        var w = 1020;
        var h = screen.height - 120;
        //var left = (screen.width/2)-(w/2);
        var top = 0;
        console.log('Image Id==' + imgId);
        var img_src = document.getElementById(imgId).src;
        //let completeURL = window.location.origin + '/apex/showDocument?type=Image&url='+encodeURIComponent(img_src)+'&width='+screen.width+'&height=' + screen.height;
        let completeURL = window.location.origin + '/apex/showDocument?type=Image&url=' + encodeURIComponent(img_src) + '&width=' + w + '&height=' + h + '&top=' + top;
        let windowFeatures = 'menubar=no,resizable=yes,scrollbars=yes';
        //windowFeatures  = 'width=' + screen.width;
        //windowFeatures += ',height=' + screen.height;
        window.open(completeURL, "_blank", windowFeatures);
    },

    //Open Modal for PDF
    openModelForPDFNewWindow: function (component, event, helper) {
        var imgId = event.currentTarget.id;
        var w = 1020;
        var h = screen.height - 120;
        var left = (screen.width / 2) - (w / 2);
        var top = 0;
        var clickedFileName = event.target.dataset.id;
        var type = imgId.includes('.html') ? 'html' : 'pdf';
        //let completeURL = window.location.origin + '/apex/showDocument?type=pdf&url='+encodeURIComponent(imgId)+'&width='+screen.width+'&height=' + screen.height;
        // let completeURL = window.location.origin + '/apex/showDocument?type=pdf&url='+encodeURIComponent(imgId)+'&width=250'+'&height=250';
        let completeURL = window.location.origin + '/apex/showDocument?type=' + type + '&url=' + encodeURIComponent(imgId) + '&width=' + w + '&height=' + h + '&top=' + top/*+'&left='+left*/;
        let windowFeatures = 'menubar=no,resizable=yes,scrollbars=yes';
        // windowFeatures  = 'width=' + screen.width;
        //windowFeatures += ',height=' + screen.height;
        window.open(completeURL, "_blank", windowFeatures);

        //Popup on click on document-- Mock

        /* Popup on click on document-- Mock
        let completeURL = window.location.origin + '/apex/showDocument?type=pdf&url='+encodeURIComponent(imgId);
        let windowFeatures = 'menubar=no,resizable=yes,scrollbars=yes';
        windowFeatures  = 'width=' + screen.width;
        windowFeatures += ',height=' + screen.height;
        console.log( 'Complete URL is ' + completeURL );
        window.open( completeURL, "_blank", windowFeatures );
         Popup on click on document-- Mock */
    },

    //set current selected tab name
    tabSelected: function (component, event, helper) {
        var currentTabName = component.get("v.selTabId");
        /*AG-3200*/
        var dynamicDocs = component.get("v.dynamicDocs");
        /*AG-3200*/

        component.set("v.selTabname", currentTabName);
        component.set("v.selTabId", currentTabName);
        console.log('v.selTabId>>>>>>>>>>', currentTabName);
        component.set("v.fileName", '');
        component.set("v.lstWrapper", null);
        helper.getFileURLList(component);
        helper.getLoanUuidHelper(component);
        /* if(currentTabName==='Sales Invoice') {
            component.set("v.salesinvoicefile", true);
        } else {
            component.set("v.salesinvoicefile", false);
        }*/
        if (currentTabName === 'Credit File') {
            component.set("v.isCreditFile", true);
        } else {
            component.set("v.isCreditFile", false);
        }
        if (currentTabName === 'Documents in Portal') {
            component.set("v.isDocumentInPortal", true);
        }
        else {
            component.set("v.isDocumentInPortal", false);
        }

        if (currentTabName === 'Privacy Policy') {
            component.set("v.isPrivacyPolicy", true);
        } else {
            component.set("v.isPrivacyPolicy", false);
        }
        /*AG-3200*/
        if (dynamicDocs.includes(currentTabName)) {
            component.set("v.isUploadDisplay", false);
        }
        else {
            component.set("v.isUploadDisplay", true);
        }
        /*AG-3200*/
        /*AG-3471*/

        /*AG-3471*/

    },

    handleFileCancel: function (component, event, helper) {
        //alert('@@  handleFileCancel Clicked');
    },

    //handle uplod file 
    s3upload: function (component, event, helper) {
       
        component.set("v.showModalSpinner", true);// Added by 10/2/23
        var strFileName = component.get("v.fileName");

        if (strFileName == null || strFileName == '') {
            alert('Please Select The File');
            return;
        }
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");

        var files = document.getElementById('fileUpload').files;
        var awsCustomset = component.get("v.AWSInfoList");
        var bucketName = awsCustomset[0].AmazonS3_BucketName__c;
        var bucketRegion = awsCustomset[0].Bucket_Region__c;
        var IdentityPoolId = awsCustomset[0].Identity_Pool_Id__c;
        var apiVer = awsCustomset[0].API_Version__c;

        AWS.config.update({
            region: bucketRegion,
            credentials: new AWS.CognitoIdentityCredentials({
                IdentityPoolId: IdentityPoolId
            })
        });

        var s3 = new AWS.S3({
            apiVersion: apiVer,
            params: { Bucket: bucketName }
        });

        if (files) {

            var file = files[0];
            var fileName = file.name;
            var contentType = file.type;
            component.set("v.fileName", fileName);
            component.set("v.fileType", file.Type);
            var folderName = component.get("v.folderName");
            var finalFolderName = folderName.concat('/');
            var filePath = finalFolderName.concat(fileName);
            //var fileUrl = 'https://us-west-2.amazonaws.com/';
            var fileUrl;
            var fileURLfirstPart = 'https://';
            var fileURLsecpart = fileURLfirstPart.concat(bucketRegion);
            var fileURLthirdpart = fileURLsecpart.concat('.amazonaws.com/');
            fileUrl = fileURLthirdpart;
            let finalfileUrl = fileUrl.concat(fileName);
            fileUrl = finalfileUrl;
            var cnDisposition;

            if (contentType == 'application/pdf' ||
                contentType == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' ||
                contentType == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
                contentType == 'message/rfc822' || contentType == 'text/html' || contentType == 'text/htm' ||
                contentType == 'application/json' || contentType == 'text/xml'
                || contentType == 'application/vnd.ms-excel.sheet.macroEnabled.12') {
                cnDisposition = 'inline';
            }
            else {
                cnDisposition = 'attachment';
            }

            s3.upload({
                Key: filePath,
                Body: file,
                ContentType: contentType,
                ContentDisposition: cnDisposition + '; filename=' + fileName

            }, function (err, data) {
                if (err) {
                    // reject('error');
                    //alert('@@ err = '+err);   
                    console.log('@@ err = ' + err);
                }
                //alert('Successfully Uploaded!');
                helper.createDoc(component, file);
                // window.location.reload();
                $A.util.addClass(spinner, "slds-hide");
                component.set("v.fileName", null);
                component.set("v.closeModelPopup", true);// Added by 10/2/23
                // Set isNotificationVariant,isNotificationHeader, isNotificationMessage attribute 
                component.set("v.isNotificationVariant", 'slds-modal__header slds-theme_success slds-theme_alert-texture');
                component.set("v.isNotificationHeader", 'Successfully Uploaded!');
                component.set("v.isNotificationMessage", 'Successfully Uploaded!');
                component.set("v.isNotificationModalFooter", true);
                // Set isNotifiModalOpen attribute to true
                component.set("v.isNotificationModalOpen", true);
                
                /*
                    component.find('notifLib').showNotice({
                        "variant": "success",
                        "header": "Successfully Uploaded!",
                        "message": "Successfully Uploaded!",
                        closeCallback: function() {
                            //helper.createDoc(component, file);
                            helper.getFileURLList(component);
                            $A.get('e.force:refreshView').fire();
                        }
                    });
                    
                */
            });
        }
    },

    handleFilesChange: function (component, event, helper) {
        var fileName = 'No File Selected..';
        var files = document.getElementById('fileUpload').files;
        if (files) {
            var file = files[0];
            var fileName = file.name;
            component.set("v.fileName", fileName);
        }
    },

    handleCancel: function (component, event, helper) {
        component.set("v.fileName", "");
    },

    getCreditFile: function (component, event, helper) {
        component.set("v.retrievingCreditFile", true);
        helper.getFileHelper(component, helper, 'creditfile', 'Credit file');
        component.set("v.retrievingCreditFile", false);
    },

    getSalesInvoice: function (component, event, helper) {
        component.set("v.retrievingSalesInvoiceFile", true);
        helper.getFileHelper(component, helper, 'salesinvoicefile', 'Sales Invoice');
        component.set("v.retrievingSalesInvoiceFile", false);
    },

    getPrivacyPolicy: function (component, event, helper) {
        component.set("v.retrievingPrivacyPolicy", true);
        helper.getFileHelper(component, helper, 'privacyPolicy', 'Privacy policy file');
        component.set("v.retrievingPrivacyPolicy", false);
    },
    // for html download
    downloadFile: function (component, event, helper) {
        var url = component.get("v.clickedIconURL");
        var fileName = component.get("v.clickedFileName");
        fetch(url)
            .then(res => {
                //console.log('res' ,res);
                //return res.text().then(str => {
                return res.blob().then(blob => {
                    //console.log('blob -- ' , blob);
                    var element = document.createElement('a');
                    //element.setAttribute('href', 'data:text/base64;charset=utf-8,' + encodeURIComponent(str));element.setAttribute('download', fileName);
                    let downloadurl = URL.createObjectURL(blob);
                    console.log('downloadurl', downloadurl);
                    //window.open(downloadurl);
                    element.setAttribute('href', downloadurl);
                    element.setAttribute('download', fileName);
                    element.style.display = 'none';
                    document.body.appendChild(element);
                    element.click();
                    document.body.removeChild(element);
                });
            });
    },



    // for pdf file download
    /*downloadFile: function(component, event, helper) {
           var url = component.get("v.clickedIconURL");
           var fileName = component.get("v.clickedFileName");
           fetch(url)
           .then(res => {
               return res.blob().then(blob => {
               var element = document.createElement('a');
               let downloadurl = URL.createObjectURL(blob)
               element.setAttribute('href', downloadurl);
               element.setAttribute('download', fileName);
               element.style.display = 'none';
               document.body.appendChild(element);
               element.click();
               document.body.removeChild(element);
           });
           })
           ;
       },*/


    //for notification popup click on ok button

    handleNotificationOk: function (component, event, helper) {
        component.set("v.isNotificationModalOpen", false);
        helper.getFileURLList(component);
        $A.get('e.force:refreshView').fire();
        // Added by 10/2/23 start
        component.set("v.closeModelPopup", false);
        window.setTimeout(
            $A.getCallback(function () {
                component.set("v.showModalSpinner", false);
            }), 500
        );
        // Added by 10/2/23 end
    },

    handleNotificationClose: function (component, event, helper) {
        component.set("v.isNotificationModalOpen", false);
    },
    handleRefresh: function (component, event, helper) {
        helper.getDocList(component);
        component.get("v.recordId");
        helper.awsInfoHelper(component, event, helper);
        helper.fetchFolderNameHelper(component, event, helper);
        window.setTimeout(
            $A.getCallback(function () {
                var findChildLWCComp = component.find('childLwcCompId');
                let docsData = component.get("v.documentsData");
                findChildLWCComp.refreshLWC(docsData);
            }), 5000
        );
    },
    handleRemove: function (component, event, helper) {
        try {
            //var docId =event.target.dataset.id;
            var docId = event.currentTarget.dataset.id;
            //console.log('docId '+docId);
            component.set("v.closeModelPopup", true);// Added by 10/2/23
            component.set("v.isRemoveModalOpen", true);
            component.set("v.removeFileId", docId);
        } catch (err) {
            console.log(err);
        }
    },
    handleRemoveModelClose: function (component, event, helper) {
        component.set("v.isRemoveModalOpen", false);
        component.set("v.closeModelPopup", false);// Added by 10/2/23
    },
    handleSoftDelete: function (component, event, helper) {
        component.set("v.isRemoveModalOpen", false);
        component.set("v.showModalSpinner", true);// Added by 10/2/23
        helper.softDeleteFile(component);
        component.set("v.closeModelPopup", false);// Added by 10/2/23
    },
    handleAccountSelect: function (component, event, helper) {
        console.log('Document Name', event.getParam('docType'));
        console.log('Document docDescription', event.getParam('docDescription'));
        component.set('v.docType', event.getParam('docType'));
        component.set('v.docDescription', event.getParam('docDescription'));
        component.set("v.closeModelPopup", false);
        component.set("v.selTabId", event.getParam('docType'));
        //this.tabSelected(component, event, helper);
        var action = component.get('c.tabSelected');
        $A.enqueueAction(action);
    },
    closeModel: function (component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.closeModelPopup", true);
        component.set("v.isModalOpen", false);
        component.set("v.isPDFModalOpen", false);
        component.set("v.clickedIconURL", '');

    },
}
)