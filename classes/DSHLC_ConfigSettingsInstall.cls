global class DSHLC_ConfigSettingsInstall {
    
    public static void insertAllSettings(){
        DSHLC_ConfigSettingsInstall.SetCustomSettings();
    }

    public static void SetCustomSettings() 
    {
        SetupCustomSettingsForDSHConfig();
        arcshared.AppConfigSupport.refreshCache();
    }

    // Add configuration custom settings fields 
    global static void SetupCustomSettingsForDSHConfig()
    {
        List<arcshared.AppConfigSupport.setting> dshFeatureConfigSettings = new List<arcshared.AppConfigSupport.setting>();
     
        Map<String, List<arcshared.AppConfigSupport.setting>> categoryToSettingsMap = new Map<String, List<arcshared.AppConfigSupport.setting>>();

        // DSH settings list    

        // Misc
        dshFeatureConfigSettings.add(new arcshared.AppConfigSupport.setting('DSH_MISC_POSSESSIVE_DETERMINER', 'String', 'My', 'My', 10000, true, true, 'The My / Your prefix that councils like to use.'));

        //Password Reset config
        dshFeatureConfigSettings.add(new arcshared.AppConfigSupport.setting('DSH_PASSWORD_RESET_OPTION', 'String', 'internal', 'external', 10000, true, true, 'This setting is used for enabling the password reset options'));

        // Map config
        dshFeatureConfigSettings.add(new arcshared.AppConfigSupport.setting('DSH_MAP_STREET_TILE_URL', 'String', 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', 10000, true, true, 'This is the URL for the tile images for the street layer in the DSH Map component.'));
        dshFeatureConfigSettings.add(new arcshared.AppConfigSupport.setting('DSH_MAP_STREET_TILE_CREDIT', 'String', '&copy; <a href="https://www.openstreetmap.org/copyright" target="_blank">OpenStreetMap</a> contributors', '&copy; <a href="https://www.openstreetmap.org/copyright" target="_blank">OpenStreetMap</a> contributors', 10000, true, true, 'This is the credit or attributition to be shown in the DSH Map for the street layer tiles. This setting can inlcude html tags such as href links.'));

        // Release version
        dshFeatureConfigSettings.add(new arcshared.AppConfigSupport.setting('DSH_RELEASE_VERSION_LC_COMMON', 'String', '', 'Unreleased', 10000, true, true, 'The release version of the LC DSH Core (common) files.'));
        dshFeatureConfigSettings.add(new arcshared.AppConfigSupport.setting('DSH_RELEASE_VERSION_LC_REVBEN', 'String', '', 'Unreleased', 10000, true, true, 'The release version of the LC DSH Core (common) files.'));
        dshFeatureConfigSettings.add(new arcshared.AppConfigSupport.setting('DSH_RELEASE_VERSION_LC_CLIENT', 'String', '', 'Unreleased', 10000, true, true, 'The release version of the LC DSH Core (client) files.'));
        dshFeatureConfigSettings.add(new arcshared.AppConfigSupport.setting('DSH_RELEASE_VERSION_VF_CLIENT', 'String', '', 'Unreleased', 10000, true, true, 'The release version of the VF DSH (client) files.'));

        // Council
        dshFeatureConfigSettings.add(new arcshared.AppConfigSupport.setting('DSH_COUNCIL_AREA_NAME', 'String', 'Arcusville', 'Arcusville', 10000, true, true, 'The name of the are which the council serves.'));
        dshFeatureConfigSettings.add(new arcshared.AppConfigSupport.setting('DSH_COUNCIL_LONG_NAME', 'String', 'Arcus Borough Council', 'Arcus Borough Council', 10000, true, true, 'The long name of the council.'));
        dshFeatureConfigSettings.add(new arcshared.AppConfigSupport.setting('DSH_COUNCIL_SHORT_NAME', 'String', 'ABC', 'ABC', 10000, true, true, 'The abbreviation / short name of the council.'));
        dshFeatureConfigSettings.add(new arcshared.AppConfigSupport.setting('DSH_COUNCIL_CMS_WEBSITE_URL', 'String', 'https://www.arcusglobal.com', 'https://www.arcusglobal.com', 10000, true, true, 'The full URL of the main council website.'));
        dshFeatureConfigSettings.add(new arcshared.AppConfigSupport.setting('DSH_COUNCIL_DSH_WEBSITE_URL', 'String', 'https://account.arcusglobal.com', 'https://account.arcusglobal.com', 10000, true, true, 'The full URL of the DSH website.'));
		dshFeatureConfigSettings.add(new arcshared.AppConfigSupport.setting('DSH_COUNCIL_CUSTOMER_SERVICE_EMAIL', 'String', 'ask@arcusglobal.com', 'ask@arcusglobal.com', 10000, true, true, 'The customer service email address.'));
        dshFeatureConfigSettings.add(new arcshared.AppConfigSupport.setting('DSH_COUNCIL_TERMS_AND_CONDITIONS_URL', 'String', 'https://account.arcusglobal.com/terms-and-conditions', 'https://account.arcusglobal.com/terms-and-conditions', 10000, true, true, 'The full URL of a page containing DSH Terms and Conditions.'));
        dshFeatureConfigSettings.add(new arcshared.AppConfigSupport.setting('DSH_COUNCIL_PRIVACY_POLICY_URL', 'String', 'https://account.arcusglobal.com/privacy-policy', 'https://account.arcusglobal.com/privacy-policy', 10000, true, true, 'The full URL of a page containing DSH Privacy Policy.'));
        dshFeatureConfigSettings.add(new arcshared.AppConfigSupport.setting('DSH_COUNCIL_HQ_LOCATION', 'String', '52.234860,0.129542', '52.234860,0.129542', 10000, true, true, 'The geolocation of the council main building. It consists of two decimal numbers separated with a comma, the numbers are ordered as the latitude and longitude.'));

        // Trigger Handlers
        List<arcshared.AppConfigSupport.setting> dispatcherSettings = new List<arcshared.AppConfigSupport.setting>();
        dispatcherSettings.add(new arcshared.AppConfigSupport.setting('DSH_CONTACT_TRIGGER_HANDLER', 'TriggerSetting', 'DSHLC_ContactTriggerHandler,Contact,10000', 'DSHLC_ContactTriggerHandler,Contact,10000', 10000, true, false));
         
        // Map all the different category lists
        categoryToSettingsMap.put('DSHFeatureConfig',  dshFeatureConfigSettings);
        categoryToSettingsMap.put('TriggerHandlers', dispatcherSettings);

        // Insert the settings
        arcshared.AppConfigSupport.setCategoryRecords(categoryToSettingsMap, 'arcusdsh');
    }

}