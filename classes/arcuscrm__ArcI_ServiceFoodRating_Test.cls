@isTest
public with sharing class ArcI_ServiceFoodRating_Test
{
    @isTest
    static void getMyAreaBinsAndCtaxDataTest_success()
    {
        //Arrange
		arcuscrm.ArcI_ConnFoodRatingMain_Mock foodRatingsRespMock = new arcuscrm.ArcI_ConnFoodRatingMain_Mock();
		foodRatingsRespMock.setAsTestMock();

        arcuscrm.ArcI_DataFoodRating pData = new arcuscrm.ArcI_DataFoodRating();
        pData.foodRatingRegNumber = arcuscrm.ArcI_ConnFoodRatingMain_Mock.REGISTERED_FOOD_BUSINESS_NUMBER;
        
        //Act
        arcuscrm.ArcI_ServiceFoodRating.getFoodBusinessRatings(pData);

        //Assert
        System.assertEquals(true, pData.isSuccess);

        System.assertNotEquals(null, pData.FoodRatingData.geocode);//"geocode":{"longitude":"0.125982","latitude":"52.201027"}
        System.assert(String.isNotEmpty(pData.FoodRatingData.geocode.latitude));
        System.assert(String.isNotEmpty(pData.FoodRatingData.geocode.longitude));

        System.assertNotEquals(null, pData.FoodRatingData.scores);//"scores":{"Hygiene":0,"Structural":0,"ConfidenceInManagement":0}
        System.assert(String.isNotEmpty(pData.FoodRatingData.scores.Hygiene));
        System.assert(String.isNotEmpty(pData.FoodRatingData.scores.Structural));
        System.assert(String.isNotEmpty(pData.FoodRatingData.scores.ConfidenceInManagement));


        System.assert(String.isNotEmpty(pData.FoodRatingData.FHRSID));//": 506429,
        System.assertEquals(arcuscrm.ArcI_ConnFoodRatingMain_Mock.REGISTERED_FOOD_BUSINESS_NUMBER, pData.FoodRatingData.FHRSID);//": 506429,
        System.assert(String.isNotEmpty(pData.FoodRatingData.LocalAuthorityBusinessID));//": "PI/000019610",
        System.assert(String.isNotEmpty(pData.FoodRatingData.BusinessName));//": "City Kebab",
        System.assert(String.isNotEmpty(pData.FoodRatingData.BusinessType));//": "Takeaway/sandwich shop",
        System.assert(String.isNotEmpty(pData.FoodRatingData.BusinessTypeID));//": 7844,
        System.assert(String.isNotEmpty(pData.FoodRatingData.AddressLine1));//": "73 Regent Street",
        System.assert(String.isNotEmpty(pData.FoodRatingData.AddressLine2));//": "Cambridge",
        System.assert(String.isNotEmpty(pData.FoodRatingData.AddressLine3));//": "Cambridgeshire",
        System.assert(String.isEmpty(pData.FoodRatingData.AddressLine4));//": "",
        System.assert(String.isNotEmpty(pData.FoodRatingData.PostCode));//": "CB2 1AB",
        System.assert(String.isEmpty(pData.FoodRatingData.Phone));//": "",
        System.assert(String.isNotEmpty(pData.FoodRatingData.RatingValue));//": "5",
        System.assert(String.isNotEmpty(pData.FoodRatingData.RatingKey));//": "fhrs_5_en-gb",
        System.assert(String.isNotEmpty(pData.FoodRatingData.RatingDate));//": "2019-03-19",
        System.assert(String.isNotEmpty(pData.FoodRatingData.LocalAuthorityCode));//": "027",
        System.assert(String.isNotEmpty(pData.FoodRatingData.LocalAuthorityName));//": "Cambridge City",
        System.assert(String.isNotEmpty(pData.FoodRatingData.LocalAuthorityWebSite));//": "http://www.cambridge.gov.uk",
        System.assert(String.isNotEmpty(pData.FoodRatingData.LocalAuthorityEmailAddress));//": "env.health@cambridge.gov.uk",
        System.assert(String.isNotEmpty(pData.FoodRatingData.SchemeType));//": "FHRS",
        System.assert(String.isEmpty(pData.FoodRatingData.RightToReply));//": "",
        System.assert(String.isEmpty(pData.FoodRatingData.Distance));//": null,

        System.assertEquals(false, pData.FoodRatingData.NewRatingPending); //"NewRatingPending":false

        System.assert(pDAta.FoodRatingData.links.size() > 0);
    }

    @isTest
    static void getMyAreaBinsAndCtaxDataTest_fail_invalidReqData()
    {
        //Arrange
		arcuscrm.ArcI_ConnFoodRatingMain_Mock foodRatingsRespMock = new arcuscrm.ArcI_ConnFoodRatingMain_Mock();
		foodRatingsRespMock.setAsTestMock();

        arcuscrm.ArcI_DataFoodRating pData = new arcuscrm.ArcI_DataFoodRating();
        pData.foodRatingRegNumber = '';
        
        //Act
        arcuscrm.ArcI_ServiceFoodRating.getFoodBusinessRatings(pData);

        //Assert
        System.assertEquals(false, pData.isSuccess);
        System.assertEquals('FHRS Number is required', pData.errorMessage);
    }
}