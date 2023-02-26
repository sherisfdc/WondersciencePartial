public class CC_trg_EventHandler {
    @future (callout=true)
    public static void sendEventInfo(Id PatientId,Id ProviderId,string startTime,Id evtId,string MethodCall,string EndPointURL,string appointmentType,integer duration) {
        try{                     
            String header = '{"alg": "HS256","typ":"jwt"}';
            String payload = '{"patientId":"'+PatientId+'"}';
            string jwt = base64URLencode(blob.valueof(header)) + '.' +base64URLencode(blob.valueof(payload));                                   
            //Blob key = blob.valueof('2ZF4WiHZCe3Xt_POfRtQJjE');\
            System.debug('Label.JWT_Secret --->'+ string.valueOf(Label.JWT_Secret));
            Blob key = blob.valueOf(string.valueOf(Label.JWT_Secret));
            blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),key);
            
            system.debug('final data --> '+jwt+'.'+base64URLencode(signature));
            List<Event> evtlist = [Select Id,StartDateTime,EndDateTime,WhatId,Appointment_Type__c,Subject,WebApp_Response__c,WebApp_Status__c,WebApp_StatusCode__c,Description from Event where Id =: evtId];
            string accessToken = jwt+'.'+base64URLencode(signature);
            
            if(accessToken != '' && accessToken != null)
            {
                HttpRequest req = new HttpRequest();
                if(MethodCall == 'PATCH')
                {
                    EndPointURL = EndPointURL + '/'+evtId;
                    string body = '{"startTime" : "'+startTime+'","providerId" :"'+ProviderId+'","newSalesforceId" : "'+evtId+'","duration":"'+duration+'"}';
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
                    System.debug('Response body data Salesforce Id--->' + respbody.data.salesforceId);
                    if(res.getStatusCode() != 204)
                    {
                        System.debug('respbody.data --->'+ respbody.data);
                        System.debug('evtlist.size() --->'+ evtlist.size());
                        if(evtlist.size() > 0 && respbody.data != null)
                        {
                            System.debug('Come in condition');
                            System.debug('evtlist[0] '+evtlist[0]);
                            System.debug('respbody.data.zoomMeetingUrl '+respbody.data.zoomMeetingUrl);
                          evtlist[0].StartDateTime = Datetime.valueOfGmt(respbody.data.startTime.replace('T', ' '));
                          evtlist[0].EndDateTime = Datetime.valueOfGmt(respbody.data.endTime.replace('T', ' '));
                          evtlist[0].Description = respbody.data.zoomMeetingUrl;
                          C_AcoidRecursiveness.sendFutureCall = false;
                          //C_AcoidRecursiveness.runEventTrigger = false;
                          C_AcoidRecursiveness.callTowebhook = false;
                          update evtlist[0];                         
                        }
                    }
                    
                    if(evtlist.size() > 0)
                    {
                        evtlist[0].WebApp_Status__c = res.getStatus();
                        evtlist[0].WebApp_StatusCode__c = string.valueOf(res.getStatusCode());
                        evtlist[0].WebApp_Response__c = res.getBody().Trim();
                        C_AcoidRecursiveness.runEventTrigger = false;
                        //update evtlist[0];
                    }
                }
                if(MethodCall == 'POST')
                {                   
                    string body = '{"startTime" : "'+startTime+'","providerId" :"'+ProviderId+'","salesforceId" : "'+evtId+'","userId" : "'+PatientId+'","appointmentType" : "'+appointmentType+'","duration":"'+duration+'"}';
                    //string body = '{"startTime" : "'+startTime+'","providerId" :"'+ProviderId+'","salesforceId" : "'+evtId+'","userId" : "'+PatientId+'","appointmentType" : "'+appointmentType+'"}';
                    req.setEndPoint(EndPointURL);
                    req.setBody(body);
                    req.setMethod('POST');
                    req.setHeader('Content-Type', 'application/json');
                    req.setHeader('Authorization', 'Bearer '+ accessToken);
                    
                    Http http = new Http();
                    req.setTimeout(120000);
                    
                    HttpResponse res = new HttpResponse();
                    res =  http.send(req);
                    
                    string JSONresp = '{"response status" : "'+res.getStatus()+'","status code" :"'+res.getStatusCode()+'"}';
                    
                    ResponseBody respbody = (ResponseBody)JSON.deserialize(res.getBody(), ResponseBody.class);
                    system.debug('response --> '+res);
                    system.debug('request --> '+req);
                    system.debug('request body --> '+req.getBody());
                    System.debug('Response body Message--->' + respbody.message);
                    if(res.getStatusCode() != 201)
                    {
                        if(evtlist.size() > 0)
                        {
                            //C_AcoidRecursiveness.runEventTrigger = false;
                            C_AcoidRecursiveness.sendFutureCall = false;
                            delete evtlist[0];
                        }
                    }
                    else if(evtlist.size() > 0)
                    {
                        Datetime StartD = Datetime.valueOf(respbody.data.startTime);
                        Datetime EndD = Datetime.valueOf(respbody.data.endTime);
                        Decimal DinM = Integer.valueOf((StartD.getTime() - EndD.getTime())/(1000*60));
                        System.debug('Minutes Manually Calulated');
                        evtlist[0].WebApp_Status__c = res.getStatus();
                        evtlist[0].WebApp_StatusCode__c = string.valueOf(res.getStatusCode());
                        evtlist[0].WebApp_Response__c = res.getBody().Trim();
                        C_AcoidRecursiveness.runEventTrigger = false;
                        update evtlist[0];
                    }
                }
                
                if(MethodCall == 'DELETE')
                {
                    EndPointURL = EndPointURL + '/'+evtId;
                    req.setEndPoint(EndPointURL);
                    req.setMethod('DELETE');
                    req.setHeader('Content-Type', 'application/json');
                    req.setHeader('Authorization', 'Bearer '+ accessToken);
                    
                    Http http = new Http();
                    req.setTimeout(120000);
                    
                    HttpResponse res = new HttpResponse();
                    res =  http.send(req);
                    
                    string JSONresp = '{"response status" : "'+res.getStatus()+'","status code" :"'+res.getStatusCode()+'"}';
                        
                        
                    system.debug('response status--> '+res.getStatus()+ ' ,status code-->'+res.getStatusCode());
                    system.debug('response body --> '+res.getBody());
                    system.debug('request body --> '+req.getBody());
                    
                    if(evtlist.size() > 0)
                    {
                        evtlist[0].WebApp_Status__c = res.getStatus();
                        evtlist[0].WebApp_StatusCode__c = string.valueOf(res.getStatusCode());
                        evtlist[0].WebApp_Response__c = res.getBody().Trim();
                        C_AcoidRecursiveness.runEventTrigger = false;
                        update evtlist[0];
                    }
                }
            }
            
        }
        catch(System.CalloutException e){
            System.debug('Error-' + e.getMessage());   
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
    public ResponsebodyData data{get;set;}
}
public class ResponsebodyData
{
    public string startTime{get;set;}
    public string endTime{get;set;}
    public string salesforceId{get;set;}
    public string zoomMeetingUrl{get;set;}
}
}