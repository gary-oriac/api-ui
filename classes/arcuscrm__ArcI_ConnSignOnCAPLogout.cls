/*
Company : Arcus Global
Product : Arcus Integration
Purpose : Connection with the Capita's web-service "Advantage Digital Portal Logout"
Notes :
 */
public with sharing class ArcI_ConnSignOnCAPLogout extends ArcI_ConnSignOnCAPMain
{
    @TestVisible private static final String WEB_SERVICE = 'CitizenPortalLogOut';
    public override String getWebService() {return WEB_SERVICE;}

    private static final String NAMESPACE_CIT = 'http://www.capita-software.co.uk/citizenportal/schema/citizenportallogoutws';
    private static final String PREFIX_CIT = 'cit';
    private static final String NAMESPACE_NS3 = NAMESPACE_CIT;
    
    public ArcI_ConnSignOnCAPLogout()
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
        createBodyNode(envelope, NAMESPACE_CIT, PREFIX_CIT).addChildElement('token', NAMESPACE_CIT, PREFIX_CIT).addTextNode(((arcuscrm.ArcI_DataSignOnLogout)dataObject).token);
    }
    
    /**
     * Parse the response Xml and populate the response properties on the dataObject (NOT realy doing atm, but we must implement the abstract method fillData())
     */
    public override void fillData(Dom.XmlNode responseXml)
    {
        //e.g. update some data if needed
    }

}