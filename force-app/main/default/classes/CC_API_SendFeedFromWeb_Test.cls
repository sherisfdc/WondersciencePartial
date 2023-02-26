@isTest
public class CC_API_SendFeedFromWeb_Test {
    
    @testSetup
    public static void CreateTestRecord() 
    {
        Account accobj = new Account();
        accobj.Name = 'TestPatient';
        insert accobj;
        
    }  
    
    @isTest static void mypostTest()
    {
        Account accobj = [SELECT Id FROM Account WHERE Name='TestPatient' LIMIT 1];
        Case caseObj = new Case();
        caseObj.AccountId = accobj.Id;
        caseObj.Subject = 'Test Subject';
        caseObj.Status = 'Open';
        caseObj.Origin = 'Web';
        Insert caseObj;
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://wondersciences--wondersci.my.salesforce.com/services/apexrest/SendFeedFromWeb';
        request.httpMethod = 'POST';
        
        request.addParameter('CaseId',caseObj.Id);
        request.addParameter('Comment','This is new Message From Web');
        
        RestContext.request = request;
        CC_API_SendFeedFromWeb.ResponseWrapper wrapper = new CC_API_SendFeedFromWeb.ResponseWrapper();
        wrapper = CC_API_SendFeedFromWeb.doPost();
    }
}