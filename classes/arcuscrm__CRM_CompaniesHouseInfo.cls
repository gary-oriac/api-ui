public with sharing class CRM_CompaniesHouseInfo {
    
    // Pass in the endpoint to be used using the string url
	@AuraEnabled
	public static Map < String, Object > getCalloutResponseContents(String url) {
 
		// Instantiate a new http object
		Http h = new Http();
 
		// Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
		HttpRequest req = new HttpRequest();
		req.setEndpoint(url);
		req.setMethod('GET');
 		req.setHeader('Authorization', 'Basic bFpYV0R5Wmt3SG52MEZHQWJwTDhMdHVHWXpYemFwamFiQm15SHRLLTo=');
		// Send the request, and return a response
		HttpResponse res = h.send(req);
		System.debug('response:--> ' + res.getBody());
 
		// Deserialize the JSON string into collections of primitive data types.
		Map < String, Object > resultsMap = (Map < String, Object > ) JSON.deserializeUntyped(res.getBody());
		system.debug('resultsMap-->' + resultsMap);
 
		return resultsMap;
	}


	@AuraEnabled(continuation=true cacheable=true)
	public static String getCompanyInfo(String companyNumber)
	{
		//System.debug('<ARCU CRM - CRM_CompaniesHouseInfo.getCompanyInfo(companyNumber)> companyNumber >>> ' + companyNumber);
		arcuscrm.ArcI_DataCompaniesHouse pData = new arcuscrm.ArcI_DataCompaniesHouse();
		pData.companyNumber = companyNumber;
		pData.getOfficers = false;
		
		//call the api
		return arcuscrm.ArcI_ServiceCompaniesHouse.getCompaniesHouseData(pData);
	}

	@AuraEnabled(continuation=true cacheable=true)
	public static String getCompanyOfficers(String companyNumber)
	{
		//System.debug('<ARCU CRM - CRM_CompaniesHouseInfo.getCompanyOfficers(companyNumber)> companyNumber >>> ' + companyNumber);
		arcuscrm.ArcI_DataCompaniesHouse pData = new arcuscrm.ArcI_DataCompaniesHouse();
		pData.companyNumber = companyNumber;
		pData.getOfficers = true;
		
		//call the api
		return arcuscrm.ArcI_ServiceCompaniesHouse.getCompaniesHouseData(pData);
	}

}