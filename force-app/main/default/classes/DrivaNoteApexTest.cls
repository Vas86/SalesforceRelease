@isTest
public class DrivaNoteApexTest {
   @isTest
    public static void testMethod1() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Case objcase = new Case();
        objcase.Status = 'Received';
        objcase.Origin = 'Phone';
        insert objcase;
        
        Note__c objnote = new Note__c();
        objnote.Public__c = true;
        objnote.Content__c = 'Test';
        objnote.Related_Case__c = objcase.Id;
        insert objnote;
        
       /* Id pid = [Select Id from profile where name='Standard User'].Id;
         List<User> userRecords = new List<User>();         
        User userRec = new User(alias = 'test123', email='test123@noemail.com',
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = pid, country='United States',IsActive =true,
                                
                                timezonesidkey='America/Los_Angeles', username='testerDriva@noemail.com');
        userRecords.add(userRec);
        if(userRecords.size() > 0 ){
            INSERT userRecords;
        }
	List<String> userList = new List<String>();
        userList.add(userRecords[0].Id);*/
        QuickText quicktext=new QuickText();
        quicktext.Channel='Email';
        quicktext.Message='Hello,this is related to quick text note';
        quicktext.Name='TestQuickText';
        insert quicktext;
        Test.startTest();
        DrivaNoteApex.getAllNotes(objcase.Id);
       // DrivaNoteApex.addNewNote(null, objcase.Id, true, 'test body',userList);
       DrivaNoteApex.addNewNote(null, objcase.Id, true, 'test body');
        DrivaNoteApex.addFeeditem(objcase.Id, 'test body');
        DrivaNoteApex.getAllQuickText();
        DrivaNoteApex.fetchQuickText(objcase.Id);
        
        // DrivaNoteApex.getAllUsers();
        Test.stopTest();
       
        list<Note__c> con = [select Id from Note__c];
        System.assertEquals(2, con.size());
    }
    
}