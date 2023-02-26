global class CC_SetEmailForPatient implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    
    global CC_SetEmailForPatient (){
        System.debug('EventListclass :::: Testststs');
    }
    
    global Database.Querylocator start (Database.BatchableContext BC) 
    {
        System.debug('EventListclass :::: Testststsstart');
        Datetime NextDate = datetime.now().addDays(-26);
        System.debug('EventListclass ::::'+ NextDate);
        return Database.getQueryLocator([Select Id,Timezone__c,OwnerId,Owner_Name__c,Owner_Provider_Id__c,StartDateTime,EndDateTime,Appointment_Type__c,WhatId from Event where Subject = 'Meeting' and StartDateTime >=: NextDate]);
    }
    global void execute(Database.BatchableContext bc, List<Event> evntList)
    {           
        Datetime CheckDate = datetime.now();
        for(Event evt : evntList)
        {                    
            Integer daysdiff =  Date.valueOf(evt.StartDateTime).daysBetween(Date.valueOf(CheckDate));
            //if(daysdiff == 10)
            // {
            
            // }
            List<Event> evttList = new List<Event>();
            evttList = [Select Id from Event where StartDateTime >: evt.StartDateTime and WhatId =: evt.WhatId and Id !=: evt.Id and Subject = 'Meeting'];
            System.debug('daysdiff ::::'+ daysdiff + 'EventId ::::' + evt.Id + 'Listsize :::'+evttList.size());
            
            if(daysdiff == 10 && evt.Appointment_Type__c == 'new-patient')
            {
                Account accObj = [Select Id,X10_Day_Email__c from Account where Id =:evt.WhatId];
                accObj.X10_Day_Email__c = true;
                Update accObj;
            }           
            if(evttList.size() == 0 && daysdiff == 25 && evt.Appointment_Type__c == 'new-patient')
            {
                Account accObj = [Select Id,X25_Day_Email__c from Account where Id =:evt.WhatId];
                accObj.X25_Day_Email__c = true;
                Update accObj;
            }          
            if(evttList.size() == 0 && daysdiff == 25 && evt.Appointment_Type__c == 'established-patient')
            {
                Account accObj = [Select Id,Re_25_Day_Email__c from Account where Id =:evt.WhatId];
                accObj.Re_25_Day_Email__c = true;
                Update accObj;
            }
        }
    }
    global void finish(Database.BatchableContext bc){
    }   
    
}