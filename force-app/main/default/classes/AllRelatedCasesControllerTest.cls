@isTest
public class AllRelatedCasesControllerTest {
    private String insertCases(){
        Contact conRec = new Contact();
        conRec.LastName = 'Test123';
        insert conRec;
        
        Case parentCase = new Case();
        parentCase.Status = 'Received';
        parentCase.Origin = 'Phone';
        parentCase.ContactId = conRec.Id;
        insert parentCase;
        
        Case objcase = new Case();
        objcase.Status = 'Received';
        objcase.Origin = 'Email';
        objcase.ParentId = parentCase.Id;
        
        insert objcase;
        
        return parentCase.Id;
    }
    @isTest
    static void fetchRelatedCasesTest(){
		AllRelatedCasesControllerTest classObj =  new AllRelatedCasesControllerTest();     
        String caseId = classObj.insertCases();
        Test.startTest();
        	AllRelatedCasesController.fetchRelatedCases(caseId);
        Test.stopTest();
    }
}