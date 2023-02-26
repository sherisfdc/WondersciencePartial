global class CC_SetEmailForPatient_Schedular implements Schedulable {
    global CC_SetEmailForPatient_Schedular(){
        
    }
    // Execute at regular intervals
    global void execute(SchedulableContext ctx)
    {
      CC_SetEmailForPatient batch = new CC_SetEmailForPatient();
      Database.executebatch(batch,20);
    }
}