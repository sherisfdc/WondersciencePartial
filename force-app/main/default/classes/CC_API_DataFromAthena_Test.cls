@isTest
public class CC_API_DataFromAthena_Test {
    @isTest
    private static void DatafromAthenaPost_Test()
    {
        RestRequest request = new RestRequest();
        request.requestUri ='https://wondersci-webchatdemo1234.cs217.force.com/webhook/services/apexrest/GetDataFromAthena';
        request.httpMethod = 'POST';
        
        Account accobj = new Account();
        accobj.Name = 'TestAccount';
        insert accobj;
        request.addParameter('salesforceAccountId',accobj.Id);
        request.addParameter('athenaAccountId','105');
                
        RestContext.request = request;
        CC_API_DataFromAthena.ResponseWrapper wrapper = new CC_API_DataFromAthena.ResponseWrapper();
		wrapper = CC_API_DataFromAthena.doPost();
    }
    
    @isTest
    private static void DatafromAthenaPost_TestNotFound()
    {
        RestRequest request = new RestRequest();
        request.requestUri ='https://wondersci-webchatdemo1234.cs217.force.com/webhook/services/apexrest/GetDataFromAthena';
        request.httpMethod = 'POST';
        
        request.addParameter('salesforceAccountId',null);
        request.addParameter('athenaAccountId','105');
                
        RestContext.request = request;
        CC_API_DataFromAthena.ResponseWrapper wrapper = new CC_API_DataFromAthena.ResponseWrapper();
		wrapper = CC_API_DataFromAthena.doPost();
    }
}