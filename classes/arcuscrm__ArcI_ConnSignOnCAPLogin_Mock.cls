/*
Company : Arcus Global
Product : Arcus Integration
Purpose : Mock data for the web service ArcI_ConnSignOnCAPLogin
Notes :
 */
public with sharing class ArcI_ConnSignOnCAPLogin_Mock extends arcshared.ArcI_ConnMain_Mock
{
    public static final String TOKEN = '4577d09c206ad9a773fbda0210a88d3b67af45745cfd522864c237fe69462df5';
    
    public override String getResponseBody(ResponseType pResponseType)
    {
        //login does not return an error, even if they are not registered yet.
        return
            '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">'
               +'<SOAP-ENV:Header/>'
               +'<SOAP-ENV:Body>'
                  +'<ns3:CitizenPortalThirdPartyLogInResponse xmlns:ns3="http://www.capita-software.co.uk/citizenportal/schema/citizenportalthirdpartyloginws" xmlns:ns2="http://www.capita-software.co.uk/schema/citizencommon">'
                     +'<ns3:token>' + TOKEN + '</ns3:token>'
                     +'<ns3:result>'
                        +'<ns2:resultCode>OK</ns2:resultCode>'
                        +'<ns2:resultMessage>Token is generated successfully for username pcc.test.username.</ns2:resultMessage>'
                     +'</ns3:result>'
                  +'</ns3:CitizenPortalThirdPartyLogInResponse>'
               +'</SOAP-ENV:Body>'
            +'</SOAP-ENV:Envelope>';
    }

}