public class CC_trg_OppHandler {
    @future (callout=true)
    public static void sendCustomerJourney(Id PatientId,Id opportunityId,string stage,string EndPointURL,string MethodCall)
    {
        system.debug(':::sendCustomerJourney Stage:::' + stage);
        List<Opportunity> oppList = [Select Id,Response_API__c,Payload_API__c from Opportunity where Id =: opportunityId];
        try {
            String header = '{"alg": "HS256","typ":"jwt"}';
            String payload = '{"patientId":"'+PatientId+'"}';
            string jwt = base64URLencode(blob.valueof(header)) + '.' +base64URLencode(blob.valueof(payload));                                   
            //Blob key = blob.valueof('2ZF4WiHZCe3Xt_POfRtQJjE');\
            System.debug('Label.JWT_Secret --->'+ string.valueOf(Label.JWT_Secret));
            Blob key = blob.valueOf(string.valueOf(Label.JWT_Secret));
            blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),key);
            
            system.debug('final data --> '+jwt+'.'+base64URLencode(signature));
            string accessToken = jwt+'.'+base64URLencode(signature);
            
            HttpRequest req = new HttpRequest();
            if(accessToken != '' && accessToken != null)
            {
                if(MethodCall == 'PATCH')
                {
                    string body = '{"opportunityId" : "'+opportunityId+'","stage" :"'+stage+'","userId" : "'+PatientId+'"}';
                    req.setBody(body);
                    req.setEndPoint(EndPointURL);
                    req.setMethod('PATCH');
                    req.setHeader('Content-Type', 'application/json');
                    req.setHeader('Authorization', 'Bearer '+ accessToken);
                    
                    Http http = new Http();
                    req.setTimeout(120000);
                    
                    HttpResponse res = new HttpResponse();
                    res =  http.send(req);
                    string JSONresp = '{"response status" : "'+res.getStatus()+'","status code" :"'+res.getStatusCode()+'"}';
                    
                    system.debug('response --> '+res);
                    system.debug('request --> '+req);
                    system.debug('request body --> '+req.getBody());
                    system.debug('response body --> '+res.getBody());
                    
                    ResponseBody respbody = (ResponseBody)JSON.deserialize(res.getBody(), ResponseBody.class);
                    System.debug('Response body Message--->' + respbody.message);
                    if(res.getStatusCode() != 200)
                    {
                        oppList[0].Payload_API__c = req.getBody();
                        oppList[0].Response_API__c = res.getBody() + ' --> StatusCode : '+res.getStatusCode();
                        C_AcoidRecursiveness.sendFutureCall = false;
                        update oppList[0];
                    }
                }
            }
            
            
        }
        catch(System.CalloutException e){
            System.debug('Error-' + e.getMessage());
            oppList[0].Payload_API__c = 'Exception Occured';
            oppList[0].Response_API__c = e.getMessage();
            C_AcoidRecursiveness.sendFutureCall = false;
            update oppList[0];
        }
    }
    
    public static String base64URLencode(Blob input){ 
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        //output = output.replaceAll('=','');
        return output;
    }
    
    
    public class ResponseBody
    {
        public string success{get;set;}
        public string code{get;set;}
        public string message{get;set;}
    }
}