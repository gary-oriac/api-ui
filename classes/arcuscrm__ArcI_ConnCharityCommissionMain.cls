/*
Company : Arcus Global
Product : Arcus Integration
Purpose : Main common features for the connection with the Charity Commission SAOP webservices
Notes :
 */
public abstract with sharing class ArcI_ConnCharityCommissionMain extends arcshared.ArcI_ConnMainSoap
{
    public static final String NAMESPACE_CHAR = 'http://www.charitycommission.gov.uk/';
    public static final String PREFIX_CHAR = 'char';

    private static final String SOAPACTION_COMMON_ENDPOINT = 'http://www.charitycommission.gov.uk/';

    //returns the name of the WS we are currently invoking
    public abstract String getWebserviceName();
    
    protected arcuscrm.ArcI_DataCharityCommission getData() {return (arcuscrm.ArcI_DataCharityCommission) dataObject;}

    //returns endpoint URL where the webservice request callouts will be made to
    public override String getActionUrl()
    {
        return 'callout:arcuscrm__' + ArcI_UtilityCreds.getNamedCredentials('charityCommission');
    }

    protected Dom.XmlNode createBodyNode(Dom.XmlNode envelopeNode)
    {
        return envelopeNode.addChildElement('Body', NAMESPACE_ENVELOPE_XMLSOAP, PREFIX_SOAP)
                .addChildElement(getWebserviceName(), NAMESPACE_CHAR, PREFIX_CHAR);
                //.addChildElement('APIKey', NAMESPACE_CHAR, PREFIX_CHAR).addTextNode(ArcI_UtilityConfigSettings.CHARITY_COMMS_API_KEY);
    }
    
    public override void addAPIHeader()
    {
        request.setHeader('Content-Type', 'text/xml; charset=UTF-8');
        request.setHeader('Accept-Encoding', 'gzip,deflate');
        request.setHeader('SOAPAction', SOAPACTION_COMMON_ENDPOINT + getWebserviceName());
    }



    public override String createRequestBody() {
        Dom.Document doc = new Dom.Document();

        createRequestBody(doc.createRootElement('Envelope', getNamespaceEnvelope(), PREFIX_SOAP));

        String inputXml = doc.toXmlString(); 

        system.debug('<ArcI_ConnCharityCommissionMain.createRequestBody() inputXml: ' + inputXml);
        system.debug('<ArcI_ConnCharityCommissionMain.createRequestBody() inputXml.indexOf('<'+PREFIX_SOAP): ' + inputXml.indexOf('<'+PREFIX_SOAP));

        return inputXml.substring(inputXml.indexOf('<'+PREFIX_SOAP));
    }

    /***** For debbuging purposes only. *****/
    //public override virtual String createRequestBody() {
    //  String requestBody = super.createRequestBody();
        
    //  System.debug('<ARCUS> ENDPOINT: '+request.getEndpoint());
    //  System.debug('<ARCUS> REQUEST: '+requestBody);
    //  return requestBody;
    //}
    //public override virtual void parseResponseBody(HttpResponse response) {
    //  System.debug('<ARCUS> RESPONSE: '+String.valueof(response.getBody()));
    //  System.debug('<ARCUS> STATUS: '+response.getStatus());
    //  System.debug('<ARCUS> STATUS CODE: '+response.getStatusCode());
    //  System.debug('<ARCUS> SUCCESS:'+dataObject.isSuccess);
        
    //  super.parseResponseBody(response);
    //}
    /***** For debbuging purposes only. *****/
}