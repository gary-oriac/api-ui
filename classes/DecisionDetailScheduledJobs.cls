global class DecisionDetailScheduledJobs implements Schedulable{

    global void execute(SchedulableContext sc){
        BatchUpdateDecisionDetails decDetailsBatch = new BatchUpdateDecisionDetails();
        BatchUpdateConfigurationRecords configsBatch = new BatchUpdateConfigurationRecords();

        Database.executeBatch(decDetailsBatch);
        Database.executeBatch(configsBatch);
    }
}