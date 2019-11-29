@isTest
public with sharing class BatchUpdateRecordTemplates_Test {
    @isTest
    public static void testUpdateRecordTemplates(){
        RecordType confRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Record_Template'];
        RecordType paymentRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Payment'];        

        insert new List<arcshared__Configuration__c>{
            new arcshared__Configuration__c(
                RecordTypeId = confRecType.Id,
                arcshared__Status__c = 'Test', 
                arcshared__Criteria__c = '{"rules" : [{"field" : "Phone","firstValue" : "match me","secondValue" : "","type" : "string","comparator" : "contains"}]}',
                arcshared__Rule__c = 'TestConfiguration',
                arcshared__Action__c = '{' + 
                                            '"recordTemplate": {' + 
                                                '"sobjectType": "arcshared__Financial_Transaction__c",' + 
                                                '"arcshared__Amount__c": 200,' + 
                                                '"RecordTypeId": "' + paymentRecType.Id + '"' + 
                                            '},' + 
                                            '"lookupToSet": "WhatId"' + 
                                        '}',
                arcshared__Enabled__c = true,
                arcshared__Object__c = 'Account'
            ),
            new arcshared__Configuration__c(
                RecordTypeId = confRecType.Id,
                arcshared__Status__c = 'Test', 
                arcshared__Criteria__c = '{"rules" : [{"field" : "Phone","firstValue" : "match me","secondValue" : "","type" : "string","comparator" : "contains"}]}',
                arcshared__Rule__c = 'TestConfiguration',
                arcshared__Action__c = '{' + 
                                            '"recordTemplate": {' + 
                                                '"sobjectType": "arcshared__Financial_Transaction__c",' + 
                                                '"arcshared__Amount__c": 200,' + 
                                                '"arcshared__Date_Due__c": "' + System.today() + '"' +
                                            '},' + 
                                            '"lookupToSet": "WhatId"' + 
                                        '}',
                arcshared__Enabled__c = true,
                arcshared__Object__c = 'Account'
            ),
            new arcshared__Configuration__c(
                RecordTypeId = confRecType.Id,
                arcshared__Status__c = 'Test', 
                arcshared__Criteria__c = '{"rules" : [{"field" : "Phone","firstValue" : "match me","secondValue" : "","type" : "string","comparator" : "contains"}]}',
                arcshared__Rule__c = 'TestConfiguration',
                arcshared__Action__c = '{' + 
                                            '"recordTemplate": {' + 
                                                '"sobjectType": "arcshared__Financial_Transaction__c",' + 
                                                '"arcshared__Amount__c": 200,' + 
                                                '"arcshared__Date_Due__c": "' + System.today() + '",' +
                                                '"RecordTypeId": ""' + 
                                            '},' + 
                                            '"lookupToSet": "WhatId"' + 
                                        '}',
                arcshared__Enabled__c = true,
                arcshared__Object__c = 'Account'
            )
        };

        Test.startTest();
        Database.executeBatch(new BatchUpdateRecordTemplates(), 200);
        Test.stopTest();

        Id recordTypeId = arcshared.Utils.getRecordTypeIdBysObjectAndDeveloperNameAndNamespacePrefix('Configuration__c', 'Record_Template', 'arcshared');
        String query = 'SELECT Id, arcshared__Action__c FROM arcshared__Configuration__c WHERE RecordTypeId = :recordTypeId';
        List<arcshared__Configuration__c> configs = Database.query(query);

        for (arcshared__Configuration__c conf : configs) {
            System.assertEquals(true, conf.arcshared__Action__c.contains('fields'), 'Record was not updated.');
            System.assertEquals(true, conf.arcshared__Action__c.contains('field'), 'Record was not updated.');
            System.assertEquals(true, conf.arcshared__Action__c.contains('type'), 'Record was not updated.');
            System.assertEquals(true, conf.arcshared__Action__c.contains('value'), 'Record was not updated.');

        }
    }
}