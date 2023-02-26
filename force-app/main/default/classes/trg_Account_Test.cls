@isTest
public class trg_Account_Test {

    @testSetup
    public static void CreateTestRecord()
    {
        Account accobj = new Account();
        accobj.Name = 'TestPatient';
        accobj.Sent_to_Athena__c = false;
        accobj.On_Boarding_Wizard_Completed_At__c = 'test';
        insert accobj; 
        accobj.Name = 'TestPatientt';
        update accobj;  
    }
    
    @isTest static void testMethod1() {
        
Account accountObj = [Select Id , Sent_to_Athena__c from Account LIMIT 1];
        accountObj.Sent_to_Athena__c = false;
        Update accountObj;
	}
    
    @isTest static void testMethod2() {
        
        Account accobjj = new Account();
        accobjj.Name = 'TestPatient2';
        insert accobjj; 
	}
    
    @isTest static void testMethod3() {
        
        Account accobjj = new Account();
        
        Account accountObj = [Select Id , Sent_to_Athena__c from Account LIMIT 1];
        accountObj.Sent_to_Athena__c = true;
        accountObj.On_Boarding_Wizard_Completed_At__c = null;
        Update accountObj;
	}
}