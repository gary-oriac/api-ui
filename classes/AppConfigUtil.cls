/*
Company : Arcus Global
Product : Arcus Built Environment
Purpose : Inserts/updates arcus built environment configuration.
Notes :
 */
global class AppConfigUtil{
    global static void createAll() {
        AppConfigUtil.createAppConfigSettings();        
    }

    public static void createAppConfigSettings(){
        List<arcshared.AppConfigSupport.setting> triggerHandlersSettings = new List<arcshared.AppConfigSupport.setting>();
        List<arcshared.AppConfigSupport.setting> wordsInHelpTextToFilterField = new List<arcshared.AppConfigSupport.setting>();
        
        /**
        Words in description
        */
        String wordsInHelpText = '["External Id field","GIS Id field","Hidden Field","Unique Id","System Field"]';        
        wordsInHelpTextToFilterField.add(new arcshared.AppConfigSupport.setting(
            'helpTextsToFilterFieldForStandardParagraphs', 
            'String', 
            wordsInHelpText,  
            wordsInHelpText, 
            1, true, false, 'Fields that have these words in their help text will not be available in the standard paragraph field selection modal.'
        ));

        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'arcusbuiltenv__Appeal__c-ProcessEngineAutoHandler', 
            'TriggerSetting', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Appeal__c,2', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Appeal__c,2', 
            1, true, false
        ));

        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'arcusbuiltenv__Action__c-ProcessEngineAutoHandler', 
            'TriggerSetting', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Action__c,2', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Action__c,2', 
            1, true, false
        ));

        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'Asset-ProcessEngineAutoHandler', 
            'TriggerSetting',
            'arcshared.ProcessEngineTriggerHandler,Asset,2', 
            'arcshared.ProcessEngineTriggerHandler,Asset,2',
            1, true, false
        ));

        
        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'arcusbuiltenv__Constraint__c-ProcessEngineAutoHandler', 
            'TriggerSetting', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Constraint__c,2', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Constraint__c,2', 
            1, true, false
        ));

        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'arcusbuiltenv__Consultation__c-ProcessEngineAutoHandler', 
            'TriggerSetting', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Consultation__c,2', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Consultation__c,2', 
            1, true, false
        ));

        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'arcusbuiltenv__Decision_Detail__c-ProcessEngineAutoHandler', 
            'TriggerSetting', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Decision_Detail__c,2', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Decision_Detail__c,2', 
            1, true, false
        ));

        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'arcusbuiltenv__Building_Control_Application__c-ProcessEngineAutoHandler', 
            'TriggerSetting', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Building_Control_Application__c,2', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Building_Control_Application__c,2', 
            1, true, false
        ));

        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'arcusbuiltenv__Enforcement__c-ProcessEngineAutoHandler', 
            'TriggerSetting', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Enforcement__c,2', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Enforcement__c,2', 
            1, true, false
        ));

        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'arcusbuiltenv__Planning_Application__c-ProcessEngineAutoHandler', 
            'TriggerSetting', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Planning_Application__c,2', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Planning_Application__c,2', 
            1, true, false
        ));

        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'arcusbuiltenv__Planning_Obligation__c-ProcessEngineAutoHandler', 
            'TriggerSetting', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Planning_Obligation__c,2', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Planning_Obligation__c,2', 
            1, true, false
        ));

        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'arcusbuiltenv__Recommendation_and_Decision__c-ProcessEngineAutoHandler', 
            'TriggerSetting', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Recommendation_and_Decision__c,2', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Recommendation_and_Decision__c,2', 
            1, true, false
        ));

        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'arcusbuiltenv__Related_Location__c-ProcessEngineAutoHandler', 
            'TriggerSetting', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Related_Location__c,2', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Related_Location__c,2', 
            1, true, false
        ));

        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'arcusbuiltenv__Related_Party__c-ProcessEngineAutoHandler', 
            'TriggerSetting', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Related_Party__c,2', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Related_Party__c,2', 
            1, true, false
        ));

        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'arcusbuiltenv__Tree_Preservation_Order__c-ProcessEngineAutoHandler', 
            'TriggerSetting', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Tree_Preservation_Order__c,2', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Tree_Preservation_Order__c,2', 
            1, true, false
        ));

        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'arcusbuiltenv__Unit_of_Work__c-ProcessEngineAutoHandler', 
            'TriggerSetting', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Unit_of_Work__c,2', 
            'arcshared.ProcessEngineTriggerHandler,arcusbuiltenv__Unit_of_Work__c,2', 
            1, true, false
        ));

        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'arcshared__Web_Comment__c-ProcessEngineAutoHandler', 
            'TriggerSetting', 
            'arcshared.ProcessEngineTriggerHandler,arcshared__Web_Comment__c,2', 
            'arcshared.ProcessEngineTriggerHandler,arcshared__Web_Comment__c,2', 
            1, true, false
        ));

        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'Street_Naming_Numbering_Application__c-ProcessEngineAutoHandler', 
            'TriggerSetting', 
            'arcshared.arcshared.ProcessEngineTriggerHandler,Street_Naming_Numbering_Application__c,2', 
            'arcshared.arcshared.ProcessEngineTriggerHandler,Street_Naming_Numbering_Application__c,2', 
            1, true, false
        ));

        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'FinancialRecordTrigger 102', 
            'TriggerSetting', 
            'FinancialRecordTriggerHandler,arcshared__Financial_Transaction__c,501', 
            'FinancialRecordTriggerHandler,arcshared__Financial_Transaction__c,501', 
            1, true, false
        ));

        triggerHandlersSettings.add(new arcshared.AppConfigSupport.setting(
            'StreetNamingNumberingTrigger 102', 
            'TriggerSetting', 
            'StreetNamingNumberingTriggerHandler,Street_Naming_Numbering_Application__c,1', 
            'StreetNamingNumberingTriggerHandler,Street_Naming_Numbering_Application__c,1', 
            1, true, false
        ));

        arcshared.AppConfigSupport.setCategoryRecords(
            new Map<String, List<arcshared.AppConfigSupport.setting>>{
                'TriggerHandlers' => triggerHandlersSettings,
                'HelpTextWordsToFilterField' => wordsInHelpTextToFilterField
            },
            'BuiltEnvUnm'
        );
    }

}