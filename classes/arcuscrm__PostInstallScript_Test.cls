@isTest
private with sharing class PostInstallScript_Test {
    
    @isTest
    private static void crmCustomSettingsAreInserted() {
        PostInstallScript install = new PostInstallScript();
        install.onInstall(null);

        List<arcshared__App_Config__c> customSettings = [
            SELECT Id 
            FROM arcshared__App_Config__c
        ];
        System.assert(customSettings.size() > 0);
    }
}