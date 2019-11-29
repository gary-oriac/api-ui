@isTest
public class BatchUpdateConfigurationRecords_Test {

    static Id configRecordTypeId = Schema.SObjectType.arcshared__Configuration__c.getRecordTypeInfosByDeveloperName().get('Record_Template').getRecordTypeId();

    @isTest 
    static void test_batchUpdateConfigurationRecords() {       
        List<arcshared__Configuration__c> configs = new List<arcshared__Configuration__c>();

        for (Integer i = 0; i < 20; i++) {
            arcshared__Configuration__c config = new arcshared__Configuration__c (
                RecordTypeId = configRecordTypeId,
                arcshared__Object__c = 'arcusbuiltenv__Planning_Application__c',
                arcshared__Criteria__c = '{"rules":[{"field":"arcusbuiltenv__Site_Address__c","type":"TEXTAREA","firstValue":"testCriteria","secondValue":"","comparator":"notEquals"}]}',
                arcshared__Action__c = '{"recordTemplate":{"sobjectType":"arcusbuiltenv__Decision_Detail__c","RecordTypeId":"0120C000000AfmhQAC","arcusbuiltenv__Category__c":"Time","arcusbuiltenv__Type__c":"Consultee"},"lookupToSet":"arcusbuiltenv__Discharge_of_Condition_Application__c"}'
            );

			configs.add(config);
        }

        insert configs;
        
        Test.startTest();      
            Database.executeBatch(new BatchUpdateConfigurationRecords(), 200);
        Test.stopTest(); 

        List<arcshared__Configuration__c> configList = [SELECT Id, Name, arcshared__Action__c FROM arcshared__Configuration__c];
        
        System.assertEquals(20, configList.size(), 'Configuration records are not inserted.');

        for (arcshared__Configuration__c config : configList) {
            System.assertEquals(true, config.arcshared__Action__c.contains('arcusbuiltenv__Type_of_Monitoring__c'), 'The type of monitoring field is not updated for ' + config.Name);
            System.assertEquals(true, config.arcshared__Action__c.contains('arcusbuiltenv__Type__c'), 'The type field is not updated for ' + config.Name );
        }
    }
}