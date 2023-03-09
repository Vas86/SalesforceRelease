public class GetBusinessDays {
    @InvocableMethod(label='Get Business Hours')
    public static List<ExpiryDateWrapper> getBusinessDays(List<GetBusinessDaysWrapper> dateAndDays){
        system.debug('dateAndDays '+dateAndDays);
        Integer noOfDays = dateAndDays.get(0).noOfDays;
        DateTime approvalDate = dateAndDays.get(0).approvalDate;
                        
        BusinessHours bHours;
        bHours = [SELECT Id FROM BusinessHours WHERE Name = 'Driva'];
        system.debug(bHours);
        approvalDate = BusinessHours.nextStartDate(bHours.Id, approvalDate);
        
        for (Integer elapsed = 0; elapsed < noOfDays; elapsed++)
        {
            //Add 1 day
            approvalDate = approvalDate.addDays(1);
            
            //Check if new date is within working days
            if (!BusinessHours.isWithin(bHours.Id, approvalDate))
            { 
                //If new date is not within working days, get new working day
                approvalDate = BusinessHours.nextStartDate(bHours.Id, approvalDate);
            }
        }
        system.debug('approvalDate '+approvalDate);
        system.debug('approvalDate date part '+approvalDate.date());
        ExpiryDateWrapper expWrap = new ExpiryDateWrapper();
        Date myDate = date.newinstance(approvalDate.year(), approvalDate.month(), approvalDate.day());
        system.debug('myDate '+myDate);
        expWrap.expDate = myDate ; //approvalDate.date();
        List<ExpiryDateWrapper> expDateList = new List<ExpiryDateWrapper>();
        expDateList.add(expWrap);  
        
        return expDateList;
    }
    
    public class GetBusinessDaysWrapper{  
        @InvocableVariable
        public Integer noOfDays;
        @InvocableVariable
        public DateTime approvalDate;      
    }
    public class ExpiryDateWrapper{
        @InvocableVariable
        public Date expDate;
    }
}