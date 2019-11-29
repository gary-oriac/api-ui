@isTest
public with sharing class ArcI_ServiceMODGOV_Test
{
    @isTest
    static void getCountyCouncillors_success()
    {
        //Arrange
		ArcI_ConnMODGOVCountyCouncillors_Mock testMock = new ArcI_ConnMODGOVCountyCouncillors_Mock();
        testMock.setAsTestMock();

        ArcI_DataMODGOVCountyCouncillors pData = new ArcI_DataMODGOVCountyCouncillors();
        pData.sShortName = 'RParl';
        pData.sOrder = '0';
        
        //Act
        ArcI_ServiceMODGOV.getCountyCouncillors(pData);

        //Assert
        System.assertEquals(true, pData.isSuccess);
    }

    @isTest
    static void getWardCouncillors_success()
    {
        //Arrange
		ArcI_ConnMODGOVWardCouncillors_Mock testMock = new ArcI_ConnMODGOVWardCouncillors_Mock();
        testMock.setAsTestMock();

        ArcI_DataMODGOVWardCouncillors pData = new ArcI_DataMODGOVWardCouncillors();
        
        //Act
        ArcI_ServiceMODGOV.getWardCouncillors(pData);

        //Assert
        System.assertEquals(true, pData.isSuccess);
    }

    @isTest
    static void getMps_success()
    {
        //Arrange
		ArcI_ConnMODGOVMps_Mock testMock = new ArcI_ConnMODGOVMps_Mock();
        testMock.setAsTestMock();

        ArcI_DataMODGOVMps pData = new ArcI_DataMODGOVMps();
        pData.bIsMPs = true;
        
        //Act
        ArcI_ServiceMODGOV.getMps(pData);

        //Assert
        System.assertEquals(true, pData.isSuccess);
    }
}