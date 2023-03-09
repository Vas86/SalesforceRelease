public class CaseInvocable {
    @InvocableMethod
    public static void updateCase(List<Id> caseIds){
        List<Case> cases = new List<Case>();
        for(Id caseId : caseIds){
            //cases.add(new Case(Id = caseId, Sub_Status__c = 'Correspondence Received'));
            cases.add(new Case(Id = caseId, Sub_Status__c = 'Document Received'));//AG-3384
        }
        System.enqueueJob(new CaseQueable(cases));
    }
}