@RestResource(urlMapping='/SendFeedFromWeb/*')
global without sharing class CC_API_SendFeedFromWeb
{   
    @HttpPost
    global static ResponseWrapper doPost()
    {
        ResponseWrapper wrapper = new ResponseWrapper();
        string salesforceCaseId = RestContext.request.params.get('CaseId'); //SalesforceId of Case
        string commentfromWeb = RestContext.request.params.get('Comment');
        try
        {
            if(salesforceCaseId != '')
            {
                FeedItem post = new FeedItem();
                post.ParentId = salesforceCaseId;
                post.Body = commentfromWeb;
                post.CreatedById = Label.Integration_User_Id;
                post.Title = 'FromWeb';
                insert post;
                
                List<Case> casObj = [Select Id , AccountId , CreatedById from Case where Id =:salesforceCaseId];
                
                Messages__c msgObj = new Messages__c();
                msgObj.CaseId__c = salesforceCaseId;
                msgObj.Comment_Text__c = commentfromWeb;
                msgObj.PatientId__c = casObj[0].AccountId;
                msgObj.From_User__c = Label.Integration_User_Id;
                msgObj.To_User__c = casObj[0].CreatedById;
                Insert msgObj;
                
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
    }
}