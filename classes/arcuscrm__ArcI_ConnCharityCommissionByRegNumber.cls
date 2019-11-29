public with sharing class ArcI_ConnCharityCommissionByRegNumber extends ArcI_ConnCharityCommissionMain
{
	@TestVisible private static final String WEB_SERVICE = 'GetCharityByRegisteredCharityNumber';
	public override String getWebserviceName()
	{
		return WEB_SERVICE;
	}
	/**
     * Creates web service request XML
     */
    public override void createRequestBody(Dom.XmlNode envelope)
    {
		System.debug('<ARCUS CRM - ArcI_ConnCharityCommissionByRegNumber.createRequestBody()> envelope: ' + envelope);

        Dom.XmlNode bodyNode = createBodyNode(envelope);
		bodyNode.addChildElement('APIKey', NAMESPACE_CHAR, PREFIX_CHAR).addTextNode(ArcI_UtilityConfigSettings.CHARITY_COMMS_API_KEY);
    	bodyNode.addChildElement('registeredCharityNumber', NAMESPACE_CHAR, PREFIX_CHAR).addTextNode(((arcuscrm.ArcI_DataCharityCommission)dataObject).charityNumber);
    }

    public override void parseResponseBody(Dom.XmlNode respBodyNode)
	{
		System.debug('<ARCUS CRM - ArcI_ConnCharityCommissionByRegNumber.parseResponseBody()> Debugging respBodyNode: ' + respBodyNode);
		
		Dom.XmlNode getCharityRespNode = respBodyNode.getChildElement(getWebserviceName() + 'Response', NAMESPACE_CHAR);
		System.debug('<ARCUS CRM - ArcI_ConnCharityCommissionByRegNumber.parseResponseBody()> getCharityRespNode: ' + String.valueOF(getCharityRespNode));
		Dom.XmlNode getCharityResultNode = getCharityRespNode.getChildElement(getWebserviceName() + 'Result', NAMESPACE_CHAR);
		System.debug('<ARCUS CRM - ArcI_ConnCharityCommissionByRegNumber.parseResponseBody()> getCharityResultNode: ' + getCharityResultNode);

		fillData(getCharityResultNode);
	}

    /**
     * Parse the response Xml and populate the response properties on the dataObject
     */
    public override void fillData(Dom.XmlNode resultNode)
	{
		System.debug('<ARCUS CRM - ArcI_ConnCharityCommissionByRegNumber.fillData()> resultNode: ' + resultNode);

		Dom.XmlNode charityNameNode = resultNode.getChildElement('CharityName', NAMESPACE_CHAR);
		//System.debug('<ARCUS CRM - ArcI_ConnCharityCommissionByRegNumber.fillData()> charityNameNode: ' + charityNameNode);
		Dom.XmlNode charityWorkingNamesNode = resultNode.getChildElement('WorkingNames', NAMESPACE_CHAR);
		//System.debug('<ARCUS CRM - ArcI_ConnCharityCommissionByRegNumber.fillData()> charityWorkingNamesNode: ' + charityWorkingNamesNode);
		Dom.XmlNode charityRegNumberNode = resultNode.getChildElement('RegisteredCharityNumber', NAMESPACE_CHAR);
		//System.debug('<ARCUS CRM - ArcI_ConnCharityCommissionByRegNumber.fillData()> charityRegNumberNode: ' + charityRegNumberNode);
		Dom.XmlNode companyNumberNode = resultNode.getChildElement('RegisteredCompanyNumber', NAMESPACE_CHAR);
		//System.debug('<ARCUS CRM - ArcI_ConnCharityCommissionByRegNumber.fillData()> companyNumberNode: ' + companyNumberNode);
		Dom.XmlNode activitiesNode = resultNode.getChildElement('Activities', NAMESPACE_CHAR);
		//System.debug('<ARCUS CRM - ArcI_ConnCharityCommissionByRegNumber.fillData()> activitiesNode: ' + activitiesNode);
		Dom.XmlNode areaOfOpNode = resultNode.getChildElement('AreaOfOperation', NAMESPACE_CHAR);
		//System.debug('<ARCUS CRM - ArcI_ConnCharityCommissionByRegNumber.fillData()> areaOfOpNode: ' + areaOfOpNode);
		Dom.XmlNode orgTypeNode = resultNode.getChildElement('OrganisationType', NAMESPACE_CHAR);
		//System.debug('<ARCUS CRM - ArcI_ConnCharityCommissionByRegNumber.fillData()> orgTypeNode: ' + orgTypeNode);
		Dom.XmlNode suspendedNode = resultNode.getChildElement('IsSuspended', NAMESPACE_CHAR);
		//System.debug('<ARCUS CRM - ArcI_ConnCharityCommissionByRegNumber.fillData()> suspendedNode: ' + suspendedNode);
		Dom.XmlNode insolventNode = resultNode.getChildElement('Insolvent', NAMESPACE_CHAR);
		//System.debug('<ARCUS CRM - ArcI_ConnCharityCommissionByRegNumber.fillData()> insolventNode: ' + insolventNode);

		if(nodeExists(charityNameNode)) getData().CharityName = charityNameNode.getText().normalizeSpace();
		if(nodeExists(charityWorkingNamesNode)) getData().WorkingNames = charityWorkingNamesNode.getText().normalizeSpace();
		if(String.isNotEmpty(getData().WorkingNames) && getData().WorkingNames.endsWithIgnoreCase('~O'))
		{
			getData().WorkingNames = getData().WorkingNames.removeEndIgnoreCase('~O');
		}
		if(nodeExists(charityRegNumberNode)) getData().RegisteredCharityNumber = charityRegNumberNode.getText();
		if(nodeExists(companyNumberNode)) getData().RegisteredCompanyNumber = companyNumberNode.getText();
		//getData().DocumentsOverdue = xyzdNode.getText();//????
		if(nodeExists(activitiesNode)) getData().Activities = activitiesNode.getText().normalizeSpace();
		if(nodeExists(areaOfOpNode)) getData().AreaOfOperation = areaOfOpNode.getText().normalizeSpace();
		if(nodeExists(orgTypeNode)) getData().OrganisationType = orgTypeNode.getText().normalizeSpace(); // R- Registered(?) / RM - Removed
		if(nodeExists(suspendedNode)) getData().IsSuspended = suspendedNode.getText() == 'true' ? true : false;
		if(nodeExists(insolventNode)) getData().Insolvent = insolventNode.getText() == '0' ? false : true;
		

		//iterate over all nodes and populate the lists; also check for accounts or returns overdue
		List<arcuscrm.ArcI_DataCharityCommission.Submission> subs = new List<arcuscrm.ArcI_DataCharityCommission.Submission>();
		List<arcuscrm.ArcI_DataCharityCommission.Trustee> trustees = new List<arcuscrm.ArcI_DataCharityCommission.Trustee>();
		for(Dom.XmlNode currentNode: resultNode.getChildElements()) 
		{
			if(currentNode.getName() == 'LatestFiling')
			{
				Dom.XmlNode accountsDueNode = currentNode.getChildElement('HasRecieveAccountsForDue', NAMESPACE_CHAR);
				Dom.XmlNode returnDueNode = currentNode.getChildElement('HasRecieveAnnualReturnForDue', NAMESPACE_CHAR);
				if(nodeExists(accountsDueNode) && nodeExists(returnDueNode))
				{
					String hasRecieveAccountsForDueTxtValue = accountsDueNode.getText();//'false' OR 'true'
					String hasRecieveAnnualReturnForDue = returnDueNode.getText(); // '0' OR '1'
					getData().DocumentsOverdue = (hasRecieveAccountsForDueTxtValue == 'false' || hasRecieveAnnualReturnForDue == '0') ? true : false;
				}
			}
			//registration History
			if(currentNode.getName() == 'RegistrationHistory')
			{
				arcuscrm.ArcI_DataCharityCommission.RegistrationHistory regHist = new arcuscrm.ArcI_DataCharityCommission.RegistrationHistory();
				for(Dom.XmlNode currentRegHistChildNode: currentNode.getChildElements()) 
				{
					if(currentRegHistChildNode.getName() == 'RegistrationDate')  regHist.RegistrationDate = currentRegHistChildNode.getText();	
					if(currentRegHistChildNode.getName() == 'RegistrationRemovalDate')  regHist.RegistrationRemovalDate = currentRegHistChildNode.getText();
				}
				getData().RegistrationHistory = regHist;
			}
			//AccountingSubmissions
			if(currentNode.getName() == 'Submission')
			{
				arcuscrm.ArcI_DataCharityCommission.Submission newSub = new arcuscrm.ArcI_DataCharityCommission.Submission();
				for(Dom.XmlNode currentSubChildNode: currentNode.getChildElements()) 
				{
					if(currentSubChildNode.getName() == 'MailingCycle')  newSub.MailingCycle = currentSubChildNode.getText();	
					if(currentSubChildNode.getName() == 'FyStart')  newSub.FyStart = currentSubChildNode.getText();
					if(currentSubChildNode.getName() == 'FyEnd')  newSub.FyEnd = currentSubChildNode.getText();
					if(currentSubChildNode.getName() == 'AnnualReturnReceivedDate')  newSub.AnnualReturnReceivedDate = currentSubChildNode.getText();
					if(currentSubChildNode.getName() == 'AccountsReturnReceivedDate')  newSub.AccountsReturnReceivedDate = currentSubChildNode.getText();
					if(currentSubChildNode.getName() == 'GrossIncome')  newSub.GrossIncome = currentSubChildNode.getText();
					if(currentSubChildNode.getName() == 'TotalExpenditure')  newSub.TotalExpenditure = currentSubChildNode.getText();
				}
				subs.add(newSub);
			}
			//CharityAddress
			if(currentNode.getName() == 'Address')
			{
				arcuscrm.ArcI_DataCharityCommission.CharityAddress addr = new arcuscrm.ArcI_DataCharityCommission.CharityAddress();
				for(Dom.XmlNode currentAddrNode: currentNode.getChildElements()) 
				{
					if(currentAddrNode.getName() == 'Line1')  addr.Line1 = currentAddrNode.getText();	
					if(currentAddrNode.getName() == 'Line2')  addr.Line2 = currentAddrNode.getText();
					if(currentAddrNode.getName() == 'Line3')  addr.Line3 = currentAddrNode.getText();
					if(currentAddrNode.getName() == 'Line4')  addr.Line4 = currentAddrNode.getText();
					if(currentAddrNode.getName() == 'Line5')  addr.Line5 = currentAddrNode.getText();
					if(currentAddrNode.getName() == 'Postcode')  addr.Postcode = currentAddrNode.getText();
				}
				getData().CharityAddress = addr;
			}
			if(currentNode.getName() == 'Trustees')
			{
				arcuscrm.ArcI_DataCharityCommission.Trustee trust = new arcuscrm.ArcI_DataCharityCommission.Trustee();
				for(Dom.XmlNode currentTrusteeChildNode: currentNode.getChildElements()) 
				{
					if(currentTrusteeChildNode.getName() == 'TrusteeNumber')  trust.TrusteeNumber = currentTrusteeChildNode.getText();	
					if(currentTrusteeChildNode.getName() == 'TrusteeName')  trust.TrusteeName = currentTrusteeChildNode.getText().trim();
					if(currentTrusteeChildNode.getName() == 'RelatedCharitiesCount')  trust.RelatedCharitiesCount = currentTrusteeChildNode.getText();
				}
				trustees.add(trust);
			}
		}

		if(subs.size() > 0) getData().AccountingSubmissions = subs;
		if(trustees.size() > 0) getData().Trustees = trustees;
	}

	private Boolean nodeExists(Dom.XmlNode theXmlNode)
	{
		return theXmlNode != null ? true : false;
	}
}