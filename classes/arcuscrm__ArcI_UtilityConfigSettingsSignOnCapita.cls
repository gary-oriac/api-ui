/*
Company : Arcus Global
Product : Arcus Integration Architecture
Purpose : Config settings manager for the Capita Portal integration
Notes :
 */
public with sharing class ArcI_UtilityConfigSettingsSignOnCapita
{
    public enum CallOutsSignOnCapita { CALL_OUT_CAPITA_PORTAL_WEB_SERVICE_PASSWORD }
    
    public static void addSettingsAndInsertList() {
        
        List<arcshared.AppConfigSupport.setting> configSettingsList = new List<arcshared.AppConfigSupport.setting>();
        configSettingsList.add(new arcshared.AppConfigSupport.setting(CallOutsSignOnCapita.CALL_OUT_CAPITA_PORTAL_WEB_SERVICE_PASSWORD.name(), 'String', '', '', 11003, true, true, ''));

        arcshared.ArcI_UtilityConfigSettingsMain.addSettingsAndInsertList(configSettingsList);
    }   

    public static String get(CallOutsSignOnCapita pSetting) {
        return arcshared.AppConfigSupport.getSingleValue(arcshared.ArcI_UtilityConfigSettingsMain.CALL_OUT_SETTINGS_CATEGORY, pSetting.name());
    }
}