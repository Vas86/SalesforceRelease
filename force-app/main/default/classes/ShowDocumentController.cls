public class ShowDocumentController {
    Public String documentUrl{get;set;}
    Public String width{get;set;}
    Public String height{get;set;}
    public ShowDocumentController(){
        documentUrl = ApexPages.currentPage().getParameters().get('url');//EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('url'), 'UTF-8');
        width = ApexPages.currentPage().getParameters().get('width');
        height = ApexPages.currentPage().getParameters().get('height');
    }
    public Boolean getIsImage(){
        return ApexPages.currentPage().getParameters().get('type') == 'Image' ? true : false;
    }
    public Boolean getIsPdf(){
        return ApexPages.currentPage().getParameters().get('type') == 'pdf' ? true : false;
    }
    public Boolean getIsHTML(){
        return ApexPages.currentPage().getParameters().get('type') == 'html' ? true : false;
    }
    public PageReference download(){
        return new PageReference(documentUrl);
    }
}