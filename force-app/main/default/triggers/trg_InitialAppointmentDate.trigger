trigger trg_InitialAppointmentDate on Event (after insert,after update) {
    if(Trigger.isAfter){
        List<Account> accList = new List<Account>();
        if(Trigger.isInsert){
            for(Event evt : trigger.new)
            {
                if(evt.Appointment_Type__c == 'new-patient')
                {
                    List<Account> accList1 = [Select Id,InitialAppointmentDate__c from Account where Id =:evt.WhatId];
                    if(accList1.size() > 0){
                    accList1[0].InitialAppointmentDate__c = Date.valueOf(evt.StartDateTime);
                    accList.add(accList1[0]);
                    }
                }
            }
        }
        if(Trigger.isUpdate){
            for(Event evt : trigger.new)
            {
                if(evt.Appointment_Type__c == 'new-patient')
                {
                     List<Account> accList2 = [Select Id,InitialAppointmentDate__c from Account where Id =:evt.WhatId];
                    if(accList2.size() > 0){
                    accList2[0].InitialAppointmentDate__c = Date.valueOf(evt.StartDateTime);
                    accList.add(accList2[0]);
                    }
                }
            }
        }
        if(accList.size() > 0){
            update accList;
        }
    }
}