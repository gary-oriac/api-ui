public with sharing class ArcI_ServiceFoodRating
{
    public static String getFoodBusinessRatings(arcuscrm.ArcI_DataFoodRating pData)
	{
		try
		{
			if(pData.validate())
			{
				System.debug('<ArcI_ServiceFoodRating.getFoodBusinessRatings()> we are good to call the external ws');

				new arcuscrm.ArcI_ConnFoodRatingMain().invoke(pData);
			}

			System.debug('<ArcI_ServiceFoodRating.getFoodBusinessRatings()> pData: ' + JSON.serialize(pData));
		}
		catch(Exception ex) {arcshared.ArcI_UtilityErrorManager.processErrorSpecificMessage('Something went wrong...', pData);}
		// {
		// 	//log the ex errors
		// 	System.debug('<ARCUS - ArcI_ServiceFoodRating.getFoodBusinessRatings()> error: ' + ex.getMessage());
		// 	System.debug('<ARCUS - ArcI_ServiceFoodRating.getFoodBusinessRatings()> error LineNumber: ' + ex.getLineNumber());
		// 	System.debug('<ARCUS - ArcI_ServiceFoodRating.getFoodBusinessRatings()> error cause: ' + ex.getCause());
		// 	System.debug('<ARCUS - ArcI_ServiceFoodRating.getFoodBusinessRatings()> error stack trace: ' + ex.getStackTraceString());
		// }
		return JSON.serialize(pData);
	}
}