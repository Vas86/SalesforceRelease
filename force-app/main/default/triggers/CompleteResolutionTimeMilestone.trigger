/*This sample case trigger marks each Resolution Time milestone Completed when its case is closed. This way, the support agent doesn’t have to manually mark the milestone completed after closing the case.*/
trigger CompleteResolutionTimeMilestone on Case (after update) {
    if (UserInfo.getUserType() == 'Standard'){
        DateTime completionDate = System.now(); 
            List<Id> updateCases = new List<Id>();
            for (Case c : Trigger.new){
                    if (((c.isClosed == true)||(c.Status == 'Closed'))&&((c.SlaStartDate 
                        <= completionDate)&&(c.SlaExitDate == null)))
        updateCases.add(c.Id);
        }
    if (updateCases.isEmpty() == false)
        milestoneUtils.completeMilestone(updateCases, 'Resolution Time', completionDate);
    }
}