@isTest
private class DSHLC_ConfigSettingsFlowUtility_Test {

	private static testMethod void get_config_value_for_council_custom_service_email() {
		arcshared__App_Config__c setting = new arcshared__App_Config__c();
		setting.Name = 'Test setting';
		setting.arcshared__Available__c = true;
		setting.arcshared__Category__c = 'DSHFeatureConfig';
		setting.arcshared__Key__c = 'DSH_COUNCIL_CUSTOMER_SERVICE_EMAIL';
		setting.arcshared__Value__c = 'test.email@test.SH_ConfigSettingsFlowUtility.com';
		insert setting;

		List<String> result = DSHLC_ConfigSettingsFlowUtility.getConfigValue();

		System.assertEquals(1, result.size());
		System.assertEquals('test.email@test.SH_ConfigSettingsFlowUtility.com', result.get(0));
	}
	
}