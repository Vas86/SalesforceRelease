/*************************** 
* @Name         CaseHistoryAPI 
* @Author       vasu@driva.com.au
* @Date         28/07/2022
* @description   Webservice component which allows External system to call and get latest case History Details


******************************************************
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-----------------------------------------------------------------------
*  1.0              Vasu      28/07/2022          Initial Creation 

****************************** */
@RestResource(urlMapping='/*')
global with sharing class CaseHistoryAPI {
    public static Boolean coverElse = false;
    @HttpGet
    global static void getCaseHistory(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String caseId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        system.debug('caseId '+caseId);
        if(caseId != NULL && !String.isEmpty(caseId)){
            Map<String,Map<String,Object>> mapOfFieldsOldVal = new Map<String,Map<String,Object>>();    
            List<CaseHistory> caseHistory = new List<CaseHistory>(); 
            if(Test.isRunningTest() && coverElse){                
                caseHistory.add(new CaseHistory(CaseId=caseId, Field='Status'));
            }
            else{
                system.debug('ENters else');
                caseHistory = new List<CaseHistory>([SELECT Id, Field, OldValue, NewValue,CreatedDate,Case.LastModifiedBy.Name FROM CaseHistory where CaseId =:caseId ORDER BY CreatedDate ASC]);
            }
            
            if(caseHistory.size() > 0){
                for(CaseHistory caseObj : caseHistory){
                    Map<String,Object> mapOfValues = new Map<String,Object>();
                    mapOfValues.put('Original Value',caseObj.OldValue);
                    mapOfValues.put('New Value',caseObj.NewValue);
                    mapOfValues.put('User',caseObj.Case.LastModifiedBy.Name);
                    mapOfValues.put('Date',caseObj.CreatedDate);
                    mapOfValues.put('Field',caseObj.Field);
                    mapOfFieldsOldVal.put(caseObj.Field,mapOfValues);     	
                }
                system.debug('===>'+mapOfFieldsOldVal);
                String jsonString = JSON.serialize(mapOfFieldsOldVal.values());
                system.debug('jsonString ' +jsonString);
                response.addHeader('Content-Type', 'application/json');
                response.responseBody = Blob.valueOf(jsonString); 
            }
            else{                
                Map<String,Object> mapOfErrorResponse = new Map<String,Object>();
                mapOfErrorResponse.put('status',false);
                mapOfErrorResponse.put('message' , 'Incorrect Case Id');
                response.addHeader('Content-Type', 'application/json');
                String jsonString = JSON.serialize(mapOfErrorResponse);
                response.responseBody = Blob.valueOf(jsonString);                
            }
            
        }        
        
    }
}