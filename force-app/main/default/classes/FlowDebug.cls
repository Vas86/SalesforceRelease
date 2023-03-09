global class FlowDebug {
   
    @InvocableMethod
    public static list<string> getAccountIds(list<string> check) {
        
        throw new CustomExceptions.RequiredException('This is a dummy Exception to Debug Flow. Check Email for Flow Log');

   }
}