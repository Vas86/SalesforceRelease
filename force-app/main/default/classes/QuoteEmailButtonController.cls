public class QuoteEmailButtonController {
    public string loanUuid;
    
    public QuoteEmailButtonController(ApexPages.StandardController controller) {
        System.debug(controller);
        List<case> lstcase = [SELECT Driva_UUID__c FROM Case WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        
        if(lstcase.size() > 0) {
            this.loanUuid = lstcase[0].Driva_UUID__c;
        }
    }
    
    public PageReference urlRedirect() {
        String envName = 'desk';
        String host = System.URL.getSalesforceBaseUrl().getHost();
        if(host.contains('dev')){
            envName = 'desk-dev';
        }
        if(host.contains('staging')){
            envName = 'desk-staging';
        }
        if(host.contains('uat')){
            envName = 'desk-uat';
        }
        string jwtToken = JWT.sign();
        string url = 'https://'+envName+'.driva.com.au/externalEmail/'+this.loanUuid+'?token='+jwtToken;
        System.debug(url);
        PageReference page = new PageReference(url);
        page.setRedirect(true);
        return page;
    }
}