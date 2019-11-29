/*
Company : Arcus Global
Product : Arcus Integration Architecture
Purpose : Config settings manager for arcus-crm package integrations
Notes :
 */
global with sharing class ArcI_UtilityConfigSettings
{
    /************************** START Charity Commision Settings***********************************************************************************/
    //keys & passwords
    public static final String CHARITY_COMMS_API_KEY = arcshared.AppConfigSupport.getSingleValue('Charity Commissions', 'CHARITY_COMMS_API_KEY');
    //named credentials
    public static final String CALL_OUT_CHARITY_COMMISSIONS_WEBSERVICES_ENDPOINT_NAMEDCREDS = 'CharityCommissions';//test and prod are same url atm
    // public static final String CALL_OUT_CHARITY_COMMISSIONS_WEBSERVICES_ENDPOINT_NAMEDCREDS_LIVE = 'Charity_Commissions_Live';
    /************************** END Charity Commision Settings**************************************************************************************/

    /************************** START Capita (Portal) SSO Settings*****************************************/
    //passwords
    public static final String CALL_OUT_CAPITA_PORTAL_WEB_SERVICE_PASSWORD_TEST = '';
    public static final String CALL_OUT_CAPITA_PORTAL_WEB_SERVICE_PASSWORD_LIVE = '';
    //named credentials
    public static final String CALL_OUT_CAPITA_PORTAL_WEB_SERVICE_NAMEDCREDS_TEST = 'CapitaRevBen_Test';    
    public static final String CALL_OUT_CAPITA_PORTAL_WEB_SERVICE_NAMEDCREDS_LIVE = 'CapitaRevBen';
    /************************** END Capita (Portal) SSO Settings*********************************************/

    //------------------------------------------------------------------------------------------------------------------------------------------------------

    /************************** START Food Rating Settings*************************************************/
    //named credentials
    public static final String CALL_OUT_FOOD_RATING_WEBSERVICES_ENDPOINT_NAMEDCREDS = 'FoodRating'; //test and prod are same url atm
    // public static final String CALL_OUT_FOOD_RATING_WEBSERVICES_ENDPOINT_NAMEDCREDS_LIVE = 'FoodRating_Live';
    /************************** END Food Rating Settings******************************************************************/

    //------------------------------------------------------------------------------------------------------------------------------------------------------

    /************************** START Companies House Settings************************************************************************************/
    //keys & passwords
    public static final String COMPANIES_HOUSE_API_KEY = arcshared.AppConfigSupport.getSingleValue('Companies House', 'COMPANIES_HOUSE_API_KEY');
    //named credentials
    public static final String CALL_OUT_COMPANIES_HOUSE_WEBSERVICES_ENDPOINT_NAMEDCREDS = 'CompaniesHouse'; //test and prod are same url atm
    // public static final String CALL_OUT_COMPANIES_HOUSE_WEBSERVICES_ENDPOINT_NAMEDCREDS_LIVE = 'CompaniesHouse_Live';
    /************************** END Companies House Settings**************************************************************************************/


	global static void insertCustomSettings()
	{
        Map<String, List<arcshared.AppConfigSupport.setting>> categoryToSettingsMap = new Map<String, List<arcshared.AppConfigSupport.setting>>();

        /********* Charity Commissions settings**********/
        List<arcshared.AppConfigSupport.setting> charitySettings = new List<arcshared.AppConfigSupport.setting>();
        charitySettings.add(new arcshared.AppConfigSupport.setting('CHARITY_COMMS_API_KEY', 'String', '', '', 1, true, true));
        //
        categoryToSettingsMap.put('Charity Commissions', charitySettings);

        /********* Companies House settings**********/
        List<arcshared.AppConfigSupport.setting> compHouseSettings = new List<arcshared.AppConfigSupport.setting>();
        compHouseSettings.add(new arcshared.AppConfigSupport.setting('COMPANIES_HOUSE_API_KEY', 'String', '', '', 1, true, true));
        //
        categoryToSettingsMap.put('Companies House', compHouseSettings);


        //insert all seettings
        arcshared.AppConfigSupport.setCategoryRecords(categoryToSettingsMap, 'arcuscrm');
	}
}