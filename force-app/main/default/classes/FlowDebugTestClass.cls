@isTest 
private class FlowDebugTestClass {

    static testmethod void testFlowDebug(){
        CustomExceptions cx= new CustomExceptions();
        CustomExceptions.RequiredException re = new CustomExceptions.RequiredException();
        List<String> dummyLst= new List<String>();
        dummyLst.add('AccidentalCoderSf.com');
        
        try{
            FlowDebug.getAccountIds(dummyLst);
        }
        
        catch(exception e){
        }
    }
   
}