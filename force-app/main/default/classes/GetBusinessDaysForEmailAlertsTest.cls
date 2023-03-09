//Test class for GetBusinessDaysForEmailAlerts and ScheduleUnderReviewEMailAlerts
@isTest
public class GetBusinessDaysForEmailAlertsTest {
    @isTest
    public static void test(){
        Case obj = new Case();
        obj.Status = 'Under Review';
        obj.Sub_Status__c = 'Chase';
        insert obj; 
    }
}