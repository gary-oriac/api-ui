@isTest
public with sharing class CRM_FoodRatingInfo_Test
{
    @testSetup static void setup()
    {
        //create test acc with char number populated
        Account myAcc = new Account(Name='Arcus Global', arcuscrm__FHRS_Number__c = arcuscrm.ArcI_ConnFoodRatingMain_Mock.REGISTERED_FOOD_BUSINESS_NUMBER);
        insert myAcc;
    }
    
    @isTest static void testGetFoodRatingInfo_success()
    {     
        
        arcuscrm.ArcI_ConnFoodRatingMain_Mock foodRatingsRespMock = new arcuscrm.ArcI_ConnFoodRatingMain_Mock();
		foodRatingsRespMock.setAsTestMock();

        Account acc = [SELECT Id, arcuscrm__FHRS_Number__c FROM Account WHERE Name = 'Arcus Global' Limit 1];
        System.assertNotEquals(null, acc.Id);
        System.assert(String.isNotEmpty(acc.arcuscrm__FHRS_Number__c));

        Test.startTest();
        arcuscrm.ArcI_DataFoodRating respData = (arcuscrm.ArcI_DataFoodRating)JSON.deserialize(CRM_FoodRatingInfo.getFoodRatingInfo(acc.arcuscrm__FHRS_Number__c), arcuscrm.ArcI_DataFoodRating.class);
        Test.stopTest();
        
        System.assertNotEquals(null, respData, 'arcuscrm.CRM_CharityInfo.getCharityInfo() method should return a valid JSON data');
        System.assertEquals(true, respData.isSuccess);
        System.assertNotEquals(null, respData.FoodRatingData);
        System.assertEquals(arcuscrm.ArcI_ConnFoodRatingMain_Mock.REGISTERED_FOOD_BUSINESS_NUMBER, respData.FoodRatingData.FHRSID);

    }

    @isTest static void testGetFoodRatingInfo_fail_invlaidInputData()
    {     
        Test.startTest();
        arcuscrm.ArcI_DataFoodRating respData = (arcuscrm.ArcI_DataFoodRating)JSON.deserialize(CRM_FoodRatingInfo.getFoodRatingInfo(null), arcuscrm.ArcI_DataFoodRating.class);
        Test.stopTest();
        
        System.assertNotEquals(null, respData, 'arcuscrm.CRM_CharityInfo.getCharityInfo() method should return a valid JSON data');
        System.assertEquals(false, respData.isSuccess);
        System.assertEquals(null, respData.FoodRatingData);       
    }
    
}