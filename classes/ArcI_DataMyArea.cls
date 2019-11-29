public class ArcI_DataMyArea extends arcshared.ArcI_DataMain 
{
	//data out
	public String uprn;
	// public String key;

    //data in
    public MyAreaData MyAreaData;

    public class MyAreaData
    {
        public Boolean Success;
        public Boolean HasCouncilTax;
        public Boolean HasRecyclingCollection;
        public Boolean HasRefuseCollection;
        public Boolean HasGardenCollection;
        public CouncilTax CouncilTax;
        public Collection RecyclingCollection;
        public Collection RefuseCollection;
        public Collection GardenCollection;
    }


	//data validation
	public override Boolean validate()
	{
        System.debug('<ARCUS - ArcI_DataMyArea> starting validation...');
		Boolean result = (String.isNotBlank(uprn)) /*&& String.isNotBlank(key))*/ ? true : false;
        System.debug('<ARCUS - ArcI_DataMyArea> Is input data valid: ' + result);

        return result;
	}


	/* JSON helper classes */

	/****  START ****/
    public class CouncilTax
    {
        public String Banding;
        public String Year;
        public String TotalCharge;
        public Precepts Precepts;
    }
    public class Precepts
    {
        public String KentCountyCouncil;
        public String KentFireAndRescueService;
        public String ThePoliceAndCrimeCommissionerforKent;
        public String FolkestoneAndHytheDistrictCouncil;
        public String KCCAdultSocialCare;
        public String TownCouncil;
        public String Special;
    }

    public class Collection
    {
        public String LastCollection;
        public String NextCollection;
        public String FutureCollection;
    }
}