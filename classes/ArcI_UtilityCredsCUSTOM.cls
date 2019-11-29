/*
Company : Arcus Global
Product : Arcus Integration Architecture
Purpose : Single point utility class used for retrieving credentials of various webservice integrations
Notes :
 */
public class ArcI_UtilityCredsCUSTOM 
{   
    public static String getNamedCredentialsName(String integrationName)
    {
        String theNamedCred;
        if(integrationName == 'fhdcMyArea')
        {
            theNamedCred = IsSandbox() ? ArcI_UtilityConfigCUSTOM.MY_AREA_API_ENDPOINT_NAMEDCREDS_TEST : ArcI_UtilityConfigCUSTOM.MY_AREA_API_ENDPOINT_NAMEDCREDS_LIVE;
        }
        //else if()
        //{

        //}

        return theNamedCred;
    }
    
    
    private static Boolean isSandbox()
    {
        //check if sandbox
        return [SELECT IsSandbox FROM Organization].IsSandbox;
    }
}