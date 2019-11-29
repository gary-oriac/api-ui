public with sharing class indexingDocumentIndexerCont {

    @AuraEnabled(cacheable=true)
    public static List<indexingDocumentFetcher.Document> getDocuments(String className) {
        indexingDocumentFetcher fetcher = instantiateDocumentFetcher(className);

        return fetcher.fetch();
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getConfigurations() {
        Date today = Date.today();
        List<arcshared__Configuration__c> configurations = [
            SELECT arcshared__Action__c 
            FROM arcshared__Configuration__c 
            WHERE RecordType.DeveloperName = 'Document_Indexing_Area'
            AND arcshared__Enabled__c = true
            AND (
                (arcshared__Start_Date__c = null AND arcshared__End_Date__c = null)
                OR (arcshared__Start_Date__c <= :today AND arcshared__End_Date__c = null)
                OR (arcshared__Start_Date__c <= :today AND arcshared__End_Date__c >= :today)
                OR (arcshared__Start_Date__c = null AND arcshared__End_Date__c >= :today)
            )
        ];

        List<Map<String, Object>> actions = new List<Map<String, Object>>();

        for(arcshared__Configuration__c configuration : configurations) {
            actions.add(
                (Map<String, Object>)JSON.deserializeUntyped(configuration.arcshared__Action__c)
            );
        }

        return actions;
    }

    @AuraEnabled(cacheable=true)
    public static List<Option> getIndexingCategoryValues() {
        List<Option> options = new List<Option>();

        Schema.DescribeFieldResult fieldDescribe = arcshared.Utils.getFieldDescribe(
            'ContentVersion', 
            'arcuscrm__Indexing_Category__c'
        );

        for(Schema.PicklistEntry picklistEntry : fieldDescribe.getPicklistValues()) {
            options.add(new Option(picklistEntry));
        }
        return options;
    }

    @AuraEnabled
    public static List<Option> getPicklistValues(String fieldName) {
        List<Schema.PicklistEntry> picklistEntries = arcshared.Utils.getFieldPicklistValues('ContentVersion', fieldName);
        List<Option> options = new List<Option>();

        for(Schema.PicklistEntry picklistEntry : picklistEntries) {
            options.add(new Option(picklistEntry));
        }

        return options;
    }

    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String entity, String term, List<String> fields){
        Schema.DescribeSobjectResult sObjectDescribe = arcshared.Utils.getsObjectDescribe(entity);
        String sObjectName = sObjectDescribe.getName();

        String sosl = 'FIND {*' 
            + String.escapeSingleQuotes(term) 
            + '*} IN ALL FIELDS RETURNING ' 
            + sObjectName + '(Id, ' + String.join(fields,',') +  ')';
        List<SObject> results = Search.query(sosl)[0];

        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, results);

        return securityDecision.getRecords();
    }

    @AuraEnabled(cacheable=true)
    public static Id getRecordTypeIdByDeveloperName(String objectApiName, String developerName){
        return [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType =: objectApiName 
            AND DeveloperName =: developerName
        ].Id;
    }

    @AuraEnabled
    public static void link(String className, List<Id> recordIds, Id versionId) {
        indexingDocumentLinker linker = instantiateDocumentLinker(className);

        linker.link(recordIds, versionId);
    }

    private static indexingDocumentFetcher instantiateDocumentFetcher(String className) {
        String fetcherClass = arcshared.AppConfigSupport.getSingleValue('DocumentIndexing', 'FetcherClass');
        
        if(String.isNotBlank(className)) {
            return (indexingDocumentFetcher)instantiateClass(className);
        } else if(String.isNotBlank(fetcherClass)) {
            return (indexingDocumentFetcher)instantiateClass(fetcherClass);
        }

        return new indexingDocumentFetcher();
    }

    private static indexingDocumentLinker instantiateDocumentLinker(String className) {
        String linkerClass = arcshared.AppConfigSupport.getSingleValue('DocumentIndexing', 'LinkerClass');

        if(String.isNotBlank(className)) {
            return (indexingDocumentLinker)instantiateClass(className);
        } else if(String.isNotBlank(linkerClass)) {
            return (indexingDocumentLinker)instantiateClass(linkerClass);
        }

        return new indexingDocumentLinker();
    }

    private static Object instantiateClass(String className) {
        Type classType = Type.forName(className);
        return classType.newInstance();
    }

    public class Option {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

        public option(Schema.PicklistEntry picklistEntry) {
            this.label = picklistEntry.getLabel();
            this.value = picklistEntry.getValue();
        }

        public option(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}