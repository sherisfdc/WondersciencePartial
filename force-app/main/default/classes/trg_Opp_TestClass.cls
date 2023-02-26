@isTest
public class trg_Opp_TestClass {
    @testSetup
    public static void CreateTestRecord()
    {
        
        Account accobj = new Account();
        accobj.Name = 'TestPatient';
        insert accobj;  
        
        Opportunity opp = New Opportunity();
        opp.Name = 'TestOpp';
        opp.AccountId = accobj.Id;
        opp.StageName = 'Disqualified';
        
        DateTime dT = System.now();
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        
        opp.CloseDate = myDate;
        insert opp;
    }
    
    @isTest static void testMethod1() {
        
        Opportunity opporObj = [Select Id,Name from Opportunity LIMIT 1];
        opporObj.Name = 'TestOpp1';
        C_AcoidRecursiveness.sendFutureCall = false;
        update opporObj;
    }
}