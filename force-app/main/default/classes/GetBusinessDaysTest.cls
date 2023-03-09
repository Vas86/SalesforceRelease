@isTest
public class GetBusinessDaysTest {
    @isTest
    public static void getBusinessDaysTest(){
        GetBusinessDays.GetBusinessDaysWrapper flowInput = new GetBusinessDays.GetBusinessDaysWrapper();
        flowInput.noOfDays = 10;
        flowInput.approvalDate = DateTime.now();
       	GetBusinessDays.getBusinessDays(
            new List<GetBusinessDays.GetBusinessDaysWrapper>{flowInput}
        );
        
    }
   
}