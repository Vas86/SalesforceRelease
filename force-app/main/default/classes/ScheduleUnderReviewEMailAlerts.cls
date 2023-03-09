public class ScheduleUnderReviewEMailAlerts implements Schedulable {
    public Case caseRecord;
    public String scheduleDuration;
    public ScheduleUnderReviewEMailAlerts(Case caseObj,String schedulingTime){
        caseRecord = caseObj;
        scheduleDuration = schedulingTime;
    }
    public void execute(SchedulableContext sc){
     
      //Create parameter
        Map<String, String> params = new Map<String, String>();
        params.put('caseRecordId',caseRecord.Id);
        params.put('Schedule_Duration',scheduleDuration);
        
        //create instance of Interview
        Flow.Interview.Schedule_Email_Alerts_when_Status_Under_Review stage = new Flow.Interview.Schedule_Email_Alerts_when_Status_Under_Review(params);
        
        //Invoke start method
        stage.start();
        system.debug('caseRecord==>'+(Object)stage.getvariableValue('caseRecord'));
        system.debug('caseRecordId==>'+(String)stage.getvariableValue('caseRecordId'));
        system.debug('Schedule_Duration==>'+(String)stage.getvariableValue('Schedule_Duration'));
        
    }

}