@isTest
public with sharing class ArcI_ServiceMyArea_Test 
{
    @isTest
    static void getMyAreaBinsAndCtaxDataTest_success()
    {
        //Arrange
		ArcI_ConnMyAreaMain_Mock myareaRespMock = new ArcI_ConnMyAreaMain_Mock();
		myareaRespMock.setAsTestMock();

        ArcI_DataMyArea pData = new ArcI_DataMyArea();
        pData.uprn = '1234567';
        
        //Act
        ArcI_ServiceMyArea.getMyAreaBinsAndCtaxData(pData);

        //Assert
        System.assertEquals(true, pData.MyAreaData.Success);
        System.assertEquals(true, pData.MyAreaData.HasRecyclingCollection);
        System.assertEquals(true, pData.MyAreaData.HasRefuseCollection);
        System.assertEquals(true, pData.MyAreaData.HasGardenCollection);
        System.assertNotEquals(null, pData.MyAreaData.RecyclingCollection);
        System.assert(String.isNotBlank(pData.MyAreaData.RecyclingCollection.LastCollection));
        System.assert(String.isNotBlank(pData.MyAreaData.RecyclingCollection.NextCollection));
        System.assert(String.isNotBlank(pData.MyAreaData.RecyclingCollection.FutureCollection));
        System.assertNotEquals(null, pData.MyAreaData.RefuseCollection);
        System.assert(String.isNotBlank(pData.MyAreaData.RefuseCollection.LastCollection));
        System.assert(String.isNotBlank(pData.MyAreaData.RefuseCollection.NextCollection));
        System.assert(String.isNotBlank(pData.MyAreaData.RefuseCollection.FutureCollection));
        System.assertNotEquals(null, pData.MyAreaData.GardenCollection);
        System.assert(String.isNotBlank(pData.MyAreaData.GardenCollection.LastCollection));
        System.assert(String.isNotBlank(pData.MyAreaData.GardenCollection.NextCollection));
        System.assert(String.isNotBlank(pData.MyAreaData.GardenCollection.FutureCollection));
        //c tax
        System.assertEquals(true, pData.MyAreaData.HasCouncilTax);
        System.assertNotEquals(null, pData.MyAreaData.CouncilTax);
        System.assert(String.isNotBlank(pData.MyAreaData.CouncilTax.Banding));
        System.assert(String.isNotBlank(pData.MyAreaData.CouncilTax.Year));
        System.assert(String.isNotBlank(pData.MyAreaData.CouncilTax.TotalCharge));
        System.assertNotEquals(null, pData.MyAreaData.CouncilTax.Precepts);
        System.assert(String.isNotBlank(pData.MyAreaData.CouncilTax.Precepts.KentCountyCouncil));
        System.assert(String.isNotBlank(pData.MyAreaData.CouncilTax.Precepts.KentFireAndRescueService));
        System.assert(String.isNotBlank(pData.MyAreaData.CouncilTax.Precepts.ThePoliceAndCrimeCommissionerforKent));
        System.assert(String.isNotBlank(pData.MyAreaData.CouncilTax.Precepts.FolkestoneAndHytheDistrictCouncil));
        System.assert(String.isNotBlank(pData.MyAreaData.CouncilTax.Precepts.KCCAdultSocialCare));
        System.assert(String.isNotBlank(pData.MyAreaData.CouncilTax.Precepts.TownCouncil));
        System.assert(String.isNotBlank(pData.MyAreaData.CouncilTax.Precepts.Special));
    }

    @isTest
    static void ArcI_UtilityConfigCUSTOM_dummyTest()
    {
        System.assert(String.isNotBlank(ArcI_UtilityConfigCUSTOM.MY_AREA_API_KEY));
        System.assert(String.isNotBlank(ArcI_UtilityConfigCUSTOM.MY_AREA_API_ENDPOINT_NAMEDCREDS_TEST));
        System.assert(String.isNotBlank(ArcI_UtilityConfigCUSTOM.MY_AREA_API_ENDPOINT_NAMEDCREDS_LIVE));
    }
}