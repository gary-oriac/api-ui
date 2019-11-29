/*
Author     :    James Yu
Company    :    Arcus Global
Product    :    Arcus DSHLC
Date       :    15/11/17
Purpose    :    Test class for DSHLC_ConfigSettingsInstall
Modified   :    
*/
@isTest
private class DSHLC_ConfigSettingsInstall_Test {

	@isTest
	private static void testConfigSettingsAreInserted() {
		Test.startTest();
		DSHLC_ConfigSettingsInstall.insertAllSettings();
		Test.stopTest();

		Map<String, arcshared__App_Config__c> settings = getConfigSettings();

		System.assertEquals(17, settings.size(), 'The total number of settings inserted is incorrect');
		System.assert(settings.containsKey('DSH_MISC_POSSESSIVE_DETERMINER'), 'The custom setting with the corresponding key is not inserted');

		System.assert(settings.containsKey('DSH_PASSWORD_RESET_OPTION'), 'The custom setting with the corresponding key is not inserted');

		System.assert(settings.containsKey('DSH_MAP_STREET_TILE_URL'), 'The custom setting with the corresponding key is not inserted');
		System.assert(settings.containsKey('DSH_MAP_STREET_TILE_CREDIT'), 'The custom setting with the corresponding key is not inserted');

		System.assert(settings.containsKey('DSH_RELEASE_VERSION_LC_COMMON'), 'The custom setting with the corresponding key is not inserted');
		System.assert(settings.containsKey('DSH_RELEASE_VERSION_LC_REVBEN'), 'The custom setting with the corresponding key is not inserted');
		System.assert(settings.containsKey('DSH_RELEASE_VERSION_LC_CLIENT'), 'The custom setting with the corresponding key is not inserted');
		System.assert(settings.containsKey('DSH_RELEASE_VERSION_VF_CLIENT'), 'The custom setting with the corresponding key is not inserted');

		System.assert(settings.containsKey('DSH_COUNCIL_AREA_NAME'), 'The custom setting with the corresponding key is not inserted');
		System.assert(settings.containsKey('DSH_COUNCIL_LONG_NAME'), 'The custom setting with the corresponding key is not inserted');
		System.assert(settings.containsKey('DSH_COUNCIL_SHORT_NAME'), 'The custom setting with the corresponding key is not inserted');
		System.assert(settings.containsKey('DSH_COUNCIL_CMS_WEBSITE_URL'), 'The custom setting with the corresponding key is not inserted');
		System.assert(settings.containsKey('DSH_COUNCIL_DSH_WEBSITE_URL'), 'The custom setting with the corresponding key is not inserted');
		System.assert(settings.containsKey('DSH_COUNCIL_CUSTOMER_SERVICE_EMAIL'), 'The custom setting with the corresponding key is not inserted');
		System.assert(settings.containsKey('DSH_COUNCIL_TERMS_AND_CONDITIONS_URL'), 'The custom setting with the corresponding key is not inserted');
		System.assert(settings.containsKey('DSH_COUNCIL_PRIVACY_POLICY_URL'), 'The custom setting with the corresponding key is not inserted');
		System.assert(settings.containsKey('DSH_COUNCIL_HQ_LOCATION'), 'The custom setting with the corresponding key is not inserted');
	}

	@isTest
	private static void testTriggerSettingsAllInserted() {
		Test.startTest();
		DSHLC_ConfigSettingsInstall.insertAllSettings();
		Test.stopTest();

		Map<String, arcshared__App_Config__c> settings = getTriggerSettings();

		System.assertEquals(1, settings.size(), 'The total number of trigger settings inserted is incorrect');
		System.assert(settings.containsKey('DSH_CONTACT_TRIGGER_HANDLER'), 'The trigger setting with the corresponding key is not inserted');
	}

	// ****************** Helper Methods ******************
	private static Map<String, arcshared__App_Config__c> getConfigSettings() {
		Map<String, arcshared__App_Config__c> settingMap = new Map<String, arcshared__App_Config__c>();

		List<arcshared__App_Config__c> settingList = [
			SELECT  arcshared__Key__c, arcshared__Default_Value__c, arcshared__Value__c, arcshared__Type__c
			FROM arcshared__App_Config__c
			WHERE arcshared__Category__c = 'DSHFeatureConfig' AND arcshared__Product__c = 'arcusdsh'
			LIMIT 2000
		];

		for (arcshared__App_Config__c setting : settingList) {
			settingMap.put(setting.arcshared__Key__c, setting);
		}

		return settingMap;
	}

	private static Map<String, arcshared__App_Config__c> getTriggerSettings() {
		Map<String, arcshared__App_Config__c> settingMap = new Map<String, arcshared__App_Config__c>();

		List<arcshared__App_Config__c> settingList = [
			SELECT  arcshared__Key__c, arcshared__Default_Value__c, arcshared__Value__c, arcshared__Type__c
			FROM arcshared__App_Config__c
			WHERE arcshared__Category__c = 'TriggerHandlers' AND arcshared__Product__c = 'arcusdsh'
			LIMIT 2000
		];

		for (arcshared__App_Config__c setting : settingList) {
			settingMap.put(setting.arcshared__Key__c, setting);
		}

		return settingMap;
	}
}