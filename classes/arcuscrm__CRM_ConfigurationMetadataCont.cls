public with sharing class CRM_ConfigurationMetadataCont {
        
    @AuraEnabled(Cacheable=true)
    public static arcuscrm__CRM_Configuration_Item__mdt[] getAllCRMConfigItems() {        
        return [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, arcuscrm__Guidance__c, arcuscrm__Description__c, arcuscrm__Status__c, arcuscrm__Ranking__c, 
                arcuscrm__Guidance_URL__c, arcuscrm__Category__c, arcuscrm__Configuration_Target__c 
                FROM arcuscrm__CRM_Configuration_Item__mdt
                ORDER BY arcuscrm__Ranking__c ASC NULLS LAST ];
    }

    @AuraEnabled
    public static void updateStatus(String mdtRecordName, String status){
        /* 
            TODO: Switch commented lines when arcshared method is packaged.
        */
        List<Metadata.CustomMetadata> customMetadata = new List<Metadata.CustomMetadata>();
        arcuscrm__CRM_Configuration_Item__mdt configToUpdate = new arcuscrm__CRM_Configuration_Item__mdt();
        configToUpdate.MasterLabel = mdtRecordName;
        configToUpdate.arcuscrm__Status__c = status;
        // arcshared.CustomMetadataCreator configMDTCreator = new arcshared.CustomMetadataCreator('CRM_Configuration_Item', configToUpdate);
        arcuscrm.CustomMetadataCreator configMDTCreator = new arcuscrm.CustomMetadataCreator('CRM_Configuration_Item', configToUpdate);
        customMetadata.addAll(configMDTCreator.customMetadataList);
        // Id deploymentId = arcshared.CustomMetadataCreator.deploy(customMetadata);
        Id deploymentId = arcuscrm.CustomMetadataCreator.deploy(customMetadata);
    }
}