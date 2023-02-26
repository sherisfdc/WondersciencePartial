@isTest
public class CC_SetDataforAthena_Schedular_Test {

    @testsetup static void setup()
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
        userobj.Athena_Username__c = 'Sheriii User';
        Insert userobj;      
        
        Account accobj = new Account();
        accobj.Name = 'TestPatient';
        accobj.Athena_Id__c = '175';
        insert accobj; 
        
        Account accobjj = new Account();
        accobjj.Name = 'TestPatient2';
        accobjj.Athena_Id__c = '176';
        insert accobjj; 
        
        Event eventObj = new Event();
        eventObj.StartDateTime = DateTime.valueOf('2022-02-20 17:00:00.000Z');
        eventObj.EndDateTime = DateTime.valueOf('2022-02-20 20:00:00.000Z');
        eventObj.ActivityDateTime = eventObj.StartDateTime;
        eventObj.Subject = 'Meeting';
        eventObj.ShowAs = 'Free';
        eventObj.Appointment_Type__c = 'new-patient';
        eventObj.OwnerId = userobj.Id;
        eventObj.WhatId = accobj.Id;
        C_AcoidRecursiveness.runEventTrigger = false;
        Insert eventObj;
        
        eventObj.ShowAs = 'Busy';
        Update eventObj;
        
        Event eventObjj = new Event();
        eventObjj.StartDateTime = DateTime.valueOf('2022-02-05 17:00:00.000Z');
        eventObjj.EndDateTime = DateTime.valueOf('2022-02-05 20:00:00.000Z');
        eventObjj.ActivityDateTime = eventObjj.StartDateTime;
        eventObjj.Subject = 'Meeting';
        eventObjj.ShowAs = 'Free';
        eventObjj.Appointment_Type__c = 'new-patient';
        eventObjj.OwnerId = userobj.Id;
        eventObjj.WhatId = accobjj.Id;
        C_AcoidRecursiveness.runEventTrigger = false;
        Insert eventObjj;
        
        eventObjj.ShowAs = 'Busy';
        Update eventObjj;
        
        Integration__c intobj = new Integration__c();
        intobj.Data_for_Athena__c = '{"ProviderUsername":null,"PreviousDateTime":null,"PatientState":"CA","NewStartDateTime":"2022-04-05T05:00:00.000Z","Duration":60,"AppointmentType":"new-patient"}';
        intobj.Athena_Status__c = '';
        intobj.Method_Action__c = 'POST';
        intobj.Payload__c = '{"startTime":"2022-04-05T05:00:00.000Z","providerId":"'+userobj.Id+'","patientId":"'+accobj.Id+'","zoomMeetingUrl":"Test Zoom URL","appointmentType":"new-patient","duration":"60"}';
        intobj.Send_To_Athena__c = false;
        intobj.Class_Name__c = 'CC_API_CalendarIntegration';
        intobj.Status_Code__c = '200';
        Insert intobj;
        
        Integration__c intobjj = new Integration__c();
        intobjj.Data_for_Athena__c = '{"ProviderUsername":null,"PreviousDateTime":null,"PatientState":"CA","NewStartDateTime":"2022-04-05T05:00:00.000Z","Duration":60,"AppointmentType":"new-patient"}';
        intobjj.Athena_Status__c = '';
        intobjj.Method_Action__c = 'PATCH';
        intobjj.Payload__c = '{"id":"'+eventObjj.Id+'"}';
        intobjj.Send_To_Athena__c = false;
        intobjj.Class_Name__c = 'CC_API_CalendarIntegration';
        intobjj.Status_Code__c = '200';
        Insert intobjj;
        
    }
    
     @isTest static void testMethod1() {
        CC_SetDataforAthena_Schedular sch = new CC_SetDataforAthena_Schedular();
        sch.execute(null);
    }
    
}