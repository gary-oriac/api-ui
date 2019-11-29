@isTest
public class FinancialRecordTriggerHandler_Test {
    static List<sObject> processEngineContext = new List<sObject>{
        new arcshared__Process_Engine_Context__mdt(
            arcshared__Object__c = 'arcusbuiltenv__Planning_Application__c',
            arcshared__Status_Field__c = 'arcusbuiltenv__Status__c',
            arcshared__Status_History_Field__c = null,
            arcshared__Matcher__c = null,
            arcshared__Related_Party_Object__c = 'arcusbuiltenv__Related_Party__c',
            arcshared__Related_Party_Role_Field__c = 'arcusbuiltenv__Role__c',
            arcshared__Related_Party_Parent_Lookup__c = 'arcusbuiltenv__Planning_Application__c',
            arcshared__Related_Party_Contact_Field__c = 'arcusbuiltenv__Contact__c',
            arcshared__Related_Party_Account_Field__c = 'arcusbuiltenv__Account__c'
        )
    };

    @testSetup
    public static void testSetup() {
        AppConfigUtil.createAll();
    }

    @isTest
    public static void testSetParentIdField() {
        Id plRtId = arcshared.Utils.getRecordTypeIdBysObjectAndDeveloperNameAndNamespacePrefix('Planning_Application__c', 'Application', 'arcusbuiltenv'); 
        Id ftRtId = arcshared.Utils.getRecordTypeIdBysObjectAndDeveloperNameAndNamespacePrefix('Financial_Transaction__c', 'Payable', 'arcshared'); 

        arcshared.ProcessEngineServiceCstMtdTestProvider.set(processEngineContext);

        arcusbuiltenv__Planning_Application__c pl  = new arcusbuiltenv__Planning_Application__c(
            RecordTypeId = plRtId,
            arcusbuiltenv__Type__c = 'County Consultation'
        );
        insert pl;

        arcshared__Financial_Transaction__c ft  =  new arcshared__Financial_Transaction__c(
            RecordTypeId = ftRtId,
            arcshared__Amount__c = 200,
            arcusbuiltenv__Planning_Application__c = pl.Id
        );

        Test.startTest();
        insert ft;
        Test.stopTest();

        arcshared__Financial_Transaction__c insertedRecord = [SELECT Id, arcshared__Parent_Id__c FROM arcshared__Financial_Transaction__c WHERE Id = :ft.Id LIMIT 1];

        System.assertEquals(pl.Id, insertedRecord.arcshared__Parent_Id__c, 'Financial Record Parent Id should have the same value as planning application id.');
    }
}