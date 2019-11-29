/*
Author     :    James Yu
Company    :    Arcus Global
Product    :    Arcus DSHLC
Date       :    14/11/17
Purpose    :    Test class for DSHLC_HeaderCont
Modified   :    
*/
@isTest
private class DSHLC_HeaderCont_Test {

	@testSetup
	private static void setup() {
		System.runAs(DSHLC_TestUtility.createSysAdminUserWithRole()) {
			DSHLC_TestUtility.createCommunityUserWithoutCreateSysAdmin();
			DSHLC_ConfigSettingsInstall.insertAllSettings();
		}
	}

	@isTest
	private static void testGetCommunityName() {
		Test.startTest();
		String result = DSHLC_HeaderCont.getCommunityName();
		Test.stopTest();

		System.assertEquals('resident2', result, 'Incorrect community name returned, it should be the default community, resident2');
	}

	@isTest
	private static void testGetCommunityPath() {
		Test.startTest();
		String result = DSHLC_HeaderCont.getCommunityPath();
		Test.stopTest();

		System.assertEquals('resident2/s/', result, 'Incorrect community path, it should be the community name follwed by /s/');
	}

	@isTest
	private static void testGetCopyrightYear() {
		String currentYear = String.valueOf(Date.today().year());

		Test.startTest();
		String result = DSHLC_HeaderCont.getCopyrightYear();
		Test.stopTest();

		System.assertEquals(currentYear, result, 'Incorrect year returned, it should be the current year');
	}

	@isTest
	private static void testCommunityUserIsIdentifiedAsLoggedInUser() {
		System.runAs(DSHLC_TestUtility.getExistingCommunityUser()) {
			Test.startTest();
			Boolean result = DSHLC_HeaderCont.isLoggedInUser();
			Test.stopTest();

			System.assert(result, 'Community user is not been identified as a logged in user which is wrong, only guest user are not logged in');
		}
	}

	@isTest
	private static void testGetLoggedInUserId() {
		User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
		System.runAs(communityUser) {
			Test.startTest();
			String result = DSHLC_HeaderCont.getUserId();
			Test.stopTest();

			System.assertEquals(communityUser.Id, result, 'The returned user id is wrong, it should be the id of current running user, the community user');
		}
	}

	@isTest
	private static void testGetLoggedInUserFirstName() {
		User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
		System.runAs(communityUser) {
			Test.startTest();
			String result = DSHLC_HeaderCont.getFirstName();
			Test.stopTest();

			System.assertEquals(communityUser.FirstName, result, 'The returned user first name is wrong, it should be the id of current running user, the community user');
		}
	}

	@isTest
	private static void testGetUserContactId() {
		User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
		System.runAs(communityUser) {
			Test.startTest();
			String result = DSHLC_HeaderCont.getContactId();
			Test.stopTest();

			System.assertEquals(communityUser.ContactId, result, 'The returned contact id is wrong, it should be the contact id of current running user, the community user');
		}
	}

	@isTest
	private static void testGetCouncilLongName() {
		Test.startTest();
		String result = DSHLC_HeaderCont.getCouncilLongName();
		Test.stopTest();

		System.assertEquals('Arcus Borough Council', result, 'Wrong council name returned, it should be the value stored in the custom setting DSH_COUNCIL_LONG_NAME');
	}

	@isTest
	private static void testGetCouncilCMSWebsiteURL() {
		Test.startTest();
		String result = DSHLC_HeaderCont.getCouncilCMSWebsiteURL();
		Test.stopTest();

		System.assertEquals('https://www.arcusglobal.com', result, 'Wrong url returned, it should be the value stored in the custom setting DSH_COUNCIL_CMS_WEBSITE_URL');
	}

	@isTest
	private static void testMakeQueryStringForLoggedInUser() {
		User loggedInUser = DSHLC_TestUtility.getExistingCommunityUser();
		System.runAs(loggedInUser) {
			Test.startTest();
			String result = DSHLC_HeaderCont.makeQueryString();
			Test.stopTest();

			System.assert(result.contains('?firstname=' + loggedInUser.FirstName), 'The logged in user first name is not in the query string');
			System.assert(result.contains('&sessionexpires='), 'The query string is missing the token named "sessionexpires"');
			System.assert(result.contains('&community=resident'), 'The correct community name is not in the query string, the community should be the default one, resident');
		}
	}
}