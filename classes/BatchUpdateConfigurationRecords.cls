global with sharing class BatchUpdateConfigurationRecords implements Database.Batchable<SObject>{
    Integer numErrors = 0;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        Id configRecordTypeId = Schema.SObjectType.arcshared__Configuration__c.getRecordTypeInfosByDeveloperName().get('Record_Template').getRecordTypeId();
        String query = 'SELECT ID, arcshared__Action__c ' +
                       'FROM arcshared__Configuration__c ' +
                       'WHERE RecordTypeId = \'' +  configRecordTypeId + '\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<arcshared__Configuration__c> scope){
        for (arcshared__Configuration__c config : scope) {
            String configAction = config.arcshared__Action__c;

            if (configAction.contains('arcusbuiltenv__Decision_Detail__c')) {
                configAction = configAction.replace('arcusbuiltenv__Type__c', 'arcusbuiltenv__Type_of_Monitoring__c');
                configAction = configAction.replace('arcusbuiltenv__Category__c', 'arcusbuiltenv__Type__c');
            }

            config.arcshared__Action__c = configAction;
        }

        List<Database.SaveResult> result = Database.update(scope, false);

        for(Integer i = 0; i < result.size(); i++){
			if(!result[i].isSuccess()) numErrors++;
		}
    }
    
    public void finish(Database.BatchableContext BC){
        if (numErrors != 0) System.assert(false, numErrors + ' records failed to update.');
	}
}