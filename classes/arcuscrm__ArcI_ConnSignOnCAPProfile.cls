/*
Company : Arcus Global
Product : Arcus Integration
Purpose : Connection with the Capita's web-service "Advantage Digital Portal Profile"
Notes :
 */
public with sharing class ArcI_ConnSignOnCAPProfile extends ArcI_ConnSignOnCAPMain
{
    @TestVisible private static final String WEB_SERVICE = 'CitizenPortalProfile';
    public override String getWebService() {return WEB_SERVICE;}

    private static final String NAMESPACE_CIT = 'http://www.capita-software.co.uk/citizenportal/schema/citizenportalprofilews';
    private static final String PREFIX_CIT = 'cit';
    private static final String NAMESPACE_NS3 = NAMESPACE_CIT;
    //private static final String NAMESPACE_NS2 = 'http://www.capita-software.co.uk/schema/citizencommon';

    public ArcI_ConnSignOnCAPProfile()
    {
        pNamespaceNS3 = NAMESPACE_NS3;
    }

    /**
     * Obtain the specific endpoint for every web service
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

        Dom.XmlNode body = createBodyNode(envelope, NAMESPACE_CIT, PREFIX_CIT);
        if(String.isNotBlank(((arcuscrm.ArcI_DataSignOnProfile)dataObject).username))
        {
            body.addChildElement('username', NAMESPACE_CIT, PREFIX_CIT).addTextNode(((arcuscrm.ArcI_DataSignOnProfile)dataObject).username);
        }
        else
        {
            body.addChildElement('emailAddress', NAMESPACE_CIT, PREFIX_CIT).addTextNode(((arcuscrm.ArcI_DataSignOnProfile)dataObject).email);
        }
    }

    //cast the data
    arcuscrm.ArcI_DataSignOnProfile getData(){return (arcuscrm.ArcI_DataSignOnProfile) dataObject;}

    
    /**
     * Parse the response Xml and populate the response properties on the dataObject
     */
    public override void fillData(Dom.XmlNode responseXml)
    {
        getData().ssid = getText(responseXml, 'ssid', NAMESPACE_NS3);
        
        responseXml = responseXml.getChildElement('citizenPortalProfileDetails', NAMESPACE_NS3);
        if(String.isBlank(getData().username))
        {
            getData().username = getText(responseXml, 'username', NAMESPACE_NS3);
        }
        else
        {
            getData().email = getText(responseXml, 'email', NAMESPACE_NS3);
        }    
        getData().companyName = getText(responseXml, 'companyName', NAMESPACE_NS3); 

        responseXml = responseXml.getChildElement('name', NAMESPACE_NS3);
        getData().title = getText(responseXml, 'title', NAMESPACE_NS3);
        getData().forename = getText(responseXml, 'forename', NAMESPACE_NS3);
        getData().middlename = getText(responseXml, 'middlename', NAMESPACE_NS3);
        getData().surname = getText(responseXml, 'surname', NAMESPACE_NS3);
    }

}