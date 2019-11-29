/*
Company : Arcus Global
Product : Arcus Integration Architecture
Purpose : Single point utility class used for retrieving credentials and endpoints of various webservice integrations which form the integrations unlocked package
Notes :
 */
public class ArcI_UtilityCreds 
{	
	public static String getNamedCredentialsName(String integrationName)
	{
		String theNamedCred;
		if(integrationName == 'modGov')
		{
			//if sandbox get test named credentials : else get the live named credentials
			theNamedCred = IsSandbox() ? ArcI_UtilityConfigSettings.CALL_OUT_MODGOV_WEBSERVICES_ENDPOINT_NAMEDCREDS_TEST : ArcI_UtilityConfigSettings.CALL_OUT_MODGOV_WEBSERVICES_ENDPOINT_NAMEDCREDS_LIVE;
		}
        // else if(){}

		return theNamedCred;
	}

	private static Boolean isSandbox()
	{
		//check if sandbox
		return [SELECT IsSandbox FROM Organization].IsSandbox;
	}
}