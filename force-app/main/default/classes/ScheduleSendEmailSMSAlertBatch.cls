public class ScheduleSendEmailSMSAlertBatch implements Schedulable {
    public void execute (SchedulableContext sc){
        SendEmailSMSAlertsBatch batchObj = new SendEmailSMSAlertsBatch(System.Today());
        Database.executeBatch(batchObj,10);
    }
}