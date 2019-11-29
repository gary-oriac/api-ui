public class BatchUpdateRecordTemplates implements Database.Batchable<sObject>, Database.Stateful {
    Integer numErrors;

    public BatchUpdateRecordTemplates() {
        numErrors = 0;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Id recordTypeId = arcshared.Utils.getRecordTypeIdBysObjectAndDeveloperNameAndNamespacePrefix('Configuration__c', 'Record_Template', 'arcshared');
		String query = 'SELECT Id, arcshared__Action__c FROM arcshared__Configuration__c WHERE RecordTypeId = :recordTypeId';

		return Database.getQueryLocator(query);
	}

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
		for (arcshared__Configuration__c configToUpdate : (List<arcshared__Configuration__c>) scope){
            List<Map<String, Object>> fields =  new List<Map<String, Object>>();
            String actionString = configToUpdate.arcshared__Action__c.replace('\n', '<br>');
            Map<String, Object> action = (Map<String, Object>) JSON.deserializeUntyped(actionString);

            if (action.containsKey('recordTemplate')) 
            {
                Map<String, Object> recordTemplate = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(action.get('recordTemplate')));
                List<String> fieldsAPIName = generateFieldsList(recordTemplate);
                Map<String, String> fieldNameToFieldTypeMap = getFieldsType(fieldsAPIName, String.valueOf(recordTemplate.get('sobjectType')));

                action.put('sobjectType', recordTemplate.get('sobjectType'));

                for (String fieldName : recordTemplate.keySet()) {                

                    if (fieldName == 'RecordTypeId') 
                    {
                        if (!String.isEmpty(String.valueOf(recordTemplate.get('RecordTypeId')))) 
                        {
                            fields.add(new Map<String, Object>{
                                'field' => fieldName,
                                'type' => 'record type',
                                'value' => arcshared.Utils.getRecordTypeDeveloperNameById(String.valueOf(recordTemplate.get('RecordTypeId')))
                            });
                        }
                    } 
                    else if (fieldName != 'sobjectType') 
                    {
                        fields.add(new Map<String, Object>{
                            'field' => fieldName,
                            'type' => fieldNameToFieldTypeMap.get(fieldName),
                            'value' => recordTemplate.get(fieldName)
                        });
                    }

                }

                action.put('fields', fields);
                action.remove('recordTemplate');
                configToUpdate.put('arcshared__Action__c', JSON.serialize(action));
            }

		}

		List<Database.SaveResult> result = Database.update(scope, false);

		for(Integer i = 0; i < result.size(); i++){
			if (!result[i].isSuccess()) numErrors++;
		}
	}

    public void finish(Database.BatchableContext bc) {
		if (numErrors != 0) System.assert(false, numErrors + ' records failed to update.');
	}

    private List<String> generateFieldsList(Map<String, Object> recordTemplate) {
        List<String> fieldsAPIName = new List<String>();

		for (String fieldName : recordTemplate.keySet()) {
            if (fieldName != 'sobjectType') {
                fieldsAPIName.add(fieldName);
            }
        }

        return fieldsAPIName;
	}

    private Map<String, String> getFieldsType(List<String> fieldsAPIName, String objectAPIName) {
        Map<String, String> fieldNameToFieldTypeMap = new Map<String, String>();
        Map<String, Schema.SObjectField> fieldsMap = arcshared.Utils.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap();
        
        for (String field : fieldsAPIName) {
            try {
                Schema.DisplayType fieldType =  fieldsMap.get(field).getDescribe().getType();
                fieldNameToFieldTypeMap.put(field, String.valueOf(fieldType).toLowerCase());
            } catch(NullPointerException npe) {
                if (field == 'RecordTypeId') {
                    continue;
                } else {
                    throw npe;
                }
            }
        }

         return fieldNameToFieldTypeMap;
    }
}