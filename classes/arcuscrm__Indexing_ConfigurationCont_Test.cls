@isTest
private with sharing class Indexing_ConfigurationCont_Test {

    @testSetup static void setup() {
        arcshared__Configuration__c configs = new arcshared__Configuration__c(
            arcshared__DeveloperName__c = 'TestConfig'
        );
        insert configs;
    }

    @isTest
    private static void getRecordDetailsShouldReturnTheConfigDetails(){
        arcshared__Configuration__c config = [SELECT Id, arcshared__DeveloperName__c FROM arcshared__Configuration__c LIMIT 1];
        arcshared__Configuration__c config2 = Indexing_ConfigurationCont.getRecordDetails(config.Id);

        System.assertEquals( config.arcshared__DeveloperName__c , config2.arcshared__DeveloperName__c );
    }

    @isTest
    private static void getMetadataDetailsShouldReturnExpectedDetails(){
        Map<String, Object> metadataDetails = Indexing_ConfigurationCont.getMetadataDetails();

        System.assertEquals(true, metadataDetails.containsKey('indexing_categories'));
        System.assertEquals(true, metadataDetails.containsKey('category_fields'));
        System.assertEquals(true, metadataDetails.containsKey('picklist_values'));
        System.assertEquals(true, metadataDetails.containsKey('available_officers'));
        System.assertEquals(true, metadataDetails.containsKey('available_objects'));
        System.assertEquals(true, metadataDetails.containsKey('additional_fields'));
    }

    @isTest
    private static void saveConfigShouldCreateAnotherConfig(){
        Map<String,String> configDetails = new Map<String,String>{
            'recordType' => 'arcuscrm.Document_Indexing_Area',
            'enabled' => 'true',
            'devName' => 'TestConfig2',
            'value' => 'test value'
        };

        Indexing_ConfigurationCont.saveConfig(configDetails);

        List<arcshared__Configuration__c> foundConfigs = [SELECT Id, arcshared__DeveloperName__c FROM arcshared__Configuration__c];

        System.assertEquals( 2 , foundConfigs.size());

    }
}