global with sharing class BatchUpdateExternalId implements Database.Batchable<String>{
    Integer numErrors = 0;

    public List<String> start(Database.BatchableContext BC) {
        return new List<String> { 
                    'arcusbuiltenv__Action__c', 
                    'arcusbuiltenv__Additional_Details__c', 
                    'arcusbuiltenv__Appeal__c',
                    'arcusbuiltenv__Building_Control_Application__c',
                    'arcusbuiltenv__Clause__c',
                    'arcusbuiltenv__Committee_Item__c',
                    'arcusbuiltenv__Committee__c',
                    'arcusbuiltenv__Constraint__c',
                    'arcusbuiltenv__Decision_Detail__c',
                    'arcusbuiltenv__Enforcement__c',
                    'arcusbuiltenv__Planning_Application__c',
                    'arcusbuiltenv__Planning_Obligation__c',
                    'arcusbuiltenv__Related_Location__c',
                    'arcusbuiltenv__Related_Party__c',
                    'arcusbuiltenv__Scheme_Committments__c',
                    'arcusbuiltenv__Scheme__c',
                    'arcusbuiltenv__Site_History__c',
                    'arcusbuiltenv__Stage__c',
                    'arcusbuiltenv__Tree_Preservation_Order__c',
                    'arcusbuiltenv__Unit_of_Work__c',
                    'arcusbuiltenv__Visit__c'
                };
    }

    public void execute(Database.BatchableContext BC, List<String> scope){
        List<SObject> sobjectsToUpdate = new List<SObject>();

        for (String sobjectName : scope) {
            String query = 'SELECT Id, arcusbuiltenv__External_Id__c, arcusbuiltenv__ExternalId__c FROM ' + sobjectName +
                           ' WHERE arcusbuiltenv__ExternalId__c != null AND arcusbuiltenv__External_Id__c = null';
            List<SObject> queryResults = Database.query(query);

            for (SObject recordToUpdate : queryResults) {
                String oldExternalIdFieldValue = String.valueOf(recordToUpdate.get('arcusbuiltenv__ExternalId__c'));
                recordToUpdate.put('arcusbuiltenv__External_Id__c', oldExternalIdFieldValue);
                sobjectsToUpdate.add(recordToUpdate);
            }
        }

        List<Database.SaveResult> result = Database.update(sobjectsToUpdate, false);

        for(Integer i = 0; i < result.size(); i++){
			if(!result[i].isSuccess()) numErrors++;
		}
    }
    
    public void finish(Database.BatchableContext BC){
        if (numErrors != 0) System.assert(false, numErrors + ' records failed to update.');
	}
}