@isTest
private class CC_API_UserData_Test{
    @isTest
    private static void InsertUser_Test(){
       
        String myJSON = '{"id":"b2b782d4-8c16-452e-90fe-0a967daf25d8","firstName":"First","lastName":"Last","email":"test@wondermed.com","phoneNumber":"+1 (222) 221-4444","biologicalSex":"female","preferredPronouns":"they-them-theirs","relationshipStatus":"married","occupation":"occupation","employer":"Employer","birthDate":"2000-01-01T00:00:00.000Z","confirmedEmail":true,"authorizeNetCustomerId":"505247454","lastSignedInAt": "2021-11-30T06:06:53.191Z","createdAt":"2021-09-02T13:18:43.744Z","updatedAt":"2021-11-30T06:06:53.191Z",'+
  '"allyContact":{"name":"ally","email":"ally@wondermed.com","createdAt":"2021-11-11T16:54:01.351Z","updatedAt":"2021-11-30T06:06:53.190Z"},'+
  '"emergencyContact":{"name":"contact","phoneNumber":"+1 (111) 111-1111","relationship":"rel","createdAt":"2021-11-11T16:54:01.344Z","updatedAt":"2021-11-30T06:06:53.187Z"},' +
  '"onboardingWizard":{"completedAt":"2021-09-02T13:18:43.744Z","lastCompletedStep":"personal-info","createdAt":"2021-09-02T13:18:43.744Z","updatedAt":"2021-12-03T15:36:06.128Z","enumValues":["welcome-screen","payment","personal-info","intake-form","telesage-form","appointment-scheduling"]},' +
  '"billingAddress":{"city":"LA","addressLine1":"tet.","addressLine2":"test1","postalCode":"77777","state":"CA"},' +
  '"shippingAddress":{"city":"LA","addressLine1":"test 1","addressLine2":"test 2","postalCode":"77777","state":"CA"},'+
'"formSubmissions":[{"id":"74b20815-705b-4329-a916-7d7a58f9da9b","form":{"id":"bcba5b1f-559f-49fd-92bd-2abb8cc3fb99","slug":"new-patient-intake"},"questions":[{"id":"ce283daa-6484-4594-b13a-5251d1ab7ef2","text":"Have any of these applied to you? (Select all that apply)",' +
          '"type":"multi",'+
          '"data":{'+
            '"options":['+
              '"Elevated Intraocular Pressure (ex: glaucoma)",'+
              '"Hyperthyroidism",'+
              '"Elevated Intracranial Pressure",'+
              '"Opioid Abuse or Dependence"'+
            '],'+
            '"noneOption":"None of the above"'+
          '},'+
          '"answers":[ '+
            '{ '+
              '"answer":"Elevated Intraocular Pressure (ex: glaucoma)",'+
              '"createdAt":"2021-12-08T08:43:52.022Z",'+
              '"updatedAt":"2021-12-08T08:43:52.022Z"'+
            '},'+
            '{'+
              '"answer":"Opioid Abuse or Dependence",'+
              '"createdAt":"2021-12-08T08:43:52.029Z",'+
              '"updatedAt":"2021-12-08T08:43:52.029Z"'+
            '}'+
          ']'+
        '},'+
        '{'+
          '"id":"cfb0c993-4c08-4c4b-8ad4-6a221c973461",'+
          '"text":"Do any of these currently apply to you? (Select all that apply)",'+
          '"type":"multi",'+
          '"data":{'+
            '"options":['+
              '"Untreated high blood pressure",'+
              '"Severe breathing problems",'+
              '"Serious heart problems",'+
              '"Other serious medical illness not listed above",'+
              '"Manic symptoms"'+
            '],'+
            '"noneOption":"None of the above"'+
          '},'+
          '"answers":['+
            '{'+
              '"answer":"None of the above",'+
              '"createdAt":"2021-12-08T08:43:53.951Z",'+
              '"updatedAt":"2021-12-08T08:43:53.951Z"'+
            '}'+
          ']'+
        '},'+
        '{'+
          '"id":"cafe4be3-59a7-454a-bea6-32562dd41c7e",'+
          '"text":"Please list any allergies you have.",'+
          '"type":"text",'+
          '"data":{'+
            '"variant":"long"'+
          '},'+
          '"answers":['+
            '{'+
              '"answer":"peanuts",'+
              '"createdAt":"2021-12-08T08:43:57.496Z",'+
              '"updatedAt":"2021-12-08T08:43:57.496Z"'+
            '}'+
          ']'+
        '}'+
      ']'+
    '}'+
  ']'+
'}';
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://wondersciences--wondersci.my.salesforce.com/services/apexrest/UserData';
        request.httpMethod = 'POST';
		request.requestBody = Blob.valueof(myJSON);
                
        RestContext.request = request;
        CC_Response response = new CC_Response();
		response = CC_API_UserData.InsertUser();
    }
    @isTest
    private static void InsertIntegrationError_Test(){
        Test.startTest();
        CC_API_UserData.InsertIntegrationError(1,'a','a');
        CC_API_UserData.InsertIntegrationError(0,'','');
        Test.stopTest();
    }
}