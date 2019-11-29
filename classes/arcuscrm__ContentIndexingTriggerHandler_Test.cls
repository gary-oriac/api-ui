@isTest
private with sharing class ContentIndexingTriggerHandler_Test {

    private static void insertCustomSetting(){
        Map<String, List<arcshared.AppConfigSupport.setting>> settings = new Map<String, List<arcshared.AppConfigSupport.setting>>();
        settings.put('TriggerHandlers', new List<arcshared.AppConfigSupport.setting>{
            new arcshared.AppConfigSupport.setting(
                'ContentIndexingTriggerHandler',
                'TriggerSetting',
                'arcuscrm.ContentIndexingTriggerHandler,ContentVersion,1',
                'arcuscrm.ContentIndexingTriggerHandler,ContentVersion,1',
                1,
                true,
                true,
                'The trigger handler for the ContentVersion object that gives access to files that have an index category.'
            )
        });
        
        arcshared.AppConfigSupport.setCategoryRecords(settings, 'arcuscrm');
    }

    @isTest
    private static void insertingConfigedFileShouldShareRecordWithConfigedOfficers(){

        insertCustomSetting();
        arcshared.AppConfigSupport.refreshCache();

        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'arcshared__Configuration__c' AND DeveloperName = 'Document_Indexing_Area'];
        User tempUser = TestUtils.createUser();

        arcshared__Configuration__c config = new arcshared__Configuration__c(
            RecordTypeId = rt.Id,
            arcshared__DeveloperName__c = 'Temp',
            arcshared__Action__c = '{"indexing_category":"Council Tax","category_field":"arcshared__Category__c","indexing_officers":[{"label":"Test","value":"' + tempUser.Id + '"}],"category_values":[{"label":"Plan","value":"Plan"},{"label":"Receipt","value":"Receipt"},{"label":"Invoice","value":"Invoice"}],"additional_fields":[{"label":"Title","value":"Title"}],"link_to":[{"label":"Account","value":"Account"},{"label":"arcshared__Service_Account__c","value":"arcshared__Service_Account__c"}],"create_as":[]}'
        );

        insert config;

        Test.startTest();
        ContentVersion cv = new ContentVersion(
            Title='Test',
            PathOnClient='Test.jpg',
            VersionData = Blob.valueOf('Test File'),
            Indexing_Category__c = 'Council Tax',
            IsMajorVersion = true
        );
        insert cv;

        Test.stopTest();

        ContentVersion updatedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        List<ContentDocumentLink> cdls = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId =:updatedCV.ContentDocumentId];


        System.assertEquals(2, cdls.size());
        System.assertEquals(tempUser.Id, cdls[1].LinkedEntityId);
    }
}