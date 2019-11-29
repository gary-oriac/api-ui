@isTest
public class StreetNamingNumberingTriggerHandler_Test {
    static Id snnRecordTypeId = Schema.SObjectType.Street_Naming_Numbering_Application__c.getRecordTypeInfosByDeveloperName().get('New_Addresses').getRecordTypeId();
    static List<sObject> processEngineContext = new List<sObject>{
        new arcshared__Process_Engine_Context__mdt(
            arcshared__Object__c = 'Street_Naming_Numbering_Application__c',
            arcshared__Status_Field__c = 'Status__c',
            arcshared__Status_History_Field__c = 'Status_History__c',
            arcshared__Matcher__c = null,
            arcshared__Related_Party_Object__c = 'arcusbuiltenv__Related_Party__c',
            arcshared__Related_Party_Role_Field__c = 'arcusbuiltenv__Role__c',
            arcshared__Related_Party_Parent_Lookup__c = 'Street_Naming_Numbering_Application__c',
            arcshared__Related_Party_Contact_Field__c = 'arcusbuiltenv__Contact__c',
            arcshared__Related_Party_Account_Field__c = 'arcusbuiltenv__Account__c'
        )
    };

    @testSetup
    public static void testSetup() {
        AppConfigUtil.createAll();
    }

    @isTest
    public static void testSetStatusHistoryField() {
        arcshared.ProcessEngineServiceCstMtdTestProvider.set(processEngineContext);

        Street_Naming_Numbering_Application__c snn  = new Street_Naming_Numbering_Application__c(
            RecordTypeId = snnRecordTypeId,
            Status__c = 'New Application'
        );
        insert snn;

        snn.Status__c = 'Valid';

        Test.startTest();
            update snn;
        Test.stopTest();

        Street_Naming_Numbering_Application__c insertedRecord = [SELECT Id, Status_History__c FROM Street_Naming_Numbering_Application__c WHERE Id = :snn.Id LIMIT 1];

        System.assertEquals('New Application', insertedRecord.Status_History__c, 'Street Naming & Numbering status history field is not populated.');
    }
}