@isTest
private class CC_SalesforceToAthena_test{

	@testSetup static void setup(){

		Account accountObj = new Account ( 
			BillingStreet = 'Test Value', 
			BillingCity = 'test value', 
			BillingState = 'test value', 
			BillingPostalCode = 'test value', 
			BillingCountry = 'test value', 
			ShippingStreet = 'Test Value', 
			ShippingCity = 'test value',
            On_Boarding_Wizard_Completed_At__c = 'test',
            On_Boarding_Wizard_Created_At__c = 'test',
            On_Boarding_Wizard_Updated_At__c = 'test',
            On_Boarding_Wizard_Last_Completed_Step__c = 'test',
            
            Date_of_Birth__c = Date.valueOf(('2012-08-19T19:30:07:00Z').split('T')[0]),
			ShippingState = 'test value', 
			ShippingPostalCode = 'test value', 
			ShippingCountry = 'test value', 
			Phone = '1234567890', 
			Name = 'test value',
            Ally_Contact_Name__c = 'test value',
            Ally_Contact_Email__c = 'testEmail@gmail.com',
            Emergency_Contact_Name__c = 'test value',
            Emergency_Contact_Phone__c = '1234567890',
            Emergency_Contact_Relationship__c = 'Friend'
		);
		insert accountObj;
               
        
		/* Contact contactObj = new Contact (
			Phone = '1234567890', 
			Email = 'testEmail@gmail.com', 
             AccountId = accountObj.Id,
             Contact_Type__c = 'Ally',
			LastName = 'test value'
		);
		insert contactObj;
        
		 Contact contactObj1 = new Contact (
			Phone = '1234567890', 
			Email = 'testEmail@gmail.com', 
             AccountId = accountObj.Id,
             Contact_Type__c = 'Emergency',
			LastName = 'test value'
		);
		insert contactObj1; */
        
		 
	}

	@isTest static void testMethod1() {
	    Account accountObj = [Select Id , Sent_to_Athena__c from Account LIMIT 1];
        accountObj.Sent_to_Athena__c = false;
        Update accountObj;
	}
}