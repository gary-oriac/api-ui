@isTest
public class BatchUpdateDecisionDetails_Test {

    static Id planningAppRecordId = Schema.SObjectType.arcusbuiltenv__Planning_Application__c.getRecordTypeInfosByDeveloperName().get('Application').getRecordTypeId();
    static Id recAndDecRecordId = Schema.SObjectType.arcusbuiltenv__Recommendation_and_Decision__c.getRecordTypeInfosByDeveloperName().get('Planning_Application').getRecordTypeId();
    static Id decisionDetailRecordTypeId = Schema.SObjectType.arcusbuiltenv__Decision_Detail__c.getRecordTypeInfosByDeveloperName().get('Approval_Reason').getRecordTypeId();

    @isTest 
    static void test_batchUpdateDecisionDetails() {       
        arcusbuiltenv__Planning_Application__c pl = new arcusbuiltenv__Planning_Application__c (
            RecordTypeId = planningAppRecordId,
            arcusbuiltenv__Type__c = 'Notification'
        );

        insert pl;

        arcusbuiltenv__Recommendation_and_Decision__c recAndDec = new arcusbuiltenv__Recommendation_and_Decision__c (
            RecordTypeId = recAndDecRecordId,
            arcusbuiltenv__Planning_Application__c = pl.Id
        );

        insert recAndDec;

        List<arcusbuiltenv__Decision_Detail__c> details = new List<arcusbuiltenv__Decision_Detail__c>();

        for (Integer i = 0; i < 20; i++) {
            arcusbuiltenv__Decision_Detail__c decDetail = new arcusbuiltenv__Decision_Detail__c (
                RecordTypeId = decisionDetailRecordTypeId,
                arcusbuiltenv__Type__c = 'Enforcement',
                arcusbuiltenv__Category__c = 'Highways',
                arcusbuiltenv__Recommendation_and_Decision__c = recAndDec.Id
            );

			details.add(decDetail);
        }

        insert details;
        
        Test.startTest();      
            Database.executeBatch(new BatchUpdateDecisionDetails(), 200);
        Test.stopTest(); 

        List<arcusbuiltenv__Decision_Detail__c> decDetailList = [SELECT Id, Name, arcusbuiltenv__Type__c, arcusbuiltenv__Type_of_Monitoring__c FROM arcusbuiltenv__Decision_Detail__c];
        
        System.assertEquals(20, decDetailList.size(), 'Decision Details records are not inserted.');

        for (arcusbuiltenv__Decision_Detail__c decDetail : decDetailList) {
            System.assertEquals('Enforcement', decDetail.arcusbuiltenv__Type_of_Monitoring__c, 'The type of monitoring field is not updated for ' + decDetail.Name);
            System.assertEquals('Highways', decDetail.arcusbuiltenv__Type__c, 'The type field is not updated for ' + decDetail.Name );
        }
    }
}