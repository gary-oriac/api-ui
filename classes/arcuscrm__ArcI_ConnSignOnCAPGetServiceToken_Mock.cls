public with sharing class ArcI_ConnSignOnCAPGetServiceToken_Mock extends arcshared.ArcI_ConnMain_Mock
{
    public enum ErrorResponseType {INVALID_TOKEN, INVALID_APPLICATION_ID, INVALID_REFERENCE_NUMBER}
    public ErrorResponseType selectedErrorResp {get; set;}

    public static final String SERVICE_TOKEN = 'd8f9c05cf2ce5c1881e0b98425596032a799d097df905b35038e0f7dfb2e5bed';
    public static final String INVALID_SESSION_TOKEN = 'invalidSessionToken';
    public static final String INVALID_APP_ID = 'invalidAppId';
    public static final String INVALID_REF = 'invalidRef123';

    public ArcI_ConnSignOnCAPGetServiceToken_Mock(ResponseType pResponseType, ErrorResponseType pErrorResponseType)
    {
        if(pErrorResponseType != null) selectedErrorResp = pErrorResponseType;
        setResponse(pResponseType);
    }


    public override String getResponseBody(ResponseType pResponseType)
    {
        return pResponseType == ResponseType.OK ? createResponseOK() : createResponseInvalidData();
    }

    String createResponseOK()
    {
    	return '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">'
			    +'<SOAP-ENV:Header/>'
			    +'<SOAP-ENV:Body>'
			        +'<ns3:CitizenPortalRequestServiceTokenResponse xmlns:ns3="http://www.capita-software.co.uk/citizenportal/schema/citizenportalrequestservicetokenws" xmlns:ns2="http://www.capita-software.co.uk/schema/citizencommon">'
			            +'<ns3:serviceToken>'+ SERVICE_TOKEN +'</ns3:serviceToken>'
			            +'<ns3:result>'
			                +'<ns2:resultCode>OK</ns2:resultCode>'
			                +'<ns2:resultMessage>Token is generated successfully.</ns2:resultMessage>'
			            +'</ns3:result>'
			        +'</ns3:CitizenPortalRequestServiceTokenResponse>'
			    +'</SOAP-ENV:Body>'
			+'</SOAP-ENV:Envelope>';
    }

    String createResponseInvalidData()
    {
    	String resp = '';
    	if(selectedErrorResp == ErrorResponseType.INVALID_TOKEN)
    	{
    		resp = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">'
			   +'<SOAP-ENV:Header/>'
			   +'<SOAP-ENV:Body>'
			      +'<ns3:CitizenPortalRequestServiceTokenResponse xmlns:ns3="http://www.capita-software.co.uk/citizenportal/schema/citizenportalrequestservicetokenws" xmlns:ns2="http://www.capita-software.co.uk/schema/citizencommon">'
			         +'<ns3:serviceToken/>'
			         +'<ns3:result>'
			            +'<ns2:resultCode>INVALID</ns2:resultCode>'
			            +'<ns2:resultMessage>No record of user being logged in</ns2:resultMessage>'
			         +'</ns3:result>'
			      +'</ns3:CitizenPortalRequestServiceTokenResponse>'
			   +'</SOAP-ENV:Body>'
			+'</SOAP-ENV:Envelope>';
    	}
    	else if(selectedErrorResp == ErrorResponseType.INVALID_APPLICATION_ID)
    	{
    		resp = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">'
			   +'<SOAP-ENV:Header/>'
			   +'<SOAP-ENV:Body>'
			      +'<ns3:CitizenPortalRequestServiceTokenResponse xmlns:ns3="http://www.capita-software.co.uk/citizenportal/schema/citizenportalrequestservicetokenws" xmlns:ns2="http://www.capita-software.co.uk/schema/citizencommon">'
			         +'<ns3:serviceToken/>'
			         +'<ns3:result>'
			            +'<ns2:resultCode>INVALID</ns2:resultCode>'
			            +'<ns2:resultMessage>Invalid applicationId '+ INVALID_APP_ID +'</ns2:resultMessage>'
			         +'</ns3:result>'
			      +'</ns3:CitizenPortalRequestServiceTokenResponse>'
			   +'</SOAP-ENV:Body>'
			+'</SOAP-ENV:Envelope>';
    	}
    	else if(selectedErrorResp == ErrorResponseType.INVALID_REFERENCE_NUMBER)
    	{
    		resp = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">'
			   +'<SOAP-ENV:Header/>'
			   +'<SOAP-ENV:Body>'
			      +'<ns3:CitizenPortalRequestServiceTokenResponse xmlns:ns3="http://www.capita-software.co.uk/citizenportal/schema/citizenportalrequestservicetokenws" xmlns:ns2="http://www.capita-software.co.uk/schema/citizencommon">'
			         +'<ns3:serviceToken/>'
			         +'<ns3:result>'
			            +'<ns2:resultCode>INVALID</ns2:resultCode>'
			            +'<ns2:resultMessage>Invalid reference '+ INVALID_REF +'</ns2:resultMessage>'
			         +'</ns3:result>'
			      +'</ns3:CitizenPortalRequestServiceTokenResponse>'
			   +'</SOAP-ENV:Body>'
			+'</SOAP-ENV:Envelope>';
    	}

    	return resp;
    }

}