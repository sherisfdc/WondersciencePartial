@RestResource(urlMapping='/CalendarIntegration/*')
global class CC_API_CalendarIntegration {
    
    @HttpGet
    global static ResponseWrapper doGet() // GET AVAILABILITY For Patient
    {
        ResponseWrapper wrapper = new ResponseWrapper();
        CC_CalendarTest_Test tclassObj = new CC_CalendarTest_Test();
        tclassObj.createTest();
        Integration__c aIntegeration = new Integration__c();
        try{
            string state = RestContext.request.params.get('state');
            String duration = '5';
            String startTimewithISO = RestContext.request.params.get('startTime');
            String endTimewithISO = RestContext.request.params.get('endTime');
            String providerId = RestContext.request.params.get('providerId');
            DateTime startTime = DateTime.valueof(startTimewithISO.replace('T',' '));
            DateTime endTime = DateTime.valueof(endTimewithISO.replace('T',' '));
            Date startDate = Date.valueOf(startTimewithISO.split('T')[0]);
            Date endDate = Date.valueOf(endTimewithISO.split('T')[0]);
            String timezone = 'GMT';
            
            TimeZone usertz = UserInfo.getTimeZone();
            Integer userTimeDifferenceWithGMT = usertz.getOffset(datetime.now());
            userTimeDifferenceWithGMT = userTimeDifferenceWithGMT/1000;  
            
            startTime = startTime.addseconds(userTimeDifferenceWithGMT);
            //startTime = startTime.addhours(integer.valueOf(Label.AddHoursLabel));
            wrapper.message  =string.valueof(startTime);
            endTime = endTime.addseconds(userTimeDifferenceWithGMT);
            //endTime = endTime.addhours(integer.valueOf(Label.AddHoursLabel));
            wrapper.message = wrapper.message + ' :' + string.valueof(endTime);
            
            Integer listSize = 0;
            Set<Id> userSET = new SET<Id>();
            SET<String> uniqueTime = new SET<String>();
            List<CalendarIntegrationResponse> responseList = new List<CalendarIntegrationResponse>();
            CalendarIntegrationResponse responseObj;
            Provider providerObj = new Provider();
            DateTime nowDateTime = datetime.now();
            if(providerId != null && providerId != ''){
                List<User> userList = [Select Id,State FROM User where ProviderStates__c INCLUDES (:state) and Id =: providerId];
                for(User userObj : userList){
                    userSET.add(userObj.Id); 
                }
                
                List<Event> eventList = [Select Id,Timezone__c,OwnerId,Owner_Name__c,Owner_Provider_Id__c,StartDateTime,EndDateTime from Event where Subject = 'Availability' and OwnerId IN: userSET and ((StartDateTime >=: startTime or StartDateTime <=: endTime) and (EndDateTime <=: endTime or EndDateTime >=: startTime))];
                listSize = eventList.size();
                for(Event eventObj : eventList){
                    datetime tempstart = datetime.valueOf(eventObj.StartDateTime.format('yyyy-MM-dd HH:mm:ss'));
                    datetime tempend = datetime.valueOf(eventObj.EndDateTime.format('yyyy-MM-dd HH:mm:ss'));
                    DateTime slotENDDT = tempstart.addMinutes(integer.valueOf(duration));
                    DateTime slotStartDT = tempstart;
                    boolean flag = false;
                    while(slotENDDT <= endTime && slotENDDT <= tempend){
                        if(slotStartDT >= startTime){
                            flag = true;
                        }
                        slotENDDT = slotENDDT.addMinutes(integer.valueOf(duration));
                        slotStartDT = slotStartDT.addMinutes(integer.valueOf(duration));
                    }
                    if(flag){
                        if(!uniqueTime.contains(string.valueOf(eventObj.StartDateTime) + '|' + string.valueOf(eventObj.EndDateTime))){
                            uniqueTime.add(string.valueOf(eventObj.StartDateTime) + '|' + string.valueOf(eventObj.EndDateTime));
                            responseObj = new CalendarIntegrationResponse();
                            responseObj.startTime =eventObj.StartDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                            responseObj.endTime = eventObj.EndDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                            responseObj.eventId = eventObj.Id;
                            providerObj = new Provider();
                            providerObj.name = eventObj.Owner_Name__c;
                            providerObj.Id = eventObj.OwnerId;
                            responseObj.provider = providerObj;
                            responseList.add(responseObj);
                        }
                    }
                }
            }
            else{
                List<User> userList = [Select Id,State FROM User where ProviderStates__c INCLUDES (:state)];
                for(User userObj : userList){
                    userSET.add(userObj.Id); 
                }
                List<Event> eventList = [Select Id,OwnerId,Owner_Name__c,Owner_Provider_Id__c,StartDateTime,EndDateTime from Event where Subject = 'Availability' and OwnerId IN: userSET and ((StartDateTime >=: startTime or StartDateTime <=: endTime) and (EndDateTime <=: endTime or EndDateTime >=: startTime))];
                listSize = eventList.size();
                wrapper.message = wrapper.message + ' :' + string.valueof(listSize);
                for(Event eventObj : eventList){
                    datetime tempstart = datetime.valueOf(eventObj.StartDateTime.format('yyyy-MM-dd HH:mm:ss'));
                    datetime tempend = datetime.valueOf(eventObj.EndDateTime.format('yyyy-MM-dd HH:mm:ss'));   
                    DateTime slotENDDT = tempstart.addMinutes(integer.valueOf(duration));
                    DateTime slotStartDT = tempstart;
                    
                    boolean flag = false;
                    while(slotENDDT <= endTime && slotENDDT <= tempend){                       
                        if(slotStartDT >= startTime){
                            
                            flag = true;
                        }
                        slotENDDT = slotENDDT.addMinutes(integer.valueOf(duration));
                        slotStartDT = slotStartDT.addMinutes(integer.valueOf(duration));
                    }
                    if(flag){
                        if(!uniqueTime.contains(string.valueOf(eventObj.StartDateTime) + '|' + string.valueOf(eventObj.EndDateTime))){
                            uniqueTime.add(string.valueOf(eventObj.StartDateTime) + '|' + string.valueOf(eventObj.EndDateTime));
                            responseObj = new CalendarIntegrationResponse();
                            //responseObj.startTime =eventObj.StartDateTime.addhours(integer.valueOf(Label.AddHoursLabel)).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                            responseObj.startTime =eventObj.StartDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                            //responseObj.endTime = eventObj.EndDateTime.addhours(integer.valueOf(Label.AddHoursLabel)).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                            responseObj.endTime = eventObj.EndDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                            responseObj.eventId = eventObj.Id;
                            providerObj = new Provider();
                            providerObj.name = eventObj.Owner_Name__c;
                            providerObj.Id = eventObj.OwnerId;
                            responseObj.provider = providerObj;
                            responseList.add(responseObj);
                            wrapper.message  = wrapper.message + ' evntobjStartTime' + string.valueof(eventObj.StartDateTime);
                            wrapper.message  = wrapper.message + ' evntobjEndTime' + string.valueof(eventObj.EndDateTime);
                        }
                    }
                }
            }
            wrapper.slotList = responseList;
            wrapper.Status_Code = 200;
            
            aIntegeration.Payload__c = System.JSON.serialize(RestContext.request.params);
            aIntegeration.Class_Name__c = 'CC_API_CalendarIntegration';
            aIntegeration.Method_Action__c = 'GET';
            aIntegeration.Status_Code__c = '200';
            insert aIntegeration;
            // wrapper.message = 'Success ' + listSize + ' ' +RestContext.request.params;
        }
        catch(Exception ex){
            wrapper.Status_Code = 400;
            wrapper.message = ex.getLineNumber() + ':: ' + ex.getMessage();
            aIntegeration.Payload__c = System.JSON.serialize(RestContext.request.params);
            aIntegeration.Class_Name__c = 'CC_API_CalendarIntegration';
            aIntegeration.Method_Action__c = 'GET';
            aIntegeration.Status_Code__c = '400';
            aIntegeration.Message__c = wrapper.message;
            insert aIntegeration;
        }
        return wrapper;
    }
    @HttpPost
    global static ResponseWrapperPost doPost() 
    {
        ResponseWrapperPost wrapper = new ResponseWrapperPost();
        Integration__c aIntegeration = new Integration__c();
        try{
            string tempDuration = '5';
            String duration = RestContext.request.params.get('duration');
            String startTimewithISO = RestContext.request.params.get('startTime');
            String zoomMeetingUrl = RestContext.request.params.get('zoomMeetingUrl');
            String ProviderId = RestContext.request.params.get('providerId');
            String PatientId = RestContext.request.params.get('patientId');
            String appointmentType = RestContext.request.params.get('appointmentType');
            String patientimezone = 'GMT';
            system.debug(':::startTimewithISO:::' + startTimewithISO);
            DateTime startTimee = (Datetime)JSON.deserialize('"'+startTimewithISO+'"', DateTime.class);
            //DateTime startTimee = DateTime.valueof(startTimewithISO.replace('T',' '));
            system.debug(':::starttime to datetime:::' + startTimee);
            Date startDate = Date.valueOf(startTimewithISO.split('T')[0]);
            system.debug(':::starttime to date:::' + startDate);
            DateTime endTimee = startTimee.addMinutes(integer.valueOf(duration));
            system.debug(':::endtime to datetime:::' + endTimee);
            
            // startTimee = startTimee.addhours(integer.valueOf(Label.AddHoursLabel));
            // endTimee = endTimee.addhours(integer.valueOf(Label.AddHoursLabel));
            /* 
TimeZone usertzget = UserInfo.getTimeZone();
Integer userTimeDifferenceWithGMTget = usertzget.getOffset(datetime.now());
userTimeDifferenceWithGMTget = userTimeDifferenceWithGMTget/1000;

startTimee = startTimee.addseconds(userTimeDifferenceWithGMTget);
system.debug(':::after gmt:startTimee::' + startTimee);
wrapper.message  =string.valueof(startTimee);
endTimee = endTimee.addseconds(userTimeDifferenceWithGMTget);*/
            system.debug(':::after gmt:endTimee::' + endTimee);
            wrapper.message = wrapper.message + ' :' + string.valueof(endTimee);
            
            Set<Id> userSET = new SET<Id>();
            Integer listSize = 0;
            SET<String> uniqueTime = new SET<String>();
            CalendarIntegrationResponse responseObj;
            Provider providerObj = new Provider();
            List<CalendarIntegrationResponse> responseList = new List<CalendarIntegrationResponse>();
            //Get Method
            List<User> userstate = [Select Id,State FROM User where Id =:ProviderId];
            string state = userstate[0].state;
            List<User> userList = [Select Id,State FROM User where Id =: ProviderId];
            for(User userObj : userList){
                userSET.add(userObj.Id); 
            }
            List<Event> eventList = [Select Id,OwnerId,Owner_Name__c,Owner_Provider_Id__c,StartDateTime,EndDateTime from Event where Subject = 'Availability' and OwnerId IN: userSET and (StartDateTime <=: startTimee or EndDateTime >=:endTimee)];
            listSize = eventList.size();
            for(Event eventObj : eventList){
                datetime tempstart = datetime.valueOf(eventObj.StartDateTime.format('yyyy-MM-dd HH:mm:ss'));
                datetime tempend = datetime.valueOf(eventObj.EndDateTime.format('yyyy-MM-dd HH:mm:ss'));                  
                DateTime slotENDDT = tempstart.addMinutes(integer.valueOf(duration));
                DateTime slotStartDT = tempstart;
                boolean flag = false;
                while(slotENDDT <= endTimee && slotENDDT <= tempend){
                    if(slotStartDT >= startTimee){
                        flag = true;
                    }
                    slotENDDT = slotENDDT.addMinutes(integer.valueOf(duration));
                    slotStartDT = slotStartDT.addMinutes(integer.valueOf(duration));
                }
                if(flag){
                    if(!uniqueTime.contains(string.valueOf(eventObj.StartDateTime) + '|' + string.valueOf(eventObj.EndDateTime))){
                        uniqueTime.add(string.valueOf(eventObj.StartDateTime) + '|' + string.valueOf(eventObj.EndDateTime));
                        responseObj = new CalendarIntegrationResponse();
                        responseObj.startTime =eventObj.StartDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                        responseObj.endTime = eventObj.EndDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                        responseObj.eventId = eventObj.Id;
                        providerObj = new Provider();
                        providerObj.name = eventObj.Owner_Name__c;
                        providerObj.Id = eventObj.OwnerId;
                        responseObj.provider = providerObj;
                        responseList.add(responseObj);
                    }
                }
            }
            //Get Method END
            if(responseList.size() == 0){
                wrapper.Status_Code = 404;
                wrapper.message = 'Provider is not available at this time';
                aIntegeration.Payload__c = System.JSON.serialize(RestContext.request.params);
                aIntegeration.Method_Action__c = 'POST';
                aIntegeration.Class_Name__c = 'CC_API_CalendarIntegration';
                aIntegeration.Status_Code__c = '404';
                insert aIntegeration;
                return wrapper;
            }
            string eventId = responseList[0].eventId;
            Event eventObj = [Select Id,TimeZone__c,OwnerId,Owner_Name__c,Owner_Provider_Id__c,StartDateTime,EndDateTime from Event where Subject = 'Availability' and Id =: eventId];
            
            Timezone usertz = Timezone.getTimeZone(string.valueof(UserInfo.getTimeZone()));
            Integer userTimeDifferenceWithGMT = usertz.getOffset(datetime.now());
            userTimeDifferenceWithGMT = userTimeDifferenceWithGMT/1000;
            
            Timezone gmttz = Timezone.getTimeZone('GMT');
            Integer GMTTimeDifferenceWithGMT = gmttz.getOffset(eventObj.StartDateTime);
            GMTTimeDifferenceWithGMT = GMTTimeDifferenceWithGMT/1000;
            
            DateTime startTime = (Datetime)JSON.deserialize('"'+startTimewithISO+'"', DateTime.class);
            /*DateTime startTime = DateTime.valueof(startTimewithISO.replace('T',' '));

startTime = startTime.addseconds(userTimeDifferenceWithGMT);*/
            DateTime endTime = startTime.addMinutes(integer.valueOf(duration));       
            
            Datetime eventstarttimeusertz = eventObj.StartDateTime.addseconds(GMTTimeDifferenceWithGMT);
            // eventstarttimeusertz = eventstarttimeusertz.addhours(integer.valueOf(Label.AddHoursLabel));
            wrapper.message = string.valueof(wrapper.message+' '+eventstarttimeusertz);
            //Datetime eventendtimeusertz = eventObj.EndDateTime.addseconds(userTimeDifferenceWithGMT);
            Datetime eventendtimeusertz = eventObj.EndDateTime.addseconds(GMTTimeDifferenceWithGMT);
            //  eventendtimeusertz = eventendtimeusertz.addhours(integer.valueOf(Label.AddHoursLabel));
            wrapper.message = string.valueof(wrapper.message+' '+eventendtimeusertz);
            
            wrapper.message = string.valueof(wrapper.message+' '+startTime);
            wrapper.message = string.valueof(wrapper.message+' '+endTime);
            
            if(eventId != '')
            {
                if(eventstarttimeusertz == startTime && eventendtimeusertz == endTime)
                {
                    eventObj.Description = zoomMeetingUrl;
                    eventObj.WhatId = PatientId;
                    eventObj.Subject = 'Meeting';
                    eventObj.ShowAs = 'Busy';
                    eventObj.Appointment_Type__c = appointmentType;
                    eventObj.Send_To_Athena__c = true;
                    update eventObj;              
                    wrapper.eventId = eventObj.Id;
                }
                else if(eventstarttimeusertz == startTime)
                {
                    eventObj.StartDateTime = endTime;
                    eventObj.Send_To_Athena__c = true;
                    update eventObj;
                    Event eventObjInsert = new Event();
                    eventObjInsert.StartDateTime = startTime;
                    eventObjInsert.EndDateTime = eventObjInsert.StartDateTime.addMinutes(integer.valueOf(duration));
                    eventObjInsert.DurationInMinutes = integer.valueOf(duration);
                    eventObjInsert.Description = zoomMeetingUrl;
                    eventObjInsert.OwnerId = ProviderId;
                    eventObjInsert.WhatId = PatientId;
                    eventObjInsert.Subject = 'Meeting';
                    eventObjInsert.ShowAs = 'Busy';
                    eventObjInsert.Appointment_Type__c = appointmentType;
                    eventObjInsert.Send_To_Athena__c = true;
                    Insert eventObjInsert; 
                    wrapper.eventId = eventObjInsert.Id;
                    
                    
                }
                else if(eventendtimeusertz == endTime)
                {
                    eventObj.EndDateTime = startTime;
                    eventObj.Send_To_Athena__c = true;
                    update eventObj;
                    Event eventObjInsert = new Event();
                    eventObjInsert.StartDateTime = startTime;
                    eventObjInsert.EndDateTime = eventObjInsert.StartDateTime.addMinutes(integer.valueOf(duration));
                    eventObjInsert.DurationInMinutes = integer.valueOf(duration);
                    eventObjInsert.Description = zoomMeetingUrl;
                    eventObjInsert.OwnerId = ProviderId;
                    eventObjInsert.WhatId = PatientId;
                    eventObjInsert.Subject = 'Meeting';
                    eventObjInsert.ShowAs = 'Busy';      
                    eventObjInsert.Appointment_Type__c = appointmentType;
                    eventObjInsert.Send_To_Athena__c = true;
                    Insert eventObjInsert; 
                    wrapper.eventId = eventObjInsert.Id;    
                }
                else
                {                   
                    Event eventObjNew = new Event();
                    eventObjNew.StartDateTime = endTime;
                    eventObjNew.EndDateTime = eventendtimeusertz;  
                    system.debug('eventObjNew.StartDateTime ::' + eventObjNew.StartDateTime + 'eventObjNew.EndDateTime ::' + eventObjNew.EndDateTime);
                    system.debug('eventObjNew.EndDateTime ::' + eventObjNew.EndDateTime);
                    eventObjNew.OwnerId = ProviderId;
                    eventObjNew.Subject = 'Availability';
                    eventObjNew.ShowAs = 'Free';
                    eventObjNew.Send_To_Athena__c = true;
                    Insert eventObjNew;
                    
                    eventObj.EndDateTime = startTime;
                    eventObj.Send_To_Athena__c = true;
                    update eventObj; 
                    
                    
                    Event eventObjInsert = new Event();
                    eventObjInsert.StartDateTime = startTime;
                    eventObjInsert.EndDateTime = eventObjInsert.StartDateTime.addMinutes(integer.valueOf(duration));
                    eventObjInsert.DurationInMinutes = integer.valueOf(duration);
                    eventObjInsert.Description = zoomMeetingUrl;
                    eventObjInsert.OwnerId = ProviderId;
                    eventObjInsert.WhatId = PatientId;
                    eventObjInsert.Subject = 'Meeting';
                    eventObjInsert.ShowAs = 'Busy';   
                    eventObjInsert.Appointment_Type__c = appointmentType;
                    system.debug('::::eventObjInsert::' + eventObjInsert);
                    eventObjInsert.Send_To_Athena__c = true;
                    Insert eventObjInsert; 
                    wrapper.eventId = eventObjInsert.Id;
                }
            }
            //Alter Availability Period
            
            wrapper.ZoomMeetingURL = zoomMeetingUrl;
            wrapper.Status_Code = 200;
            
            List<Event> NewEventCreated = [Select Id,Subject , Provider_Name__c , Appointment_Type__c, StartDateTime, DurationInMinutes , Send_To_Athena__c ,Account.Athena_Id__c , Account.ShippingState from Event where Id =: wrapper.eventId];
            DataforAthena dforA = new DataforAthena();
            dforA.ProviderUsername = NewEventCreated[0].Provider_Name__c;
            dforA.PatientState = NewEventCreated[0].Account.ShippingState;
            dforA.AppointmentType = NewEventCreated[0].Appointment_Type__c;
            dforA.NewStartDateTime = NewEventCreated[0].StartDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            dforA.Duration = NewEventCreated[0].DurationInMinutes;
            dforA.PatientAthenaId = NewEventCreated[0].Account.Athena_Id__c;
            
            
            aIntegeration.Payload__c = System.JSON.serialize(RestContext.request.params);
            aIntegeration.Method_Action__c = 'POST';
            aIntegeration.Status_Code__c = '200';
            aIntegeration.Class_Name__c = 'CC_API_CalendarIntegration';
            aIntegeration.Data_for_Athena__c = System.JSON.serialize(dforA);
            aIntegeration.Record_Ids__c = 'EventId : ' + wrapper.eventId + ', ProviderId : '+ ProviderId + ', PatientId : '+PatientId;
            
            insert aIntegeration;
            //wrapper.message = 'Success';
        }
        catch(Exception ex){
            wrapper.Status_Code = 400;
            wrapper.message = ex.getLineNumber() + ':: ' + ex.getMessage();
            aIntegeration.Payload__c = System.JSON.serialize(RestContext.request.params);
            aIntegeration.Method_Action__c = 'POST';
            aIntegeration.Status_Code__c = '400';
            aIntegeration.Class_Name__c = 'CC_API_CalendarIntegration';
            aIntegeration.Message__c = wrapper.message;
            insert aIntegeration;
            System.debug('wrapper.messageeee :::::' + wrapper.message);
        }
        return wrapper;
    }
    
    @HttpPatch
    global static ResponseWrapperPost doPatch() // GET AVAILABILITY For Patient
    {
        ResponseWrapperPost wrapper = new ResponseWrapperPost();
        Integration__c aIntegeration = new Integration__c();
        Savepoint sp = Database.setSavepoint();
        try{
            string tempDuration = '5';
            String duration = RestContext.request.params.get('duration');
            String startTimewithISO = RestContext.request.params.get('startTime');
            String ProviderId = RestContext.request.params.get('providerId');
            String EventId = RestContext.request.params.get('id');
            String zoomMeetingUrl = RestContext.request.params.get('zoomMeetingUrl');
            //String patientimezone = RestContext.request.params.get('timezone');
            DateTime customerEventStartTime = (Datetime)JSON.deserialize('"'+startTimewithISO+'"', DateTime.class);
            /*DateTime customerEventStartTime = DateTime.valueof(startTimewithISO.replace('T',' '));*/
            DateTime customerEventEndTime = customerEventStartTime.addMinutes(integer.valueOf(duration));
            //String PatientId = RestContext.request.params.get('patientId');
            //String newEventId = RestContext.request.params.get('neweventId');
            String appointmentType = RestContext.request.params.get('appointmentType');
            
            /*TimeZone usertzget = UserInfo.getTimeZone();
Integer userTimeDifferenceWithGMTget = usertzget.getOffset(datetime.now());
userTimeDifferenceWithGMTget = userTimeDifferenceWithGMTget/1000;  

customerEventStartTime = customerEventStartTime.addseconds(userTimeDifferenceWithGMTget);
// customerEventStartTime = customerEventStartTime.addhours(integer.valueOf(Label.AddHoursLabel));
wrapper.message  =string.valueof(customerEventStartTime);
customerEventEndTime = customerEventEndTime.addseconds(userTimeDifferenceWithGMTget);
// customerEventEndTime = customerEventEndTime.addhours(integer.valueOf(Label.AddHoursLabel));
wrapper.message = wrapper.message + ' :' + string.valueof(customerEventEndTime);*/
            
            List<Event> existingEventObj = [Select Id,TimeZone__c,OwnerId,Owner_Name__c,Owner_Provider_Id__c,StartDateTime,EndDateTime,WhatId from Event where Id =: EventId];
            If(existingEventObj.size() == 0)
            {
                wrapper.Status_Code = 404;
                wrapper.message = 'Event not Found';
                aIntegeration.Payload__c = System.JSON.serialize(RestContext.request.params);
                aIntegeration.Method_Action__c = 'PATCH';
                aIntegeration.Status_Code__c = '404';
                aIntegeration.Class_Name__c = 'CC_API_CalendarIntegration';
                aIntegeration.Message__c = wrapper.message;
                insert aIntegeration;
                return wrapper;
            }
            
            //String ProviderId = existingEventObj[0].OwnerId;
            wrapper.message = wrapper.message + ' :' + string.valueof(ProviderId);
            String PatientId = existingEventObj[0].WhatId;
            
            List<Event> eventTobeUpdated = new List<Event>();
            eventTobeUpdated = existingEventObj;
            
            List<Event> previousEventList = [Select Id,TimeZone__c,OwnerId,Owner_Name__c,Owner_Provider_Id__c,StartDateTime,EndDateTime from Event where EndDateTime =: existingEventObj[0].StartDateTime and Subject = 'Availability'];
            List<Event> nextEventList = [Select Id,TimeZone__c,OwnerId,Owner_Name__c,Owner_Provider_Id__c,StartDateTime,EndDateTime from Event where StartDateTime =: existingEventObj[0].EndDateTime and Subject = 'Availability'];            
            
            if(previousEventList.size() > 0 && nextEventList.size() > 0)
            {
                previousEventList[0].EndDateTime = nextEventList[0].EndDateTime;
                previousEventList[0].Send_To_Athena__c = true;
                update previousEventList[0];
                delete nextEventList[0];
                delete existingEventObj[0];               
            }
            else if(previousEventList.size() > 0){
                previousEventList[0].EndDateTime = existingEventObj[0].EndDateTime;
                previousEventList[0].Send_To_Athena__c = true;
                update previousEventList[0];
                delete existingEventObj[0];
            }
            else if(nextEventList.size() > 0)
            {
                nextEventList[0].StartDateTime = existingEventObj[0].StartDateTime;
                nextEventList[0].Send_To_Athena__c = true;
                update nextEventList[0];
                delete existingEventObj[0];
            }
            else
            {
                existingEventObj[0].Subject = 'Availability';
                existingEventObj[0].ShowAs = 'Free';
                existingEventObj[0].Description = '';
                existingEventObj[0].WhatId = null;
                existingEventObj[0].Send_To_Athena__c = true;
                update existingEventObj[0];
            }
            
            ///Post method start
            List<Event> eventList = [Select Id,Timezone__c,OwnerId,Owner_Name__c,Owner_Provider_Id__c,StartDateTime,EndDateTime from Event where Subject = 'Availability' and OwnerId =: ProviderId and ((StartDateTime <=: customerEventEndTime) and (EndDateTime >=: customerEventStartTime))];
            Event  eventObj = new Event();
            System.debug('eventList.size()size ::::' + eventList.size());
            if(eventList.size() > 0)
            {
                eventObj = [Select Id,TimeZone__c,OwnerId,Owner_Name__c,Owner_Provider_Id__c,StartDateTime,EndDateTime from Event where Subject = 'Availability' and Id =: eventList[0].Id];
            }
            else
            {
                Database.rollback(sp);
                wrapper.Status_Code = 404;
                wrapper.message = 'Requested time slot is not available';
                aIntegeration.Payload__c = System.JSON.serialize(RestContext.request.params);
                aIntegeration.Method_Action__c = 'PATCH';
                aIntegeration.Status_Code__c = '404';
                aIntegeration.Class_Name__c = 'CC_API_CalendarIntegration';
                aIntegeration.Message__c = wrapper.message;
                insert aIntegeration;
                return wrapper;
            }
            //Timezone patienttz = Timezone.getTimeZone(patientimezone);
            // Integer patientTimeDifferenceWithGMT = patienttz.getOffset(eventObj.StartDateTime);
            // patientTimeDifferenceWithGMT = patientTimeDifferenceWithGMT/1000;
            
            Timezone usertz = Timezone.getTimeZone(string.valueof(UserInfo.getTimeZone()));
            Integer userTimeDifferenceWithGMT = usertz.getOffset(datetime.now());
            userTimeDifferenceWithGMT = userTimeDifferenceWithGMT/1000;
            
            //Timezone providertz = Timezone.getTimeZone(eventObj.TimeZone__c);
            // Integer providerTimeDifferenceWithGMT = providertz.getOffset(eventObj.StartDateTime);
            // providerTimeDifferenceWithGMT = providerTimeDifferenceWithGMT/1000;
            
            //GMT Timezone
            Timezone gmttz = Timezone.getTimeZone('GMT');
            Integer GMTTimeDifferenceWithGMT = gmttz.getOffset(eventObj.StartDateTime);
            GMTTimeDifferenceWithGMT = GMTTimeDifferenceWithGMT/1000;
            
            DateTime startTime = (Datetime)JSON.deserialize('"'+startTimewithISO+'"', DateTime.class);
            /*DateTime startTime = DateTime.valueof(startTimewithISO.replace('T',' '));
startTime = startTime.addseconds(userTimeDifferenceWithGMT);*/
            //startTime = startTime.addseconds(-patientTimeDifferenceWithGMT);
            //startTime = startTime.addseconds(userTimeDifferenceWithGMT);
            DateTime endTime = startTime.addMinutes(integer.valueOf(duration));
            
            Datetime eventstarttimeusertz = eventObj.StartDateTime.addseconds(GMTTimeDifferenceWithGMT);
            //eventstarttimeusertz = eventstarttimeusertz.addhours(integer.valueOf(Label.AddHoursLabel));
            wrapper.message = string.valueof(wrapper.message+' '+eventstarttimeusertz);
            Datetime eventendtimeusertz = eventObj.EndDateTime.addseconds(GMTTimeDifferenceWithGMT);
            // eventendtimeusertz = eventendtimeusertz.addhours(integer.valueOf(Label.AddHoursLabel));
            wrapper.message = string.valueof(wrapper.message+' '+eventendtimeusertz);
            
            wrapper.message = string.valueof(wrapper.message+' '+startTime);
            wrapper.message = string.valueof(wrapper.message+' '+endTime);
            
            if(string.valueOf(eventObj.Id) != '')
            {
                System.debug('eventstarttimeusertzpatch ::::' + eventstarttimeusertz);
                System.debug('eventendtimeusertzpatch ::::' + eventendtimeusertz);
                System.debug('startTimepatch ::::'+ startTime);
                System.debug('endTimepatch ::::'+ endTime);
                if(eventstarttimeusertz == startTime && eventendtimeusertz == endTime)
                {
                    eventObj.Description = zoomMeetingUrl;
                    eventObj.WhatId = PatientId;
                    eventObj.Subject = 'Meeting';
                    eventObj.ShowAs = 'Busy';  
                    eventObj.Appointment_Type__c = appointmentType;
                    eventObj.Send_To_Athena__c = true;
                    update eventObj;              
                    wrapper.eventId = eventObj.Id;
                }
                else if(eventstarttimeusertz == startTime)
                {
                    eventObj.StartDateTime = endTime;
                    eventObj.Send_To_Athena__c = true;
                    update eventObj;
                    Event eventObjInsert = new Event();
                    eventObjInsert.StartDateTime = startTime;
                    eventObjInsert.EndDateTime = eventObjInsert.StartDateTime.addMinutes(integer.valueOf(duration));
                    eventObjInsert.DurationInMinutes = integer.valueOf(duration);
                    eventObjInsert.Description = zoomMeetingUrl;
                    eventObjInsert.OwnerId = ProviderId;
                    eventObjInsert.WhatId = PatientId;
                    eventObjInsert.Subject = 'Meeting';
                    eventObjInsert.ShowAs = 'Busy';      
                    eventObjInsert.Appointment_Type__c = appointmentType;
                    eventObjInsert.Send_To_Athena__c = true;
                    Insert eventObjInsert; 
                    wrapper.eventId = eventObjInsert.Id;
                    
                    
                }
                else if(eventendtimeusertz == endTime)
                {
                    eventObj.EndDateTime = startTime;
                    eventObj.Send_To_Athena__c = true;
                    update eventObj;
                    Event eventObjInsert = new Event();
                    eventObjInsert.StartDateTime = startTime;
                    eventObjInsert.EndDateTime = eventObjInsert.StartDateTime.addMinutes(integer.valueOf(duration));
                    eventObjInsert.DurationInMinutes = integer.valueOf(duration);
                    eventObjInsert.Description = zoomMeetingUrl;
                    eventObjInsert.OwnerId = ProviderId;
                    eventObjInsert.WhatId = PatientId;
                    eventObjInsert.Subject = 'Meeting';
                    eventObjInsert.ShowAs = 'Busy';    
                    eventObjInsert.Appointment_Type__c = appointmentType;
                    eventObjInsert.Send_To_Athena__c = true;
                    Insert eventObjInsert; 
                    wrapper.eventId = eventObjInsert.Id;    
                }
                else
                {
                    System.debug('StartEndEnd : :::' + endTime);
                    System.debug('EndEndEnd : :::' + eventendtimeusertz);
                    System.debug('');
                    Event eventObjNew = new Event();
                    eventObjNew.StartDateTime = endTime;
                    eventObjNew.EndDateTime = eventendtimeusertz;             
                    eventObjNew.OwnerId = ProviderId;
                    eventObjNew.Subject = 'Availability';
                    eventObjNew.ShowAs = 'Free';  
                    eventObjNew.Send_To_Athena__c = true;
                    Insert eventObjNew;
                    
                    eventObj.EndDateTime = startTime;
                    eventObj.Send_To_Athena__c = true;
                    update eventObj;                               
                    
                    Event eventObjInsert = new Event();
                    eventObjInsert.StartDateTime = startTime;
                    eventObjInsert.EndDateTime = eventObjInsert.StartDateTime.addMinutes(integer.valueOf(duration));
                    eventObjInsert.DurationInMinutes = integer.valueOf(duration);
                    eventObjInsert.Description = zoomMeetingUrl;
                    eventObjInsert.OwnerId = ProviderId;
                    eventObjInsert.WhatId = PatientId;
                    eventObjInsert.Subject = 'Meeting';
                    eventObjInsert.ShowAs = 'Busy'; 
                    eventObjInsert.Appointment_Type__c = appointmentType;
                    eventObjInsert.Send_To_Athena__c = true;
                    Insert eventObjInsert; 
                    wrapper.eventId = eventObjInsert.Id;
                }
            }
            
            List<Event> NewEventCreated = [Select Id,Subject , Provider_Name__c , Appointment_Type__c, StartDateTime,EndDateTime, DurationInMinutes , Send_To_Athena__c ,Account.Athena_Id__c , Account.ShippingState from Event where Id =: wrapper.eventId];
            //Create Note
            if(wrapper.eventId != null && wrapper.eventId != '')
            {
                ContentNote noteRecord = new ContentNote();
                noteRecord.Title   = 'Appointment Rescheduled by Patient';
                String body        = 'Appointment with the Start Time : '+eventTobeUpdated[0].StartDateTime+' (GMT/UTC) and End Time : '+DateTime.ValueOf(eventTobeUpdated[0].EndDateTime)+' (GMT/UTC) was rescheduled and New Start Date Time is '+ NewEventCreated[0].StartDateTime + ' (GMT/UTC) and New End Date Time is ' + NewEventCreated[0].EndDateTime + ' (GMT/UTC).' ;
                noteRecord.Content = Blob.valueOf(body.escapeHTML4());
                insert noteRecord;
                ContentDocumentLink link = new ContentDocumentLink();
                link.ContentDocumentId   = noteRecord.id;
                link.LinkedEntityId      = PatientId;
                link.ShareType           = 'V';
                link.Visibility          = 'InternalUsers';
                insert link;
                //Create Note
            }
            
            //Post method end
            
            wrapper.Status_Code = 200;
            wrapper.message = '';
            wrapper.ZoomMeetingURL = zoomMeetingUrl;
            
            
            DataforAthena dforA = new DataforAthena();
            dforA.ProviderUsername = NewEventCreated[0].Provider_Name__c;
            dforA.PatientState = NewEventCreated[0].Account.ShippingState;
            dforA.AppointmentType = NewEventCreated[0].Appointment_Type__c;
            dforA.NewStartDateTime = NewEventCreated[0].StartDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            dforA.PreviousDateTime = eventTobeUpdated[0].StartDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            dforA.Duration = NewEventCreated[0].DurationInMinutes;
            dforA.PatientAthenaId = NewEventCreated[0].Account.Athena_Id__c;
            
            PayloadData plobj = new PayloadData();  
            plobj.patchOldEventId =  EventId;
            plobj.id = wrapper.eventId;
            plobj.providerId = ProviderId;
            plobj.patientId = PatientId;
            plobj.zoomMeetingUrl = zoomMeetingUrl;
            plobj.appointmentType = appointmentType;
            plobj.duration = duration;
            string jsonO = System.JSON.serialize(plobj);
            
            
            aIntegeration.Payload__c = System.JSON.serialize(plobj);
            aIntegeration.Method_Action__c = 'PATCH';
            aIntegeration.Status_Code__c = '200';
            aIntegeration.Class_Name__c = 'CC_API_CalendarIntegration';
            aIntegeration.Data_for_Athena__c = System.JSON.serialize(dforA);
            aIntegeration.Record_Ids__c = 'EventId : ' + wrapper.eventId + ', ProviderId : '+ ProviderId + ', PatientId : '+PatientId;
            aIntegeration.Payload__c = jsonO;
            insert aIntegeration;
        }
        catch(Exception ex){
            Database.rollback(sp);
            wrapper.Status_Code = 400;
            wrapper.message = ex.getLineNumber() + ':: ' + ex.getMessage();
            aIntegeration.Payload__c = System.JSON.serialize(RestContext.request.params);
            aIntegeration.Method_Action__c = 'PATCH';
            aIntegeration.Status_Code__c = '400';
            aIntegeration.Class_Name__c = 'CC_API_CalendarIntegration';
            aIntegeration.Message__c = wrapper.message;
            insert aIntegeration;
            system.debug('::::error message:::' + ex.getLineNumber() + ':: ' + ex.getMessage());
        }
        return wrapper;
    }
    
    @HttpDelete
    global static ResponseWrapper doDelete() // GET AVAILABILITY For Patient
    {
        ResponseWrapper wrapper = new ResponseWrapper();
        Integration__c aIntegeration = new Integration__c();
        try
        {
            String EventId = RestContext.request.params.get('id');
            //String providerId = RestContext.request.params.get('providerId');
            
            List<Event> existingEventObj  = [Select Id,StartDateTime,EndDateTime,OwnerId,WhatId,AccountId from Event where Id = :EventId];
            if(existingEventObj.size() == 0){
                wrapper.Status_Code = 404;
                wrapper.message = 'Record not Found';
                aIntegeration.Payload__c = System.JSON.serialize(RestContext.request.params);
                aIntegeration.Method_Action__c = 'DELETE';
                aIntegeration.Status_Code__c = '404';
                aIntegeration.Class_Name__c = 'CC_API_CalendarIntegration';
                aIntegeration.Message__c = 'Record not Found';
                insert aIntegeration;
                return wrapper;
            }
            String providerId = existingEventObj[0].OwnerId;
            String whatId = existingEventObj[0].WhatId;
            List<Event> previousEventList = [Select Id,StartDateTime,EndDateTime,OwnerId from Event where EndDateTime = :existingEventObj[0].StartDateTime and Subject = 'Availability' and OwnerId =: providerId];
            List<Event> nextEventList = [Select Id,StartDateTime,EndDateTime,OwnerId from Event where StartDateTime = :existingEventObj[0].EndDateTime and Subject = 'Availability' and OwnerId =: providerId];
            if(previousEventList.size() > 0 && nextEventList.size() > 0){
                previousEventList[0].EndDateTime = nextEventList[0].EndDateTime;
                previousEventList[0].Send_To_Athena__c = true;
                update previousEventList[0];
                delete nextEventList[0];
            }
            else if(previousEventList.size() > 0){
                previousEventList[0].EndDateTime = existingEventObj[0].EndDateTime;
                previousEventList[0].Send_To_Athena__c = true;
                update previousEventList[0];
            }
            else if(nextEventList.size() > 0){
                nextEventList[0].StartDateTime = existingEventObj[0].StartDateTime;
                nextEventList[0].Send_To_Athena__c = true;
                update nextEventList[0];
            }           
            
            //Create Note
            ContentNote noteRecord = new ContentNote();
            noteRecord.Title   = 'Meeting Cancelled by Patient';
            String body        = 'Meeting with the Start Time : '+existingEventObj[0].StartDateTime+' (GMT/UTC) and End Time : '+DateTime.ValueOf(existingEventObj[0].EndDateTime)+' (GMT/UTC) was cancelled.';
            noteRecord.Content = Blob.valueOf(body.escapeHTML4());
            insert noteRecord;
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId   = noteRecord.id;
            if(whatId != null && whatId != '')
                link.LinkedEntityId = whatId;
            else
                link.LinkedEntityId = existingEventObj[0].AccountId;
            link.ShareType           = 'V';
            link.Visibility          = 'InternalUsers';
                insert link;
            //Create Note
            List<Event> NewEventCreated = [Select Id,Subject , Provider_Name__c , Appointment_Type__c, StartDateTime, DurationInMinutes , Send_To_Athena__c ,Account.Athena_Id__c , Account.ShippingState from Event where Id =: existingEventObj[0].Id];
            delete existingEventObj[0];
            
            
            wrapper.Status_Code = 200;
            wrapper.message = 'Deleted Successfully';  
            
            
            DataforAthena dforA = new DataforAthena();
            dforA.ProviderUsername = NewEventCreated[0].Provider_Name__c;
            dforA.PatientState = NewEventCreated[0].Account.ShippingState;
            dforA.AppointmentType = NewEventCreated[0].Appointment_Type__c;
            dforA.PreviousDateTime = NewEventCreated[0].StartDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            dforA.Duration = NewEventCreated[0].DurationInMinutes;
            dforA.PatientAthenaId = NewEventCreated[0].Account.Athena_Id__c;
            
            
            //aIntegeration.Payload__c = System.JSON.serialize(RestContext.request.params);
            
            PayloadData plobj = new PayloadData();   
            plobj.id = EventId;
            plobj.providerId = ProviderId;
            plobj.patientId = whatId;
            string jsonO = System.JSON.serialize(plobj);
            
            aIntegeration.Method_Action__c = 'DELETE';
            aIntegeration.Status_Code__c = '200';
            aIntegeration.Class_Name__c = 'CC_API_CalendarIntegration';
            aIntegeration.Message__c = 'Deleted Successfully';  
            aIntegeration.Data_for_Athena__c = System.JSON.serialize(dforA);
            aIntegeration.Record_Ids__c = 'EventId : ' + EventId + ', ProviderId : '+ ProviderId + ', PatientId : '+whatId;
            aIntegeration.Payload__c = jsonO;
            System.debug('Data_for_Athena__c' + System.JSON.serialize(dforA));
            insert aIntegeration;
        }
        catch(Exception ex)
        {
            wrapper.Status_Code = 400;
            wrapper.message = ex.getLineNumber() + ':: ' + ex.getMessage();
            aIntegeration.Payload__c = System.JSON.serialize(RestContext.request.params);
            aIntegeration.Method_Action__c = 'DELETE';
            aIntegeration.Status_Code__c = '400';
            aIntegeration.Class_Name__c = 'CC_API_CalendarIntegration';
            aIntegeration.Message__c = wrapper.message;
            insert aIntegeration;
            system.debug('wrapper.message :::' + wrapper.message);
        }
        return wrapper;
    }
    
    global class CalendarIntegrationResponse{
        public string startTime{get;set;}
        public string endTime{get;set;}
        public string eventId{get;set;}
        public Provider provider{get;set;}
        
    }
    public class Provider{
        public string id{get;set;}
        public string name{get;set;}
    }
    global class ResponseWrapper{
        public List<CalendarIntegrationResponse> slotList {get;set;}
        public integer Status_Code{get;set;}
        public string message{get;set;}
        public string eventId{get;set;}
    }
    global class ResponseWrapperPost{
        public string ZoomMeetingURL {get;set;}
        public integer Status_Code{get;set;}
        public string message{get;set;}
        public string eventId{get;set;}
    }
    global class DataforAthena
    {
        public string ProviderUsername {get;set;}
        public string PatientState {get;set;}
        public string AppointmentType {get;set;}
        public string NewStartDateTime {get;set;}
        public string PreviousDateTime {get;set;}
        public integer Duration {get;set;}
        public string PatientAthenaId {get;set;}
    }
    global class PayloadData
    {
        public string id {get;set;}
        public string providerId {get;set;}
        public string patientId {get;set;}
        public string startTime {get;set;}
        public string zoomMeetingUrl {get;set;}
        public string appointmentType {get;set;}
        public string duration {get;set;} 
        public string patchOldEventId{get;set;}      
    }
}