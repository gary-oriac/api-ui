public virtual with sharing class ArcI_ConnMyAreaMain extends arcshared.ArcI_ConnMainRest
{
	public override String getActionUrl()
	{
        return 'callout:' + ArcI_UtilityCredsCUSTOM.getNamedCredentialsName('fhdcMyArea')+'//?u='+getMyAreaData().uprn+'&k='+ArcI_UtilityConfigCUSTOM.MY_AREA_API_KEY;
	}

    public override void addAPIHeader()
	{
		// request.setHeader('Content-Type', 'application/json');
		request.setHeader('Accept-Encoding', 'gzip, deflate');
        request.setTimeout(120000);
    }
    public override String createRequestBody()
    {
        //no need to do anything
        return '"test":"test"';
    }

   	protected ArcI_DataMyArea getMyAreaData(){return (ArcI_DataMyArea) dataObject;}


    public override void parseResponseBody(System.HttpResponse response)
	{
		System.debug('<ArcI_ConnMyAreaMain.parseResponseBody()> response.Body: ' + response.getBody());

        String jsonToDeserialize = response.getBody();
        jsonToDeserialize = jsonToDeserialize.replaceFirst('([a-zA-Z]*)TownCouncil', 'TownCouncil');
        jsonToDeserialize = jsonToDeserialize.replaceFirst('([a-zA-Z]*)Special([a-zA-Z]*)', 'Special');
        // jsonToDeserialize = jsonToDeserialize.replace('Kent County Council', 'KentCountyCouncil');
        // jsonToDeserialize = jsonToDeserialize.replace('Kent Fire And Rescue Service', 'KentFireAndRescueService');
        // jsonToDeserialize = jsonToDeserialize.replace('The Police And Crime Commissioner For Kent', 'ThePoliceAndCrimeCommissionerFor');
        // jsonToDeserialize = jsonToDeserialize.replace('Folkestone And Hythe District Council', 'FolkestoneAndHytheDistrictCouncil');
        // jsonToDeserialize = jsonToDeserialize.replace('Kcc Adult Social Care', 'KccAdultSocialCare');
        // jsonToDeserialize = jsonToDeserialize.replace('Hawkinge Town Council', 'HawkingeTownCouncil');

        // jsonToDeserialize = jsonToDeserialize.replaceAll('Last Collection', 'LastCollection');
        // jsonToDeserialize = jsonToDeserialize.replaceAll('Next Collection', 'NextCollection');
        // jsonToDeserialize = jsonToDeserialize.replaceAll('Future Collection', 'FutureCollection');
        // System.debug('jsonToDeserialize: '+jsonToDeserialize);

		getMyAreaData().MyAreaData = (ArcI_DataMyArea.MyAreaData)JSON.deserialize(jsonToDeserialize, ArcI_DataMyArea.MyAreaData.class);
	}

    // public override virtual void parseResponseBody(HttpResponse response) {
	// 	System.debug('<ARCUS> RESPONSE: '+response.getBody());
	// 	System.debug('<ARCUS> STATUS: '+response.getStatus());
	// 	System.debug('<ARCUS> STATUS CODE: '+response.getStatusCode());
	// 	System.debug('<ARCUS> SUCCESS:'+dataObject.isSuccess);
		
	// 	parseResponseBody(response);
	// }
}