@RestResource(urlMapping='/CaseFromWeb/*')
global without sharing class CC_API_CaseFromWeb 
{
    @HttpGet
    global static ResponseWrapper doGet() //Return Open Cases
    {
        ResponseWrapper wrapper = new ResponseWrapper();
        string salesforceAccountId = RestContext.request.params.get('AccountId'); //SalesforceId of User logged In on Web
        try
        {
            if(salesforceAccountId != '')
            {
                List<Case> caseObj = [Select Id,CaseNumber,Subject,AccountId,Status,Origin from Case where AccountId =: salesforceAccountId and Status = 'Open'];
                List<CaseResponseList> caseRespList = new List<CaseResponseList>();
                for(Case caseSingleObj : caseObj)
                {
                    CaseResponseList caseResp = new CaseResponseList();
                    caseResp.CaseId = caseSingleObj.Id;
                    caseResp.CaseNumber = caseSingleObj.CaseNumber;
                    caseResp.Subject = caseSingleObj.Subject;
                    
                    List<Messages__c> messageItemList = [Select Id,CaseId__c,Comment_Text__c,PatientId__c,From_User__c,To_User__c from Messages__c where CaseId__c =: caseSingleObj.Id];
                    if(messageItemList.size() > 0)
                    {
                        List<MessagestoSend> casemessagelist = new List<MessagestoSend>();
                        for(Messages__c messageSingleObj : messageItemList)
                        {
                            string FromName = '';
                            string ToName = '';
                            if(messageSingleObj.From_User__c == Label.Integration_User_Id)
                            {
                               List<Account> accObj = [Select Id , Name from Account where Id =: messageSingleObj.PatientId__c];
                                if(accObj.size() > 0)
                                {
                               FromName = accObj[0].Name;
                                }
                            }
                            else
                            {
                                User usrObj = [Select Id , Name from User where Id =: messageSingleObj.From_User__c];
                                FromName = usrObj.Name;
                            }
                            
                            if(messageSingleObj.To_User__c == Label.Integration_User_Id)
                            {
                               List<Account> accObj = [Select Id , Name from Account where Id =: messageSingleObj.PatientId__c];
                                if(accObj.size() > 0)
                                {
                               ToName = accObj[0].Name;
                                }
                            }
                            else
                            {
                                User usrObj = [Select Id , Name from User where Id =: messageSingleObj.To_User__c];
                                ToName = usrObj.Name;
                            }
                            
                            MessagestoSend mtosendObj = new MessagestoSend();
                            mtosendObj.CaseId = messageSingleObj.CaseId__c;
                            mtosendObj.PatientId = messageSingleObj.PatientId__c;
                            mtosendObj.FromUser = FromName;
                            mtosendObj.ToUser = ToName;
                            mtosendObj.Comment = messageSingleObj.Comment_Text__c;
                            casemessagelist.Add(mtosendObj);
                        }
                        
                        caseResp.MessageList = casemessagelist;
                    }
                    caseRespList.Add(caseResp);
                }
                
                
                if(caseObj.size() > 0)
                {
                    wrapper.caseList = caseRespList;
                    wrapper.Status_Code = 200;
                    wrapper.message = 'Success';
                }
                else
                {
                    wrapper.Status_Code = 404;
                    wrapper.message = 'No Case found';  
                }
            }
            
            
        }
        catch(Exception ex){
            wrapper.Status_Code = 400;
            wrapper.message = ex.getLineNumber() + ':: ' + ex.getMessage();
        }
        return wrapper;
    }
    
    
    @HttpPost
    global static ResponseWrapper doPost()
    {
        ResponseWrapper wrapper = new ResponseWrapper();
        string salesforceAccountId = RestContext.request.params.get('AccountId'); //SalesforceId of User logged In on Web
        string caseSubject = RestContext.request.params.get('Subject'); //Subject of the Case
        try
        {
            if(salesforceAccountId != '')
            {
                Case caseObj = new Case();
                caseObj.AccountId = salesforceAccountId;
                caseObj.Subject = caseSubject;
                caseObj.Status = 'Open';
                caseObj.Origin = 'Web';  
                
                Insert caseObj;
                wrapper.Status_Code = 200;
                wrapper.message = 'Success';
            }
            
            
        }
        catch(Exception ex){
            wrapper.Status_Code = 400;
            wrapper.message = ex.getLineNumber() + ':: ' + ex.getMessage();
        }
        return wrapper;
    }
    
    global class ResponseWrapper
    {
        public integer Status_Code{get;set;}
        public string message{get;set;}
        public List<CaseResponseList> caseList {get;set;}
    }
    
    global class CaseResponseList
    {
        public string CaseId {get;set;}
        public string CaseNumber {get;set;}
        public string Subject {get;set;}
        public List<MessagestoSend> MessageList {get;set;}
    }
    
    global class MessagestoSend
    {
        public string CaseId {get;set;}
        public string PatientId {get;set;}
        public string FromUser {get;set;}
        public string ToUser {get;set;}
        public string Comment {get;set;}
    }
    
    
}