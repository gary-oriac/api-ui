/*
Company : Arcus Global
Product : Arcus Integration Architecture
Purpose : Single point utility class used for retrieving credentials of various arcus-crm webservice integrations
Notes :
 */
public class ArcI_UtilityCreds 
{	
	public static String getNamedCredentials(String integrationName)
	{
		String theNamedCred;
		if(integrationName == 'charityCommission')
		{
			theNamedCred = arcuscrm.ArcI_UtilityConfigSettings.CALL_OUT_CHARITY_COMMISSIONS_WEBSERVICES_ENDPOINT_NAMEDCREDS;
			//if sandbox get test named credentials : else get the live named credentials
			// theNamedCred = IsSandbox() ? arcuscrm.ArcI_UtilityConfigSettings.CALL_OUT_CHARITY_COMMISSIONS_WEBSERVICES_ENDPOINT_NAMEDCREDS_TEST : arcuscrm.ArcI_UtilityConfigSettings.CALL_OUT_CHARITY_COMMISSIONS_WEBSERVICES_ENDPOINT_NAMEDCREDS_LIVE;
		}
		else if(integrationName == 'foodRating')
		{
			theNamedCred = arcuscrm.ArcI_UtilityConfigSettings.CALL_OUT_FOOD_RATING_WEBSERVICES_ENDPOINT_NAMEDCREDS;
			//if sandbox get test named credentials : else get the live named credentials
			// theNamedCred = IsSandbox() ? arcuscrm.ArcI_UtilityConfigSettings.CALL_OUT_FOOD_RATING_WEBSERVICES_ENDPOINT_NAMEDCREDS_TEST : arcuscrm.ArcI_UtilityConfigSettings.CALL_OUT_FOOD_RATING_WEBSERVICES_ENDPOINT_NAMEDCREDS_LIVE;
		}
		else if(integrationName == 'companiesHouse')
		{
			theNamedCred = arcuscrm.ArcI_UtilityConfigSettings.CALL_OUT_COMPANIES_HOUSE_WEBSERVICES_ENDPOINT_NAMEDCREDS;
			//if sandbox get test named credentials : else get the live named credentials
			// theNamedCred = IsSandbox() ? arcuscrm.ArcI_UtilityConfigSettings.CALL_OUT_COMPANIES_HOUSE_WEBSERVICES_ENDPOINT_NAMEDCREDS_TEST : arcuscrm.ArcI_UtilityConfigSettings.CALL_OUT_COMPANIES_HOUSE_WEBSERVICES_ENDPOINT_NAMEDCREDS_LIVE;
		}
		else if(integrationName == 'capitaAD')
		{
			//if sandbox get test named credentials : else get the live named credentials
			theNamedCred = IsSandbox() ? arcuscrm.ArcI_UtilityConfigSettings.CALL_OUT_CAPITA_PORTAL_WEB_SERVICE_NAMEDCREDS_TEST : arcuscrm.ArcI_UtilityConfigSettings.CALL_OUT_CAPITA_PORTAL_WEB_SERVICE_NAMEDCREDS_LIVE;
		}
		//else if(integrationName == /*replace with another intgration name*/)
		//{
			//get creds for that integration		
		//}

		return theNamedCred;
	}

	public static String getAPIPass(String integrationName)
	{
		String thePass;
		if(integrationName == 'capitaAD')
		{
			//if sandbox get test password for the API integr., else, get production password for the API integr.
			thePass = isSandbox() ? arcuscrm.ArcI_UtilityConfigSettings.CALL_OUT_CAPITA_PORTAL_WEB_SERVICE_PASSWORD_TEST : arcuscrm.ArcI_UtilityConfigSettings.CALL_OUT_CAPITA_PORTAL_WEB_SERVICE_PASSWORD_LIVE;
		}
		//else if(integrationName == /*replace with another intgration name*/)
		//{
			//get password for that integration		
		//}
		return thePass;
	}
	
	
	private static Boolean isSandbox()
	{
		//check if sandbox
		return [SELECT IsSandbox FROM Organization].IsSandbox;
	}
}