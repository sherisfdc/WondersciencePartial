@isTest
public class trg_InitialAppointmentDate_Test {
	@testSetup
    public static void SetupData(){
        Account accObj = new Account();
        accObj.Name = 'Test';
        insert accObj;
        Event eventObjNew = new Event();
        eventObjNew.StartDateTime = datetime.now();
        eventObjNew.EndDateTime = datetime.now().addHours(1);
        eventObjNew.Subject = 'Availability';
        eventObjNew.ShowAs = 'Free';
        eventObjNew.whatID = accObj.Id;
        eventObjNew.Appointment_Type__c = 'new-patient';
        Insert eventObjNew;
        update eventObjNew;
    }
    @isTest
    public static void MethodA(){
        
    }
}