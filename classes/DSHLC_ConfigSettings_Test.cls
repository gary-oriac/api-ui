/*
Company    :    Arcus Global
Product    :    Arcus DSH
Purpose    :    Tests ConfigSettings class
Notes      :     
*/
@isTest
private with sharing class DSHLC_ConfigSettings_Test {

    @testSetup
    private static void setup() {
        List<arcshared.AppConfigSupport.setting> dshFeatureConfigSettings = new List<arcshared.AppConfigSupport.setting>();
        Map<String, List<arcshared.AppConfigSupport.setting>> categoryToSettingsMap = new Map<String, List<arcshared.AppConfigSupport.setting>>();
        dshFeatureConfigSettings.add(new arcshared.AppConfigSupport.setting('SETTING_1_STRING', 'String', 'Setting 1', 'Setting 1', 10000, true, true));
        dshFeatureConfigSettings.add(new arcshared.AppConfigSupport.setting('SETTING_2_INTEGER', 'Integer', '15', '15', 10000, true, true));
        dshFeatureConfigSettings.add(new arcshared.AppConfigSupport.setting('SETTING_3_BOOLEAN', 'Boolean', 'true', 'true', 10000, true, true));
        categoryToSettingsMap.put('DSHFeatureConfig',  dshFeatureConfigSettings);
        arcshared.AppConfigSupport.setCategoryRecords(categoryToSettingsMap, 'arcusdsh');
    }

    @isTest
    private static void test_Location() {
        Test.startTest();

        DSHLC_ConfigSettings cs = new DSHLC_ConfigSettings();

        // Misc
        DSHLC_ConfigSettings.getPossessiveDeterminer();

        // Map
        DSHLC_ConfigSettings.getMapStreetTileURL();
        DSHLC_ConfigSettings.getMapStreetTileCredit();

        // Version release
        DSHLC_ConfigSettings.getReleaseVersionLCCommon();
        DSHLC_ConfigSettings.getReleaseVersionLCRevBen();
        DSHLC_ConfigSettings.getReleaseVersionLCClient();
        DSHLC_ConfigSettings.getReleaseVersionVFClient();

        // Council
        DSHLC_ConfigSettings.getCouncilAreaName();
        DSHLC_ConfigSettings.getCouncilLongName();
        DSHLC_ConfigSettings.getCouncilShortName();
        DSHLC_ConfigSettings.getCouncilCMSWebsiteURL();
        DSHLC_ConfigSettings.getCouncilDSHWebsiteURL();
        DSHLC_ConfigSettings.getCouncilCustomerServiceEmail();
        DSHLC_ConfigSettings.getCouncilTermsAndConditionsURL();
        DSHLC_ConfigSettings.getCouncilPrivacyPolicyURL();
        DSHLC_ConfigSettings.getCouncilHQLocation();

        //Password Reset config
        DSHLC_ConfigSettings.getPasswordResetOption();

        Test.stopTest();

        System.assertNotEquals(null, cs, 'DSHLC_ConfigSettings object');
    }

    @isTest
    private static void testGetConfigSettingByKey() {
        String key = 'SETTING_1_STRING';

        Test.startTest();
        String result = DSHLC_ConfigSettings.getConfigSetting(key);
        Test.stopTest();

        System.assertEquals('Setting 1', result, 'Wrong value of config setting returned, it should be the value of setting with key SETTING_1_STRING');
    }

    @isTest
    private static void testGetConfigSettingIntegerByKey() {
        String key = 'SETTING_2_INTEGER';

        Test.startTest();
        Integer result = DSHLC_ConfigSettings.getConfigSettingInteger(key);
        Test.stopTest();

        System.assertEquals(15, result, 'Wrong value of config setting returned, it should be the value of setting with key SETTING_2_INTEGER');
    }

    @isTest
    private static void testGetConfigSettingIntegerForNonExistSetting() {
        String key = 'SETTING_?';

        Test.startTest();
        Integer result = DSHLC_ConfigSettings.getConfigSettingInteger(key);
        Test.stopTest();

        System.assertEquals(null, result, 'Wrong value returned, it should be null since there is no setting with the key SETTING_?');
    }

    @isTest
    private static void testGetConfigSettingBooleanByKey() {
        String key = 'SETTING_3_BOOLEAN';

        Test.startTest();
        Boolean result = DSHLC_ConfigSettings.getConfigSettingBoolean(key);
        Test.stopTest();

        System.assert(result, 'Wrong value of config setting returned, it should be the value of setting with key SETTING_3_BOOLEAN');
    }

    @isTest
    private static void testGetConfigSettingBooleanForNonExistSetting() {
        String key = 'SETTING_?';

        Test.startTest();
        Boolean result = DSHLC_ConfigSettings.getConfigSettingBoolean(key);
        Test.stopTest();

        System.assertEquals(null, result, 'null should be returned since there is no setting with key SETTING_?');
    }
}