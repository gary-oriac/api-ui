global with sharing class BatchUpdateDecisionDetails implements Database.Batchable<SObject>{
    Integer numErrors = 0;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID, arcusbuiltenv__Category__c, arcusbuiltenv__Type__c, arcusbuiltenv__Type_of_Monitoring__c ' +
                       'FROM arcusbuiltenv__Decision_Detail__c';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<arcusbuiltenv__Decision_Detail__c> scope){
        for (arcusbuiltenv__Decision_Detail__c details : scope) {
            details.arcusbuiltenv__Type_of_Monitoring__c = details.arcusbuiltenv__Type__c;
            details.arcusbuiltenv__Type__c = details.arcusbuiltenv__Category__c;
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