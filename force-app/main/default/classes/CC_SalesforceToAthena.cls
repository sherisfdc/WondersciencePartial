global class CC_SalesforceToAthena implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    public string accountId;
    public CC_SalesforceToAthena(string accId){  
        System.debug('AccountId:: '+AccountId);
        accountId = accId;
    }
    global Database.Querylocator start (Database.BatchableContext BC) {
        System.debug('AccountId: '+accountId);
        //string query = 'SELECT Id,BillingAddress,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,Confirmed_Email__c,CreatedById,CreatedDate,Date_of_Birth__c,Email__c,Employer__c,Gender__c,Id,LastModifiedDate,Maritial_Status__c,Name,Occupation__c,On_Boarding_Wizard_Completed_At__c,On_Boarding_Wizard_Created_At__c,On_Boarding_Wizard_Last_Completed_Step__c,On_Boarding_Wizard_Updated_At__c,On_Boarding_Wizard__c,OwnerId,ParentId,Phone,Preferred_Pronouns__c,RecordTypeId,ShippingAddress,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet,Stripe_Customer_Id__c'+'FROM Account'+'WHERE Id =:\'' + accountId + '\'';
        return Database.getQueryLocator([SELECT BillingAddress,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,Confirmed_Email__c,CreatedById,CreatedDate,Date_of_Birth__c,Email__c,Employer__c,Gender__c,Id,LastModifiedDate,Maritial_Status__c,Name,Occupation__c,On_Boarding_Wizard_Completed_At__c,On_Boarding_Wizard_Created_At__c,On_Boarding_Wizard_Last_Completed_Step__c,On_Boarding_Wizard_Updated_At__c,On_Boarding_Wizard__c,OwnerId,ParentId,Phone,Preferred_Pronouns__c,RecordTypeId,ShippingAddress,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet,Authorizenet_Customer_Id__c,Ally_Contact_Name__c,Ally_Contact_Email__c,Emergency_Contact_Name__c,Emergency_Contact_Phone__c,Emergency_Contact_Relationship__c,SSN__c FROM Account WHERE Id =:accountId]);
        //return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Account> accList){
        System.debug('AcctList: '+ accList);
        List<CC_API_Wrapper> wrapperList = new List<CC_API_Wrapper>();
        CC_API_Wrapper wrapperObj;
        for(Account acc : accList){
            
            //List<Contact> allyContactList = [SELECT LastName,Email,CreatedDate,LastModifiedDate from Contact where AccountId =: acc.Id and Contact_Type__c = 'Ally'];
            //List<Contact> emergencyContactList = [SELECT LastName,Phone,CreatedDate,LastModifiedDate,Relationship__c from Contact where AccountId =: acc.Id and Contact_Type__c = 'Emergency'];
            Integer allycontactListsize = 0;
            Integer emergencycontactListsize = 0;
            //allycontactListsize = allyContactList.size();
            //emergencycontactListsize = emergencyContactList.size();
            
            wrapperObj = new CC_API_Wrapper();
            wrapperObj.onboardingWizard = new CC_API_Wrapper.cls_onboardingWizard();
            wrapperObj.allyContact = new CC_API_Wrapper.cls_allyContact();
            wrapperObj.emergencyContact = new CC_API_Wrapper.cls_emergencyContact();
            wrapperObj.billingAddress = new CC_API_Wrapper.cls_billingAddress();
            wrapperObj.shippingAddress = new CC_API_Wrapper.cls_shippingAddress();
            
            wrapperObj.id = acc.Id;
            wrapperObj.lastName = acc.Name;
            wrapperObj.email = acc.Email__c;
            wrapperObj.phoneNumber = acc.Phone;
            wrapperObj.biologicalSex = acc.Gender__c;
            wrapperObj.preferredPronouns = acc.Preferred_Pronouns__c;
            wrapperObj.relationshipStatus = acc.Maritial_Status__c;
            wrapperObj.occupation = acc.Occupation__c;
            wrapperObj.employer = acc.Employer__c;
            if(acc.Date_of_Birth__c != null)
            //wrapperObj.birthDate = acc.Date_of_Birth__c.format('yyyy/MM/dd hh:mm:ss');
            wrapperObj.birthDate = String.valueOf(acc.Date_of_Birth__c);
            wrapperObj.confirmedEmail = acc.Confirmed_Email__c;
            wrapperObj.authorizeNetCustomerId = acc.Authorizenet_Customer_Id__c;
            if(acc.CreatedDate != null)
                wrapperObj.createdAt = acc.CreatedDate.format('yyyy/MM/dd hh:mm:ss');
            if(acc.LastModifiedDate != null)
                wrapperObj.updatedAt = acc.LastModifiedDate.format('yyyy/MM/dd hh:mm:ss');
            if(acc.On_Boarding_Wizard_Completed_At__c != null && acc.On_Boarding_Wizard_Completed_At__c != '')
                wrapperObj.onboardingWizard.completedAt = string.valueof(acc.On_Boarding_Wizard_Completed_At__c);
            if(acc.On_Boarding_Wizard_Last_Completed_Step__c != null && acc.On_Boarding_Wizard_Last_Completed_Step__c != '')
                wrapperObj.onboardingWizard.lastCompletedStep = acc.On_Boarding_Wizard_Last_Completed_Step__c;
            if(acc.On_Boarding_Wizard_Created_At__c != null && acc.On_Boarding_Wizard_Created_At__c != '')
                wrapperObj.onboardingWizard.createdAt = string.valueof(acc.On_Boarding_Wizard_Created_At__c);
            if(acc.On_Boarding_Wizard_Updated_At__c != null && acc.On_Boarding_Wizard_Updated_At__c != '')
                wrapperObj.onboardingWizard.updatedAt = String.valueof(acc.On_Boarding_Wizard_Updated_At__c);
            
            if(acc.Ally_Contact_Name__c != '')
            {
                wrapperObj.allyContact.name = acc.Ally_Contact_Name__c;
                wrapperObj.allyContact.email = acc.Ally_Contact_Email__c;
                //if(allyContactList[0].CreatedDate != null)
                   // wrapperObj.allyContact.createdAt = allyContactList[0].CreatedDate.format('yyyy/MM/dd hh:mm:ss');
                //if(allyContactList[0].LastModifiedDate != null)
                   // wrapperObj.allyContact.updatedAt = allyContactList[0].LastModifiedDate.format('yyyy/MM/dd hh:mm:ss');
            }
            
            if(acc.Emergency_Contact_Name__c != '')
            {
                wrapperObj.emergencyContact.name = acc.Emergency_Contact_Name__c;
                wrapperObj.emergencyContact.phoneNumber = acc.Emergency_Contact_Phone__c;
                wrapperObj.emergencyContact.relationship = acc.Emergency_Contact_Relationship__c;
                //if(emergencyContactList[0].CreatedDate != null)
                   // wrapperObj.emergencyContact.createdAt = emergencyContactList[0].CreatedDate.format('yyyy/MM/dd hh:mm:ss');
               // if(emergencyContactList[0].LastModifiedDate != null)
                   // wrapperObj.emergencyContact.updatedAt = emergencyContactList[0].LastModifiedDate.format('yyyy/MM/dd hh:mm:ss');
            }
            
            if(acc.SSN__c != '')
            {
               wrapperObj.ssn = acc.SSN__c;
            }
            
            wrapperObj.billingAddress.city = acc.BillingCity;
           // wrapperObj.billingAddress.country = acc.BillingCountry;
            wrapperObj.billingAddress.addressLine1 = acc.BillingStreet;
            wrapperObj.billingAddress.postalCode = acc.BillingPostalCode;
            wrapperObj.billingAddress.state = acc.BillingState;
            
            wrapperObj.shippingAddress.city = acc.ShippingCity;
            //wrapperObj.shippingAddress.country = acc.ShippingCountry;
            wrapperObj.shippingAddress.addressLine1 = acc.ShippingStreet;
            wrapperObj.shippingAddress.postalCode = acc.ShippingPostalCode;
            wrapperObj.shippingAddress.state = acc.ShippingState;
            
            wrapperList.add(wrapperObj);
            string output = JSON.serialize(wrapperList);
            CC_SalesforcetoAthenaResponse saltoathObj = new CC_SalesforcetoAthenaResponse();
            saltoathObj.name = 'TstItem';
            saltoathObj.dataJson = output;
            saltoathObj.queueId = 'EF469028-F0FA-463C-893A-B99DB8B8459C';
            saltoathObj.type = 'Json';
            saltoathObj.jsonType = 'QueueItem';
            saltoathObj.expireOnUTC = '';
            saltoathObj.postponeUntilUTC = '';
            saltoathObj.source = 'Salesforce';
            saltoathObj.event = '';
            saltoathObj.accountId = acc.Id;
            //if(allycontactListsize > 0)
            //{
            //saltoathObj.allycontactId = allyContactList[0].Id;
            //}
            //if(emergencycontactListsize > 0)
            ///{
            //saltoathObj.emergencycontactId = emergencyContactList[0].Id;
           // }
            string saltoathObjjson = JSON.serialize(saltoathObj);
            System.debug('OutputJSON::::::: '+saltoathObjjson);
            HttpRequest req = new HttpRequest();
            req.setEndPoint('https://dev-api.cloudserver.openbots.io/api/v3/SalesforceQueueItems/Enqueue');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('APIKEYNAME', 'zp3woXvS0EsHBfXMEAnu');
            req.setBody(saltoathObjjson);
            req.setTimeout(120000);
            Http http = new Http();
            HttpResponse res = new HttpResponse();
            if(Test.isRunningTest()){
                res.setStatusCode(200);
                res.setBody('{"status_message":"Success"}');
            }else{
                res =  http.send(req);
            }
            if(res.getStatusCode() == 200)
            {
                system.debug(':::res.getbody:::' + res.getBody());
                CC_Response responseObj = (CC_Response)Json.deserialize(res.getBody(),CC_Response.class);
                if(responseObj.status_message == 'Success'){
                }
            }
            else
            {
                Integration__c interrobj = new Integration__c();
                interrobj.Class_Name__c = 'CC_SalesforceToAthena';
                interrobj.Payload__c = saltoathObjjson;
                interrobj.Message__c = res.getBody();
                Insert interrobj;
            }
        }
    }
    global void finish(Database.BatchableContext bc){
    }   
    
}