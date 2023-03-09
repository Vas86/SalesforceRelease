public class CaseQueable implements Queueable {
    public List<Case> caseList ; 
    public CaseQueable(List<Case> caseList){
        this.caseList = caseList ; 
        System.debug('@@thiscaseListCons'+ this.caseList);
    }
    public void execute(QueueableContext context) {
        /*for(Case cas :caseList){
          cas.Sub_Status__c = 'Correspondence Received'; 
        }
        System.debug('@@caseListjust'+caseList);*/
        try{
            if(caseList.size() > 0)
        	update caseList;
        }
        catch(Exception e){
            List<Error_Handler__c> Errors = new List<Error_Handler__c>();
            Error_Handler__c Error = new Error_Handler__c();
            Error.Response_Message__c = e.getMessage();
            Errors.add(Error);
            
            IF(Errors.size()>0){
                INSERT Errors;
            }
            
            system.debug(e);
        }
    }
}