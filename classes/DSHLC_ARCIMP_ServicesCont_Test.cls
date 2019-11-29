/*
Author     :    James Yu
Company    :    Arcus Global
Product    :    Arcus DSHLC
Date       :    15/11/17
Purpose    :    Test class for DSHLC_ARCIMP_ServicesCont
Modified   :    
*/
@isTest
private class DSHLC_ARCIMP_ServicesCont_Test {

	@testSetup
	private static void setup() {
		System.runAs(DSHLC_TestUtility.createSysAdminUserWithRole()) {
			List<arcshared__Council_Service_Area__c> serviceAreaList = new List<arcshared__Council_Service_Area__c>();
			serviceAreaList.add(new arcshared__Council_Service_Area__c(Name = 'Area 1', Icon_Class__c = 'Icon 1', arcshared__Status__c = 'Active', arcshared__Ranking__c = 3, arcshared__Community__c = 'Resident'));
			serviceAreaList.add(new arcshared__Council_Service_Area__c(Name = 'Area 2', Icon_Class__c = 'Icon 2', arcshared__Status__c = 'InActive', arcshared__Ranking__c = 2, arcshared__Community__c = 'Resident'));
			serviceAreaList.add(new arcshared__Council_Service_Area__c(Name = 'Area 3', Icon_Class__c = 'Icon 3', arcshared__Status__c = 'Active', arcshared__Ranking__c = 1, arcshared__Community__c = 'Resident'));
			serviceAreaList.add(new arcshared__Council_Service_Area__c(Name = 'Navigation 4', Icon_Class__c = 'Icon 4', arcshared__Status__c = 'Active', arcshared__Ranking__c = 4, arcshared__Community__c = 'Resident'));
			insert serviceAreaList;

			List<arcshared__Council_Service__c> serviceList = new List<arcshared__Council_Service__c>();
			serviceList.add(new arcshared__Council_Service__c(Name = 'Service 1', arcshared__Service_URL__c = 'url1/', arcshared__Process_Type__c = 'Lightning DSH', arcshared__Description__c = 'Test 1', arcshared__Council_Service_Area__c = serviceAreaList[0].Id, arcshared__Status__c = 'Active', arcshared__Ranking__c = 2, arcshared__Community__c = 'Resident'));
			serviceList.add(new arcshared__Council_Service__c(Name = 'Service 2', arcshared__Service_URL__c = 'url2/', arcshared__Process_Type__c = 'Lightning DSH', arcshared__Description__c = 'Test 2', arcshared__Council_Service_Area__c = serviceAreaList[0].Id, arcshared__Status__c = 'Active', arcshared__Ranking__c = 1, arcshared__Community__c = 'Resident'));
			serviceList.add(new arcshared__Council_Service__c(Name = 'Service 3', arcshared__Service_URL__c = 'url3/', arcshared__Process_Type__c = 'Lightning DSH', arcshared__Description__c = 'Test 3', arcshared__Council_Service_Area__c = serviceAreaList[2].Id, arcshared__Status__c = 'Active', arcshared__Ranking__c = 1, arcshared__Community__c = 'Resident'));
			serviceList.add(new arcshared__Council_Service__c(Name = 'Service 4', arcshared__Service_URL__c = 'url4/', arcshared__Process_Type__c = 'Lightning DSH', arcshared__Description__c = 'Test 4', arcshared__Council_Service_Area__c = serviceAreaList[2].Id, arcshared__Status__c = 'Inactive', arcshared__Ranking__c = 2, arcshared__Community__c = 'Resident'));
			insert serviceList;

			DSHLC_TestUtility.createCommunityUserWithoutCreateSysAdmin();
			DSHLC_ConfigSettingsInstall.insertAllSettings();
		}
	}
	
	@isTest
	private static void testGetCommunityName() {
		User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
		System.runAs(communityUser) {
			Test.startTest();
			String result = DSHLC_ARCIMP_ServicesCont.getCommunityName();
			Test.stopTest();

			System.assertEquals('resident2', result, 'Incorrect community name returned, it should be the default community, resident2');
		}
	}


	@isTest
	private static void testMakeQueryStringForLoggedInUser() {
		User loggedInUser = DSHLC_TestUtility.getExistingCommunityUser();
		System.runAs(loggedInUser) {
			Test.startTest();
			String result = DSHLC_ARCIMP_ServicesCont.makeQueryString();
			Test.stopTest();

			System.assert(result.contains('?firstname=' + loggedInUser.FirstName), 'The logged in user first name is not in the query string');
			System.assert(result.contains('&sessionexpires='), 'The query string is missing the token named "sessionexpires"');
			System.assert(result.contains('&community=resident'), 'The correct community name is not in the query string, the community should be the default one, resident');
		}
	}

	@isTest
	private static void testGetCouncilCMSWebsiteURL() {
		Test.startTest();
		String result = DSHLC_ARCIMP_ServicesCont.getCouncilCMSWebsiteURL();
		Test.stopTest();

		System.assertEquals('https://www.arcusglobal.com', result, 'Wrong url returned, it should be the value stored in the custom setting DSH_COUNCIL_CMS_WEBSITE_URL');
	}

	@isTest
	private static void testServiceWrapperConstructorLightningService() {
		System.runAs(DSHLC_TestUtility.getExistingCommunityUser()) {
			arcshared__Council_Service__c service = new arcshared__Council_Service__c();
			service.Name = 'Test Service';
			service.arcshared__Service_URL__c = 'test-dsh';
			service.arcshared__Process_Type__c = 'Lightning DSH';
			service.arcshared__Description__c = 'Testing DSH';
			
            insert service;
            
			Test.startTest();
			DSHLC_ARCIMP_ServicesCont.ServiceWrapper result = new DSHLC_ARCIMP_ServicesCont.ServiceWrapper(service);
			Test.stopTest();

			System.assertEquals('Test Service', result.Name, 'Wrong service name, it should the name on the service record');
            System.assertEquals('/resident2/s/test-dsh?council_service_id='+service.Id , result.ServiceURL, 'Wrong url returned, it should be in the format in "/(community name)/s/(service url on service record)?council_service_id=(record id)"');
			System.assertEquals('Testing DSH', result.Description, 'Wrong description returned, it should be the same as the description on the service record');
		}
	}

	@isTest
	private static void testServiceWrapperConstructorVisualforceService() {
		System.runAs(DSHLC_TestUtility.getExistingCommunityUser()) {
			arcshared__Council_Service__c service = new arcshared__Council_Service__c();
			service.Name = 'Test Service';
			service.arcshared__Service_URL__c = 'test-dsh';
			service.arcshared__Process_Type__c = 'Visualforce DSH';
			service.arcshared__Description__c = 'Testing DSH';

			Test.startTest();
			DSHLC_ARCIMP_ServicesCont.ServiceWrapper result = new DSHLC_ARCIMP_ServicesCont.ServiceWrapper(service);
			Test.stopTest();

			System.assertEquals('Test Service', result.Name, 'Wrong service name, it should the name on the service record');
			//System.assertEquals('/resident/test-dsh', result.ServiceURL, 'Wrong url returned, it should be in the format in "/(community name)/s/(service url on service record)"');
			System.assertEquals('Testing DSH', result.Description, 'Wrong description returned, it should be the same as the description on the service record');
		}
	}

	@isTest
	private static void testServiceWrapperConstructorExternalService() {
		System.runAs(DSHLC_TestUtility.getExistingCommunityUser()) {
			arcshared__Council_Service__c service = new arcshared__Council_Service__c();
			service.Name = 'Test Service';
			service.arcshared__Service_URL__c = 'test-dsh';
			service.arcshared__Process_Type__c = 'External';
			service.arcshared__Description__c = 'Testing DSH';

			Test.startTest();
			DSHLC_ARCIMP_ServicesCont.ServiceWrapper result = new DSHLC_ARCIMP_ServicesCont.ServiceWrapper(service);
			Test.stopTest();

			System.assertEquals('Test Service', result.Name, 'Wrong service name, it should the name on the service record');
			System.assertEquals('test-dsh', result.ServiceURL, 'Wrong url returned, as the URL is external it shouldnt have any reference to DSH');
			System.assertEquals('Testing DSH', result.Description, 'Wrong description returned, it should be the same as the description on the service record');
		}
	}


	@isTest
	private static void testServiceWrapperConstructorCMSWebsiteService() {
			
		System.runAs(DSHLC_TestUtility.getExistingCommunityUser()) {
            String councilCMS = DSHLC_ARCIMP_ServicesCont.getCouncilCMSWebsiteURL();
			arcshared__Council_Service__c service = new arcshared__Council_Service__c();
			service.Name = 'Test Service';
			service.arcshared__Service_URL__c = councilCMS + '/test-dsh';
			service.arcshared__Process_Type__c = 'CMS Website';
			service.arcshared__Description__c = 'Testing DSH';
			 
			Test.startTest();
           
			DSHLC_ARCIMP_ServicesCont.ServiceWrapper result = new DSHLC_ARCIMP_ServicesCont.ServiceWrapper(service);
			Test.stopTest();

			System.assertEquals('Test Service', result.Name, 'Wrong service name, it should the name on the service record');
			System.assert(result.ServiceURL.contains(councilCMS), 'The query string is missing the Council CMS URL');


			System.assert(result.ServiceURL.contains('&sessionexpires='), 'The query string is missing the token named "sessionexpires"');
			System.assert(result.ServiceURL.contains('&community=resident'), 'The correct community name is not in the query string, the community should be the default one, resident');

			System.assertEquals('Testing DSH', result.Description, 'Wrong description returned, it should be the same as the description on the service record');
		}
	}

	@isTest
	private static void testServiceAreaWrapperConstructor() {
		arcshared__Council_Service_Area__c serviceArea = [
			SELECT Name, Icon_Class__c, arcshared__Description__c, (SELECT Name, arcshared__Service_URL__c, arcshared__Process_Type__c, arcshared__Description__c, arcuscrm__Flow_Name__c FROM arcshared__Council_Services__r)
			FROM arcshared__Council_Service_Area__c WHERE Name = 'Area 1' LIMIT 1
		];

		System.runAs(DSHLC_TestUtility.getExistingCommunityUser()) {
			Test.startTest();
			DSHLC_ARCIMP_ServicesCont.ServiceAreaWrapper result = new DSHLC_ARCIMP_ServicesCont.ServiceAreaWrapper(serviceArea);
			Test.stopTest();

			System.assertEquals('Area 1', result.Name, 'Wrong name returned, it should be the name on the service area record');
			System.assertEquals('Icon 1', result.IconClass, 'Wrong icon class returned, it should be the sames as the Icon_Class__c on the service area record');
			System.assertEquals(2, result.services.size(), 'Wrong number of service wrappers attached to the service area wrapper, it should be 2');
		}
	}

	@isTest
	private static void testGetCouncilServiceArea() {
		System.runAs(DSHLC_TestUtility.getExistingCommunityUser()) {
			Test.startTest();
			List<DSHLC_ARCIMP_ServicesCont.ServiceAreaWrapper> result = DSHLC_ARCIMP_ServicesCont.getCouncilServiceArea();
			Test.stopTest();

			System.assertEquals(2, result.size(), 'Wrong number of service area, it should only include the ones that are active');
			System.assertEquals('Area 3', result[0].Name, 'The service area is in the wrong order, it should be ordered by arcshared__Ranking__c on the service area records in ascending order');
			System.assertEquals('Area 1', result[1].Name, 'The service area is in the wrong order, it should be ordered by arcshared__Ranking__c on the service area records in ascending order');

			System.assertEquals(1, result[0].services.size(), 'Wrong number of services related to the service area, it should only include the ones that are active and the arcshared__Council_Service_Area__c is set to the service area');
			System.assertEquals('Service 3', result[0].services[0].Name, 'Wrong related service, it should be the one that is active');

			System.assertEquals(2, result[1].services.size(), 'Wrong number of services related to the service area, it should only include the ones that are active and the arcshared__Council_Service_Area__c is set to the service area');
			System.assertEquals('Service 2', result[1].services[0].Name, 'Related services are in the wrong order, the services should be ordered by arcshared__Ranking__c in ascending order');
			System.assertEquals('Service 1', result[1].services[1].Name, 'Related services are in the wrong order, the services should be ordered by arcshared__Ranking__c in ascending order');
		}
	}
}