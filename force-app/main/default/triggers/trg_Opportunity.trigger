trigger trg_Opportunity on Opportunity (before insert,before Update,after update) {
    if(C_AcoidRecursiveness.runAccountTrigger){
        Map<string,string> WEBToSFDC = new Map<string,string>();
        Map<string,string> SFDCToWEB = new Map<string,string>();
        Map<String, Opportunity_Stage_Transformation__mdt> oppStageTransformationMap = Opportunity_Stage_Transformation__mdt.getAll();
        for(Opportunity_Stage_Transformation__mdt transformationObj : oppStageTransformationMap.values()){
            SFDCToWEB.put(transformationObj.Label,transformationObj.Web_App_Stage__c);
            WEBToSFDC.put(transformationObj.Web_App_Stage__c,transformationObj.Label);
        }
        if(Trigger.isAfter){
            if(Trigger.isUpdate){
                for(Opportunity opp : trigger.new){
                    system.debug(':::Opp Triggered:::' + opp);
                    if(opp.StageName == 'Disqualified' ||opp.StageName == 'appointment-no-show' ||opp.StageName == 'Prescribed' ||opp.StageName == 'Shipped' ||opp.StageName == 'On Hold' )
                    {
                        if(C_AcoidRecursiveness.sendFutureCall)
                        {
                            string CustStageName = SFDCToWEB.get(opp.StageName) != null ? SFDCToWEB.get(opp.StageName) : opp.StageName; 
                            // Call @Future
                            // string EndPointURL = Label.WebAPP_BaseURL+'/webhooks/api/salesforce/customer-journey';
                            string EndPointURL = 'https://44a2-2600-1700-21f0-ff80-e9e6-952a-a0de-f70b.ngrok.io/api/webhooks/salesforce/customer-journey';
                            CC_trg_OppHandler.sendCustomerJourney(opp.AccountId,opp.Id,CustStageName,EndPointURL,'PATCH');
                            // Call @Future
                        }
                    }
                    
                }
            }
        }
        if(Trigger.isBefore){
            if(Trigger.isInsert || Trigger.isUpdate){
                for(Opportunity oppObj : trigger.new){
                    oppObj.StageName = WEBToSFDC.get(oppObj.StageName) != null ? WEBToSFDC.get(oppObj.StageName) : SFDCToWEB.get(oppObj.StageName) != null ? SFDCToWEB.get(oppObj.StageName) : oppObj.StageName;
                }
            }
        }
    }
}
//Test code change