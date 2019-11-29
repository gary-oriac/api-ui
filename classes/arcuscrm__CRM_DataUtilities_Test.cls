@isTest
public class CRM_DataUtilities_Test {

    @testSetup static void setup() {

    }

    @isTest
    static void test_insertQRICustomSettings(){
        List<arcshared__App_Config__c> settingsBefore = arcshared.appConfigSupport.getCategoryRecords(arcuscrm.CRM_DataUtilities.QUICK_REPORT_IT_CATEGORY_NAME);

        Test.startTest();
            arcuscrm.CRM_DataUtilities.insertQRICustomSettings();
            arcshared.appConfigSupport.refreshCache();
        Test.stopTest();

        List<arcshared__App_Config__c> settingsAfter = arcshared.appConfigSupport.getCategoryRecords(arcuscrm.CRM_DataUtilities.QUICK_REPORT_IT_CATEGORY_NAME);

        System.assert(settingsBefore.size() == 0, 'QRI settings should not be inserted before using method.');
        System.assert(settingsAfter.size() > 0, 'QRI settings should be inserted using method.');
    }
    
}