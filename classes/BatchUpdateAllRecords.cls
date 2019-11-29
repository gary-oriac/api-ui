global with sharing class BatchUpdateAllRecords implements Database.Batchable<SObject>{
    public String sobjectApiName;
    public Integer minutes;

    public BatchUpdateAllRecords(SObjectType anSobjectType, Integer theMinutes) {
        sobjectApiName = anSobjectType.getDescribe().getName();
        minutes = theMinutes;
    }

	global Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime dt = DateTime.now().addMinutes(minutes);
        String query = 'SELECT Id FROM ' + sobjectApiName + ' WHERE LastModifiedDate < ' + dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Database.SaveResult> result = Database.update(scope, false);
	}

	global void finish(Database.BatchableContext BC) {

	}
}