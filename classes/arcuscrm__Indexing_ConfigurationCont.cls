public with sharing class Indexing_ConfigurationCont {
    @AuraEnabled
    public static arcshared__Configuration__c getRecordDetails(Id recordId) {
        String query = 'SELECT Id, arcshared__Action__c, arcshared__Action_Continued__c, arcshared__Criteria__c, arcshared__Object__c, arcshared__Rule__c, arcshared__Priority__c, arcshared__Start_Date__c, arcshared__End_Date__c, arcshared__Enabled__c, arcshared__Apply_On__c, arcshared__Status__c, arcshared__Description__c, arcshared__DeveloperName__c, arcshared__Tags__c ' +
                        'FROM arcshared__Configuration__c ' +
                        'WHERE Id = \'' + recordId + '\'';
        arcshared__Configuration__c config = (arcshared__Configuration__c) arcshared.RecordCRUDUtils.soqlRecord(query)[0];
        if (String.isNotBlank(config.arcshared__Action_Continued__c)) {
            config.arcshared__Action__c += config.arcshared__Action_Continued__c;
        }
        return config;
    }

    @AuraEnabled
    public static Map<String, Object> getMetadataDetails() {
        List<PicklistElement> picklistFields = getPicklistFields();
        List<PicklistElement> indexingCategories = getIndexingCategories();
        List<PicklistElement> availableOfficers = getAvailableOfficers();
        List<PicklistElement> availableObjects = getSObjects();
        List<PicklistElement> additionalFields = getSObjectFields('ContentVersion');
        Map<String, List<PicklistElement>> picklistValues = getPicklistValues(picklistFields);

        return new Map<String, Object>{
            'indexing_categories' => indexingCategories,
            'category_fields' => picklistFields,
            'picklist_values' => picklistValues,
            'available_officers' => availableOfficers,
            'available_objects' => availableObjects,
            'additional_fields' => additionalFields
        };
    }

    @AuraEnabled
    public static Id saveConfig(Map<String,String> configDetails) {
        Id recordTypeId = getRecordTypeId(configDetails.get('recordType'));

        if(recordTypeId == null) throw new AuraHandledException('Invalid record type: ' + configDetails.get('recordType'));

        arcshared__Configuration__c config = new arcshared__Configuration__c();
        if(configDetails.containsKey('recordId') && String.isNotBlank(configDetails.get('recordId'))) config.id = configDetails.get('recordId');
        if(configDetails.containsKey('enabled')) config.arcshared__Enabled__c = Boolean.valueOf(configDetails.get('enabled'));
        config.RecordTypeId = recordTypeId;
        if(configDetails.containsKey('devName')) config.arcshared__DeveloperName__c = configDetails.get('devName');

        if(configDetails.containsKey('value')){
            String actionsJSON = configDetails.get('value');
            if (actionsJSON.length() > 131072) {
                config.arcshared__Action__c = actionsJSON.subString(0, 131072);
                config.arcshared__Action_Continued__c = actionsJSON.subString(131072, actionsJSON.length());
            } else {
                config.arcshared__Action__c = actionsJSON;
                config.arcshared__Action_Continued__c = '';
            }
        }

        if (String.isNotBlank(config.id)) {
            arcshared.RecordCRUDUtils.updateRecord(config);
        } else {
            arcshared.RecordCRUDUtils.insertRecord(config);
        }
        return config.Id;
    }

    private static Id getRecordTypeId(String recordType){
        if(recordType.contains('.')){
            List<String> namespaceAndDeveloperName = recordType.split('\\.');
            return arcshared.Utils.getRecordTypeIdByNamespacedsObjectAndDeveloperNameAndNamespacePrefix(
                'arcshared__Configuration__c',
                namespaceAndDeveloperName[1],
                namespaceAndDeveloperName[0]
            );
        }else{
            return arcshared.Utils.getRecordTypeIdByNamespacedsObjectAndDeveloperNameAndNamespacePrefix(
                'arcshared__Configuration__c',
                recordType,
                ''
            );
        }
    }

    private static List<PicklistElement> getAvailableOfficers(){
        List<PicklistElement> availableOfficers = new List<PicklistElement>();
        for(User u: [SELECT Id, Name FROM User WHERE isActive = true]){
            availableOfficers.add(new PicklistElement('User: ' + u.Name, u.Id));
        }

        for(CollaborationGroup g: [SELECT Id, Name FROM CollaborationGroup]){
            availableOfficers.add(new PicklistElement('Group: ' + g.Name, g.Id));
        }

        return availableOfficers;
    }

    @AuraEnabled
    public static List<PicklistElement> getSObjectFields(String sObjectName){
        List<PicklistElement> picklistFields = new List<PicklistElement>();

        Set<String> ignoreFields = new Set<String>{'PathOnClient'};

        Map<String,Schema.SObjectField> objectFields = arcshared.Utils.getsObjectDescribe(sObjectName).fields.getMap();
        for(String fieldName: objectFields.keySet()){
            Schema.DescribeFieldResult fieldDetails = objectFields.get(fieldName).getDescribe();
            if(fieldDetails.isUpdateable() && !ignoreFields.contains(fieldDetails.getName())){
                picklistFields.add(new PicklistElement(fieldDetails.getLabel(), fieldDetails.getName()));
            }
        }
        return picklistFields;
    }

    private static List<PicklistElement> getPicklistFields(){
        List<PicklistElement> picklistFields = new List<PicklistElement>();

        Map<String,Schema.SObjectField> objectFields = arcshared.Utils.getsObjectDescribe('ContentVersion').fields.getMap();
        for(String fieldName: objectFields.keySet()){
            Schema.DescribeFieldResult fieldDetails = objectFields.get(fieldName).getDescribe();
            if(fieldDetails.getType() == Schema.DisplayType.Picklist){
                picklistFields.add(new PicklistElement(fieldDetails.getLabel(), fieldDetails.getName()));
            }
        }

        return picklistFields;
    }

    @AuraEnabled
    public static List<PicklistElement> getIndexingCategories(){
        return toCustomPicklistEntry(arcshared.Utils.getFieldPicklistValues('ContentVersion', 'arcuscrm__Indexing_Category__c'));
    }

    private static Map<String, List<PicklistElement>> getPicklistValues(List<PicklistElement> picklistFields){
        Map<String, List<PicklistElement>> picklistValuesByFieldName= new Map<String, List<PicklistElement>>();

        for(PicklistElement field: picklistFields){
            picklistValuesByFieldName.put(
                field.value,
                toCustomPicklistEntry(arcshared.Utils.getFieldPicklistValues('ContentVersion', field.value))
            );
        }

        return picklistValuesByFieldName;
    }

    private static List<PicklistElement> getSObjects(){
        List<PicklistElement> availableSObjects = new List<PicklistElement>();

        for(EntityDefinition definition : [SELECT Id, Label, QualifiedAPIName FROM EntityDefinition WHERE isApexTriggerable = true AND isLayoutable = true AND KeyPrefix != null]){
            Schema.DescribeSObjectResult objDetails = arcshared.Utils.getsObjectDescribe(definition.QualifiedAPIName);
            if(objDetails != null && objDetails.isAccessible() && objDetails.isUpdateable()){
                availableSObjects.add(new PicklistElement(definition.Label, definition.QualifiedAPIName));
            }
        }
        availableSObjects.sort();
        return availableSObjects;
    }


    private static List<PicklistElement> toCustomPicklistEntry(List<Schema.PicklistEntry> entries){
        List<PicklistElement> picklistEntries = new List<PicklistElement>();
        for(Schema.PicklistEntry entry: entries){
            picklistEntries.add(new PicklistElement(entry));
        }

        return picklistEntries;
    }

    public class PicklistElement implements Comparable {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

        public PicklistElement(String label, String value){
            this.label = label;
            this.value = value;
        }

        public PicklistElement(Schema.PicklistEntry entry){
            this.label = entry.getLabel();
            this.value = entry.getValue();
        }

        public Integer compareTo(Object compareTo) {
            PicklistElement compareToElem = (PicklistElement)compareTo;
            Integer returnValue = 0;

            if(label < compareToElem.label) returnValue = -1;
            else if(compareToElem.label < label) returnValue = 1;

            return returnValue;
        }
    }

    @AuraEnabled
    public static void updateFileCategories(List<Id> documentIds, String category){
        List<ContentVersion> files = [SELECT Id FROM ContentVersion WHERE ContentDocumentId IN :documentIds AND IsLatest = true];
        for(ContentVersion file: files){
            file.Indexing_Category__c = category;
        }
        arcshared.RecordCRUDUtils.updateRecord(files);
    }
}