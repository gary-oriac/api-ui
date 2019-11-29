/*
Company : Arcus Global
Product : Arcus Land Charges
Purpose : Inserts/updates arcus built environment configuration for Land Charges.
Notes :
 */
global class AppConfigUtilLCS {

    global static void createAll() {
        AppConfigUtilLCS.createAppConfigSettings();        
    }

    public static void createAppConfigSettings(){
        List<arcshared.AppConfigSupport.setting> triggerHandlersSettings = getTriggerHandlerSettings();
        
        List<arcshared.AppConfigSupport.setting> landChargeSearchSettings = new List<arcshared.AppConfigSupport.setting>{
            new arcshared.AppConfigSupport.setting(
                'Unmanaged Land Charges',
                'String',
                'LandChargeResponseGenerator',
                'LandChargeResponseGenerator',
                1, true, false, 'Unmanaged version of CON29 and LLC1 processor'
            )
        };
        


        arcshared.AppConfigSupport.setCategoryRecords(
            new Map<String, List<arcshared.AppConfigSupport.setting>>{
                'TriggerHandlers' => triggerHandlersSettings,
                'SpatialSearchProcessor' => landChargeSearchSettings
            },
            'BuiltEnvLCSUnm'
        );
    }

    private static List<arcshared.AppConfigSupport.setting> getTriggerHandlerSettings(){
        List<arcshared.AppConfigSupport.setting> triggerHandlersSettings = new List<arcshared.AppConfigSupport.setting>();

        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'FinancialRecordTrigger 1', 
            'TriggerSetting', 
            'LCFinancialRecordTriggerHandler,arcshared__Financial_Transaction__c,502', 
            'LCFinancialRecordTriggerHandler,arcshared__Financial_Transaction__c,502', 
            1, true, false
        ));

        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'arcuslandcharge__LC_Register__c-ProcessEngineAutoHandler', 
            'TriggerSetting', 
            'arcshared.ProcessEngineTriggerHandler,arcuslandcharge__LC_Register__c,2', 
            'arcshared.ProcessEngineTriggerHandler,arcuslandcharge__LC_Register__c,2', 
            1, true, false
        ));

        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'arcuslandcharge__LCApplication__c-ProcessEngineAutoHandler', 
            'TriggerSetting', 
            'arcshared.ProcessEngineTriggerHandler,arcuslandcharge__LCApplication__c,2', 
            'arcshared.ProcessEngineTriggerHandler,arcuslandcharge__LCApplication__c,2', 
            1, true, false
        ));
        
        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'arcuslandcharge__External_Answer__c-ProcessEngineAutoHandler', 
            'TriggerSetting', 
            'arcshared.ProcessEngineTriggerHandler,arcuslandcharge__External_Answer__c,2', 
            'arcshared.ProcessEngineTriggerHandler,arcuslandcharge__External_Answer__c,2', 
            1, true, false
        ));
        
        return triggerHandlersSettings;
    }

}