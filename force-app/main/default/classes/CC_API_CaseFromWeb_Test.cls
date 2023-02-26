@isTest
public class CC_API_CaseFromWeb_Test {
    
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
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://wondersciences--wondersci.my.salesforce.com/services/apexrest/CaseFromWeb';
        request.httpMethod = 'POST';
        
        request.addParameter('AccountId',accobj.Id);
        request.addParameter('Subject','This is new Test Subject');
        
        RestContext.request = request;
        CC_API_CaseFromWeb.ResponseWrapper wrapper = new CC_API_CaseFromWeb.ResponseWrapper();
        wrapper = CC_API_CaseFromWeb.doPost();
    }
    
    @isTest static void mygetTest()
    {
        Account accobj = [SELECT Id FROM Account WHERE Name='TestPatient' LIMIT 1];
        Case caseObj = new Case();
        caseObj.AccountId = accobj.Id;
        caseObj.Subject = 'Test Subject';
        caseObj.Status = 'Open';
        caseObj.Origin = 'Web';
        Insert caseObj;
        
        FeedItem post = new FeedItem();
        post.ParentId = caseObj.Id;
        post.Body = 'Message From Web';
        post.CreatedById = Label.Integration_User_Id;
        post.Title = 'FromWeb';
        insert post;
        
        List<Case> casObj = [Select Id , AccountId , CreatedById from Case where Id =:caseObj.Id];
        
        Messages__c msgObj = new Messages__c();
        msgObj.CaseId__c = caseObj.Id;
        msgObj.Comment_Text__c = 'Message From Web';
        msgObj.PatientId__c = casObj[0].AccountId;
        msgObj.From_User__c = Label.Integration_User_Id;
        msgObj.To_User__c = casObj[0].CreatedById;
        Insert msgObj;
        
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://wondersciences--wondersci.my.salesforce.com/services/apexrest/CaseFromWeb';
        request.httpMethod = 'GET';
        
        request.addParameter('AccountId',accobj.Id);
        
        RestContext.request = request;
        CC_API_CaseFromWeb.ResponseWrapper wrapper = new CC_API_CaseFromWeb.ResponseWrapper();
        wrapper = CC_API_CaseFromWeb.doGet();
    }
    
}