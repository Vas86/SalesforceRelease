trigger trackCaseHistory on Case (before update )
{
  Map<string, Schema.SobjectField> caseFields = Schema.SObjectType.Case.fields.getMap();

  case caseold=trigger.old[0];
  For (Case cs : Trigger.new)
  {
    for (string fieldName : caseFields.keySet())
     {
       
        if ( cs.get(fieldName) != Trigger.oldMap.get(cs.id).get(fieldName))
        {
           // cs.Track_status_history__c = 'Field ' + fieldName + ' changed from ' + string.valueOf(Trigger.oldMap.get(cs.id).get(fieldName)) + ' to '  +string.valueOf(cs.get(fieldName));
             string oldvalue = string.valueOf(caseold.get(fieldName));
            
             string newvalue= string.valueOf(cs.get(fieldName));
           
             cs.Track_status_history__c = 'Changed '+fieldName +' From '+oldvalue +' to '+ newvalue;
         
             break;
          }   
       }
  }
}