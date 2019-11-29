/*
Company : Arcus Global
Product : Arcus Integration Architecture
Purpose : A common class used for estalishing connection with the ModGov APIs. It is part of the unlocked 'arcus-integration' package
Notes :
 */
public abstract with sharing class ArcI_ConnMODGOVMain extends arcshared.ArcI_ConnMainRest
{
    public abstract String getWebserviceName();

    public override String getActionUrl()
	{
        System.debug('<ArcI_ConnMODGOVMain.getActionUrl()> url: ' + ArcI_UtilityCreds.getNamedCredentialsName('modGov') + getWebserviceName());

        return 'callout:' + ArcI_UtilityCreds.getNamedCredentialsName('modGov') + getWebserviceName();
	}

    public override HttpRequest createRequest()
    {
        request = new HttpRequest();
		request.setEndPoint(getActionUrl());
		request.setMethod('GET');
        request.setTimeout(120000);
		//Particular header of every API.
		addAPIHeader();

		String bodyRequest = createRequestBody();
		// if (String.isNotEmpty(bodyRequest)) //no requirement to set the request body at present for FHDC but leaving it in case it changes for another customer
        // {
		// 	request.setBody(bodyRequest);
        // }
		return request;
    }
    

    public override void addAPIHeader()
    {
        // request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept-Encoding', 'gzip, deflate');
    }
    public override String createRequestBody()
    {
        //no requirement to add anything at present
        return '';//'"test":"test"';
    }

   	protected ArcI_DataMODGOVCountyCouncillors getCountyCouncillorsData(){return (ArcI_DataMODGOVCountyCouncillors) dataObject;}
   	protected ArcI_DataMODGOVWardCouncillors getCouncillorsByWardData(){return (ArcI_DataMODGOVWardCouncillors) dataObject;}
   	protected ArcI_DataMODGOVMps getMpsData(){return (ArcI_DataMODGOVMps) dataObject;}

    // public virtual void parseXmlBody(Dom.XmlNode bodyXml){}

    public abstract void parseResponseBody(Dom.Document responseBodyDocument);

    public override void parseResponseBody(HttpResponse response)
	{
        try
        {
            // System.debug('<ArcI_ConnMODGOVMain.parseResponseBody()> response.Body: ' + response.getBody());
            parseResponseBody(response.getBodyDocument());            
        }
        catch (Exception ex)
        {
            System.debug('There was an error >>> ' + ex.getMessage());
            System.debug('Error line number >>> ' + ex.getLineNumber());
            System.debug('Error cause >>> ' + ex.getCause());
        } 
	}

    // public override virtual void parseResponseBody(HttpResponse response) {
	// 	System.debug('<ARCUS> RESPONSE: '+response.getBody());
	// 	System.debug('<ARCUS> STATUS: '+response.getStatus());
	// 	System.debug('<ARCUS> STATUS CODE: '+response.getStatusCode());
	// 	System.debug('<ARCUS> SUCCESS:'+dataObject.isSuccess);
		
	// 	parseResponseBody(response);
	// }

    public virtual ArcI_DataMODGOVCommon.Member instantiateNewMember(Dom.XmlNode currentMemberNode)
    {
        // System.debug('currentMemberNode name: ' + currentMemberNode.getName());
        ArcI_DataMODGOVCommon.Member newMember = new ArcI_DataMODGOVCommon.Member();

        for(Dom.XmlNode currentMemberElementNode: currentMemberNode.getChildElements())
        {
            if(currentMemberElementNode.getName() == 'memberid' || currentMemberElementNode.getName() == 'councillorid' || currentMemberElementNode.getName() == 'mpid')
            {
                newMember.memberId = currentMemberElementNode.getText();
            }
            else if(currentMemberElementNode.getName() == 'fullusername')
            {
                newMember.fullUsername = currentMemberElementNode.getText();
            }
            else if(currentMemberElementNode.getName() == 'photosmallurl')
            {
                newMember.photoSmallUrl = currentMemberElementNode.getText();
            }
            else if(currentMemberElementNode.getName() == 'photobigurl')
            {
                newMember.photoBigUrl = currentMemberElementNode.getText();
            }
            else if(currentMemberElementNode.getName() == 'politicalpartytitle')
            {
                newMember.politicalPartyTitle = currentMemberElementNode.getText();
            }
            else if(currentMemberElementNode.getName() == 'districttitle')
            {
                newMember.districtTitle = currentMemberElementNode.getText();
            }
            else if(currentMemberElementNode.getName() == 'representing')
            {
                newMember.representing = currentMemberElementNode.getText();
            }
            else if(currentMemberElementNode.getName() == 'keyposts')
            {
                newMember.keyPosts = currentMemberElementNode.getText();
            }
            //home address
            else if(currentMemberElementNode.getName() == 'homeaddress')
            {
                newMember.homeAddress = new ArcI_DataMODGOVCommon.Address();
                for(Dom.XmlNode currentHomeAddressElementNode: currentMemberElementNode.getChildElements())
                {
                    if(currentHomeAddressElementNode.getName() == 'line1')
                    {
                        newMember.homeAddress.line1 = currentHomeAddressElementNode.getText();
                    }
                    else if(currentHomeAddressElementNode.getName() == 'line2')
                    {
                        newMember.homeAddress.line2 = currentHomeAddressElementNode.getText();
                    }
                    else if(currentHomeAddressElementNode.getName() == 'line3')
                    {
                        newMember.homeAddress.line3 = currentHomeAddressElementNode.getText();
                    }
                    else if(currentHomeAddressElementNode.getName() == 'line4')
                    {
                        newMember.homeAddress.line4 = currentHomeAddressElementNode.getText();
                    }
                    else if(currentHomeAddressElementNode.getName() == 'postcode')
                    {
                        newMember.homeAddress.postcode = currentHomeAddressElementNode.getText();
                    }
                    else if(currentHomeAddressElementNode.getName() == 'phone')
                    {
                        newMember.homeAddress.phone = currentHomeAddressElementNode.getText();
                    }
                    else if(currentHomeAddressElementNode.getName() == 'mobile')
                    {
                        newMember.homeAddress.mobile = currentHomeAddressElementNode.getText();
                    }                    
                    else if(currentHomeAddressElementNode.getName() == 'email')
                    {
                        newMember.homeAddress.email = currentHomeAddressElementNode.getText();
                    }
                }
            }
            //Work address
            else if(currentMemberElementNode.getName() == 'workaddress')
            {
                newMember.workAddress = new ArcI_DataMODGOVCommon.Address();
                for(Dom.XmlNode currentWorkAddressElementNode: currentMemberElementNode.getChildElements())
                {
                    if(currentWorkAddressElementNode.getName() == 'line1')
                    {
                        newMember.workAddress.line1 = currentWorkAddressElementNode.getText();
                    }
                    else if(currentWorkAddressElementNode.getName() == 'line2')
                    {
                        newMember.workAddress.line2 = currentWorkAddressElementNode.getText();
                    }
                    else if(currentWorkAddressElementNode.getName() == 'line3')
                    {
                        newMember.workAddress.line3 = currentWorkAddressElementNode.getText();
                    }
                    else if(currentWorkAddressElementNode.getName() == 'line4')
                    {
                        newMember.workAddress.line4 = currentWorkAddressElementNode.getText();
                    }
                    else if(currentWorkAddressElementNode.getName() == 'postcode')
                    {
                        newMember.workAddress.postcode = currentWorkAddressElementNode.getText();
                    }
                    else if(currentWorkAddressElementNode.getName() == 'phone')
                    {
                        newMember.workAddress.phone = currentWorkAddressElementNode.getText();
                    }
                    else if(currentWorkAddressElementNode.getName() == 'mobile')
                    {
                        newMember.workAddress.mobile = currentWorkAddressElementNode.getText();
                    }                    
                    else if(currentWorkAddressElementNode.getName() == 'email')
                    {
                        newMember.workAddress.email = currentWorkAddressElementNode.getText();
                    }
                }
            }
            //terms of office
            else if(currentMemberElementNode.getName() == 'termsofoffice')
            {
                newMember.termsOfOffice = new List<ArcI_DataMODGOVCommon.TermOfOffice>();
                for(Dom.XmlNode currentTermOfOfficeNode: currentMemberElementNode.getChildElements())
                {
                    ArcI_DataMODGOVCommon.TermOfOffice newTOOF = new ArcI_DataMODGOVCommon.TermOfOffice();
                    for(Dom.XmlNode currentTermOfOfficeElementNode: currentTermOfOfficeNode.getChildElements())
                    {
                        if(currentTermOfOfficeElementNode.getName() == 'startdate')
                        {
                            newTOOF.startDate = currentTermOfOfficeElementNode.getText();
                        }
                        else if(currentTermOfOfficeElementNode.getName() == 'enddate')
                        {
                            newTOOF.endDate = currentTermOfOfficeElementNode.getText();
                        }
                    }
                    newMember.termsOfOffice.add(newTOOF);
                }
            }
        }

        //return the member instance
        return newMember;
    }
}