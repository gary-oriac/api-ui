/*
Company : Arcus Global
Product : Arcus Integration
Purpose : Mock data for the web service ArcI_ConnSSOCapitaLogout
Notes :
 */
public with sharing class ArcI_ConnSignOnCAPLogout_Mock extends arcshared.ArcI_ConnMain_Mock
{
    public override String getResponseBody(ResponseType pResponseType)
    {
        //logout does not return an error, even if the token is wrong.
        return
            '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">'
               +'<SOAP-ENV:Header/>'
               +'<SOAP-ENV:Body>'
                  +'<ns3:CitizenPortalLogOutResponse xmlns:ns3="http://www.capita-software.co.uk/citizenportal/schema/citizenportallogoutws" xmlns:ns2="http://www.capita-software.co.uk/schema/citizencommon">'
                     +'<ns3:result>'
                        +'<ns2:resultCode>OK</ns2:resultCode>'
                        +'<ns2:resultMessage>Citizen logged out.</ns2:resultMessage>'
                     +'</ns3:result>'
                  +'</ns3:CitizenPortalLogOutResponse>'
               +'</SOAP-ENV:Body>'
            +'</SOAP-ENV:Envelope>';
    }
}