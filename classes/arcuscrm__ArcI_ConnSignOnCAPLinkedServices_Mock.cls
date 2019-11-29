/*
Company : Arcus Global
Product : Arcus Integration
Purpose : Mock data for the web service ArcI_ConnSignOnCAPLinkedServices
Notes :
 */
public with sharing class ArcI_ConnSignOnCAPLinkedServices_Mock extends arcshared.ArcI_ConnMain_Mock
{
    public ArcI_ConnSignOnCAPLinkedServices_Mock(ResponseType pResponseType)
    {
        setResponse(pResponseType);
    }


    public override String getResponseBody(ResponseType pResponseType)
    {
        return pResponseType == ResponseType.OK ? createResponseOK() : createResponseInvalidToken();
    }


    String createResponseOK()
    {
        return '<SOAP-ENV:Envelope  xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">'
            +'<SOAP-ENV:Header/>'
            +'<SOAP-ENV:Body>'
                +'<ns4:CitizenPortalLinkedServicesResponse xmlns:ns4="http://www.capita-software.co.uk/citizenportal/schema/citizenportallinkedservicesws" xmlns:ns2="http://www.capita-software.co.uk/schema/citizencommon">'
                    +'<linkedServices>'
                        +'<service>'
                            +'<referenceNumber>11111111</referenceNumber>'
                            +'<applicationId>ct</applicationId>'
                            +'<applicationName>Council Tax</applicationName>'
                            +'<address>1 TEST STREET, TESTVILLE, AA11AA</address>'
                            +'<status>Active</status>'
                            +'<link>href link 1</link>'
                        +'</service>'
                        +'<service>'
                            +'<referenceNumber>22222222</referenceNumber>'
                            +'<applicationId>hb</applicationId>'
                            +'<applicationName>Housing Benefit</applicationName>'
                            +'<address/>'
                            +'<status>PIN Changed</status>'
                            +'<link>href link 2</link>'
                        +'</service>'
                    +'</linkedServices>'
                    +'<result>'
                        +'<ns2:resultCode>OK</ns2:resultCode>'
                        +'<ns2:resultMessage>Successful query</ns2:resultMessage>'
                    +'</result>'
                +'</ns4:CitizenPortalLinkedServicesResponse>'
            +'</SOAP-ENV:Body>'
        +'</SOAP-ENV:Envelope>';
    }

    String createResponseInvalidToken()
    {

        return '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">'
            +'<SOAP-ENV:Body>'
                +'<ns4:CitizenPortalLinkedServicesResponse xmlns:ns4="http://www.capita-software.co.uk/citizenportal/schema/citizenportallinkedservicesws" xmlns:ns2="http://www.capita-software.co.uk/schema/citizencommon">'
                    +'<result>'
                        +'<ns2:resultCode>INVALID</ns2:resultCode>'
                        +'<ns2:resultMessage>Citizen not authorised</ns2:resultMessage>'
                    +'</result>'
                +'</ns4:CitizenPortalLinkedServicesResponse>'
           +'</SOAP-ENV:Body>'
        +'</SOAP-ENV:Envelope>';
    }
    
}