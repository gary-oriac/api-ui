public with sharing class CRM_FoodRatingInfo
{
    @AuraEnabled(continuation=true cacheable=true)
    public static String getFoodRatingInfo(String foodRatingNumber)
    {
        //System.debug('<CRM_FoodRatingInfo.getFoodRatingInfo(foodRatingNumber)> foodRatingNumber >>> ' + foodRatingNumber);
        arcuscrm.ArcI_DataFoodRating pData = new arcuscrm.ArcI_DataFoodRating();
        pData.foodRatingRegNumber = foodRatingNumber;

        // System.debug('<CRM_FoodRatingInfo.getFoodRatingInfo(foodRatingNumber)> pData >>> ' + pData);
        //call the api
        return arcuscrm.ArcI_ServiceFoodRating.getFoodBusinessRatings(pData);
    }
}