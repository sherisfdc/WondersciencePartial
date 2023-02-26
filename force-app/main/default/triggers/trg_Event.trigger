trigger trg_Event on Event (before update,before insert , after update , after insert , after delete) {
    
    if(C_AcoidRecursiveness.runEventTrigger)
    {
        if(Trigger.isBefore){
            
            if(Trigger.isUpdate){
                if(System.URL.getCurrentRequestUrl().getPath() != '/services/apexrest/CalendarIntegration')
                {
                    for(Event evt : trigger.new)
                    {
                        system.debug('DurationInMinutes of new Event :::' + evt.DurationInMinutes);
                        
                        string newSubject = evt.Subject;
                        /*if(newSubject == 'Meeting' && evt.Appointment_Type__c == 'new-patient' && evt.DurationInMinutes != 45)
                        {
                            System.debug('Come in condition');
                             evt.addError('APPOINTMENT DURATION SHOULD BE 45 MINUTES FOR NEW-PATIENT');
                        }
                        else if(newSubject == 'Meeting' && evt.Appointment_Type__c == 'established-patient' && evt.DurationInMinutes != 30)
                        {
                             evt.addError('APPOINTMENT DURATION SHOULD BE 30 MINUTES FOR ESTABLISHED-PATIENT');
                        }*/
                        List<Event> eventList = [Select Id,StartDateTime,EndDateTime,OwnerId,Subject from Event where 
                                                 Id !=: evt.Id and OwnerId =: evt.OwnerId and 
                                                 ((StartDateTime =: evt.StartDateTime or EndDateTime =:evt.EndDateTime) 
                                                 // or (StartDateTime >: evt.StartDateTime and StartDateTime <:evt.EndDateTime) 
                                                 // or (EndDateTime >: evt.StartDateTime and EndDateTime <:evt.EndDateTime)  
                                                  or (StartDateTime <: evt.StartDateTime and EndDateTime >:evt.EndDateTime))];
                        system.debug('eventList ::::'+eventList);
                        system.debug('listsize ::::'+eventList.size());
                        system.debug('URL :::' +System.URL.getCurrentRequestUrl().getPath());
                        if(eventList.size() > 0)
                        {   
                            Timezone gmttz = Timezone.getTimeZone('GMT');
                            Integer GMTTimeDifferenceWithGMT = gmttz.getOffset(eventList[0].StartDateTime);
                            GMTTimeDifferenceWithGMT = GMTTimeDifferenceWithGMT/1000;
                            
                            Datetime eventstarttimeusertz = eventList[0].StartDateTime.addseconds(GMTTimeDifferenceWithGMT);
                            Datetime eventendtimeusertz = eventList[0].EndDateTime.addseconds(GMTTimeDifferenceWithGMT);
                            
                            Datetime neweventstarttimeusertz = evt.StartDateTime.addseconds(GMTTimeDifferenceWithGMT);
                            Datetime neweventendtimeusertz = evt.EndDateTime.addseconds(GMTTimeDifferenceWithGMT);
                            
                            if(eventList.size() == 1)
                            {
                                if(eventList[0].Subject == 'Availability' && newSubject == 'Meeting')
                                {
                                    if(eventstarttimeusertz == neweventstarttimeusertz && eventendtimeusertz == neweventendtimeusertz)
                                    {
                                        delete eventList[0];
                                    }
                                    else if(eventstarttimeusertz == neweventstarttimeusertz)
                                    {
                                        if(eventendtimeusertz > neweventendtimeusertz)
                                        {
                                            eventList[0].StartDateTime = neweventendtimeusertz;
                                            update eventList[0];
                                        }
                                        else
                                        {
                                            delete eventList[0];
                                        }
                                    }
                                    else if(eventendtimeusertz == neweventendtimeusertz)
                                    {
                                        if(eventstarttimeusertz < neweventstarttimeusertz)
                                        {
                                            eventList[0].EndDateTime = neweventstarttimeusertz;
                                            update eventList[0];
                                        }
                                        else
                                        {
                                            delete eventList[0];
                                        }
                                    }
                                    else
                                    {   
                                        if(eventstarttimeusertz > neweventstarttimeusertz && eventendtimeusertz > neweventendtimeusertz)
                                        {
                                            eventList[0].StartDateTime = neweventendtimeusertz;
                                            update eventList[0];
                                        }
                                        else
                                        {
                                            eventList[0].EndDateTime = neweventstarttimeusertz;
                                            update eventList[0];
                                        }
                                        
                                        if(eventstarttimeusertz < neweventstarttimeusertz && eventendtimeusertz > neweventendtimeusertz)
                                        {
                                            system.debug('Last else :::: Come in');
                                            Event eventObjNew = new Event();
                                            system.debug('evt.EndDateTime::' + evt.EndDateTime);
                                            system.debug('evt.EndDateTime::' +eventList[0].EndDateTime);
                                            eventObjNew.StartDateTime =neweventendtimeusertz;
                                            eventObjNew.EndDateTime = eventendtimeusertz ;  
                                            eventObjNew.OwnerId = eventList[0].OwnerId;
                                            eventObjNew.Subject = 'Availability';
                                            eventObjNew.ShowAs = 'Free';
                                            eventObjNew.Send_To_Athena__c = true;
                                            Insert eventObjNew;
                                        }
                                        
                                        
                                    }
                                }
                                else
                                {
                                    evt.addError('EVENT CANNOT BE CREATED BECAUSE EXISTING EVENT IS OVERLAPPING');
                                }
                            }
                            else if(eventList.size() == 2)
                            {
                                System.debug('2 Events Found '+ eventList[0].Subject + ' AND '+ eventList[1].Subject);
                                if(eventList[0].Subject == 'Availability' && eventList[1].Subject == 'Availability' && newSubject == 'Meeting')
                                {
                                    Datetime secondeventstarttimeusertz = eventList[1].StartDateTime.addseconds(GMTTimeDifferenceWithGMT);
                                    Datetime secondeventendtimeusertz = eventList[1].EndDateTime.addseconds(GMTTimeDifferenceWithGMT);
                                    
                                    if(eventstarttimeusertz < neweventstarttimeusertz && eventendtimeusertz > neweventstarttimeusertz && secondeventstarttimeusertz < neweventendtimeusertz && secondeventendtimeusertz > neweventendtimeusertz)
                                    {
                                        eventList[0].EndDateTime = neweventstarttimeusertz;
                                        update eventList[0];
                                        
                                        eventList[1].StartDateTime = neweventendtimeusertz;
                                        update eventList[1];
                                    }
                                    if(secondeventstarttimeusertz < neweventstarttimeusertz && secondeventendtimeusertz > neweventstarttimeusertz && eventstarttimeusertz < neweventendtimeusertz && eventendtimeusertz > neweventendtimeusertz)
                                    {
                                        eventList[1].EndDateTime = neweventstarttimeusertz;
                                        update eventList[1];
                                        
                                        eventList[0].StartDateTime = neweventendtimeusertz;
                                        update eventList[0];
                                    }
                                }
                                else
                                {
                                    evt.addError('EVENT CANNOT BE CREATED BECAUSE EXISTING EVENT IS OVERLAPPING');
                                }
                            }
                        }
                        else
                        {
                            /*boolean flaggerror = true;
                            for(Event evtold : trigger.old)
                            {
                                if((evtold.StartDateTime <= evt.StartDateTime && evtold.EndDateTime == evt.EndDateTime)||(evtold.StartDateTime == evt.StartDateTime && evtold.EndDateTime <= evt.EndDateTime))
                                {
                                  flaggerror = false;  
                                }
                            }*/
                            if(newSubject == 'Meeting' && C_AcoidRecursiveness.callTowebhook == true)
                           {
                              System.debug('Came in event trigger to show error message '+ C_AcoidRecursiveness.callTowebhook);
                              evt.addError('PLEASE CREATE AVAILABILITY AT DESIRED TIME BEFORE CREATING A MEETING !');  
                           }
                       }
                    }
                }
            }
            if(Trigger.isInsert)
            {
                if(System.URL.getCurrentRequestUrl().getPath() != '/services/apexrest/CalendarIntegration')
                {
                    List<Event> evttlist = [Select Id,Subject,StartDateTime,EndDateTime,OwnerId from Event];
                    Map<Id,Event> Eventmap = new Map<Id,Event>();
                    for(Event evttob : evttlist)
                    {
                        Eventmap.put(evttob.Id,evttob);
                    }
                    for(Event evt : trigger.new)
                    {
                        system.debug('DurationInMinutes of new Event :::' + evt.DurationInMinutes);
                        string newSubject = evt.Subject;
                        /*if(newSubject == 'Meeting' && evt.Appointment_Type__c == 'new-patient' && evt.DurationInMinutes != 45)
                        {
                             evt.addError('APPOINTMENT DURATION SHOULD BE 45 MINUTES FOR NEW-PATIENT');
                        }
                        else if(newSubject == 'Meeting' && evt.Appointment_Type__c == 'established-patient' && evt.DurationInMinutes != 30)
                        {
                             evt.addError('APPOINTMENT DURATION SHOULD BE 30 MINUTES FOR ESTABLISHED-PATIENT');
                        }*/
                        //List<Event> eventList = [Select Id,Subject,StartDateTime,EndDateTime,OwnerId from Event where 
                                                // Id !=: evt.Id and OwnerId =: evt.OwnerId and 
                                               //  ((StartDateTime =: evt.StartDateTime or EndDateTime =:evt.EndDateTime) 
                                               //   //or (StartDateTime >: evt.StartDateTime and StartDateTime <:evt.EndDateTime) 
                                               //   //or (EndDateTime >: evt.StartDateTime and EndDateTime <:evt.EndDateTime)  
                                                //  or (StartDateTime <: evt.StartDateTime and EndDateTime >:evt.EndDateTime)
                                                //  or (StartDateTime <: evt.StartDateTime and EndDateTime >:evt.StartDateTime)
                                                // or (StartDateTime <: evt.EndDateTime and EndDateTime >:evt.EndDateTime))];
                        List<Event> eventList = new List<Event>();
                        
                        for (Id key : Eventmap.keySet()) {
                            Event eventObject = Eventmap.get(key);
                            if(eventObject.Id != evt.Id && eventObject.OwnerId == evt.OwnerId && ((eventObject.StartDateTime == evt.StartDateTime || eventObject.EndDateTime == evt.EndDateTime) || (eventObject.StartDateTime < evt.StartDateTime && eventObject.EndDateTime > evt.EndDateTime) || (eventObject.StartDateTime < evt.StartDateTime && eventObject.EndDateTime > evt.StartDateTime) || (eventObject.StartDateTime < evt.EndDateTime && eventObject.EndDateTime > evt.EndDateTime)))
                            {
                              eventList.add(eventObject);  
                            }
                        }
                        
                        
                        integer listsize = eventList.size();
                        system.debug('listsize Insert :::' +listsize);
                        system.debug('URL :::' +System.URL.getCurrentRequestUrl().getPath());
                        if(listsize > 0)
                        {
                            Timezone gmttz = Timezone.getTimeZone('GMT');
                            Integer GMTTimeDifferenceWithGMT = gmttz.getOffset(eventList[0].StartDateTime);
                            GMTTimeDifferenceWithGMT = GMTTimeDifferenceWithGMT/1000;
                            
                            Datetime eventstarttimeusertz = eventList[0].StartDateTime.addseconds(GMTTimeDifferenceWithGMT);
                            Datetime eventendtimeusertz = eventList[0].EndDateTime.addseconds(GMTTimeDifferenceWithGMT);
                            
                            Datetime neweventstarttimeusertz = evt.StartDateTime.addseconds(GMTTimeDifferenceWithGMT);
                            Datetime neweventendtimeusertz = evt.EndDateTime.addseconds(GMTTimeDifferenceWithGMT);
                            if(listsize == 1)
                            {
                                if(eventList[0].Subject == 'Availability' && newSubject == 'Meeting')
                                {
                                    if(eventstarttimeusertz == neweventstarttimeusertz && eventendtimeusertz == neweventendtimeusertz)
                                    {
                                        System.debug('Comes here to delete because start and end time are same insert');
                                        delete eventList[0];
                                    }
                                    else if(eventstarttimeusertz == neweventstarttimeusertz)
                                    {
                                        eventList[0].StartDateTime = neweventendtimeusertz;
                                        update eventList[0];
                                    }
                                    else if(eventendtimeusertz == neweventendtimeusertz)
                                    {
                                        eventList[0].EndDateTime = neweventstarttimeusertz;
                                        update eventList[0];
                                    }
                                    else
                                    {                               
                                        system.debug('Existing Available event StartDateTime ::::' + eventList[0].StartDateTime);
                                        system.debug('Existing Available event EndDateTime :::::' + eventList[0].EndDateTime);
                                        system.debug('New Meeting event StartDateTime :::::' + evt.StartDateTime);
                                        system.debug('New Meeting event EndDateTime :::::' + evt.EndDateTime);
                                        
                                        //eventList[0].EndDateTime = evt.StartDateTime;
                                        //update eventList[0];
                                        
                                        //Event eventObjNew = new Event();
                                        //eventObjNew.StartDateTime = neweventendtimeusertz;
                                        //eventObjNew.EndDateTime = eventendtimeusertz;
                                        //eventObjNew.OwnerId = eventList[0].OwnerId;
                                        //eventObjNew.Subject = 'Availability';
                                        //eventObjNew.ShowAs = 'Free';
                                        //Insert eventObjNew;
                                        
                                        //Update Code of this section
                                        if(eventstarttimeusertz > neweventstarttimeusertz && eventendtimeusertz > neweventendtimeusertz)
                                        {
                                            eventList[0].StartDateTime = neweventendtimeusertz;
                                            update eventList[0];
                                        }
                                        else
                                        {
                                            eventList[0].EndDateTime = neweventstarttimeusertz;
                                            update eventList[0];
                                        }
                                        
                                        if(eventstarttimeusertz < neweventstarttimeusertz && eventendtimeusertz > neweventendtimeusertz)
                                        {
                                            system.debug('Last else :::: Come in');
                                            Event eventObjNew = new Event();
                                            system.debug('evt.EndDateTime::' + evt.EndDateTime);
                                            system.debug('evt.EndDateTime::' +eventList[0].EndDateTime);
                                            eventObjNew.StartDateTime =neweventendtimeusertz;
                                            eventObjNew.EndDateTime = eventendtimeusertz ;  
                                            eventObjNew.OwnerId = eventList[0].OwnerId;
                                            eventObjNew.Subject = 'Availability';
                                            eventObjNew.ShowAs = 'Free';
                                            eventObjNew.Send_To_Athena__c = true;
                                            Insert eventObjNew;
                                        }
                                        //Update Code of this section
                                        
                                    }
                                }
                                else
                                {
                                    evt.addError('EVENT CANNOT BE CREATED BECAUSE EXISTING EVENT IS OVERLAPPING');
                                }
                            }      
                            else if(listsize == 2)
                            {
                                if(eventList[0].Subject == 'Availability' && eventList[1].Subject == 'Availability' && newSubject == 'Meeting')
                                {
                                    Datetime secondeventstarttimeusertz = eventList[1].StartDateTime.addseconds(GMTTimeDifferenceWithGMT);
                                    Datetime secondeventendtimeusertz = eventList[1].EndDateTime.addseconds(GMTTimeDifferenceWithGMT);
                                    
                                    if(eventstarttimeusertz < neweventstarttimeusertz && eventendtimeusertz > neweventstarttimeusertz && secondeventstarttimeusertz < neweventendtimeusertz && secondeventendtimeusertz > neweventendtimeusertz)
                                    {
                                        eventList[0].EndDateTime = neweventstarttimeusertz;
                                        update eventList[0];
                                        
                                        eventList[1].StartDateTime = neweventendtimeusertz;
                                        update eventList[1];
                                    }
                                    if(secondeventstarttimeusertz < neweventstarttimeusertz && secondeventendtimeusertz > neweventstarttimeusertz && eventstarttimeusertz < neweventendtimeusertz && eventendtimeusertz > neweventendtimeusertz)
                                    {
                                        eventList[1].EndDateTime = neweventstarttimeusertz;
                                        update eventList[1];
                                        
                                        eventList[0].StartDateTime = neweventendtimeusertz;
                                        update eventList[0];
                                    }
                                }
                                else
                                {
                                    evt.addError('EVENT CANNOT BE CREATED BECAUSE EXISTING EVENT IS OVERLAPPING');
                                }
                            }
                        }
                        else
                        {
                            if(newSubject == 'Meeting')
                            {
                              evt.addError('PLEASE CREATE AVAILABILITY AT DESIRED TIME BEFORE CREATING A MEETING !');  
                            }
                        }
                    }
                }
            }      
        }
        
        if(Trigger.isAfter)
        {
            if(Trigger.isUpdate)
            {
                if(System.URL.getCurrentRequestUrl().getPath() != '/services/apexrest/CalendarIntegration')
                {
                    
                    string PreviousStartDateTime = '';
                    
                    Datetime NewEvStartDateTime;
                    Datetime NewEvEndDateTime;
                    Datetime OldEvStartDateTime;
                    Datetime OldEvEndDateTime;
                    for(Event evt : trigger.new)
                    {
                        NewEvStartDateTime = evt.StartDateTime;
                        NewEvEndDateTime = evt.EndDateTime;
                    }
                    
                    for(Event evt : trigger.old)
                    {
                        PreviousStartDateTime = evt.StartDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                        OldEvStartDateTime = evt.StartDateTime;
                        OldEvEndDateTime = evt.EndDateTime;
                        
                        Timezone gmttz = Timezone.getTimeZone('GMT');
                        Integer GMTTimeDifferenceWithGMT = gmttz.getOffset(evt.StartDateTime);
                        GMTTimeDifferenceWithGMT = GMTTimeDifferenceWithGMT/1000;
                        
                        Datetime nexteventstarttimeusertz;
                        Datetime nexteventendtimeusertz;
                        Datetime previouseventstarttimeusertz;
                        Datetime previouseventendtimeusertz;
                        
                        datetime currenteventstarttimeusertz = evt.StartDateTime.addseconds(GMTTimeDifferenceWithGMT);
                        datetime currenteventendtimeusertz = evt.EndDateTime.addseconds(GMTTimeDifferenceWithGMT);
                        
                        datetime neweventstarttimeusertz = NewEvStartDateTime.addseconds(GMTTimeDifferenceWithGMT);
                        datetime neweventendtimeusertz = NewEvEndDateTime.addseconds(GMTTimeDifferenceWithGMT);
                        
                        
                        //Change Appointment to Availability on update start
                        if(evt.Subject == 'Meeting')
                        {
                            if(NewEvStartDateTime >= OldEvEndDateTime || NewEvEndDateTime <= OldEvStartDateTime)
                            {
                                System.debug('Before Update After old Triggered');
                                String providerId = evt.OwnerId;
                                List<Event> previousEventList = [Select Id,StartDateTime,EndDateTime,OwnerId from Event where EndDateTime = :evt.StartDateTime and Subject = 'Availability' and OwnerId =: providerId];
                                List<Event> nextEventList = [Select Id,StartDateTime,EndDateTime,OwnerId from Event where StartDateTime = :evt.EndDateTime and Subject = 'Availability' and OwnerId =: providerId];
                                
                                if(nextEventList.size() > 0)
                                {
                                    nexteventstarttimeusertz = nextEventList[0].StartDateTime.addseconds(GMTTimeDifferenceWithGMT);
                                    nexteventendtimeusertz = nextEventList[0].EndDateTime.addseconds(GMTTimeDifferenceWithGMT);
                                }
                                
                                if(previousEventList.size() > 0)
                                {
                                    previouseventstarttimeusertz = previousEventList[0].StartDateTime.addseconds(GMTTimeDifferenceWithGMT);
                                    previouseventendtimeusertz = previousEventList[0].EndDateTime.addseconds(GMTTimeDifferenceWithGMT);
                                }
                                
                                if(previousEventList.size() > 0 && nextEventList.size() > 0){
                                    previousEventList[0].EndDateTime = nexteventendtimeusertz;
                                    previousEventList[0].Send_To_Athena__c = true;
                                    delete nextEventList[0];
                                    update previousEventList[0];                                   
                                }
                                else if(previousEventList.size() > 0){
                                    previousEventList[0].EndDateTime = currenteventendtimeusertz;
                                    previousEventList[0].Send_To_Athena__c = true;
                                    update previousEventList[0];
                                }
                                else if(nextEventList.size() > 0){
                                    nextEventList[0].StartDateTime = currenteventstarttimeusertz;
                                    nextEventList[0].Send_To_Athena__c = true;
                                    update nextEventList[0];
                                }
                                else
                                {
                                    Event eventObjNew = new Event();
                                    eventObjNew.StartDateTime = currenteventstarttimeusertz;
                                    eventObjNew.EndDateTime = currenteventendtimeusertz;
                                    eventObjNew.OwnerId = evt.OwnerId;
                                    eventObjNew.Subject = 'Availability';
                                    eventObjNew.ShowAs = 'Free';
                                    Insert eventObjNew;
                                }
                            }
                            else if(NewEvStartDateTime > OldEvStartDateTime)
                            {
                                List<Event> previousEventList = [Select Id,StartDateTime,EndDateTime,OwnerId from Event where EndDateTime = :currenteventstarttimeusertz and Subject = 'Availability' and OwnerId =: evt.OwnerId];
                                if(previousEventList.size() > 0)
                                {
                                    previousEventList[0].EndDateTime = neweventstarttimeusertz;
                                    previousEventList[0].Send_To_Athena__c = true;
                                    update previousEventList[0];
                                }
                                else
                                {
                                    Event eventObjNew = new Event();
                                    eventObjNew.StartDateTime = currenteventstarttimeusertz;
                                    eventObjNew.EndDateTime = neweventstarttimeusertz;
                                    eventObjNew.OwnerId = evt.OwnerId;
                                    eventObjNew.Subject = 'Availability';
                                    eventObjNew.ShowAs = 'Free';
                                    Insert eventObjNew;
                                }                               
                            }
                        }
                        //Change Appointment to Availability on update end
                    }
                    for(Event evt : trigger.new)
                    {
                        if(evt.Subject == 'Meeting')
                        {    
                            List<Account> accList = [Select Id , ShippingState from Account where Id =: evt.AccountId];
                            string PatientShippingState = '';
                            if(accList.size() > 0)
                            {
                                PatientShippingState = accList[0].ShippingState;
                            }
                            string NewStartDateTime = evt.StartDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                            
                            Integration__c aIntegeration = new Integration__c();
                            aIntegeration.Data_for_Athena__c = '{"ProviderUsername":"","PreviousDateTime":"'+PreviousStartDateTime+'","PatientState":"'+PatientShippingState+'","PatientAthenaId":null,"NewStartDateTime":"'+NewStartDateTime+'","Duration":'+evt.DurationInMinutes+',"AppointmentType":"'+evt.Appointment_Type__c+'"}';
                            aIntegeration.Payload__c = '{"id":"'+evt.Id+'","startTime":"'+NewStartDateTime+'","providerId":"'+evt.OwnerId+'","patientId":"'+evt.AccountId+'","zoomMeetingUrl":"","appointmentType":"'+evt.Appointment_Type__c+'","duration":"'+evt.DurationInMinutes+'"}';
                            aIntegeration.Method_Action__c = 'PATCH';
                            aIntegeration.Status_Code__c = '200';
                            aIntegeration.Class_Name__c = 'CC_API_CalendarIntegration';
                            aIntegeration.Record_Ids__c = 'EventId : ' + evt.Id + ', ProviderId : '+ evt.OwnerId + ', PatientId : '+evt.AccountId;
                            insert aIntegeration;
                            
                            if(C_AcoidRecursiveness.sendFutureCall)
                            {
                            //Call @Future
                            string EndPointURL = Label.WebAPP_BaseURL+'api/webhooks/salesforce/appointments';
                            CC_trg_EventHandler.sendEventInfo(accList[0].Id,evt.OwnerId,NewStartDateTime,evt.Id,'PATCH',EndPointURL,'',evt.DurationInMinutes);
                            //Call @Future
                            }
                        }
                        else if(evt.Subject == 'Availability')
                        {
                            List<Event> eventListA = [Select Id,Subject,StartDateTime,EndDateTime,OwnerId from Event where Subject = 'Availability' and Id !=: evt.Id and OwnerId =: evt.OwnerId and ((StartDateTime =: evt.EndDateTime) or (EndDateTIme =: evt.StartDateTime))];
                            
                            List<Event> CurrEvnt = [Select Id,Subject,StartDateTime,EndDateTime,OwnerId from Event where Id =: evt.Id];
                            if(eventListA.size() > 0)
                            {
                                if(evt.EndDateTime == eventListA[0].StartDateTime)
                                {
                                    C_AcoidRecursiveness.runEventTrigger = false;
                                    eventListA[0].StartDateTime =  evt.StartDateTime;
                                    update eventListA[0];
                                    delete CurrEvnt[0];
                                }
                                else if(evt.StartDateTime == eventListA[0].EndDateTime)
                                {
                                    C_AcoidRecursiveness.runEventTrigger = false;
                                    eventListA[0].EndDateTime =  evt.EndDateTime;
                                    update eventListA[0];
                                    delete CurrEvnt[0];
                                }
                            }
                        }
                    }
                }
            }
            if(Trigger.isInsert)
            {
                if(System.URL.getCurrentRequestUrl().getPath() != '/services/apexrest/CalendarIntegration')
                {
                    List<Event> evttlist = [Select Id,Subject,StartDateTime,EndDateTime,OwnerId from Event where Subject = 'Availability'];
                    Map<Id,Event> Eventmap = new Map<Id,Event>();
                    for(Event evttob : evttlist)
                    {
                        Eventmap.put(evttob.Id,evttob);
                    }
                    for(Event evt : trigger.new)
                    {
                        System.debug('Subject New After Trigger :::' + evt.Subject);
                        if(evt.Subject == 'Meeting')
                        {
                            List<Account> accList = [Select Id , ShippingState from Account where Id =: evt.AccountId];
                            string PatientShippingState = '';
                            if(accList.size() > 0)
                            {
                                PatientShippingState = accList[0].ShippingState;
                            }
                            string NewStartDateTime = evt.StartDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                            Integration__c aIntegeration = new Integration__c();
                            aIntegeration.Data_for_Athena__c = '{"ProviderUsername":"","PreviousDateTime":"","PatientState":"'+PatientShippingState+'","PatientAthenaId":null,"NewStartDateTime":"'+NewStartDateTime+'","Duration":'+evt.DurationInMinutes+',"AppointmentType":"'+evt.Appointment_Type__c+'"}';
                            aIntegeration.Payload__c = '{"startTime":"'+NewStartDateTime+'","providerId":"'+evt.OwnerId+'","patientId":"'+evt.AccountId+'","zoomMeetingUrl":"","appointmentType":"'+evt.Appointment_Type__c+'","duration":"'+evt.DurationInMinutes+'"}';
                            aIntegeration.Method_Action__c = 'POST';
                            aIntegeration.Status_Code__c = '200';
                            aIntegeration.Class_Name__c = 'CC_API_CalendarIntegration';
                            aIntegeration.Record_Ids__c = 'EventId : ' + evt.Id + ', ProviderId : '+ evt.OwnerId + ', PatientId : '+evt.AccountId;
                            insert aIntegeration;
                            if(C_AcoidRecursiveness.sendFutureCall)
                            {
                            //Call @Future
                            string EndPointURL = Label.WebAPP_BaseURL+'api/webhooks/salesforce/appointments';
                            CC_trg_EventHandler.sendEventInfo(accList[0].Id,evt.OwnerId,NewStartDateTime,evt.Id,'POST',EndPointURL,evt.Appointment_Type__c,evt.DurationInMinutes);
                            //Call @Future
                            }
                        }
                        else if(evt.Subject == 'Availability')
                        {
                            //List<Event> eventListA = [Select Id,Subject,StartDateTime,EndDateTime,OwnerId from Event where Subject = 'Availability' and Id !=: evt.Id and OwnerId =: evt.OwnerId and ((StartDateTime =: evt.EndDateTime) or (EndDateTIme =: evt.StartDateTime))];
                            List<Event> eventListA = new List<Event>(); 
                            List<Event> CurrEvnt = new List<Event>(); 
                            for (Id key : Eventmap.keySet()) {
                            Event eventObject = Eventmap.get(key);
                            if(eventObject.Id != evt.Id && eventObject.OwnerId == evt.OwnerId && ((eventObject.StartDateTime == evt.EndDateTime || eventObject.EndDateTime == evt.StartDateTime)))
                            {
                              eventListA.add(eventObject);  
                            }
                            if(eventObject.Id == evt.Id)
                            {
                              CurrEvnt.add(eventObject);  
                            }
                        }
                            if(eventListA.size() > 0)
                            {
                                if(evt.EndDateTime == eventListA[0].StartDateTime)
                                {
                                    C_AcoidRecursiveness.runEventTrigger = false;
                                    eventListA[0].StartDateTime =  evt.StartDateTime;
                                    update eventListA[0];
                                    delete CurrEvnt[0];
                                }
                                else if(evt.StartDateTime == eventListA[0].EndDateTime)
                                {
                                    C_AcoidRecursiveness.runEventTrigger = false;
                                    eventListA[0].EndDateTime =  evt.EndDateTime;
                                    update eventListA[0];
                                    delete CurrEvnt[0];
                                }
                            }
                        }
                    }
                }
            }
            if(Trigger.isDelete)
            {
                if(System.URL.getCurrentRequestUrl().getPath() != '/services/apexrest/CalendarIntegration')
                {
                    for(Event evt : trigger.old)
                    {
                        if(evt.Subject == 'Meeting')
                        {
                            System.debug('Before Delete Triggered');
                            C_AcoidRecursiveness.runEventTrigger = false;
                            String providerId = evt.OwnerId;
                            List<Event> previousEventList = [Select Id,StartDateTime,EndDateTime,OwnerId from Event where EndDateTime = :evt.StartDateTime and Subject = 'Availability' and OwnerId =: providerId];
                            List<Event> nextEventList = [Select Id,StartDateTime,EndDateTime,OwnerId from Event where StartDateTime = :evt.EndDateTime and Subject = 'Availability' and OwnerId =: providerId];
                            
                            Timezone gmttz = Timezone.getTimeZone('GMT');
                            Integer GMTTimeDifferenceWithGMT = gmttz.getOffset(evt.StartDateTime);
                            GMTTimeDifferenceWithGMT = GMTTimeDifferenceWithGMT/1000;
                            
                            Datetime nexteventstarttimeusertz;
                            Datetime nexteventendtimeusertz;
                            Datetime previouseventstarttimeusertz;
                            Datetime previouseventendtimeusertz;
                            
                            datetime currenteventstarttimeusertz = evt.StartDateTime.addseconds(GMTTimeDifferenceWithGMT);
                            datetime currenteventendtimeusertz = evt.EndDateTime.addseconds(GMTTimeDifferenceWithGMT);
                            if(nextEventList.size() > 0)
                            {
                                nexteventstarttimeusertz = nextEventList[0].StartDateTime.addseconds(GMTTimeDifferenceWithGMT);
                                nexteventendtimeusertz = nextEventList[0].EndDateTime.addseconds(GMTTimeDifferenceWithGMT);
                            }
                            
                            if(previousEventList.size() > 0)
                            {
                                previouseventstarttimeusertz = previousEventList[0].StartDateTime.addseconds(GMTTimeDifferenceWithGMT);
                                previouseventendtimeusertz = previousEventList[0].EndDateTime.addseconds(GMTTimeDifferenceWithGMT);
                            }
                            
                            if(previousEventList.size() > 0 && nextEventList.size() > 0){
                                previousEventList[0].EndDateTime = nexteventendtimeusertz;
                                previousEventList[0].Send_To_Athena__c = true;
                                delete nextEventList[0];
                                update previousEventList[0];                               
                            }
                            else if(previousEventList.size() > 0){
                                previousEventList[0].EndDateTime = currenteventendtimeusertz;
                                previousEventList[0].Send_To_Athena__c = true;
                                update previousEventList[0];
                            }
                            else if(nextEventList.size() > 0){
                                nextEventList[0].StartDateTime = currenteventstarttimeusertz;
                                nextEventList[0].Send_To_Athena__c = true;
                                update nextEventList[0];
                            }
                            else
                            {
                                Event eventObjNew = new Event();
                                eventObjNew.StartDateTime = currenteventstarttimeusertz;
                                eventObjNew.EndDateTime = currenteventendtimeusertz;
                                eventObjNew.OwnerId = evt.OwnerId;
                                eventObjNew.Subject = 'Availability';
                                eventObjNew.ShowAs = 'Free';
                                Insert eventObjNew;
                            }
                            
                            List<Account> accList = [Select Id , ShippingState from Account where Id =: evt.AccountId];
                            string PatientShippingState = '';
                            if(accList.size() > 0)
                            {
                                PatientShippingState = accList[0].ShippingState;
                            }
                            string PreviousStartDateTime = evt.StartDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                            Integration__c aIntegeration = new Integration__c();
                            aIntegeration.Data_for_Athena__c = '{"ProviderUsername":null,"PreviousDateTime":"'+PreviousStartDateTime+'","PatientState":"'+PatientShippingState+'","PatientAthenaId":"","NewStartDateTime":null,"Duration":'+evt.DurationInMinutes+',"AppointmentType":"'+evt.Appointment_Type__c+'"}';
                            aIntegeration.Payload__c = '{"id":"'+evt.Id+'","providerId":"'+evt.OwnerId+'","patientId":"'+evt.AccountId+'"}';
                            aIntegeration.Method_Action__c = 'DELETE';
                            aIntegeration.Status_Code__c = '200';
                            aIntegeration.Class_Name__c = 'CC_API_CalendarIntegration';
                            aIntegeration.Record_Ids__c = 'EventId : ' + evt.Id + ', ProviderId : '+ evt.OwnerId + ', PatientId : '+evt.AccountId;
                            insert aIntegeration;
                            
                            if(C_AcoidRecursiveness.sendFutureCall)
                            {
                            //Call @Future
                            string EndPointURL = Label.WebAPP_BaseURL+'api/webhooks/salesforce/appointments';
                            CC_trg_EventHandler.sendEventInfo(accList[0].Id,evt.OwnerId,'',evt.Id,'DELETE',EndPointURL,evt.Appointment_Type__c,evt.DurationInMinutes);
                            //Call @Future
                            }
                            
                        }
                        
                    }
                }
            }
        }
    } 
}