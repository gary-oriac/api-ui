@isTest
public class PP_FHDC_MyArea_Controller_MOCK
{
    public static arcusint.ArcI_DataMODGOVCountyCouncillors getCountyCouncillorsData()
    {
        arcusint.ArcI_DataMODGOVCountyCouncillors councilData = new arcusint.ArcI_DataMODGOVCountyCouncillors();
        councilData.isSuccess = true;
        councilData.countyCouncillorsList = getMembersList('Mr Test County');        

        return councilData;        
    }

   	public static arcusint.ArcI_DataMODGOVWardCouncillors getCouncillorsByWardData()
    {
        arcusint.ArcI_DataMODGOVWardCouncillors wardsData = new arcusint.ArcI_DataMODGOVWardCouncillors();
        wardsData.isSuccess = true;
        //
        arcusint.ArcI_DataMODGOVWardCouncillors.Ward w = new arcusint.ArcI_DataMODGOVWardCouncillors.Ward();
        w.wardTitle = 'testWard';
        w.wardCouncillorsList = getMembersList('Mr Test Ward');
        //
        wardsData.wardsList = new List<arcusint.ArcI_DataMODGOVWardCouncillors.Ward>();
        wardsData.wardsList.add(w);
        return wardsData; 
    }

   	public static arcusint.ArcI_DataMODGOVMps getMpsData()
    {
        arcusint.ArcI_DataMODGOVMps mpData = new arcusint.ArcI_DataMODGOVMps();
        mpData.isSuccess = true;
        mpData.mpsList = getMembersList('Mr Test Mp');

        return mpData; 
    }

    public static List<arcusint.ArcI_DataMODGOVCommon.Member> getMembersList(String memberName)
    {
        arcusint.ArcI_DataMODGOVCommon.Address testAddr = new arcusint.ArcI_DataMODGOVCommon.Address();
        testAddr.line1 = 'test';
        testAddr.line2 = 'test';
        testAddr.line3 = 'test';
        testAddr.line4 = 'test';
        testAddr.postcode = 'CD12CD';
        testAddr.phone = '0123456789';
        testAddr.mobile = '0777777777';
        testAddr.email = 'test@aexample.com';

        arcusint.ArcI_DataMODGOVCommon.TermOfOffice termsOfOffice = new arcusint.ArcI_DataMODGOVCommon.TermOfOffice();
        termsOfOffice.startDate = '2017-01-01';
        termsOfOffice.endDate = '2017-01-01';

        arcusint.ArcI_DataMODGOVCommon.Member memb = new arcusint.ArcI_DataMODGOVCommon.Member();
        memb.memberId = '12345';
        memb.fullUsername = memberName;
        memb.photoSmallUrl = 'http://www.test.com';
        memb.photoBigUrl = 'http://www.test2.com';
        memb.politicalPartyTitle = 'test';
        memb.districtTitle = 'test';
        memb.representing = 'test';
        memb.keyPosts = 'test';
        memb.workAddress = testAddr;
        memb.homeAddress = testAddr;
        memb.termsOfOffice = new List<arcusint.ArcI_DataMODGOVCommon.TermOfOffice>();//.add(termsOfOffice);

        List<arcusint.ArcI_DataMODGOVCommon.Member> theList = new List<arcusint.ArcI_DataMODGOVCommon.Member>();
        theList.add(memb);

        return theList;
    }

}