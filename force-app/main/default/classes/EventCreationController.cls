public with sharing class EventCreationController {
    //public EventCreationController() 
    //{
    
    //}
    @AuraEnabled
    public static string createEvent(Event eventrecObj , Boolean Allowrecurring , string SelectedValuess)
    {
        System.Debug('Date passed in: ' + eventrecObj);
        try 
        {
            string startDate = string.valueof(eventrecObj.StartDateTime.date());
            string endDate = string.valueof(eventrecObj.EndDateTime.date());
            string startTime =string.valueof(eventrecObj.StartDateTime.format('HH:mm:ss'));
            string endTime = string.valueof(eventrecObj.EndDateTime.format('HH:mm:ss'));
            boolean allowrec = Allowrecurring;
            string selectvals = SelectedValuess;
            //System.debug('eventrecObj.StartDateTime:::::'+eventrecObj.StartDateTime);
            //System.debug('eventrecObj.EndDateTime:::::'+eventrecObj.EndDateTime);
            //System.debug('startDate:::::'+startDate);
            //System.debug('endDate:::::'+endDate);
            System.debug('allowrec:::::'+allowrec);
            System.debug('selectvals:::::'+selectvals);
            Integer daysdiff =  Date.valueOf(startDate).daysBetween(Date.valueOf(endDate));
            
            List<String> DaysList = new List<String>();
            if(selectvals != '' && allowrec == true)
            {
                DaysList = selectvals.split(',');
            }
            
            
            
            List<SendDatesSets> sendDatasetList = new List<SendDatesSets>();
            
            string currentUserId = UserInfo.getUserId();
            string message = '';
            integer unSuccessfullEvents = 0;
            if(startDate == endDate)
            {
                List<Event> eventList = [Select Id from Event where OwnerId =: currentUserId and ((StartDateTime =: eventrecObj.StartDateTime or EndDateTime =:eventrecObj.EndDateTime) or (StartDateTime >: eventrecObj.StartDateTime and StartDateTime <:eventrecObj.EndDateTime) or (EndDateTime >: eventrecObj.StartDateTime and EndDateTime <:eventrecObj.EndDateTime)  or (StartDateTime <: eventrecObj.StartDateTime and EndDateTime >:eventrecObj.EndDateTime))];
                
                List<Event> eventListtomerge = [Select Id,StartDateTime,EndDateTime from Event where Subject = 'Availability' and OwnerId =: currentUserId and (StartDateTime =: eventrecObj.EndDateTime or EndDateTime =:eventrecObj.StartDateTime)];
                Integer listSize = eventList.size();    
                System.debug('eventrecObj.StartDateTime:::::'+eventrecObj.StartDateTime);
                System.debug('eventrecObj.EndDateTime:::::'+eventrecObj.EndDateTime);    
                if(listSize == 0)
                {
                    if(eventListtomerge.size() == 0)
                    {            
                        eventrecObj.ActivityDateTime = DateTime.valueof(eventrecObj.StartDateTime);
                        eventrecObj.ShowAs = 'Free';      
                        insert eventrecObj;
                    }
                    else 
                    {
                        if(eventListtomerge[0].StartDateTime == eventrecObj.EndDateTime)
                        {
                            eventListtomerge[0].StartDateTime = eventrecObj.StartDateTime;
                            update eventListtomerge[0];
                        }
                        else if(eventListtomerge[0].EndDateTime == eventrecObj.StartDateTime) 
                        {
                            eventListtomerge[0].EndDateTime = eventrecObj.EndDateTime;
                            update eventListtomerge[0];
                        }
                    }
                    message = 'EVENT CREATED SUCCESSFULLY';
                }
                else 
                {
                    message = 'AVAILABILTY EVENT ALREADY EXIST IN SELECTED TIMESLOT';
                }
            }
            else 
            {
                if(daysdiff == 1)
                {
                    Event senddataobj = new Event();
                    senddataobj.StartDateTime = eventrecObj.StartDateTime;
                    senddataobj.EndDateTime = DateTime.valueOf(startDate+' 23:59:00');
                    senddataobj.ActivityDateTime = DateTime.valueof(eventrecObj.StartDateTime);
                    senddataobj.ShowAs = 'Free';
                    System.debug('senddataobj.StartDateTime:::::'+senddataobj.StartDateTime);
                    System.debug('senddataobj.EndDateTime:::::'+senddataobj.EndDateTime);
                    List<Event> eventList1 = [Select Id from Event where OwnerId =: currentUserId and ((StartDateTime =: senddataobj.StartDateTime or EndDateTime =:senddataobj.EndDateTime) or (StartDateTime >: senddataobj.StartDateTime and StartDateTime <:senddataobj.EndDateTime) or (EndDateTime >: senddataobj.StartDateTime and EndDateTime <:senddataobj.EndDateTime) or (StartDateTime <: senddataobj.StartDateTime and EndDateTime >:senddataobj.EndDateTime))];
                    if(eventList1.size() == 0)
                    {
                        Insert senddataobj;
                        message = 'EVENT CREATED SUCCESSFULLY';
                    }
                    else 
                    {
                        message = 'AVAILABILTY EVENT ALREADY EXIST IN SELECTED TIMESLOT'; 
                    }
                    
                    Event senddataobj2 = new Event();
                    senddataobj2.StartDateTime = DateTime.valueOf(endDate+' 00:00:00');
                    senddataobj2.EndDateTime = DateTime.valueOf(endDate+' '+endTime);
                    senddataobj2.ActivityDateTime = DateTime.valueof(senddataobj2.StartDateTime);
                    senddataobj2.ShowAs = 'Free';
                    List<Event> eventList2 = [Select Id from Event where OwnerId =: currentUserId and ((StartDateTime =: senddataobj2.StartDateTime or EndDateTime =:senddataobj2.EndDateTime) or (StartDateTime >: senddataobj2.StartDateTime and StartDateTime <:senddataobj2.EndDateTime) or (EndDateTime >: senddataobj2.StartDateTime and EndDateTime <:senddataobj2.EndDateTime) or (StartDateTime <: senddataobj2.StartDateTime and EndDateTime >:senddataobj2.EndDateTime) )];
                    if(eventList2.size() == 0)
                    {
                        Insert senddataobj2;
                        message = 'EVENT CREATED SUCCESSFULLY';
                    }
                    else 
                    {
                        message = 'AVAILABILTY EVENT ALREADY EXIST IN SELECTED TIMESLOT'; 
                    }
                }
                else 
                {
                    List<Event> evttlist = [Select Id,StartDateTime,EndDateTime from Event where OwnerId =: currentUserId];
                    Map<Id,Event> Eventmap = new Map<Id,Event>();
                    for(Event evttob : evttlist)
                    {
                        Eventmap.put(evttob.Id,evttob);
                    }
                    for(integer i = 0 ; i <= daysdiff ; i++)
                    {            
                        SendDatesSets sendDatesObj = new SendDatesSets();
                        sendDatesObj.sentStartDate = eventrecObj.StartDateTime.addDays(i);
                        sendDatesObj.sentEndDate = DateTime.valueOf(startDate+' '+endTime).addDays(i);
                        String dayOfWeekstart = sendDatesObj.sentStartDate.format('EEEEEE');
                        String dayOfWeekend = sendDatesObj.sentStartDate.format('EEEEEE');
                        
                        if(allowrec == true)
                        {
                            if(DaysList.contains(dayOfWeekstart) && DaysList.contains(dayOfWeekend))
                            {
                                sendDatasetList.Add(sendDatesObj);
                            }
                        }
                        else
                        {
                            sendDatasetList.Add(sendDatesObj);
                        }
                    }
                    List<Event> eventList3Insert = new List<Event>();
                    for(SendDatesSets sendDatesSetsObj : sendDatasetList)
                    {
                        Event newObjtoInsert = new Event();
                        newObjtoInsert.StartDateTime = DateTime.valueof(sendDatesSetsObj.sentStartDate);
                        newObjtoInsert.EndDateTime = DateTime.valueof(sendDatesSetsObj.sentEndDate);
                        newObjtoInsert.ActivityDateTime = DateTime.valueof(sendDatesSetsObj.sentStartDate);
                        newObjtoInsert.Subject = 'Availability';
                        newObjtoInsert.ShowAs = 'Free';      
                        //List<Event> eventList3 = [Select Id from Event where OwnerId =: currentUserId and ((StartDateTime =: newObjtoInsert.StartDateTime or EndDateTime =:newObjtoInsert.EndDateTime) or (StartDateTime >: newObjtoInsert.StartDateTime and StartDateTime <:newObjtoInsert.EndDateTime) or (EndDateTime >: newObjtoInsert.StartDateTime and EndDateTime <:newObjtoInsert.EndDateTime) or (StartDateTime <: newObjtoInsert.StartDateTime and EndDateTime >:newObjtoInsert.EndDateTime))];
                        List<Event> eventList3 = new List<Event>();
                        
                        for (Id key : Eventmap.keySet()) {
                            Event eventObject = Eventmap.get(key);
                            if((eventObject.StartDateTime == newObjtoInsert.StartDateTime || eventObject.EndDateTime == newObjtoInsert.EndDateTime) || (eventObject.StartDateTime > newObjtoInsert.StartDateTime && eventObject.StartDateTime < newObjtoInsert.EndDateTime) || (eventObject.EndDateTime > newObjtoInsert.StartDateTime && eventObject.EndDateTime < newObjtoInsert.EndDateTime) || (eventObject.StartDateTime < newObjtoInsert.StartDateTime && eventObject.EndDateTime > newObjtoInsert.EndDateTime))
                            {
                              eventList3.add(eventObject);  
                            }
                        }
                        
                        if(eventList3.size() == 0)
                        {
                            eventList3Insert.add(newObjtoInsert);
                            message = 'EVENT CREATED SUCCESSFULLY';
                        }
                        else 
                        {
                            unSuccessfullEvents = unSuccessfullEvents + 1;
                            message = 'AVAILABILTY EVENT ALREADY EXIST IN SELECTED TIMESLOT'; 
                        }
                    }
                    if(eventList3Insert.size() > 0)
                    {
                        Insert eventList3Insert;
                    }
                }        
            }
            if(unSuccessfullEvents > 0)
            {
                message = 'EVENTS CREATED SUCCESSFULLY EXCEPT '+unSuccessfullEvents + ' AVAILABILITY EVENTS BECAUSE EVENTS ALREADY EXISTS ON SAME TIME !';
            }
            return message;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Event> getEventList()
    {
        try {
            string currentUserId = UserInfo.getUserId();
            Date todaysDate = System.today();
            List<Event> eventList = [Select Id , Subject , StartDateTime , EndDateTime from Event where Subject = 'Availability' and OwnerId =: currentUserId and (ActivityDate =: todaysDate or ActivityDate >:todaysDate)];    
            System.Debug('EventList:'+eventList);
            
            List<Event> eventListtoreturnObj = new List<Event>();
            
            for(Event evtobj : eventList)
            {
                Event eventrtobj = new Event();
                eventrtobj.Id = evtobj.Id;
                eventrtobj.Subject = evtobj.Subject;
                eventrtobj.StartDateTime = toUTC(evtobj.StartDateTime);
                eventrtobj.EndDateTime = toUTC(evtobj.EndDateTime);
                eventListtoreturnObj.add(eventrtobj);
            }
            
            return eventListtoreturnObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static boolean deleteEvent(string lwcrecordId)
    {
        System.Debug('RowId:'+lwcrecordId);
        try {
            string currentUserId = UserInfo.getUserId();
            Date todaysDate = System.today();
            Event eventobjdelete = [Select Id from Event where Id =: lwcrecordId];
            delete eventobjdelete;
            return true;
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class SendDatesSets
    {
        public DateTime sentStartDate{get;set;}
        public DateTime sentEndDate{get;set;}
    }
    public static DateTime toUTC(DateTime value) {
        Integer offset = UserInfo.getTimezone().getOffset(value);
        return value.addSeconds(offset/1000);
    }
}