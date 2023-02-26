trigger trg_Account on Account (after insert,after update) {
    if(C_AcoidRecursiveness.runAccountTrigger){
        if(Trigger.isAfter){
            List<Account> accList = new List<Account>();
            if(Trigger.isInsert){
                Account accObj = new Account();
                for(Account acc : trigger.new){
                    if(acc.Sent_to_Athena__c == false && acc.On_Boarding_Wizard_Completed_At_Date__c != null){
                        
                        accObj = new Account();
                        accObj.Id = acc.Id;
                        accObj.Sent_to_Athena__c  = true;
                        accList.add(accObj);
                    }
                }
                
            }
            if(Trigger.isUpdate){
                Account accObj;
                System.debug('Account after update trigger');
                for(Account acc : trigger.new){
                    if(acc.Sent_to_Athena__c == false && acc.On_Boarding_Wizard_Completed_At_Date__c != null){
                        accObj = new Account();
                        accObj.Id = acc.Id;
                        accObj.Sent_to_Athena__c  = true;
                        accList.add(accObj);
                        
                    }
                }
                
            }
            if(accList.size() > 0){
                C_AcoidRecursiveness.runAccountTrigger = false;
                update accList;
            }
                
        }
    }
}