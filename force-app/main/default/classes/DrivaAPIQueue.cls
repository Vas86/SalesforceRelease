public class DrivaAPIQueue implements System.Queueable, Database.AllowsCallouts
{
    private String endpoint;
    private String method;
    private String objType;
    private String id;
    private String objJson;
    private Set<String> objIds;
    // Added on 2/02/2023
    private List<String> fieldName;
    private List<String> sids;     //Limit Exception fix
    
    
    public DrivaAPIQueue(String endpoint, String method, String objType, SObject obj) {
        this.endpoint = endpoint;
        this.method = method;
        this.objType = objType;
        this.objJson = JSON.serialize(obj);
    }
    
    public DrivaAPIQueue(String endpoint, String method, String objType, String id) {
        this.endpoint = endpoint;
        this.method = method;
        this.objType = objType;
        this.id = id;
    }

    //Limit Exception Fix
    public DrivaAPIQueue(String endpoint, String method, String objType, Set<String> ids, List<String> fieldNames) {
        this.endpoint = endpoint;
        this.method = method;
        this.objType = objType;
        this.objIds = ids;
        // Added on 2/02/2023
		this.fieldName = fieldNames;
        System.debug('fieldName>>'+this.fieldName);
    }

   /* public DrivaAPIQueue(String endpoint, String method, String objType,Set<String> ids, List<String> ids1) {
        this.endpoint = endpoint;
        this.method = method;
        this.objType = objType;
        this.objIds = ids;
        this.sids = ids1;
    } */
    
    
    public List<Sobject> getObjectFields() {
        // Get the Map of Schema of Account SObject
        Map<String, Schema.SObjectField> fieldMap;
        
        switch on this.objType {
            when 'Case' {
                fieldMap = Case.sObjectType.getDescribe().fields.getMap();
            } 
            when 'Contact' {
                fieldMap = Contact.sObjectType.getDescribe().fields.getMap();
            } 
            when 'Note__c' {
                fieldMap = Note__c.sObjectType.getDescribe().fields.getMap();
            } 
            when 'Additional_Income__c' {
                fieldMap = Additional_Income__c.sObjectType.getDescribe().fields.getMap();
            } 
            when 'Liability__c' {
                fieldMap = Liability__c.sObjectType.getDescribe().fields.getMap();
            } 
        }
        
		// Added on: 1/02/2023
        List<syncToDrivaDB_DynamicFields__mdt> mtd = [Select syncFields__c, syncObject__c from
                                                   	syncToDrivaDB_DynamicFields__mdt WHERE syncObject__c =: this.objType];
                
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
    	list<String> lstFieldNames = new List<String>(setFieldNames);
        
		// Added on: 1/02/2023-- This is used when we have to add only the fields in custom metadata SF( whitelist fields) in request payload to DB from SF
      /*  if(this.fieldName != null){
            lstFieldNames = this.fieldName;
            System.debug('lstFieldNames>>'+lstFieldNames);
        }*/
        
        String query;
        // Dynamic Query String.
        if (String.isNotBlank(this.id)){
            query = 'SELECT '+String.join(lstFieldNames, ',')+' FROM '+this.objType+' WHERE Id = \''+this.id+'\' LIMIT 1';
        }
        
        else {
            Set<String> objectIds = this.objIds;
            query = 'SELECT '+String.join(lstFieldNames, ',')+' FROM '+this.objType+' WHERE Id IN :objectIds';
        }

        List<Sobject> objRecords = Database.query(query); 
        system.debug('Request object records'+objRecords);       
        return objRecords;
       
    }
    
    public void execute(System.QueueableContext objContext)
    {
        string reqBody = '';
        if (String.isNotBlank(this.objJson)) {
            reqBody = this.objJson;
            System.debug('reqBody'+reqBody);
        } 
        else {
            reqBody = JSON.serialize(getObjectFields()); 
            system.debug('request payload'+reqBody);
        }
      
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        // Use NamedCredentials & callout to get Bearer JWT
        string url = 'callout:Salesforce_Service' + this.endpoint;

        request.setEndpoint(url);
        request.setMethod(this.method);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');        
        request.setBody(reqBody);

        // Merge fields after setBody
        request.setHeader('Authorization', '{!$Credential.Password}');
        
        request.setTimeout(120000);

        HttpResponse response = http.send(request);
        //check the response
        if (response.getStatusCode() == 200) {
            System.debug('Sync to Driva DB successed');
        } else {
            System.debug('Sync to Driva DB failed: ' + response);
        }
    
    }//Limit Fix
    
}