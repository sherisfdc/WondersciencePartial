@isTest
public class CC_API_CalendarIntegration_Test 
{
    @testSetup
    public static void CreateTestRecord() 
    {
        User userobj = new User();
        userobj.LastName = 'Test Code';
        userobj.Email = 'test@test.com';
        userobj.Alias = 'Tcode';
        userobj.Username = 'test123114@test.com';
        userobj.CommunityNickname = 'test12';
        userobj.LocaleSidKey = 'en_US';
        userobj.TimeZoneSidKey = 'GMT';
        userobj.ProfileID = userinfo.getProfileId();
        userobj.LanguageLocaleKey = 'en_US';
        userobj.EmailEncodingKey = 'UTF-8';
        userobj.ProviderStates__c = 'CA';
        Insert userobj;      
        
        Event eventObj = new Event();
        eventObj.StartDateTime = DateTime.valueOf('2022-02-10 17:00:00.000Z');
        eventObj.EndDateTime = DateTime.valueOf('2022-02-10 20:00:00.000Z');
        eventObj.ActivityDateTime = eventObj.StartDateTime;
        eventObj.Subject = 'Availability';
        eventObj.ShowAs = 'Free';
        eventObj.OwnerId = userobj.Id;
        Insert eventObj;  
        
        Account accobj = new Account();
        accobj.Name = 'TestPatient';
        insert accobj; 

    }
    @isTest static void mygetTest() 
    {
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        RestRequest request = new RestRequest();
        request.requestUri =baseUrl +'/services/apexrest/CalendarIntegration';
        request.httpMethod = 'GET';
        
        request.addParameter('state','CA');
        request.addParameter('startTime','2022-02-10T16:00:00.000Z');
        request.addParameter('endTime','2022-02-10T22:00:00.000Z');
        
        RestContext.request = request;
        CC_API_CalendarIntegration.ResponseWrapper wrapper = new CC_API_CalendarIntegration.ResponseWrapper();
        wrapper = CC_API_CalendarIntegration.doGet();
    }
    
      @isTest static void mygetproTest() 
    {
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        User userobj = [SELECT Id FROM User WHERE Username='test123114@test.com' LIMIT 1];
        RestRequest request = new RestRequest();
        request.requestUri =baseUrl+'/services/apexrest/CalendarIntegration';
        request.httpMethod = 'GET';
        
        request.addParameter('state','CA');
        request.addParameter('startTime','2022-02-10T16:00:00.000Z');
        request.addParameter('endTime','2022-02-10T22:00:00.000Z');
        request.addParameter('providerId',userobj.Id);
        
        RestContext.request = request;
        CC_API_CalendarIntegration.ResponseWrapper wrapper = new CC_API_CalendarIntegration.ResponseWrapper();
        wrapper = CC_API_CalendarIntegration.doGet();
    }
    
    @isTest static void mypostTest() 
    {
        User userobj = [SELECT Id FROM User WHERE Username='test123114@test.com' LIMIT 1];
        Account accobj = [SELECT Id FROM Account WHERE Name='TestPatient' LIMIT 1];
        Event evntobj = [SELECT Id,StartDateTime,EndDateTime FROM Event WHERE Subject = 'Availability' LIMIT 1];
        System.debug('userobj.Id :::' + userobj.Id);
        
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        RestRequest request = new RestRequest();
        request.requestUri =baseUrl+'/services/apexrest/CalendarIntegration';
        request.httpMethod = 'POST';
        
        request.addParameter('duration','60');
        request.addParameter('startTime','2022-02-10T21:00:00.000Z');
        request.addParameter('providerId',userobj.Id);
        request.addParameter('patientId',accobj.Id);
        request.addParameter('zoomMeetingUrl','Test Zoom Meeting URL');
        request.addParameter('appointmentType','established-patient');
        
        RestContext.request = request;
        CC_API_CalendarIntegration.ResponseWrapperPost wrapper = new CC_API_CalendarIntegration.ResponseWrapperPost();
        wrapper = CC_API_CalendarIntegration.doPost();
    }
    
    @isTest static void myposttTest() 
    {
        User userobj = [SELECT Id FROM User WHERE Username='test123114@test.com'];
        Account accobj = [SELECT Id FROM Account WHERE Name='TestPatient'];
        Event evntobj = [SELECT Id,StartDateTime,EndDateTime FROM Event WHERE Subject = 'Availability' LIMIT 1];
        System.debug('userobj.Id :::' + userobj.Id);
        
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        RestRequest request = new RestRequest();
        request.requestUri =baseUrl + '/services/apexrest/CalendarIntegration';
        request.httpMethod = 'POST';
        
        request.addParameter('duration','180');
        request.addParameter('startTime','2022-02-10T21:00:00.000Z');
        request.addParameter('providerId',userobj.Id);
        request.addParameter('patientId',accobj.Id);
        request.addParameter('zoomMeetingUrl','Test Zoom Meeting URL');
        request.addParameter('appointmentType','established-patient');
        
        RestContext.request = request;
        CC_API_CalendarIntegration.ResponseWrapperPost wrapper = new CC_API_CalendarIntegration.ResponseWrapperPost();
        wrapper = CC_API_CalendarIntegration.doPost();
    }  
    
     @isTest static void mypostttTest() 
    {
        User userobj = [SELECT Id FROM User WHERE Username='test123114@test.com'];
        Account accobj = [SELECT Id FROM Account WHERE Name='TestPatient'];
        Event evntobj = [SELECT Id,StartDateTime,EndDateTime FROM Event WHERE Subject = 'Availability' LIMIT 1];
        System.debug('userobj.Id :::' + userobj.Id);
        
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        RestRequest request = new RestRequest();
        request.requestUri =baseUrl+'/services/apexrest/CalendarIntegration';
        request.httpMethod = 'POST';
        
        request.addParameter('duration','60');
        request.addParameter('startTime','2022-02-10T23:00:00.000Z');
        request.addParameter('providerId',userobj.Id);
        request.addParameter('patientId',accobj.Id);
        request.addParameter('zoomMeetingUrl','Test Zoom Meeting URL');
        request.addParameter('appointmentType','established-patient');
        
        RestContext.request = request;
        CC_API_CalendarIntegration.ResponseWrapperPost wrapper = new CC_API_CalendarIntegration.ResponseWrapperPost();
        wrapper = CC_API_CalendarIntegration.doPost();
    } 
    
    @isTest static void myposttttTest() 
    {
        User userobj = [SELECT Id FROM User WHERE Username='test123114@test.com'];
        Event eventObj = new Event();
        eventObj.StartDateTime = DateTime.valueOf('2022-02-15 17:00:00.000Z');
        eventObj.EndDateTime = DateTime.valueOf('2022-02-15 20:00:00.000Z');
        eventObj.ActivityDateTime = eventObj.StartDateTime;
        eventObj.Subject = 'Availability';
        eventObj.ShowAs = 'Free';
        eventObj.OwnerId = userobj.Id;
        Insert eventObj; 
        
        
        Account accobj = [SELECT Id FROM Account WHERE Name='TestPatient'];
        Event evntobj = [SELECT Id,StartDateTime,EndDateTime FROM Event WHERE Subject = 'Availability' LIMIT 1];
        System.debug('userobj.Id :::' + userobj.Id);
        
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        RestRequest request = new RestRequest();
        request.requestUri =baseUrl+'/services/apexrest/CalendarIntegration';
        request.httpMethod = 'POST';
        
        request.addParameter('duration','60');
        request.addParameter('startTime','2022-02-15T22:00:00.000Z');
        request.addParameter('providerId',userobj.Id);
        request.addParameter('patientId',accobj.Id);
        request.addParameter('zoomMeetingUrl','Test Zoom Meeting URL');
        request.addParameter('appointmentType','established-patient');
        
        RestContext.request = request;
        CC_API_CalendarIntegration.ResponseWrapperPost wrapper = new CC_API_CalendarIntegration.ResponseWrapperPost();
        wrapper = CC_API_CalendarIntegration.doPost();
    }
    
    @isTest static void mypatchTest() 
    {
        Event evenobj = [SELECT Id FROM Event WHERE Subject='Availability'];
        Account accobj = [SELECT Id FROM Account WHERE Name='TestPatient'];
        User userobj = [SELECT Id FROM User WHERE Username='test123114@test.com'];
        
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        RestRequest request = new RestRequest();
        request.requestUri =baseUrl+'/services/apexrest/CalendarIntegration';
        request.httpMethod = 'PATCH';
        
        request.addParameter('duration','60');
        request.addParameter('startTime','2022-02-10T21:00:00.000Z');
        request.addParameter('zoomMeetingUrl','Test Zoom Meeting URL');
        request.addParameter('id',evenobj.Id);
         request.addParameter('appointmentType','established-patient');
        request.addParameter('providerId',userobj.Id);
        
        RestContext.request = request;
        CC_API_CalendarIntegration.ResponseWrapperPost wrapper = new CC_API_CalendarIntegration.ResponseWrapperPost();
        wrapper = CC_API_CalendarIntegration.doPatch();
    }
    
    @isTest static void mypatchhTest() 
    {
        Event evenobj = [SELECT Id FROM Event WHERE Subject='Availability'];
        Account accobj = [SELECT Id FROM Account WHERE Name='TestPatient'];
        User userobj = [SELECT Id FROM User WHERE Username='test123114@test.com'];
        
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        RestRequest request = new RestRequest();
        request.requestUri =baseUrl+'/services/apexrest/CalendarIntegration';
        request.httpMethod = 'PATCH';
        
        request.addParameter('duration','180');
        request.addParameter('startTime','2022-02-10T21:00:00.000Z');
        request.addParameter('zoomMeetingUrl','Test Zoom Meeting URL');
        request.addParameter('id',evenobj.Id);
        request.addParameter('appointmentType','established-patient');
        request.addParameter('providerId',userobj.Id);
        
        RestContext.request = request;
        CC_API_CalendarIntegration.ResponseWrapperPost wrapper = new CC_API_CalendarIntegration.ResponseWrapperPost();
        wrapper = CC_API_CalendarIntegration.doPatch();
    }
    
    @isTest static void mypatchhhTest() 
    {
        Event evenobj = [SELECT Id FROM Event WHERE Subject='Availability' LIMIT 1];
        Account accobj = [SELECT Id FROM Account WHERE Name='TestPatient'];
        User userobj = [SELECT Id FROM User WHERE Username='test123114@test.com'];
        
        Event eventObjj = new Event();
        eventObjj.StartDateTime = DateTime.valueOf('2022-02-15 01:00:00.000Z');
        eventObjj.EndDateTime = DateTime.valueOf('2022-02-15 09:00:00.000Z');
        eventObjj.ActivityDateTime = eventObjj.StartDateTime;
        eventObjj.Subject = 'Availability';
        eventObjj.ShowAs = 'Free';
        eventObjj.WhatId = accobj.Id;
        eventObjj.OwnerId = userobj.Id;
        Insert eventObjj;
        
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        RestRequest request = new RestRequest();
        request.requestUri =baseUrl+'/services/apexrest/CalendarIntegration';
        request.httpMethod = 'PATCH';
        
        request.addParameter('duration','120');
        request.addParameter('startTime','2022-02-15T05:00:00.000Z');
        request.addParameter('zoomMeetingUrl','Test Zoom Meeting URL');
        request.addParameter('id',eventObjj.Id);
        request.addParameter('appointmentType','established-patient');
        request.addParameter('providerId',userobj.Id);
        
        RestContext.request = request;
        CC_API_CalendarIntegration.ResponseWrapperPost wrapper = new CC_API_CalendarIntegration.ResponseWrapperPost();
        wrapper = CC_API_CalendarIntegration.doPatch();
    }
    
    @isTest static void mydeleteTest() 
    {
        User userobj = [SELECT Id FROM User WHERE Username='test123114@test.com'];
        Account accobj = [SELECT Id FROM Account WHERE Name='TestPatient'];
        Event eventObj = new Event();
        eventObj.StartDateTime = DateTime.valueOf('2022-02-11 17:00:00.000Z');
        eventObj.EndDateTime = DateTime.valueOf('2022-02-11 20:00:00.000Z');
        eventObj.ActivityDateTime = eventObj.StartDateTime;
        eventObj.Subject = 'Meeting';
        eventObj.ShowAs = 'Busy';
        eventObj.WhatId = accobj.Id;
        eventObj.OwnerId = userobj.Id;
        C_AcoidRecursiveness.runEventTrigger = false;
        Insert eventObj;
        
        Event evenobj = [SELECT Id FROM Event WHERE Subject='Availability'];
        
        /*ent eventObj1 = new Event();
        eventObj1.StartDateTime = DateTime.valueOf('2022-02-10 20:00:00.000Z');
        eventObj1.EndDateTime = DateTime.valueOf('2022-02-10 23:00:00.000Z');
        eventObj1.ActivityDateTime = eventObj1.StartDateTime;
        eventObj1.Subject = 'Availability';
        eventObj1.ShowAs = 'Free';
        eventObj1.OwnerId = evenobj.OwnerId;
        Insert eventObj1; */
        
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        RestRequest request = new RestRequest();
        request.requestUri =baseUrl+'/services/apexrest/CalendarIntegration';
        request.httpMethod = 'DELETE';
        
        request.addParameter('id',eventObj.Id);
        
        RestContext.request = request;
        CC_API_CalendarIntegration.ResponseWrapper wrapper = new CC_API_CalendarIntegration.ResponseWrapper();
        wrapper = CC_API_CalendarIntegration.doDelete();
    }
}