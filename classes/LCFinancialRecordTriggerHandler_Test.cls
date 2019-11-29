@isTest
public class LCFinancialRecordTriggerHandler_Test {
    static List<sObject> processEngineContext = new List<sObject>{
        new arcshared__Process_Engine_Context__mdt(
            arcshared__Object__c = 'arcuslandcharge__LCApplication__c',
            arcshared__Status_Field__c = 'arcuslandcharge__Search_Status__c',
            arcshared__Status_History_Field__c = 'arcuslandcharge__Status_History__c',
            arcshared__Related_Party_Object__c = 'arcusbuiltenv__Related_Party__c',
            arcshared__Related_Party_Role_Field__c = 'arcusbuiltenv__Role__c',
            arcshared__Related_Party_Parent_Lookup__c = 'arcuslandcharge__LCApplication__c',
            arcshared__Related_Party_Contact_Field__c = 'arcusbuiltenv__Contact__c',
            arcshared__Related_Party_Account_Field__c = 'arcusbuiltenv__Account__c'
        ),
        new arcshared__Process_Engine_Context__mdt(
            arcshared__Object__c = 'arcuslandcharge__LC_Register__c',
            arcshared__Status_Field__c = 'arcuslandcharge__Status__c',
            arcshared__Status_History_Field__c = 'arcuslandcharge__Status_History__c'
        )
    };

    @testSetup
    public static void testSetup() {
        AppConfigUtilLCS.createAll();
    }

    @isTest
    public static void testSetParentIdField() { 
        arcshared.ProcessEngineServiceCstMtdTestProvider.set(processEngineContext);
        Id ftRtId = arcshared.Utils.getRecordTypeIdBysObjectAndDeveloperNameAndNamespacePrefix('Financial_Transaction__c', 'Payable', 'arcshared'); 

        arcuslandcharge__LC_Register__c lcReg  = new arcuslandcharge__LC_Register__c(
            arcuslandcharge__Register_Part__c = '	Part 1: General Financial Charges',
            arcuslandcharge__Originating_Authority__c = 'British Pipeline Agency'
        );
        insert lcReg;

        arcshared__Financial_Transaction__c ft  =  new arcshared__Financial_Transaction__c(
            RecordTypeId = ftRtId,
            arcshared__Amount__c = 200,
            arcuslandcharge__Land_Charge_Register__c = lcReg.Id
        );

        Test.startTest();
        insert ft;
        Test.stopTest();

        arcshared__Financial_Transaction__c insertedRecord = [SELECT Id, arcshared__Parent_Id__c FROM arcshared__Financial_Transaction__c WHERE Id = :ft.Id LIMIT 1];

        System.assertEquals(lcReg.Id, insertedRecord.arcshared__Parent_Id__c, 'Financial Record Parent Id should have the same value as Land Charge Register id.');
    }

    @isTest
    public static void testSetParentIdFieldLCSearch() { 
        arcshared.ProcessEngineServiceCstMtdTestProvider.set(processEngineContext);
        Id ftRtId = arcshared.Utils.getRecordTypeIdBysObjectAndDeveloperNameAndNamespacePrefix('Financial_Transaction__c', 'Payable', 'arcshared'); 

        arcuslandcharge__LCApplication__c lcs  = new arcuslandcharge__LCApplication__c(
           arcuslandcharge__Respond_Via__c = 'Email' 
        );
        insert lcs;

        arcshared__Financial_Transaction__c ft  =  new arcshared__Financial_Transaction__c(
            RecordTypeId = ftRtId,
            arcshared__Amount__c = 200,
            arcuslandcharge__LC_Search__c = lcs.Id
        );

        Test.startTest();
        insert ft;
        Test.stopTest();

        arcshared__Financial_Transaction__c insertedRecord = [SELECT Id, arcshared__Parent_Id__c FROM arcshared__Financial_Transaction__c WHERE Id = :ft.Id LIMIT 1];

        System.assertEquals(lcs.Id, insertedRecord.arcshared__Parent_Id__c, 'Financial Record Parent Id should have the same value as Land Charge Register id.');
    }
}