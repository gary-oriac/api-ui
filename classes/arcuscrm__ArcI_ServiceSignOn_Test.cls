/*
Company : Arcus Global
Product : Arcus Integration
Purpose : Test all the services for a SignOn integration
Notes : it covers not just the ArcI_ServiceSignOn class, but also all Data and Conn classes
 */
@isTest
public class ArcI_ServiceSignOn_Test
{   
    @isTest
    //This tests all the connections, not only the Profile one.
    static void testConnectionError()
    {
        //Arrange
        arcuscrm.ArcI_ConnSignOnCAPProfile_Mock theMock = new arcuscrm.ArcI_ConnSignOnCAPProfile_Mock();
        theMock.setResponse(arcshared.ArcI_ConnMain_Mock.ResponseType.HTTP_ERROR);
        theMock.setAsTestMock();
        arcuscrm.ArcI_DataSignOnProfile data = new arcuscrm.ArcI_DataSignOnProfile();
        data.username = arcshared.ArcI_ConnMain_Mock.USERNAME;

        //Act
        Test.startTest();
        ArcI_ServiceSignOn.getProfile(data);
        Test.stopTest();
        
        //Assert
        System.assertEquals(false, data.isSuccess, 'get Profile process must fail');
        System.assertEquals(arcshared.ArcI_UtilityErrorManager.ERR_COD_HTTP_500, data.errorCode, 'Returned error code getting the Profile is not correct');
        System.assert(data.errorMessage.length() > 0, 'Returned error message getting the Profile usually is filled with the external API message.');
    }
    
    @isTest
    static void testMissingRequiredData()
    {
        //Arrange
        arcuscrm.ArcI_DataSignOnLogin dataLogin = new arcuscrm.ArcI_DataSignOnLogin();
        arcuscrm.ArcI_DataSignOnProfile dataProfile = new arcuscrm.ArcI_DataSignOnProfile();
        arcuscrm.ArcI_DataSignOnProfile  dataProfileFull = new arcuscrm.ArcI_DataSignOnProfile();
        dataProfileFull.username = 'anUsername';
        dataProfileFull.email = 'anEmail@anEmail.com';
        arcuscrm.ArcI_DataSignOnLogout dataLogout = new arcuscrm.ArcI_DataSignOnLogout();
        arcuscrm.ArcI_DataSignOnLinkedServices dataLinkedServices = new ArcI_DataSignOnLinkedServices();
        arcuscrm.ArcI_DataSignOnGetServiceToken dataServiceToken = new arcuscrm.ArcI_DataSignOnGetServiceToken();

        //Act
        Test.startTest();
        arcuscrm.ArcI_ServiceSignOn.login(dataLogin);
        arcuscrm.ArcI_ServiceSignOn.getProfile(dataProfile);
        arcuscrm.ArcI_ServiceSignOn.getProfile(dataProfileFull);
        arcuscrm.ArcI_ServiceSignOn.logout(dataLogout);
        arcuscrm.ArcI_ServiceSignOn.getLinkedServices(dataLinkedServices);
        arcuscrm.ArcI_ServiceSignOn.getServiceToken(dataServiceToken);
        Test.stopTest();
        
        //Assert
        System.assertEquals(false, dataLogin.isSuccess, 'Login process must fail because there is no input data');
        System.assertEquals(false, dataProfile.isSuccess, 'Profile process must fail because there is no input data');
        System.assertEquals(false, dataProfileFull.isSuccess, 'Profile process must fail because only one parameter is allowed');
        System.assertEquals(false, dataLogout.isSuccess, 'Logout process must fail because there is no input data');
        System.assertEquals(false, dataLinkedServices.isSuccess, 'LinkedServices process must fail because there is no input data');
        System.assertEquals(false, dataServiceToken.isSuccess, 'ServiceToken process must fail because there is no input data');
    }
   
    @isTest
    static void testLogin()
    {
        //Arrange
        new arcuscrm.ArcI_ConnSignOnCAPLogin_Mock().setAsTestMock();
        arcuscrm.ArcI_DataSignOnLogin data = new arcuscrm.ArcI_DataSignOnLogin();
        data.username = arcshared.ArcI_ConnMain_Mock.USERNAME;

        //Act
        Test.startTest();
        ArcI_ServiceSignOn.login(data);
        Test.stopTest();
        
        //Assert
        System.assertEquals(true, data.isSuccess, 'Process fail. Code:'+data.errorCode+' - Message:'+data.errorMessage);
        System.assertEquals(arcuscrm.ArcI_ConnSignOnCAPLogin_Mock.TOKEN, data.token, 'Returned token is not correct');
    }
    
    @isTest
    static void testProfile()
    {
        //Arrange
        new arcuscrm.ArcI_ConnSignOnCAPProfile_Mock().setAsTestMock();
        arcuscrm.ArcI_DataSignOnProfile dataWithUser = new arcuscrm.ArcI_DataSignOnProfile();
        arcuscrm.ArcI_DataSignOnProfile dataWithEmail = new arcuscrm.ArcI_DataSignOnProfile();
        dataWithUser.username = arcshared.ArcI_ConnMain_Mock.USERNAME;
        dataWithEmail.email = arcshared.ArcI_ConnMain_Mock.EMAIL;

        //Act
        Test.startTest();
        arcuscrm.ArcI_ServiceSignOn.getProfile(dataWithUser);
        arcuscrm.ArcI_ServiceSignOn.getProfile(dataWithEmail);
        Test.stopTest();
        
        //Assert
        System.assertEquals(true, dataWithUser.isSuccess, 'Process with username fails. Code:'+dataWithUser.errorCode+' - Message:'+dataWithUser.errorMessage);
        System.assertEquals(true, dataWithEmail.isSuccess, 'Process with email fails. Code:'+dataWithEmail.errorCode+' - Message:'+dataWithEmail.errorMessage);
        System.assertEquals(arcshared.ArcI_ConnMain_Mock.EMAIL, dataWithUser.email, 'Returned EMAIL for username is not correct');
        System.assertEquals(arcshared.ArcI_ConnMain_Mock.USERNAME, dataWithEmail.username, 'Returned USERNAME for email is not correct');
        System.assertEquals(arcuscrm.ArcI_ConnSignOnCAPProfile_Mock.SSID, dataWithUser.ssid, 'Returned SSID for SSID is not correct');
        System.assertEquals(arcuscrm.ArcI_ConnSignOnCAPProfile_Mock.SSID, dataWithEmail.ssid, 'Returned SSID for SSID is not correct');
        System.assertEquals(arcuscrm.ArcI_ConnSignOnCAPProfile_Mock.TITLE, dataWithUser.title, 'Returned TITLE for username is not correct');
        System.assertEquals(arcuscrm.ArcI_ConnSignOnCAPProfile_Mock.TITLE, dataWithEmail.title, 'Returned TITLE for email is not correct');
        System.assertEquals(arcuscrm.ArcI_ConnSignOnCAPProfile_Mock.FORENAME, dataWithUser.forename, 'Returned FORENAME for username is not correct');
        System.assertEquals(arcuscrm.ArcI_ConnSignOnCAPProfile_Mock.FORENAME, dataWithEmail.forename, 'Returned FORENAME for email is not correct');
        System.assertEquals(arcuscrm.ArcI_ConnSignOnCAPProfile_Mock.MIDDLENAME, dataWithUser.middlename, 'Returned MIDDLENAME for username is not correct');
        System.assertEquals(arcuscrm.ArcI_ConnSignOnCAPProfile_Mock.MIDDLENAME, dataWithEmail.middlename, 'Returned MIDDLENAME for email is not correct');
        System.assertEquals(arcuscrm.ArcI_ConnSignOnCAPProfile_Mock.SURNAME, dataWithUser.surname, 'Returned SURNAME for username is not correct');
        System.assertEquals(arcuscrm.ArcI_ConnSignOnCAPProfile_Mock.SURNAME, dataWithEmail.surname, 'Returned SURNAME for email is not correct');
        System.assertEquals(arcuscrm.ArcI_ConnSignOnCAPProfile_Mock.COMPANY_NAME, dataWithUser.companyName, 'Returned COMPANY NAME for username is not correct');
        System.assertEquals(arcuscrm.ArcI_ConnSignOnCAPProfile_Mock.COMPANY_NAME, dataWithEmail.companyName, 'Returned COMPANY NAME for email is not correct');
    }

    @isTest
    static void testProfile_error()
    {
        //Arrange
        arcuscrm.ArcI_ConnSignOnCAPProfile_Mock theMock = new arcuscrm.ArcI_ConnSignOnCAPProfile_Mock();
        theMock.setResponse(arcshared.ArcI_ConnMain_Mock.ResponseType.ERROR);
        theMock.setAsTestMock();
        arcuscrm.ArcI_DataSignOnProfile data = new arcuscrm.ArcI_DataSignOnProfile();
        data.username = arcshared.ArcI_ConnMain_Mock.USERNAME;

        //Act
        Test.startTest();
        arcuscrm.ArcI_ServiceSignOn.getProfile(data);
        Test.stopTest();
        
        //Assert
        System.assertEquals(false, data.isSuccess, 'get Profile process must fail');
        System.assertEquals(arcshared.ArcI_UtilityErrorManager.ERR_COD_SPECIFIC, data.errorCode, 'Returned error code getting the Profile is not correct');
        System.assert(data.errorMessage.length() > 0, 'Returned error message getting the Profile usually is filled with the external API message.');
    }

    @isTest
    static void testLogout()
    {
        //Arrange
        new arcuscrm.ArcI_ConnSignOnCAPLogout_Mock().setAsTestMock();
        arcuscrm.ArcI_DataSignOnLogout data = new arcuscrm.ArcI_DataSignOnLogout();
        data.token = '11111111112222222222333333333344444444445555555555';

        //Act
        Test.startTest();
        arcuscrm.ArcI_ServiceSignOn.logout(data);
        Test.stopTest();
        
        //Assert
        System.assertEquals(true, data.isSuccess, 'Process fail. Code:'+data.errorCode+' - Message:'+data.errorMessage);
    }

    @isTest
    static void testGetLinkedServices_ok()
    {
        //Arrange
        new arcuscrm.ArcI_ConnSignOnCAPLinkedServices_Mock(arcshared.ArcI_ConnMain_Mock.ResponseType.OK).setAsTestMock();
        arcuscrm.ArcI_DataSignOnLinkedServices data = new arcuscrm.ArcI_DataSignOnLinkedServices();
        data.token = '11111111112222222222333333333344444444445555555555';

        //Act
        Test.startTest();
        arcuscrm.ArcI_ServiceSignOn.getLinkedServices(data);

        //Assert
        System.assertEquals(true, data.isSuccess, 'Process fail. Error Code: ' + data.errorCode + ' - Error Message: ' + data.errorMessage);
        System.assert(data.linkedServices.size() > 0, 'The linkedService list appears to be empty (it should have 2 items) || data.linkedServices: ' + data.linkedServices);
        Test.stopTest();
    }

    @isTest
    static void testGetLinkedServices_invalidToken()
    {
        //Arrange
        new arcuscrm.ArcI_ConnSignOnCAPLinkedServices_Mock(arcshared.ArcI_ConnMain_Mock.ResponseType.Error).setAsTestMock();
        arcuscrm.ArcI_DataSignOnLinkedServices data = new arcuscrm.ArcI_DataSignOnLinkedServices();
        data.token = 'invalidtoken123';

        //Act
        Test.startTest();
        arcuscrm.ArcI_ServiceSignOn.getLinkedServices(data);

        //Assert
        System.assertEquals(false, data.isSuccess, 'The server should respond with INVALID result. Error Code: ' + data.errorCode + ' and Error Message: ' + data.errorMessage);
        Test.stopTest();
    }

    @isTest
    static void testGetServiceToken_ok()
    {
        //Arrange
        new arcuscrm.ArcI_ConnSignOnCAPGetServiceToken_Mock(arcshared.ArcI_ConnMain_Mock.ResponseType.OK, null).setAsTestMock();
        arcuscrm.ArcI_DataSignOnGetServiceToken data = new arcuscrm.ArcI_DataSignOnGetServiceToken();
        data.token = '11111111112222222222333333333344444444445555555555';
        data.referenceNumber = 'ref123';
        data.applicationId = 'appId123';

        //Act
        Test.startTest();
        arcuscrm.ArcI_ServiceSignOn.getServiceToken(data);

        //Assert
        System.assertEquals(true, data.isSuccess, 'Process fail. Error Code: ' + data.errorCode + ' - Error Message: ' + data.errorMessage);
        System.assert(String.isNotBlank(data.serviceToken), 'The serviceToken appears to be empty');
        System.assertEquals(arcuscrm.ArcI_ConnSignOnCAPGetServiceToken_Mock.SERVICE_TOKEN, data.serviceToken, 'Service token appears to be incorrect');
        Test.stopTest();
    }

    @isTest
    static void testGetServiceToken_invalidSessionToken()
    {
        //Arrange
        new arcuscrm.ArcI_ConnSignOnCAPGetServiceToken_Mock(arcshared.ArcI_ConnMain_Mock.ResponseType.ERROR, arcuscrm.ArcI_ConnSignOnCAPGetServiceToken_Mock.ErrorResponseType.INVALID_TOKEN).setAsTestMock();
        arcuscrm.ArcI_DataSignOnGetServiceToken data = new arcuscrm.ArcI_DataSignOnGetServiceToken();
        data.token = arcuscrm.ArcI_ConnSignOnCAPGetServiceToken_Mock.INVALID_SESSION_TOKEN;
        data.applicationId = 'appId123';
        data.referenceNumber = 'ref123';

        //Act
        Test.startTest();
        arcuscrm.ArcI_ServiceSignOn.getServiceToken(data);

        //Assert
        System.assertEquals(false, data.isSuccess, 'The server should respond with INVALID result. Error Code: ' + data.errorCode + ' - Error Message: ' + data.errorMessage);
        System.assertEquals('No record of user being logged in', data.errorMessage, 'The returned error message is wrong');
        System.assert(String.isBlank(data.serviceToken), 'The serviceToken appears NOT to be empty');
        Test.stopTest();
    }

    @isTest
    static void testGetServiceToken_invalidAppId()
    {
        //Arrange
        new arcuscrm.ArcI_ConnSignOnCAPGetServiceToken_Mock(arcshared.ArcI_ConnMain_Mock.ResponseType.ERROR, arcuscrm.ArcI_ConnSignOnCAPGetServiceToken_Mock.ErrorResponseType.INVALID_APPLICATION_ID).setAsTestMock();
        arcuscrm.ArcI_DataSignOnGetServiceToken data = new arcuscrm.ArcI_DataSignOnGetServiceToken();
        data.token = '11111111112222222222333333333344444444445555555555';
        data.applicationId = arcuscrm.ArcI_ConnSignOnCAPGetServiceToken_Mock.INVALID_APP_ID;
        data.referenceNumber = 'ref123';

        //Act
        Test.startTest();
        arcuscrm.ArcI_ServiceSignOn.getServiceToken(data);

        //Assert
        System.assertEquals(false, data.isSuccess, 'The server should respond with INVALID result. Error Code: ' + data.errorCode + ' - Error Message: ' + data.errorMessage);
        System.assertEquals('Invalid applicationId '+ arcuscrm.ArcI_ConnSignOnCAPGetServiceToken_Mock.INVALID_APP_ID , data.errorMessage, 'The returned error message is wrong');
        System.assert(String.isBlank(data.serviceToken), 'The serviceToken appears NOT to be empty');
        Test.stopTest();
    }

    @isTest
    static void testGetServiceToken_invalidRef()
    {
        //Arrange
        new arcuscrm.ArcI_ConnSignOnCAPGetServiceToken_Mock(arcshared.ArcI_ConnMain_Mock.ResponseType.ERROR, arcuscrm.ArcI_ConnSignOnCAPGetServiceToken_Mock.ErrorResponseType.INVALID_REFERENCE_NUMBER).setAsTestMock();
        arcuscrm.ArcI_DataSignOnGetServiceToken data = new arcuscrm.ArcI_DataSignOnGetServiceToken();
        data.token = '11111111112222222222333333333344444444445555555555';
        data.applicationId = 'appId123';
        data.referenceNumber = arcuscrm.ArcI_ConnSignOnCAPGetServiceToken_Mock.INVALID_REF;

        //Act
        Test.startTest();
        arcuscrm.ArcI_ServiceSignOn.getServiceToken(data);

        //Assert
        System.assertEquals(false, data.isSuccess, 'The server should respond with INVALID result. Error Code: ' + data.errorCode + ' - Error Message: ' + data.errorMessage);
        System.assertEquals('Invalid reference '+ arcuscrm.ArcI_ConnSignOnCAPGetServiceToken_Mock.INVALID_REF, data.errorMessage, 'The returned error message is wrong');
        System.assert(String.isBlank(data.serviceToken), 'The serviceToken appears NOT to be empty');
        Test.stopTest();
    }


    
}