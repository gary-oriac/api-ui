public with sharing class ArcI_ConnCompaniesHouse_Officers_Mock extends arcshared.ArcI_ConnMain_Mock
{
	public static final String REGISTERED_COMPANY_NUMBER = '88888888';

    public override String getResponseBody(ResponseType pResponseType)
    {
        return '{"active_count":5,"items_per_page":35,"etag":"312d221f0492ccaecdcacd50383625928a06ef5f","start_index":0,"items":[{"officer_role":"director","nationality":"Italian","occupation":"Company Director","links":{"officer":{"appointments":"/officers/ITyTpq1LZ-FgucPLh6Lbsc2sDeg/appointments"}},"address":{"premises":"Future Business Centre","region":"Cambridgeshire","postal_code":"CB4 2HY","locality":"Cambridge","address_line_1":"Kings Hedges Road","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","address_line_5":"line5","country":"United Kingdom"},"name":"DOE, John","resigned_on":"2019-08-28","appointed_on":"2009-06-29","country_of_residence":"England","date_of_birth":{"year":1981,"month":2}}],"inactive_count":0,"resigned_count":1,"kind":"officer-list","total_results":1,"links":{"self":"/company/'+REGISTERED_COMPANY_NUMBER+'/officers"}}';
    }
}