/*
Company : Arcus Global
Product : Arcus Integration
Purpose : Mock data for the web service ArcI_ConnSSOCapitaProfile
Notes :
 */
public with sharing class ArcI_ConnSignOnCAPProfile_Mock extends arcshared.ArcI_ConnMain_Mock
{
    public static final String TITLE = 'Mss';
    public static final String FORENAME = 'Smith';
    public static final String MIDDLENAME = 'Mac';
    public static final String SURNAME = 'Carmen';
    public static final String COMPANY_NAME = 'Arcus Global Ltd.';
    public static final String SSID = 'ssid';
    
    public override String getResponseBody(ResponseType pResponseType)
    {
        return pResponseType == ResponseType.OK ? createResponseOK() : createResponseKO();
    }
    
    String createResponseOK()
    {
        return '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">'
               +'<SOAP-ENV:Header/>'
               +'<SOAP-ENV:Body>'
                  +'<ns3:CitizenPortalProfileResponse xmlns:ns3="http://www.capita-software.co.uk/citizenportal/schema/citizenportalprofilews" xmlns:ns2="http://www.capita-software.co.uk/schema/citizencommon">'
                     +'<ns3:citizenPortalProfileDetails>'
                        +'<ns3:username>' + USERNAME + '</ns3:username>'
                        +'<ns3:name>'
                           +'<ns3:title>' + TITLE + '</ns3:title>'
                           +'<ns3:forename>' + FORENAME + '</ns3:forename>'
                           +'<ns3:middlename>' + MIDDLENAME + '</ns3:middlename>'
                           +'<ns3:surname>' + SURNAME + '</ns3:surname>'
                        +'</ns3:name>'
                        +'<ns3:companyName>' + COMPANY_NAME + '</ns3:companyName>'
                        +'<ns3:email>' + EMAIL + '</ns3:email>'
                        +'<ns3:dateCreated>2017-07-12T16:02:17+0100</ns3:dateCreated>'
                        +'<ns3:dateUpdated>2017-07-12T16:02:17+0100</ns3:dateUpdated>'
                     +'</ns3:citizenPortalProfileDetails>'
                     +'<ns3:ssid>' + SSID + '</ns3:ssid>'
                     +'<ns3:result>'
                        +'<ns2:resultCode>OK</ns2:resultCode>'
                        +'<ns2:resultMessage>Successful query</ns2:resultMessage>'
                     +'</ns3:result>'
                  +'</ns3:CitizenPortalProfileResponse>'
               +'</SOAP-ENV:Body>'
            +'</SOAP-ENV:Envelope>';
    }
    
    String createResponseKO()
    {
        return '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">'
               +'<SOAP-ENV:Header/>'
               +'<SOAP-ENV:Body>'
                  +'<ns3:CitizenPortalProfileResponse xmlns:ns3="http://www.capita-software.co.uk/citizenportal/schema/citizenportalprofilews" xmlns:ns2="http://www.capita-software.co.uk/schema/citizencommon">'
                     +'<ns3:result>'
                        +'<ns2:resultCode>ERROR</ns2:resultCode>'
                        +'<ns2:resultMessage>Valid response could not be generated: DATA INTEGRITY ERROR. A profile could not be retrieved for the citizen currently associated with email address pcc.tesail@peterborough.gov.uk</ns2:resultMessage>'
                     +'</ns3:result>'
                  +'</ns3:CitizenPortalProfileResponse>'
               +'</SOAP-ENV:Body>'
            +'</SOAP-ENV:Envelope>';
    }

}