public with sharing class ArcI_ConnFoodRatingMain_Mock  extends arcshared.ArcI_ConnMain_Mock
{
	public static final String REGISTERED_FOOD_BUSINESS_NUMBER = '506429';

    public override String getResponseBody(ResponseType pResponseType)
    {
        return '{"FHRSID":'+REGISTERED_FOOD_BUSINESS_NUMBER+',"LocalAuthorityBusinessID":"PI/000019610","BusinessName":"City Kebab","BusinessType":"Takeaway/sandwich shop","BusinessTypeID":7844,"AddressLine1":"73 Regent Street","AddressLine2":"Cambridge","AddressLine3":"Cambridgeshire","AddressLine4":"","PostCode":"CB2 1AB","Phone":"","RatingValue":"5","RatingKey":"fhrs_5_en-gb","RatingDate":"2019-03-19T00:00:00","LocalAuthorityCode":"027","LocalAuthorityName":"Cambridge City","LocalAuthorityWebSite":"http://www.cambridge.gov.uk","LocalAuthorityEmailAddress":"env.health@cambridge.gov.uk","scores":{"Hygiene":0,"Structural":0,"ConfidenceInManagement":0},"SchemeType":"FHRS","geocode":{"longitude":"0.125982","latitude":"52.201027"},"RightToReply":"","Distance":null,"NewRatingPending":false,"meta":{"dataSource":"Lucene","extractDate":"0001-01-01T00:00:00","itemCount":0,"returncode":"OK","totalCount":1,"totalPages":1,"pageSize":1,"pageNumber":1},"links":[{"rel":"self","href":"http://api.ratings.food.gov.uk/establishments/506429"}]}';
    }
}