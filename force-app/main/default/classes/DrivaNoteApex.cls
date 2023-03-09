public class DrivaNoteApex {
    @AuraEnabled
    //Quick text-Experiment
    public static list<QuickTextWrapper> getAllQuickText(){
        List<QuickTextWrapper> quickTexts = new List<QuickTextWrapper>();
        for(QuickText obj : [SELECT Id, Name, Message FROM QuickText Order by Name limit 200]){
            QuickTextWrapper quickObj = new QuickTextWrapper();
            quickObj.label = obj.Name;
            quickObj.value = obj.Message;
            quickTexts.add(quickObj);
        }
        return quickTexts;
    }
    @AuraEnabled
    //Quick text-Experiment
    public static String fetchQuickText(String Id){
        String message = '';
        for(QuickText obj : [SELECT Id, Name, Message FROM QuickText Where Id =: Id]){
            message = obj.Message;
        }
        return message;
    }
    public class QuickTextWrapper{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String value{get;set;}
    }
    @AuraEnabled
    //Quick text -Experiment
    public static list<Note__c> getAllNotes(string caseId)
    {
        List<Note__c> notesList=new List<Note__c>();
        
        for(Note__c obj:[Select id, Poster__c, Public__c, format(Created_At__c) Created_At__c, Created_By__c, Content__c, Created_By__r.FirstName, Created_By__r.MiddleName, Created_By__r.LastName, Partner__c, Partner__r.Name, Partner_User_Email__c,Related_Case__r.Sub_Status__c from Note__c where Related_Case__c=:caseId ORDER BY Created_At__c desc limit 200])
        {
            notesList.add(obj);
        }
        return notesList;
    }
    
    @AuraEnabled
   // public static void addNewNote(string createdBy, string caseId, boolean isPublic, string content,List<String> usersIds)
    public static void addNewNote(string createdBy, string caseId, boolean isPublic, string content)
    {
        Note__c note = new Note__c();
        note.Created_By__c = createdBy;
        note.Related_Case__c = caseId;
        //note.Related_Case__r.Sub_Status__c= 'Correspondence Received';
        note.Public__c = isPublic;
        note.Content__c = content;
        Database.insert(note);
        //Case c=new Case();
        //c.Id=caseId;
       // c.Sub_Status__c='Correspondence Received';
       // if(note.Related_Case__c !=''){
        //    Database.upsert(c);
       // }
       /* system.debug('Note===>'+note);
        system.debug('usersIds===>'+usersIds);
        if(note.Id != NULL && usersIds != NULL && usersIds.size() > 0 ){
            DrivaNoteApex.sendNotifications(usersIds,content,note.id);
        }*/
    }
    
    @AuraEnabled
    public static void addFeeditem(string caseId, string body)
    {
        FeedItem post = new FeedItem();
        post.ParentId =caseId;
        post.Body = body;
        post.isRichText = true;
        Database.insert(post);
    }
    //Added 1-8-2022 
    @AuraEnabled
    public static List<QuickTextWrapper> getAllUsers(){
        
        List<QuickTextWrapper> allUsers = new List<QuickTextWrapper>();
        for(User usr : [SELECT Id,Email,Name FROM User where IsActive = true]){
            QuickTextWrapper user = new QuickTextWrapper();
            user.label = usr.Name;
            user.value = usr.Id;
            allUsers.add(user);
            
        }
        system.debug('allUsers'+allUsers);
        return allUsers;
    }
   /* public static void sendNotifications(List<String> usersIds,String content,String noteId){
        Set<String> userSet = new Set<String>();        
        userSet.addAll(usersIds);
        List<CustomNotificationType > TemplateInfoDetail = [SELECT Id,DeveloperName FROM CustomNotificationType                                                        
                                                            WHERE DeveloperName='Notes_Notification'];   
        
        // Create a new custom notification                
        Messaging.CustomNotification currNotification = new Messaging.CustomNotification();                
        // Set the contents                
        currNotification.setTitle('You have received new note');   
        String plainText = content.stripHtmlTags();
        currNotification.setBody(''+plainText);                
        // Set the notification type and target                
        currNotification.setNotificationTypeId(TemplateInfoDetail[0].Id);               
        currNotification.setTargetId(noteId);
        
        try {                    
            currNotification.send(userSet);                  
        }                
        catch (Exception ex) {                    
            System.debug('Notification Failed: ' + ex.getMessage());                    
        }
        
    }*/
}