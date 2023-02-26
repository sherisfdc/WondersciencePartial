@RestResource(urlMapping='/GetDataFromAthena/*')
global without sharing class CC_API_DataFromAthena {
    @HttpPost
    global static ResponseWrapper doPost()
    {
        ResponseWrapper wrapper = new ResponseWrapper();
        string salesforceAccountId = RestContext.request.params.get('salesforceAccountId');
            string athenaAccountId = RestContext.request.params.get('athenaAccountId');
        try
        {
            
            system.debug(salesforceAccountId);
            system.debug(athenaAccountId);
            if(salesforceAccountId != '' && athenaAccountId != '')
            {
                Account accobj = [Select Id , Athena_Id__c from Account where Id =:salesforceAccountId];
                if(accobj != null)
                {
                    accobj.Athena_Id__c = athenaAccountId;
                    Update accobj;
                    wrapper.Status_Code = 200;
                    wrapper.message = 'Success';
                }else{
                    wrapper.Status_Code = 404;
                    wrapper.message = 'Not Found';
                }
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