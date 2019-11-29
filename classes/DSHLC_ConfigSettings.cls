/*
Company    :    Arcus Global
Product    :    Arcus DSH
Purpose    :    ConfigSettings class
Notes      :     
*/
public with sharing virtual class DSHLC_ConfigSettings
{
    //// AppConfig Custom Settings below (Custom Metadata above)

    //Utilities to obtain a custom setting value from DSHFeatureConfig
    public static String getConfigSetting(String pKey){return arcshared.AppConfigSupport.getSingleValue('DSHFeatureConfig', pKey);}
    public static Integer getConfigSettingInteger(String pKey){return (getConfigSetting(pKey) == null ? null : Integer.valueOf(getConfigSetting(pKey)));}
    public static Boolean getConfigSettingBoolean(String pKey){return (getConfigSetting(pKey) == null ? null : Boolean.valueOf(getConfigSetting(pKey)));}


    // Misc Config
    public static String getPossessiveDeterminer()
    {
      return arcshared.AppConfigSupport.getSingleValue('DSHFeatureConfig', 'DSH_MISC_POSSESSIVE_DETERMINER');
    }

    // Map Config
    @AuraEnabled
    public static String getMapStreetTileURL() {
      return arcshared.AppConfigSupport.getSingleValue('DSHFeatureConfig', 'DSH_MAP_STREET_TILE_URL');
    }

    @AuraEnabled
    public static String getMapStreetTileCredit() {
      return arcshared.AppConfigSupport.getSingleValue('DSHFeatureConfig', 'DSH_MAP_STREET_TILE_CREDIT');
    }

    //Password Reset config
    public static String getPasswordResetOption()
    {
      return arcshared.AppConfigSupport.getSingleValue('DSHFeatureConfig', 'DSH_PASSWORD_RESET_OPTION');
    }

    // Release version Config
    public static String getReleaseVersionLCCommon()
    {
      return arcshared.AppConfigSupport.getSingleValue('DSHFeatureConfig', 'DSH_RELEASE_VERSION_LC_COMMON');
    }

    public static String getReleaseVersionLCRevBen()
    {
      return arcshared.AppConfigSupport.getSingleValue('DSHFeatureConfig', 'DSH_RELEASE_VERSION_LC_REVBEN');
    }

    public static String getReleaseVersionLCClient()
    {
      return arcshared.AppConfigSupport.getSingleValue('DSHFeatureConfig', 'DSH_RELEASE_VERSION_LC_CLIENT');
    }

    public static String getReleaseVersionVFClient()
    {
      return arcshared.AppConfigSupport.getSingleValue('DSHFeatureConfig', 'DSH_RELEASE_VERSION_VF_CLIENT');
    }


    // Council Config
    public static String getCouncilAreaName()
    {
      return arcshared.AppConfigSupport.getSingleValue('DSHFeatureConfig', 'DSH_COUNCIL_AREA_NAME');
    }

    public static String getCouncilLongName()
    {
      return arcshared.AppConfigSupport.getSingleValue('DSHFeatureConfig', 'DSH_COUNCIL_LONG_NAME');
    }

    public static String getCouncilShortName()
    {
      return arcshared.AppConfigSupport.getSingleValue('DSHFeatureConfig', 'DSH_COUNCIL_SHORT_NAME');
    }

    public static String getCouncilCMSWebsiteURL()
    {
      return arcshared.AppConfigSupport.getSingleValue('DSHFeatureConfig', 'DSH_COUNCIL_CMS_WEBSITE_URL');
    }

    public static String getCouncilDSHWebsiteURL()
    {
      return arcshared.AppConfigSupport.getSingleValue('DSHFeatureConfig', 'DSH_COUNCIL_DSH_WEBSITE_URL');
    }

    public static String getCouncilCustomerServiceEmail()
    {
      return arcshared.AppConfigSupport.getSingleValue('DSHFeatureConfig', 'DSH_COUNCIL_CUSTOMER_SERVICE_EMAIL');
    }

    public static String getCouncilTermsAndConditionsURL()
    {
      return arcshared.AppConfigSupport.getSingleValue('DSHFeatureConfig', 'DSH_COUNCIL_TERMS_AND_CONDITIONS_URL');
    }

    public static String getCouncilPrivacyPolicyURL()
    {
      return arcshared.AppConfigSupport.getSingleValue('DSHFeatureConfig', 'DSH_COUNCIL_PRIVACY_POLICY_URL');
    }

    @AuraEnabled
    public static String getCouncilHQLocation()
    {
      return arcshared.AppConfigSupport.getSingleValue('DSHFeatureConfig', 'DSH_COUNCIL_HQ_LOCATION');
    }
}