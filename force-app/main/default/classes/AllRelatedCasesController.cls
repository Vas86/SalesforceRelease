public class AllRelatedCasesController {
    @AuraEnabled(cacheable = true)
    public static List<AllCasesWrapper> fetchRelatedCases(String caseId){      
        List<Case> caseRecords = new List<Case>([SELECT Id,ContactPhone from Case where Id =: caseId AND ContactPhone != NULL]);
        system.debug('caseRecords '+caseRecords);
        String phoneNum;
        String query;
        List<Case> relatedCases = new List<Case>();
        if(caseRecords.size() > 0){
           phoneNum = caseRecords[0].ContactPhone;
        }
        query = 'SELECT Id,CaseNumber,Status,CreatedDate,ContactId,Contact.Name,Partner_Account__c,Partner_Account__r.Name,Lender__c ,Loan_Amount__c,Personal_Loan__c,LastModifiedDate from Case where Id != : caseId AND (';
        if(String.isNotBlank(phoneNum)){
            query += ' ContactPhone =: phoneNum OR ';
        }
		query += ' ParentId  =: caseId OR Parent.Id =: caseId OR Parent.Parent.Id =: caseId OR Parent.Parent.Parent.Id =:caseId OR Parent.Parent.Parent.Parent.Id =: caseId OR Parent.Parent.Parent.Parent.Parent.Id =: caseId)';
        relatedCases = Database.query(query);
        
        
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        List<AllCasesWrapper> allCasesInfo = new List<AllCasesWrapper>();
        for(Case caseRec : relatedCases){
            AllCasesWrapper wrapObj = new AllCasesWrapper();
            wrapObj.createdDate = caseRec.CreatedDate;
            wrapObj.modifiedDate = caseRec.LastModifiedDate;
            wrapObj.caseNumber = caseRec.CaseNumber;
            wrapObj.caseStatus = caseRec.Status;
            wrapObj.casePersonalLoan = caseRec.Personal_Loan__c;
            wrapObj.caseLoanAmount = caseRec.Loan_Amount__c;
            wrapObj.caseLender = caseRec.Lender__c;
            wrapObj.caseIdUrl = baseUrl+'/lightning/r/Case/'+caseRec.Id+'/view';
            if(caseRec.ContactId != NULL){
                wrapObj.contactUrl= baseUrl+'/lightning/r/Contact/'+caseRec.ContactId+'/view';
                wrapObj.contactName = caseRec.Contact.Name;
            }
            else{
                wrapObj.contactName = '';
                wrapObj.contactUrl = '';
            }
            if(caseRec.Partner_Account__c != NULL){
                wrapObj.partnerAccName = caseRec.Partner_Account__r.Name;
                wrapObj.partnerAccUrl = baseUrl+'/lightning/r/Account/'+caseRec.Partner_Account__c+'/view';
            }
            else{
                wrapObj.partnerAccUrl = '';
                wrapObj.partnerAccName = '';
            }
            allCasesInfo.add(wrapObj);
        }
        return allCasesInfo;
    }
    public class AllCasesWrapper{
        
        @AuraEnabled
        public DateTime createdDate;
        @AuraEnabled
        public DateTime modifiedDate;
        @AuraEnabled
        public String partnerAccName;
        @AuraEnabled
        public String partnerAccUrl;
        @AuraEnabled
        public String contactName;
        @AuraEnabled
        public String contactUrl;
        @AuraEnabled
        public String caseIdUrl;
        @AuraEnabled
        public String caseNumber;
        @AuraEnabled
        public String caseStatus;
        @AuraEnabled
        public String caseLender;
        @AuraEnabled
        public Decimal caseLoanAmount;
        @AuraEnabled
        public String casePersonalLoan;
    }
}