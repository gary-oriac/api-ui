/*
Company : Arcus Global
Product : Arcus Integration
Purpose : Connection with the Capita's web-service "Advantage Digital Portal Request Service Token"
Notes :
 */
public with sharing class ArcI_ConnSignOnCAPGetServiceToken extends ArcI_ConnSignOnCAPMain
{
    @TestVisible private static final String WEB_SERVICE = 'CitizenPortalRequestServiceToken';
    public override String getWebService() {return WEB_SERVICE;}

    private static final String NAMESPACE_CIT = 'http://www.capita-software.co.uk/citizenportal/schema/citizenportalrequestservicetokenws';
    private static final String PREFIX_CIT = 'cit';
    private static final String NAMESPACE_NS3 = NAMESPACE_CIT;

    public ArcI_ConnSignOnCAPGetServiceToken()
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
        Dom.XmlNode bodyNode = createBodyNode(envelope, NAMESPACE_CIT, PREFIX_CIT);
    	bodyNode.addChildElement('token', NAMESPACE_CIT, PREFIX_CIT).addTextNode(((arcuscrm.ArcI_DataSignOnGetServiceToken)dataObject).token);
    	bodyNode.addChildElement('applicationId', NAMESPACE_CIT, PREFIX_CIT).addTextNode(((arcuscrm.ArcI_DataSignOnGetServiceToken)dataObject).applicationId);
        bodyNode.addChildElement('referenceNumber', NAMESPACE_CIT, PREFIX_CIT).addTextNode(((arcuscrm.ArcI_DataSignOnGetServiceToken)dataObject).referenceNumber);
    }

    /**
     * Parse the response Xml and populate the response properties on the dataObject
     */
    public override void fillData(Dom.XmlNode pNode)
    {
        ((arcuscrm.ArcI_DataSignOnGetServiceToken)dataObject).serviceToken = getText(pNode, 'serviceToken', NAMESPACE_NS3);
    }

}