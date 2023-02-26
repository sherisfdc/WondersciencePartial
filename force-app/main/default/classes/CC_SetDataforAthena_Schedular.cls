global class CC_SetDataforAthena_Schedular implements Schedulable {
    global CC_SetDataforAthena_Schedular(){

    }
    // Execute at regular intervals
    global void execute(SchedulableContext ctx)
    {
      CC_SetDataforAthena batch = new CC_SetDataforAthena();
      Database.executebatch(batch,200);
    }
}