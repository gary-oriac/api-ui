/*
Company : Arcus Global
Product : Arcus Integration
Purpose : Connection with the Capita's web-service "Advantage Digital Portal Get Linked Services"
Notes :
 */
public with sharing class ArcI_ConnSignOnCAPLinkedServices extends ArcI_ConnSignOnCAPMain
{
	@TestVisible private static final String WEB_SERVICE = 'CitizenPortalLinkedServices';
    public override String getWebService() {return WEB_SERVICE;}

    private static final String NAMESPACE_CIT = 'http://www.capita-software.co.uk/citizenportal/schema/citizenportallinkedservicesws';
    private static final String PREFIX_CIT = 'cit';
    private static final String NAMESPACE_NS3 = NAMESPACE_CIT;

    public ArcI_ConnSignOnCAPLinkedServices()
    {
        pNamespaceNS3 = NAMESPACE_NS3;
    }

    /**
     * Obtain the specific endpoint for every web service
    **/
    public override String getActionUrl()
    {
        return super.getActionUrl() + WEB_SERVICE.toLowerCase();
    }
    
    /**
     * Creates web service request XML
    **/
    public override void createRequestBody(Dom.XmlNode envelope)
    {
        createSecurityHeaderWithPasswordDigest(envelope);
        Dom.XmlNode body = createBodyNode(envelope, NAMESPACE_CIT, PREFIX_CIT);
    	body.addChildElement('token', null, null).addTextNode(((arcuscrm.ArcI_DataSignOnLinkedServices)dataObject).token);
    }

    //cast the data
	arcuscrm.ArcI_DataSignOnLinkedServices getData(){return (arcuscrm.ArcI_DataSignOnLinkedServices) dataObject;}
    
    /**
     * Parse the response Xml and populate the response properties on the dataObject
    **/
	public override void fillData(Dom.XmlNode responseXml)
	{
		System.debug('<ARCUS - ArcI_ConnSignOnCAPLinkedServices.fillData()> responseXml: '+responseXml);

		
    	getData().linkedServices = new List<arcuscrm.ArcI_DataSignOnLinkedServices.PortalService>();
    	//loop over the linkedServices node
    	for(Dom.XmlNode currentLinkedService: responseXml.getChildElement('linkedServices', null).getChildElements())//NAMESPACE_CIT is the same as ns4 which is used in the XML response for this node
    	{
    		arcuscrm.ArcI_DataSignOnLinkedServices.PortalService newLinkedService = new arcuscrm.ArcI_DataSignOnLinkedServices.PortalService();
    		//loop over the current linked service nodes/props
    		for(Dom.XmlNode currentLinkedServiceProp: currentLinkedService.getChildElements())
    		{
    			if(currentLinkedServiceProp.getName() == 'referenceNumber')
    			{
    				newLinkedService.referenceNumber = currentLinkedServiceProp.getText();
    			}
    			else if(currentLinkedServiceProp.getName() == 'applicationId')
    			{
    				newLinkedService.applicationId = currentLinkedServiceProp.getText();
    			}
    			else if(currentLinkedServiceProp.getName() == 'applicationName')
    			{
    				newLinkedService.applicationName = currentLinkedServiceProp.getText();
    			}
    			else if(currentLinkedServiceProp.getName() == 'address')
    			{
    				newLinkedService.address = currentLinkedServiceProp.getText();
    			}
    			else if(currentLinkedServiceProp.getName() == 'status')
    			{
    				newLinkedService.status = currentLinkedServiceProp.getText();
    			}
    			else if(currentLinkedServiceProp.getName() == 'link')
    			{
    				newLinkedService.link = currentLinkedServiceProp.getText();
    			}
    		}

    		getData().linkedServices.add(newLinkedService);
    	}
	}

}