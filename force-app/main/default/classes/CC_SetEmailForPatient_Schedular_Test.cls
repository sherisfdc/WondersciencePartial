@isTest
public class CC_SetEmailForPatient_Schedular_Test {
    @testSetup static void setup()
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
        
        Account accobj = new Account();
        accobj.Name = 'TestPatient';
        insert accobj; 
        
        Account accobjj = new Account();
        accobjj.Name = 'TestPatient2';
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
        
    }
    
    @isTest static void testMethod1() {
        CC_SetEmailForPatient_Schedular sch = new CC_SetEmailForPatient_Schedular();
        sch.execute(null);
    }
}