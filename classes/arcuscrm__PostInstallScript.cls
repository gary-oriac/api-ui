global class PostInstallScript implements InstallHandler {
    
    global void onInstall(InstallContext context) {
        Map<String, List<arcshared.AppConfigSupport.setting>> settings = new Map<String, List<arcshared.AppConfigSupport.setting>>();

        settings.put('ConfigurationRecordTypeComponent', new List<arcshared.AppConfigSupport.setting>{
            new arcshared.AppConfigSupport.setting(
                'arcuscrm.Document_Indexing_Area',
                'String',
                'arcuscrm:Indexing_Configuration',
                'arcuscrm:Indexing_Configuration',
                1,
                true,
                true,
                'The lightning component to be loaded when the Document_Indexing record type is selected on the configuration sObject.'
            )
        });

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
}