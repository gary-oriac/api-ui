/*
Company : Arcus Global
Product : Arcus Integration
Purpose : Main common features for the connection with the Capita RebcBens API for single-sign-on
Notes :
 */
public abstract with sharing class ArcI_ConnSignOnCAPMain extends arcshared.ArcI_ConnMainSoap
{
    private static final String NAMESPACE_WSSE = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd';
    private static final String PREFIX_WSSE = 'wsse';
    private static final String NAMESPACE_WSU = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd';
    private static final String PREFIX_WSU = 'wsu';
    public static final String NAMESPACE_NS2 = 'http://www.capita-software.co.uk/schema/citizencommon';
    protected String pNamespaceNS3;
    
    /**
     * Obtain the specific web service name witch we are going to work
     */
    public abstract String getWebService();
    
    /**
     * Obtain the specific endpoint for every web service
     */
    public override virtual String getActionUrl()
    {
        return 'callout:' + ArcI_UtilityCreds.getNamedCredentials('capitaAD') + '/ws/';
    }


    protected Dom.XmlNode createBodyNode(Dom.XmlNode envelope, String pNamespace, String pPrefix)
    {
        return envelope.addChildElement('Body', NAMESPACE_ENVELOPE_XMLSOAP, PREFIX_SOAP).addChildElement(getWebService() + 'Request', pNamespace, pPrefix);
    }

    /**
     * Creates a Header and Security node with:
     *  - Timestamp node
     *  - UsernameToken node with Password Digest (= Base64 ( SHA-1 ( nonce + created + password ) ))
     */
    protected void createSecurityHeaderWithPasswordDigest(Dom.XMLNode pEnvelope)
    {
        //1.- ENCODING
        String nonceTxt = String.valueOf(Crypto.getRandomLong());
        Blob nonceBlob = Blob.valueOf(nonceTxt);
        String nonceB64 =EncodingUtil.base64Encode(nonceBlob);
                
        String createdTxt = Datetime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        Blob createdBlob = Blob.valueOf(createdTxt);
        
        String pwdTxt = ArcI_UtilityCreds.getAPIPass('capitaAD');
        Blob pwdBlob = Blob.valueOf(pwdTxt);
        
        //Password_Digest = Base64 ( SHA-1 ( nonce + created + password ) )
        Blob targetBlob = Blob.valueOf( nonceTxt + createdTxt + pwdTxt );
        Blob hash = Crypto.generateDigest('SHA1', targetBlob);
        String pwdDigest = EncodingUtil.base64Encode(hash);

        //2.- HEADER XML
        Dom.XMLNode header = pEnvelope.addChildElement('Header', NAMESPACE_ENVELOPE_XMLSOAP, PREFIX_SOAP);

        Dom.XMLNode security = header.addChildElement('Security', NAMESPACE_WSSE, PREFIX_WSSE);
        security.setAttribute('soap:mustUnderstand', '1');
        security.setNamespace(PREFIX_WSU, NAMESPACE_WSU);

        Dom.XMLNode timestamp = security.addChildElement('Timestamp', NAMESPACE_WSU, PREFIX_WSU);
        String idLongTxt = String.valueOf(Crypto.getRandomLong());
        timestamp.setAttribute('wsu:Id', 'TS-'+idLongTxt);
        timestamp.addChildElement('Created', NAMESPACE_WSU, PREFIX_WSU).addTextNode(createdTxt);
        timestamp.addChildElement('Expires', NAMESPACE_WSU, PREFIX_WSU).addTextNode(Datetime.now().addMinutes(15).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));

        Dom.XMLNode usernameToken = security.addChildElement('UsernameToken', NAMESPACE_WSSE, PREFIX_WSSE);
        usernameToken.setAttribute('wsu:Id', 'UNT-'+idLongTxt);
        usernameToken.addChildElement('Username', NAMESPACE_WSSE, PREFIX_WSSE).addTextNode('{!$Credential.UserName}');

        Dom.XMLNode password = usernameToken.addChildElement('Password', NAMESPACE_WSSE, PREFIX_WSSE);
        password.setAttribute('Type', 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest');
        password.addTextNode(pwdDigest);

        Dom.XMLNode nonce = usernameToken.addChildElement('Nonce', NAMESPACE_WSSE, PREFIX_WSSE);
        nonce.setAttribute('EncodingType', 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary');
        nonce.addTextNode(nonceB64);

        usernameToken.addChildElement('Created', NAMESPACE_WSU, PREFIX_WSU).addTextNode(createdTxt);
    }


    public override void parseResponseBody(Dom.XmlNode responseBody)
    {
    	//System.debug('<ARCUS - ArcI_ConnSignOnCAPMain.parseResponseBody()> responseBody: ' + responseBody);
        if(responseBody.getChildElement(getWebService()+'Response', pNamespaceNS3) == null && getWebService() == 'CitizenPortalLinkedServices')
        {
            pNamespaceNS3 = '';
        }

        Dom.XmlNode responseXml = responseBody.getChildElement(getWebService()+'Response', pNamespaceNS3);
        Dom.XmlNode resultNode = responseXml.getChildElement('result', pNamespaceNS3);
        
        if(resultNode == null)
        {
            resultNode = responseXml.getChildElement('result', null);
        }

        String success = getText(resultNode, 'resultCode', NAMESPACE_NS2);
        String resultMsg = getText(resultNode, 'resultMessage', NAMESPACE_NS2);

        if (success.trim().equalsIgnoreCase('OK'))
        {
            dataObject.errorMessage = resultMsg;
            if(responseXml != null) fillData(responseXml);
        } 
        else
        {
            if (String.isNotBlank(resultMsg))
            {
                dataObject.processError(arcshared.ArcI_UtilityErrorManager.ERR_COD_SPECIFIC, resultMsg);
            }
            else
            {
                dataObject.processError(arcshared.ArcI_UtilityErrorManager.ERR_COD_SPECIFIC, arcshared.ArcI_UtilityErrorManager.ERR_MSG_WEB_SERVICE_PROBLEM);
            }
        }
    }


    /***** For debbuging purposes only. *****
	public override virtual String createRequestBody() {
		String requestBody = super.createRequestBody();
		
		System.debug('<ARCUS> ENDPOINT: '+request.getEndpoint());
		System.debug('<ARCUS> REQUEST: '+requestBody);
		return requestBody;
	}
	public override virtual void parseResponseBody(HttpResponse response) {
		if (isSmallResponse) System.debug('<ARCUS> RESPONSE: '+response.getBody());
		else System.debug('<ARCUS> RESPONSE: isSmallResponse is false');
		System.debug('<ARCUS> STATUS: '+response.getStatus());
		System.debug('<ARCUS> STATUS CODE: '+response.getStatusCode());
		System.debug('<ARCUS> SUCCESS:'+dataObject.isSuccess);
		
		super.parseResponseBody(response);
	}
	/***** For debbuging purposes only. *****/

}