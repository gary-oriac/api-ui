public virtual with sharing class ArcI_ConnFoodRatingMain  extends arcshared.ArcI_ConnMainRest
{
	public override String getActionUrl()
	{
		// return 'https://api.ratings.food.gov.uk/establishments/506429';
        return 'callout:arcuscrm__' + arcuscrm.ArcI_UtilityCreds.getNamedCredentials('foodRating')+'/establishments/'+getFoodRatingData().foodRatingRegNumber;
	}

	public override HttpRequest createRequest()
	{
		System.debug('<ARCUS CRM - ArcI_ConnFoodRatingMain.createRequest()> creating the request...');

		request = new HttpRequest();
		request.setEndPoint(getActionUrl());
		request.setMethod('GET');//ArcI core Conn class sets each request's method to 'POST' by default so we need to explicitly change it for our scenario here
		//add custom headers for this API request
		addAPIHeader();

		String bodyRequest = createRequestBody();//ArcI core Conn class requires that we call the method (even if we do not need to set the body) 
		// if (String.isNotEmpty(bodyRequest)) request.setBody(bodyRequest); - CALLING THE FOOD RATING API DOES NOT REQUIRE FOR THE BODY TO BE SET
		return request;
	}

	public override void addAPIHeader()
	{
		request.setHeader('x-api-version', '2'); //REQUIRED BY THE api; IF NOT PRESENT RETURNS AN ERROR
		System.debug('<ARCUS CRM - ArcI_ConnFoodRatingMain.addAPIHeader()> custom HTTP headers added');
    }

    public override String createRequestBody()
    {
		System.debug('<ARCUS CRM - ArcI_ConnFoodRatingMain.createRequestBody()> creating req body...');
		// System.debug('getEndpoint():' + request.getEndpoint());
		// System.debug('request:' + request.getMethod());
		// System.debug('getHeader(x-api-version):' + request.getHeader('x-api-version'));
		// System.debug('getBody():' + request.getBody());

        //no need to do anything
        return '';
    }

   	protected arcuscrm.ArcI_DataFoodRating getFoodRatingData(){return (arcuscrm.ArcI_DataFoodRating) dataObject;}


    public override void parseResponseBody(System.HttpResponse response)
	{
		System.debug('<ARCUS CRM - ArcI_ConnFoodRatingMain.parseResponseBody()> response.Body: ' + response.getBody());

        String jsonToDeserialize = response.getBody();
        // System.debug('jsonToDeserialize: '+jsonToDeserialize);

		getFoodRatingData().FoodRatingData = (arcuscrm.ArcI_DataFoodRating.FoodRatingData)JSON.deserialize(jsonToDeserialize, arcuscrm.ArcI_DataFoodRating.FoodRatingData.class);
	}

    // public override virtual void parseResponseBody(HttpResponse response) {
	// 	System.debug('<ARCUS CRM - ARCUS> RESPONSE: '+response.getBody());
	// 	System.debug('<ARCUS CRM - ARCUS> STATUS: '+response.getStatus());
	// 	System.debug('<ARCUS CRM - ARCUS> STATUS CODE: '+response.getStatusCode());
	// 	System.debug('<ARCUS CRM - ARCUS> SUCCESS:'+dataObject.isSuccess);
		
	// 	parseResponseBody(response);
	// }
}