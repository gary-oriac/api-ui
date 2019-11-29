public with sharing class ArcI_ConnMyAreaMain_Mock extends arcshared.ArcI_ConnMain_Mock
{
    public static final String jsonStr = '{"Success":true,"HasCouncilTax": true,"CouncilTax":{"Banding":"C","Year":"2019/2020","TotalCharge":"1,696.82","Precepts":{"KentCountyCouncil":"1072.64","KentFireAndRescueService": "69.12","ThePoliceAndCrimeCommissionerforKent":"171.69","FolkestoneAndHytheDistrictCouncil": "221.52","KCCAdultSocialCare":"82.40","FolkestoneParksCharitySpecialExpense": "29.84","FolkestoneTownCouncil":"49.61"}},"HasRecyclingCollection":true,"RecyclingCollection":{"LastCollection":"2019-09-25","NextCollection":"2019-10-09","FutureCollection":"2019-10-23"},"HasRefuseCollection":true,"RefuseCollection":{"LastCollection":"2019-09-18","NextCollection":"2019-10-02","FutureCollection":"2019-10-16"},"HasGardenCollection":true,"GardenCollection":{"LastCollection":"2019-09-18","NextCollection":"2019-10-02","FutureCollection":"2019-10-16"}}';

    public override String getResponseBody(ResponseType pResponseType)
    {
        return jsonStr;
    }
}

// {"Success":false,"Error":{"ErrorReason":"invalid key supplied"}}