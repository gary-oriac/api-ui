public virtual with sharing class ArcI_ConnCompaniesHouseMain extends arcshared.ArcI_ConnMainRest
{
	public override String getActionUrl()
	{
        return 'callout:arcuscrm__' + arcuscrm.ArcI_UtilityCreds.getNamedCredentials('companiesHouse') +'/'+ getCompaniesHouseData().companyNumber + (getCompaniesHouseData().getOfficers ? '/officers' : '');
	}

	public override HttpRequest createRequest()
	{
		System.debug('<ARCUS CRM - ArcI_ConnCompaniesHouseMain.createRequest()> creating the request...');

		request = new HttpRequest();
		request.setEndPoint(getActionUrl());
		request.setMethod('GET');//ArcI core Conn class sets each request's method to 'POST' by default, so we need to explicitly change it for our scenario here
		//add custom headers for this API request
		addAPIHeader();

		String bodyRequest = createRequestBody();//ArcI core Conn class requires that we call the method (even if we do not need to set the body) 
		// if (String.isNotEmpty(bodyRequest)) request.setBody(bodyRequest); - CALLING THE FOOD RATING API DOES NOT REQUIRE FOR THE BODY TO BE SET
		return request;
	}

	public override void addAPIHeader()
	{
		request.setHeader('Authorization', 'Basic ' + arcuscrm.ArcI_UtilityConfigSettings.COMPANIES_HOUSE_API_KEY);
		System.debug('<ARCUS CRM - ArcI_ConnCompaniesHouseMain.addAPIHeader()> custom HTTP headers added');
    }

    public override String createRequestBody()
    {
		System.debug('<ARCUS CRM - ArcI_ConnCompaniesHouseMain.createRequestBody()> creating req body...');

        //no need to do anything
        return '';
    }

   	protected arcuscrm.ArcI_DataCompaniesHouse getCompaniesHouseData(){return (arcuscrm.ArcI_DataCompaniesHouse) dataObject;}


    public override void parseResponseBody(System.HttpResponse response)
	{
		System.debug('<ARCUS CRM - ArcI_ConnCompaniesHouseMain.parseResponseBody()> response.Body: ' + response.getBody());

        String jsonToDeserialize = response.getBody();
        // System.debug('jsonToDeserialize: '+jsonToDeserialize);

		if(getCompaniesHouseData().getOfficers == true)
		{
			getCompaniesHouseData().CompanyOfficersData = (arcuscrm.ArcI_DataCompaniesHouse.CompaniesHouseOfficers)JSON.deserialize(jsonToDeserialize, arcuscrm.ArcI_DataCompaniesHouse.CompaniesHouseOfficers.class);
		}
		else
		{
			getCompaniesHouseData().CompanyData = (arcuscrm.ArcI_DataCompaniesHouse.CompaniesHouseData)JSON.deserialize(jsonToDeserialize, arcuscrm.ArcI_DataCompaniesHouse.CompaniesHouseData.class);
		}
	}

}

    // public override virtual void parseResponseBody(HttpResponse response) {
	// 	System.debug('<ARCUS CRM - ARCUS> RESPONSE: '+response.getBody());
	// 	System.debug('<ARCUS CRM - ARCUS> STATUS: '+response.getStatus());
	// 	System.debug('<ARCUS CRM - ARCUS> STATUS CODE: '+response.getStatusCode());
	// 	System.debug('<ARCUS CRM - ARCUS> SUCCESS:'+dataObject.isSuccess);
		
	// 	parseResponseBody(response);
	// }