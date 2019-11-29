public with sharing class DSHLC_ConfigSettingsFlowUtility
{	
	@InvocableMethod
	public static List<String> getConfigValue()
	{
		List<String> listOfConfigSettings = new List<String>();

		String config = DSHLC_ConfigSettings.getCouncilCustomerServiceEmail();

		listOfConfigSettings.add(config);

		return listOfConfigSettings;
	}
}