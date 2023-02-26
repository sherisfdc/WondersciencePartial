@isTest
public class EventCreationController_Test {

    @isTest static void myCreateTest() 
    {
        Event eventObjj = new Event();
        eventObjj.StartDateTime = DateTime.valueOf('2022-02-12 20:00:00.000Z');
        eventObjj.EndDateTime = DateTime.valueOf('2022-02-12 23:00:00.000Z');
        eventObjj.ActivityDateTime = eventObjj.StartDateTime;
        eventObjj.Subject = 'Availability';
        eventObjj.ShowAs = 'Free';
        eventObjj.OwnerId = UserInfo.getUserId();
        Insert eventObjj;
        
        Event eventObj = new Event();
        eventObj.StartDateTime = DateTime.valueOf('2022-02-12 17:00:00.000Z');
        eventObj.EndDateTime = DateTime.valueOf('2022-02-12 20:00:00.000Z');
        eventObj.Subject = 'Availability';
        
        string message = EventCreationController.createEvent(eventObj,false,'');
        System.assertEquals('EVENT CREATED SUCCESSFULLY',message);
    }
    
    @isTest static void myCreateeTest() 
    {
        Event eventObj = new Event();
        eventObj.StartDateTime = DateTime.valueOf('2022-02-13 17:00:00.000Z');
        eventObj.EndDateTime = DateTime.valueOf('2022-02-15 20:00:00.000Z');
        eventObj.Subject = 'Availability';
        
        string message = EventCreationController.createEvent(eventObj,false,'');
        System.assertEquals('EVENT CREATED SUCCESSFULLY',message);
    }
    
    @isTest static void myCreateeeTest() 
    {
        Event eventObj = new Event();
        eventObj.StartDateTime = DateTime.valueOf('2022-02-16 17:00:00.000Z');
        eventObj.EndDateTime = DateTime.valueOf('2022-02-17 20:00:00.000Z');
        eventObj.Subject = 'Availability';
        
        string message = EventCreationController.createEvent(eventObj,false,'');
        System.assertEquals('EVENT CREATED SUCCESSFULLY',message);
    }
    
    @isTest static void myListTest() 
    {
        Event eventObj = new Event();
        eventObj.StartDateTime = DateTime.valueOf('2022-02-10 17:00:00.000Z');
        eventObj.EndDateTime = DateTime.valueOf('2022-02-10 20:00:00.000Z');
        eventObj.ActivityDateTime = eventObj.StartDateTime;
        eventObj.Subject = 'Availability';
        eventObj.ShowAs = 'Free';
        eventObj.OwnerId = UserInfo.getUserId();
        Insert eventObj;
        
        List<Event> myevent = new List<Event>();       
        myevent = EventCreationController.getEventList();
    }
    
    @isTest static void mydeleteTest() 
    {   
        Event eventObj = new Event();
        eventObj.StartDateTime = DateTime.valueOf('2022-02-10 17:00:00.000Z');
        eventObj.EndDateTime = DateTime.valueOf('2022-02-10 20:00:00.000Z');
        eventObj.ActivityDateTime = eventObj.StartDateTime;
        eventObj.Subject = 'Availability';
        eventObj.ShowAs = 'Free';
        Insert eventObj;
        boolean abc = EventCreationController.deleteEvent(eventObj.Id);
    }
}