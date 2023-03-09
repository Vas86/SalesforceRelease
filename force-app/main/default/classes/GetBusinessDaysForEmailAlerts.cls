public class GetBusinessDaysForEmailAlerts {
    @InvocableMethod(Label = 'Get Business Hours for Email Alert')
    public static void getBusinessDays(List<GetBusinessDaysForEmailAlertsWrapper> wrapList){
        BusinessHours bHours;
        bHours = [SELECT Id FROM BusinessHours WHERE Name = 'Driva'];
        Datetime fourBusinessDays = BusinessHours.nextStartDate(bHours.Id, wrapList[0].flowDateTime);
        Datetime twoBusinessDays = BusinessHours.nextStartDate(bHours.Id, wrapList[0].flowDateTime);
        Datetime oneBusinessDays = BusinessHours.nextStartDate(bHours.Id, wrapList[0].flowDateTime);
        for(Integer elapsed = 0; elapsed < 1; elapsed++){
            oneBusinessDays = oneBusinessDays.addDays(1);
            if(!BusinessHours.isWithin(bHours.Id, oneBusinessDays)){
                oneBusinessDays = BusinessHours.nextStartDate(bHours.Id, oneBusinessDays);
            }
        }
        for(Integer elapsed = 0; elapsed < 2; elapsed++){
            twoBusinessDays = twoBusinessDays.addDays(1);
            if(!BusinessHours.isWithin(bHours.Id, twoBusinessDays)){
                twoBusinessDays = BusinessHours.nextStartDate(bHours.Id, twoBusinessDays);
            }
        }
        for (Integer elapsed = 0; elapsed < 4; elapsed++)
        {
            fourBusinessDays = fourBusinessDays.addDays(1);
            if (!BusinessHours.isWithin(bHours.Id, fourBusinessDays))
            { 
                fourBusinessDays = BusinessHours.nextStartDate(bHours.Id, fourBusinessDays);
            }
        } 
        System.schedule('Schedule Job For 24Hrs '+wrapList[0].caseRecord.CaseNumber + ' '+wrapList[0].caseRecord.LastModifiedDate,  getCronExpression(oneBusinessDays), new ScheduleUnderReviewEMailAlerts(wrapList[0].caseRecord,'24 Hrs')); //Modified Job Name 24-02-2023 
        System.schedule('Schedule Job For 48Hrs '+wrapList[0].caseRecord.CaseNumber + ' '+wrapList[0].caseRecord.LastModifiedDate,  getCronExpression(twoBusinessDays), new ScheduleUnderReviewEMailAlerts(wrapList[0].caseRecord,'48 Hrs')); //Modified Job Name 24-02-2023
        System.schedule('Schedule Job For 4Days '+wrapList[0].caseRecord.CaseNumber + ' '+wrapList[0].caseRecord.LastModifiedDate,  getCronExpression(fourBusinessDays), new ScheduleUnderReviewEMailAlerts(wrapList[0].caseRecord,'4 Days')); //Modified Job Name 24-02-2023

    }
    public class GetBusinessDaysForEmailAlertsWrapper{
        @InvocableVariable public Case caseRecord;
        @InvocableVariable public DateTime flowDateTime; 
    }
    public static String getCronExpression(Datetime businessDays){
        return businessDays.second() + ' ' + businessDays.minute() + ' ' + businessDays.hour() + ' ' + businessDays.day() + ' ' + businessDays.month() + ' ? ' + businessDays.year();
    }
}