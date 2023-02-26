@RestResource(urlMapping='/UserData/*')
global class CC_API_UserData {
    @HttpPost
    global static CC_Response InsertUser() {
        CC_Response response = new CC_Response();
        RestRequest req = RestContext.request;
        response.input_result = req.requestBody.tostring();
        system.debug('::::REQ::::'+req.requestBody.tostring());
        CC_API_Wrapper jasonApex = CC_API_Wrapper.parse(req.requestBody.toString());
        system.debug('::::jasonApex:::' + jasonApex);
        try{        
            ReturnResult returnResultObj = new ReturnResult();
            returnResultObj = insertAccount(jasonApex);   
            InsertIntegration(req.requestBody.tostring(), returnResultObj.accountId);
            Map<string,Id> formIdMap = new Map<string,Id>();
            Map<string,Id> questionIdMap = new Map<string,Id>();
            if(jasonApex.formSubmissions != null){
                if(jasonApex.formSubmissions.size() >0){
                    formIdMap = insertForm(jasonApex.formSubmissions);
                    questionIdMap = insertQuestion(jasonApex,formIdMap);
                    insertAccQA(jasonApex,returnResultObj.accountId,formIdMap,questionIdMap);
                }
            }
            response.status_code = 200;
            response.account_id = returnResultObj.accountId;
            response.opportunity_id = returnResultObj.opportunityId;
            response.status_message = 'Success';
            
            
        }catch(Exception ex){
            response.status_code = 400;
            response.status_message =ex.getLineNumber() + ':::' + ex.getMessage();    
            InsertIntegrationError(ex.getLineNumber(),ex.getMessage(),req.requestBody.toString());
        }
        return response;
    }
    
    Public static ReturnResult insertAccount(CC_API_Wrapper jasonApex){
        List<Account> accountList = [Select Id from Account where User_Id__c =: jasonApex.id];
        Account accObj = new Account();    
        accObj.User_Id__c = jasonApex.id;
        accObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        Opportunity oppObj;
        if((jasonApex.firstName != null && jasonApex.firstName != '') || (jasonApex.lastName != '' && jasonApex.lastName != null))
        {
            accObj.Name = jasonApex.firstName+' '+ jasonApex.lastName;
            accObj.First_Name__c = jasonApex.firstName;
            accObj.Last_Name__c = jasonApex.lastName;
        }
        if(jasonApex.referralCode != null && jasonApex.referralCode != '')
            accObj.Referral_Code__c = jasonApex.referralCode;
        if(jasonApex.stateIdNumber != null && jasonApex.stateIdNumber != '')
            accObj.State_Id_Number__c = jasonApex.stateIdNumber;
        if(jasonApex.email != null && jasonApex.email != '')
            accObj.Email__c = jasonApex.email;
        if(jasonApex.phoneNumber != null && jasonApex.phoneNumber != '')
            accObj.Phone = jasonApex.phoneNumber;
        if(jasonApex.biologicalSex != null && jasonApex.biologicalSex != '')
            accObj.Gender__c = jasonApex.biologicalSex;
        if(jasonApex.preferredPronouns != null && jasonApex.preferredPronouns != '')
            accObj.Preferred_Pronouns__c = jasonApex.preferredPronouns;
        if(jasonApex.relationshipStatus != null && jasonApex.relationshipStatus != '')
            accObj.Maritial_Status__c = jasonApex.relationshipStatus;
        if(jasonApex.occupation != null && jasonApex.occupation != '')
            accObj.Occupation__c = jasonApex.occupation;
        if(jasonApex.employer != null && jasonApex.employer != '')
            accObj.Employer__c = jasonApex.employer;
        if(jasonApex.confirmedEmail != null)
            accObj.Confirmed_Email__c = jasonApex.confirmedEmail;
        if(jasonApex.authorizeNetCustomerId != null && jasonApex.authorizeNetCustomerId != '')
            accObj.Authorizenet_Customer_Id__c = jasonApex.authorizeNetCustomerId;
        if(jasonApex.birthDate != null && jasonApex.birthDate != '')
            accObj.Date_of_Birth__c = Date.valueOf(jasonApex.birthDate.split('T')[0]);
        if(accountList.size() == 0 && jasonApex.createdAt != null && jasonApex.updatedAt != null){
            //accObj.Created_At__c = string.valueof(jasonApex.createdAt.replace('T',' '));
            //accObj.Updated_At__c = string.valueof(jasonApex.updatedAt.replace('T',' '));
            accObj.Created_At_Date__c = (Datetime)JSON.deserialize('"'+jasonApex.createdAt+'"', DateTime.class);
            accObj.Updated_At_Date__c = (Datetime)JSON.deserialize('"'+jasonApex.updatedAt+'"', DateTime.class);
            //System.debug('CreatedDatetest ---->'+accObj.Created_At__c);
            //System.debug('UpdatedDatetest ---->'+accObj.Updated_At__c);
        }
        if(jasonApex.ssn != null)
        {
            accObj.SSN__c = jasonApex.ssn;
        }
        
        if(jasonApex.onboardingWizard != null){
            if(jasonApex.onboardingWizard.completedAt != null && jasonApex.onboardingWizard.completedAt != '')
                //accObj.On_Boarding_Wizard_Completed_At__c = string.valueof(jasonApex.onboardingWizard.completedAt.replace('T',' '));
                accObj.On_Boarding_Wizard_Completed_At_Date__c = (Datetime)JSON.deserialize('"'+jasonApex.onboardingWizard.completedAt+'"', DateTime.class);
            if(jasonApex.onboardingWizard.lastCompletedStep != null && jasonApex.onboardingWizard.lastCompletedStep != '')
                accObj.On_Boarding_Wizard_Last_Completed_Step__c = jasonApex.onboardingWizard.lastCompletedStep;
            if(jasonApex.onboardingWizard.createdAt != null && jasonApex.onboardingWizard.createdAt != '')
                //accObj.On_Boarding_Wizard_Created_At__c = string.valueof(jasonApex.onboardingWizard.createdAt.replace('T',' '));
                accObj.On_Boarding_Wizard_Created_At_Date__c = (Datetime)JSON.deserialize('"'+jasonApex.onboardingWizard.createdAt+'"', DateTime.class);
            if(jasonApex.onboardingWizard.updatedAt != null && jasonApex.onboardingWizard.updatedAt != '')
                //accObj.On_Boarding_Wizard_Updated_At__c = string.valueof(jasonApex.onboardingWizard.updatedAt.replace('T',' '));
                accObj.On_Boarding_Wizard_Updated_At_Date__c = (Datetime)JSON.deserialize('"'+jasonApex.onboardingWizard.updatedAt+'"', DateTime.class);
            if(jasonApex.biologicalSex != null && jasonApex.biologicalSex != '')
                accObj.On_Boarding_Wizard__c = jasonApex.onboardingWizard.lastCompletedStep;
        }
        if(jasonApex.shippingAddress != null){
            if(jasonApex.shippingAddress.city != null & jasonApex.shippingAddress.city != '')
                accObj.ShippingCity = jasonApex.shippingAddress.city;   
            //if(jasonApex.shippingAddress.country != null && jasonApex.shippingAddress.country != '')
            // accObj.ShippingCountry = jasonApex.shippingAddress.country;   
            if((jasonApex.shippingAddress.addressLine1 != null && jasonApex.shippingAddress.addressLine1 != '') || (jasonApex.shippingAddress.addressLine2 != null && jasonApex.shippingAddress.addressLine2 != ''))
                accObj.ShippingStreet = jasonApex.shippingAddress.addressLine1 +' '+ jasonApex.shippingAddress.addressLine2;    
            if(jasonApex.shippingAddress.postalCode != null && jasonApex.shippingAddress.postalCode != '')
                accObj.ShippingPostalCode = jasonApex.shippingAddress.postalCode;
            if(jasonApex.shippingAddress.state != null && jasonApex.shippingAddress.state != '')
                accObj.ShippingState = jasonApex.shippingAddress.state; 
        }
        if(jasonApex.billingAddress != null){
            if(jasonApex.billingAddress.city != null && jasonApex.billingAddress.city != '')
                accObj.BillingCity = jasonApex.billingAddress.city; 
            // if(jasonApex.billingAddress.country != null && jasonApex.billingAddress.country != '')
            //accObj.BillingCountry = jasonApex.billingAddress.country; 
            if((jasonApex.billingAddress.addressLine1 != null && jasonApex.billingAddress.addressLine1 != '') || (jasonApex.billingAddress.addressLine2 != null && jasonApex.billingAddress.addressLine2 != ''))
                accObj.BillingStreet = jasonApex.billingAddress.addressLine1 + jasonApex.billingAddress.addressLine2;
            if(jasonApex.billingAddress.postalCode != null && jasonApex.billingAddress.postalCode != '')
                accObj.BillingPostalCode = jasonApex.billingAddress.postalCode;
            if(jasonApex.billingAddress.state != null && jasonApex.billingAddress.state != '')
                accObj.BillingState = jasonApex.billingAddress.state;
        }
        if(jasonApex.allyContact != null && jasonApex.allyContact.email != null)
        {
            accObj.Ally_Contact_Name__c = jasonApex.allyContact.name;  //ally
            accObj.Ally_Contact_Email__c = jasonApex.allyContact.email; //ally@wondermed.com
        }
        if(jasonApex.allyContact != null && jasonApex.allyContact.consentedAt != null)
        {
            accObj.Ally_Contact_Consented_At__c = jasonApex.allyContact.consentedAt;
        }
        if(jasonApex.allyContact != null && jasonApex.allyContact.createdAt != null)
        {
            //accObj.Ally_Contact_Created_At__c = jasonApex.allyContact.createdAt;
            accObj.Ally_Contact_Created_At_Date__c = (Datetime)JSON.deserialize('"'+jasonApex.allyContact.createdAt+'"', DateTime.class);
        }
        if(jasonApex.allyContact != null && jasonApex.allyContact.updatedAt != null)
        {
            //accObj.Ally_Contact_Updated_At__c = jasonApex.allyContact.updatedAt;
            accObj.Ally_Contact_Updated_At_Date__c = (Datetime)JSON.deserialize('"'+jasonApex.allyContact.updatedAt+'"', DateTime.class);
        }
        if(jasonApex.emergencyContact != null && jasonApex.emergencyContact.phoneNumber != null)
        {
            accObj.Emergency_Contact_Name__c =  jasonApex.emergencyContact.name;  //contact
            accObj.Emergency_Contact_Phone__c = jasonApex.emergencyContact.phoneNumber;   //+1 (111) 111-1111
            accObj.Emergency_Contact_Relationship__c = jasonApex.emergencyContact.relationship; //rel
        }
        
        
        if(jasonApex.customerJourney != null){
            if(jasonApex.customerJourney.stage != '' && jasonApex.customerJourney.stage != null)
            {
                accObj.Opportunity_Stage__c = jasonApex.customerJourney.stage;
                system.debug('Opp stage---> '+jasonApex.customerJourney.stage);
            }
        }
        if(jasonApex.discountCode != null){
            if(jasonApex.discountCode.code != '' && jasonApex.discountCode.code != null)
            {
                accObj.Code__c = jasonApex.discountCode.code;
                system.debug('Discount Code ---> '+jasonApex.discountCode.code);
            }
        }
        
        if(jasonApex.heightFeet != null && jasonApex.heightFeet != 0)
        {
            accObj.heightFeet__c = jasonApex.heightFeet;
        }
        if(jasonApex.heightInches != null && jasonApex.heightInches != 0)
        {
            accObj.heightInches__c = jasonApex.heightInches;
        }
        if(jasonApex.weight != null && jasonApex.weight != 0)
        {
            accObj.weight__c = jasonApex.weight;
        }
        
        
        upsert accObj User_Id__c;
        ReturnResult returnObj = new ReturnResult();
        if(jasonApex.customerJourney != null){
            accObj.Opportunity_Stage__c = (jasonApex.customerJourney.stage != '' && jasonApex.customerJourney.stage != null) ? jasonApex.customerJourney.stage : '';
            if(jasonApex.customerJourney.salesforceOpportunityId != '' && jasonApex.customerJourney.salesforceOpportunityId != null){
                oppObj = new Opportunity();
                oppObj.Id = jasonApex.customerJourney.salesforceOpportunityId;
                oppObj.StageName = jasonApex.customerJourney.stage;
                update oppObj;
                returnObj.opportunityId = oppObj.Id;
            }
            else{
                Integer oppCount = [Select count() from Opportunity where AccountId =: accObj.Id];
                Account AccOb = [Select Id,Name from Account where Id =: accObj.Id];
                //if(oppCount == 0){
                string OppType = jasonApex.customerJourney.opportunityType;
                if(OppType == 'onboarding')
                {
                    OppType = 'Onboarding';
                }
                else if(OppType == 'initial-appointment')
                {
                    OppType = 'Initial';
                }
                else if (OppType == 'renewal-appointment')
                {
                    OppType = 'Renewal';
                }
                if(OppType == '' || OppType == null)
                    OppType = 'Onboarding';
                Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OppType).getRecordTypeId();
                oppObj = new Opportunity();
                oppObj.Name = AccOb.Name;
                oppObj.StageName = jasonApex.customerJourney.stage;
                oppObj.AccountId = accObj.Id;
                oppObj.CloseDate = system.today();
                oppObj.RecordTypeId = recordTypeId;
                insert oppObj;
                returnObj.opportunityId = oppObj.Id;
            }
        }
        returnObj.accountId = accObj.Id;
        return returnObj;
    }
    
    Public static Map<string,Id> insertForm(List<CC_API_Wrapper.cls_formSubmissions> formsList){
        Map<string,Id> formIdMap = new Map<string,Id>();
        System.debug('formsListttt ::::::' + formsList);
        List<Form__c> formList = new List<Form__c>();
        SET<string> formIdSET = new SET<string>();
        
        for(CC_API_Wrapper.cls_formSubmissions formObje : formsList){
            if(!formIdSET.contains(formObje.form.id)){
                Form__c formObj = new Form__c();
                formObj.Form_Id__c = formObje.form.id;  //bcba5b1f-559f-49fd-92bd-2abb8cc3fb99
                formObj.Form_Name__c = formObje.form.slug;  //new-patient-intake
                formList.add(formObj);
                formIdSET.add(formObje.form.id);
            }
        }
        upsert formList Form_Id__c;
        for(Form__c formObje : formList){
            formIdMap.put(formObje.Form_Id__c,formObje.Id);
        }
        
        return formIdMap;
    }
    
    Public static Map<string,Id> insertQuestion(CC_API_Wrapper jasonApex,Map<string,Id> formIdMap){
        Map<string,Id> questionIdMap = new Map<string,Id>();
        List<Question__c> questionList = new List<Question__c>();
        for(CC_API_Wrapper.cls_formSubmissions formObje : jasonApex.formSubmissions){
            if(formObje.questions.size() > 0){
                for(CC_API_Wrapper.cls_questions ques: formObje.questions){
                    Question__c quesObj = new Question__c();
                    quesObj.Question_Id__c = ques.id + ':' + formObje.form.id;
                    quesObj.Question_Text__c = ques.text;
                    quesObj.Form__c = formIdMap.get(formObje.form.id);
                    questionList.add(quesObj);
                }
            }
        }
        upsert questionList Question_Id__c;
        for(Question__c ques :questionList){
            system.debug('Ques.Id :::'+ques.Id);
            system.debug('ques.Question_Id_c :::'+ques.Question_Id__c);
            questionIdMap.put(ques.Question_Id__c,ques.Id);
        }
        
        return questionIdMap;
    }
    
    Public static void insertAccQA(CC_API_Wrapper jasonApex,Id accountId,Map<string,Id> formIdMap,Map<string,Id> questIdMap){
        List<Account_Question_Answer__c> accQaList = new List<Account_Question_Answer__c>();
        Account_Question_Answer__c accQaObj;
        SET<string> accQuesAnsExtId = new SET<string>();
        for(CC_API_Wrapper.cls_formSubmissions formObje : jasonApex.formSubmissions){
            if(formObje.questions.size() > 0){
                for(CC_API_Wrapper.cls_questions ques: formObje.questions){
                    if(ques.answers.size() > 0){
                        Integer flag = 0;
                        for(CC_API_Wrapper.cls_answers ans : ques.answers){
                            accQaObj = new Account_Question_Answer__c();
                            accQaObj.Account__c = accountId;
                            accQaObj.AccountIdandQuestionId__c = accountId + '|' + ques.id + '|' + formObje.Id + flag;
                            accQaObj.Form__c = formIdMap.get(formObje.form.id);
                            accQaObj.Question__c = questIdMap.get(ques.id + ':' + formObje.form.id);
                            if(ans.createdAt != null)
                                accQaObj.Created_At__c =string.valueof(ans.createdAt.replace('T',' '));
                            if(ans.updatedAt != null)
                                accQaObj.Updated_At__c =string.valueof(ans.updatedAt.replace('T',' '));
                            accQaObj.Answer__c = ans.answer;
                            accQaList.add(accQaObj);
                            flag++;
                        }
                    }
                }
            }
        }
        upsert accQaList AccountIdandQuestionId__c;
    }
    public static void InsertIntegrationError(Integer lineNumber, string errorMessage,string payload){
        Integration__c integrationErrorObj = new Integration__c();
        integrationErrorObj.Message__c = lineNumber + ' ' +errorMessage;
        integrationErrorObj.Class_Name__c = 'CC_API_UserData';
        integrationErrorObj.Payload__c = payload;
        integrationErrorObj.Status_Code__c = '400';
        insert integrationErrorObj;
    }
    
    public static void InsertIntegration(string payload , Id AccountId){
        Integration__c integrationObj = new Integration__c();
        integrationObj.Class_Name__c = 'CC_API_UserData';
        integrationObj.PayLoad__c = payload;
        integrationObj.Method_Action__c = 'POST';
        Insert integrationObj;      
    }
    public class ReturnResult{
        public string accountId{get;set;}
        public string opportunityId{get;set;}
    }
}