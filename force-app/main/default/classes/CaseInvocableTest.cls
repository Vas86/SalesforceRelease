@isTest
public class CaseInvocableTest {
    @isTest private static void unit(){
        Case obj = new Case();
        obj.Subject = 'Test';
        obj.Status = 'Received';
        insert obj;
  
        CaseInvocable.updateCase(new List<Id>{obj.Id});
    }
    @isTest private static void unit2(){
        Case obj = new Case();
        obj.Subject = 'Test';
        obj.Status = 'Received';
        insert obj;
        List<Case> cases = new List<Case>();
        cases.add(new Case(Id = obj.Id, Sub_Status__c = 'Cold Lead'));
        System.enqueueJob(new CaseQueable(cases));
        
    }
}