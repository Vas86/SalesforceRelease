/*************************** 
* @Name         GoogleEmailHandlerPROD 
* @Author       vasu@driva.com.au
* @Date         29/04/2022
* @description  Handles Single Sign on Using Google Credentials for PROD
******************************************************
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-----------------------------------------------------------------------
*  1.0              Vasu      29/04/2022          Initial Creation 

****************************** */

global class GoogleEmailHandlerPROD implements Auth.RegistrationHandler{
    global User createUser(Id portalId, Auth.UserData data){
                
        String userName = data.email.subStringBefore('@') + '@driva.com.au';
        if(data.attributeMap.containsKey('sfdc_networkid')) {
            userName = data.email.subStringBefore('@') + '@Testsso.com.gemail.portal';
        }
        //The user is authorized, so create their Salesforce user
        List<User> userList = [Select Id, Name, Email, UserName From User 
                               Where ( UserName =: userName)
                               AND isActive = true
                              ];
        User user = new User();
        if(userList != null && userList.size() > 0){
            user = userList.get(0);
            return user;
        }
        else
        {
            if(data.attributeMap.containsKey('sfdc_networkid')) {
                //We have a community id, so create a user with community access
                //TODO: Get an actual account
                
                Account a = [SELECT Id FROM account WHERE name='GoogleEmail'];
                
                Contact c = new Contact();
                c.accountId = a.Id;
                c.email = data.email;
                c.firstName = data.firstName;
                c.lastName  = data.lastName;
                insert(c);
                
                
                User u = new User();
                //Profile p = [SELECT Id FROM profile WHERE name='Partner Community Login User'];
                // sfdcpnather@gmail.com
                String partnerUserName = data.email.subStringBefore('@') + '@Testsso.com.gemail.portal';
                
                u.username = partnerUserName;
                u.email = data.email;
                u.lastName = data.lastName;
                u.firstName = data.firstName;
                String alias = u.username;
                //Alias must be 8 characters or less
                if(alias !=null && alias.length() > 8) {
                    alias = alias.substring(0, 8);
                }
                u.alias = alias;
                u.languagelocalekey = UserInfo.getLocale();
                u.localesidkey = UserInfo.getLocale();
                u.emailEncodingKey = 'UTF-8';
                u.timeZoneSidKey = 'America/Los_Angeles';
               // u.profileId = p.Id;
                u.contactId = c.Id;
                return u;
            } else {
                
                User u = new User();
                
                Profile p = [SELECT Id FROM profile WHERE name='System Administrator'];
                
                u.username = data.email.subStringBefore('@') + '@driva.com.au';
                u.email = data.email;
                u.lastName = data.lastName;
                u.firstName = data.firstName;
                String alias = u.username;
                //Alias must be 8 characters or less
                if(alias.length() > 8) {
                    alias = alias.substring(0, 8);
                }
                u.alias = alias;
                u.languagelocalekey = UserInfo.getLocale();
                u.localesidkey = UserInfo.getLocale();
                u.emailEncodingKey = 'UTF-8';
                u.timeZoneSidKey = 'America/Los_Angeles';
                u.profileId = p.Id;
                /*Test code-- for testing
String user=data.email.subStringBefore('@') + '@driva.com.au.devdemo';
User u=[Select Id from user where username=:user];*/
                
                return u;
            }
        }
    }
    
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        
        String userName = data.email.subStringBefore('@') + '@driva.com.au';
        
        if(data.attributeMap.containsKey('sfdc_networkid')) {
            userName = data.email.subStringBefore('@') + '@Testsso.com.gemail.portal';
        }
        System.debug('#### userId '+userId);
        List<User> userList = [Select Id, Name, Email, UserName From User Where UserName =: userName AND isActive = true];
        User u = new User();
        if(userList != null && userList.size() > 0){
            u = userList.get(0);
            update u; 
        }
    }
}