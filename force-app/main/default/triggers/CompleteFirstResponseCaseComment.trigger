/*this sample case comment trigger marks a First Response milestone Completed( Initial Verification) when a public comment is made on the case. You can use it if a public case comment is a valid first response in your support terms.*/
trigger CompleteFirstResponseCaseComment on CaseComment (after insert) {
    if (UserInfo.getUserType() == 'Standard'){
        DateTime completionDate = System.now();
        List<Id> caseIds = new List<Id>();
        for (CaseComment cc : Trigger.new){
                if(cc.IsPublished == true)
                caseIds.add(cc.ParentId);
        }
        if (caseIds.isEmpty() == false){
            List<Case> caseList = [Select c.Id, c.ContactId, c.Contact.Email,
                    c.OwnerId, c.Status,
                    c.EntitlementId, c.SlaStartDate,
                    c.SlaExitDate
                    From Case c
                    Where c.Id IN :caseIds];
        if (caseList.isEmpty() == false){
            List<Id> updateCases = new List<Id>();
            for (Case caseObj:caseList) {
                if ((caseObj.Status == 'In Progress')&&
                        (caseObj.EntitlementId != null)&&
                        (caseObj.SlaStartDate <= completionDate)&&
                        (caseObj.SlaStartDate != null)&&
                        (caseObj.SlaExitDate == null))
                    updateCases.add(caseObj.Id);
                }
                if(updateCases.isEmpty() == false)
                    milestoneUtils.completeMilestone(updateCases, 
                    'First Response', completionDate);
            }
        }
    }
}