/*
Company : Arcus Global
Product : Arcus Integration
Purpose : Connection with the Capita's web-service "Advantage Digital Portal Login"
Notes :
 */
public with sharing class ArcI_ConnSignOnCAPLogin extends ArcI_ConnSignOnCAPMain
{
    @TestVisible private static final String WEB_SERVICE = 'CitizenPortalThirdPartyLogIn';
    public override String getWebService() {return WEB_SERVICE;}

    private static final String NAMESPACE_CIT = 'http://www.capita-software.co.uk/citizenportal/schema/citizenportalthirdpartyloginws';
    private static final String PREFIX_CIT = 'cit';
    private static final String NAMESPACE_NS3 = NAMESPACE_CIT;

    public ArcI_ConnSignOnCAPLogin()
    {
        pNamespaceNS3 = NAMESPACE_NS3;
    }
    
    /**
     * Obtain the endpoint for this web service
     */
    public override String getActionUrl()
    {
        return super.getActionUrl() + WEB_SERVICE.toLowerCase();
    }

    /**
     * Creates web service request XML
     */
    public override void createRequestBody(Dom.XmlNode envelope)
    {
        createSecurityHeaderWithPasswordDigest(envelope);
        createBodyNode(envelope, NAMESPACE_CIT, PREFIX_CIT).addChildElement('username', NAMESPACE_CIT, PREFIX_CIT).addTextNode(((arcuscrm.ArcI_DataSignOnLogin)dataObject).username);
    }

    /**
     * Parse the response Xml and populate the response properties on the dataObject
     */
    public override void fillData(Dom.XmlNode pNode)
    {
        ((arcuscrm.ArcI_DataSignOnLogin)dataObject).token = getText(pNode, 'token', NAMESPACE_NS3);
    }

}