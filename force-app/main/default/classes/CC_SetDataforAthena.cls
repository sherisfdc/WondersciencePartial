global class CC_SetDataforAthena implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    
    global CC_SetDataforAthena (){
     System.debug('IntegrationSchedule :::: Testststs');
    }
    
    global Database.Querylocator start (Database.BatchableContext BC) 
    {       
        return Database.getQueryLocator([SELECT Id, Data_for_Athena__c, Athena_Status__c, Method_Action__c,Payload__c FROM Integration__c where Send_To_Athena__c = false and Class_Name__c = 'CC_API_CalendarIntegration' and Status_Code__c = '200' and Method_Action__c !='' and Method_Action__c !='GET' and Ready_for_Athena__c = false]);
    }
    global void execute(Database.BatchableContext bc, List<Integration__c> IntegrationList)
    {       
        SET<Id> providerIdSET = new SET<Id>();
        SET<Id> patientIdSET = new SET<Id>();
        for(Integration__c integr : IntegrationList)
        {
            PayloadData pldata = new PayloadData();
            pldata = (PayloadData)System.JSON.deserialize(integr.Payload__c,PayloadData.class);
            providerIdSET.add(pldata.providerId);
            DataforAthena dadata = new DataforAthena();
            dadata = (DataforAthena)System.JSON.deserialize(integr.Data_for_Athena__c,DataforAthena.class);
            patientIdSET.add(pldata.patientId);
        }
        Map<Id,Account> patientMap = new Map<Id,Account>([Select Id,ShippingState,Athena_Id__c from Account where Id IN: patientIdSET]);
        Map<Id,User> providerMap = new Map<Id,User>([Select Id,Athena_Username__c from User where Id IN: providerIdSET]);
        for(Integration__c integ : IntegrationList)
        {                    
            PayloadData pldata = new PayloadData();
            pldata = (PayloadData)System.JSON.deserialize(integ.Payload__c,PayloadData.class);
            System.debug('payloaddata :::::' + pldata);
            
            DataforAthena dadata = new DataforAthena();
            dadata = (DataforAthena)System.JSON.deserialize(integ.Data_for_Athena__c,DataforAthena.class);
            System.debug('dadata :::::' + dadata);
            if(providerMap.get(pldata.providerId) != null && patientMap.get(pldata.patientId) != null){
                if(providerMap.get(pldata.providerId).Athena_Username__c != '' && providerMap.get(pldata.providerId).Athena_Username__c != null && patientMap.get(pldata.patientId).Athena_Id__c != '' && patientMap.get(pldata.patientId).Athena_Id__c != null){
                    dadata.ProviderUsername = providerMap.get(pldata.providerId).Athena_Username__c + '_' + patientMap.get(pldata.patientId).ShippingState;
                    dadata.PatientAthenaId = patientMap.get(pldata.patientId).Athena_Id__c;
                    integ.Data_for_Athena__c = System.JSON.serialize(dadata);
                    integ.Ready_for_Athena__c = true;
                }
            }
        }
        update IntegrationList;
    }
    global void finish(Database.BatchableContext bc){
    }   
    global class DataforAthena
    {
        public string ProviderUsername {get;set;}
        public string PatientState {get;set;}
        public string AppointmentType {get;set;}
        public string NewStartDateTime {get;set;}
        public string PreviousDateTime {get;set;}
        public integer Duration {get;set;}
        public string PatientAthenaId {get;set;}
    }
    global class PayloadData
    {
        public string id {get;set;}
        public string providerId {get;set;}
        public string patientId {get;set;}
        
    }
}