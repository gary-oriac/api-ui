@isTest
public class BatchUpdateExternalId_Test {
    static Id planningAppRecordId = Schema.SObjectType.arcusbuiltenv__Planning_Application__c.getRecordTypeInfosByDeveloperName().get('Application').getRecordTypeId();
    static Id relatedPartyRecordId = Schema.SObjectType.arcusbuiltenv__Related_Party__c.getRecordTypeInfosByDeveloperName().get('Override').getRecordTypeId();

    @isTest 
    static void test_batchUpdateExternalId() {       
        arcusbuiltenv__Planning_Application__c pl = new arcusbuiltenv__Planning_Application__c (
            RecordTypeId = planningAppRecordId,
            arcusbuiltenv__ExternalId__c = 'Test'
        );

        insert pl;

        arcusbuiltenv__Related_Party__c relatedParty = new arcusbuiltenv__Related_Party__c (
            RecordTypeId = relatedPartyRecordId,
            arcusbuiltenv__Name_Override__c = 'Test Name',
            arcusbuiltenv__External_Id__c = 'Test11'
        );

        insert relatedParty;
        
        Test.startTest();      
            Database.executeBatch(new BatchUpdateExternalId(), 200);
        Test.stopTest(); 

        arcusbuiltenv__Planning_Application__c pa = [SELECT Id, arcusbuiltenv__ExternalId__c, arcusbuiltenv__External_Id__c FROM arcusbuiltenv__Planning_Application__c LIMIT 1];
        System.assertEquals(pa.arcusbuiltenv__ExternalId__c, pa.arcusbuiltenv__External_Id__c, 'The new external id field is not updated');

        arcusbuiltenv__Related_Party__c rp = [SELECT Id, arcusbuiltenv__ExternalId__c, arcusbuiltenv__External_Id__c FROM arcusbuiltenv__Related_Party__c LIMIT 1];
        System.assertNotEquals(rp.arcusbuiltenv__ExternalId__c, rp.arcusbuiltenv__External_Id__c, 'The new external id field should not be updated if already has a value in it');
    }
}