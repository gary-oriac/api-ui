public with sharing class ArcI_DataFoodRating extends arcshared.ArcI_DataMain 
{
	//reqest
    @AuraEnabled
	public String foodRatingRegNumber;

	//response
    public FoodRatingData FoodRatingData;

	//data validation
	public override Boolean validate()
	{
		if(String.isNotBlank(foodRatingRegNumber))
		{
			return true;
		}
        else 
        {
            processError(arcshared.ArcI_UtilityErrorManager.ERR_COD_SPECIFIC, 'FHRS Number is required');
            return false;
        }
	}


    public class FoodRatingData
    {
        @AuraEnabled
        public String FHRSID;//": 506429,
        public String LocalAuthorityBusinessID;//": "PI/000019610",
        public String BusinessName;//": "City Kebab",
        public String BusinessType;//": "Takeaway/sandwich shop",
        public String BusinessTypeID;//": 7844,
        public String AddressLine1;//": "73 Regent Street",
        public String AddressLine2;//": "Cambridge",
        public String AddressLine3;//": "Cambridgeshire",
        public String AddressLine4;//": "",
        public String PostCode;//": "CB2 1AB",
        public String Phone;//": "",
        public String RatingValue;//": "5",
        public String RatingKey;//": "fhrs_5_en-gb",
        public String RatingDate {
            get;
            set { RatingDate = value.replace('T00:00:00', ''); }
        }//": "2019-03-19T00:00:00",
        public String LocalAuthorityCode;//": "027",
        public String LocalAuthorityName;//": "Cambridge City",
        public String LocalAuthorityWebSite;//": "http://www.cambridge.gov.uk",
        public String LocalAuthorityEmailAddress;//": "env.health@cambridge.gov.uk",
        public Scores scores;
        public String SchemeType;//": "FHRS",
        public String RightToReply;//": "",
        public String Distance;//": null,
        public Boolean NewRatingPending;//": false,
        public List<WebsiteLink> links;//": [{
        public Geoloc geocode;
    }


	public class WebsiteLink
	{
		public String rel;
		public String href;
	}

	public class Scores
	{
		public String Hygiene;
		public String Structural;
		public String ConfidenceInManagement;
	}

	public class Geoloc
	{
       public String longitude;	// "0.125982",
       public String latitude; // "52.201027"
	}

}