/*
Company    :    Arcus Global
Product    :    Arcus DSH
Purpose    :    Test profile controller
Notes      :    
*/
@isTest
private with sharing class DSHLC_ProfileCont_Test {
	@testSetup
	private static void setup() {
		DSHLC_TestUtility.createCommunityUser();
	}

	@isTest
	private static void testGetCommunityName() {
		String result;
		System.runAs(DSHLC_TestUtility.getExistingCommunityUser()) {
			Test.startTest();
			result = DSHLC_ProfileCont.getCommunityName();
			Test.stopTest();
		}

		System.assertEquals('resident2', result, 'Incorrect community name returned, it should be the default community, resident2');
	}

	@isTest
	private static void testGetBaseUrl() {
		Test.startTest();
		String result = DSHLC_ProfileCont.getBaseUrl();
		Test.stopTest();

		System.assertEquals(true, String.isNotBlank(result), 'The url should not be null nor empty');
	}
    
    @isTest static void testGetBusinessName() {
	    User obtainedUser = null;
	    User u = [
	            SELECT 
	                User.Contact.arcshared__Company_Name__c
	            FROM 
	                User 
	            WHERE 
	                Id = :UserInfo.getUserId() 
	            LIMIT 1];

	    Test.startTest();
	    obtainedUser = DSHLC_ProfileCont.getBusinessName();
	    Test.stopTest();

	    System.assertEquals(u.Contact.arcshared__Company_Name__c, obtainedUser.Contact.arcshared__Company_Name__c, 'Business name | Expected: ' + u.Contact.arcshared__Company_Name__c + ' Actual: ' + obtainedUser.Contact.arcshared__Company_Name__c);
	}

	@isTest static void testGetContactDetails() {
		User obtainedUser = null;
	    User u = [
	            SELECT 
	                User.Contact.Id
	            FROM 
	                User 
	            WHERE 
	                Id = :UserInfo.getUserId() 
	            LIMIT 1];

	    Test.startTest();
	    obtainedUser = DSHLC_ProfileCont.getContactDetails();
	    Test.stopTest();

	    System.assertEquals(u.Contact.Id, obtainedUser.Contact.Id, 'Contact details | Expected: ' + u.Contact.Id + ' Actual: ' + obtainedUser.Contact.Id);
	}

    @isTest
	private static void testupdateBusinessName() {
		User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
		String newBusinessName = 'Smiths Bakery';
		String result;
		System.runAs(communityUser) {
			Test.startTest();
			result = DSHLC_ProfileCont.updateBusinessName(newBusinessName);
			Test.stopTest();
		}

		System.assertEquals('', result, 'Empty string should be returned as we expect no error message to be returned');

		Contact resultContact = [SELECT arcshared__Company_Name__c FROM Contact WHERE Id = :communityUser.ContactId];
		System.assertEquals(newBusinessName, resultContact.arcshared__Company_Name__c, 'The business name on the contact record should be updated to the new business name');
	}

    @isTest
	private static void testSaveCase() {
		User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
		Case result;
		String description = 'This is a case description';

		System.runAs(communityUser) {
			Test.startTest();
			result = DSHLC_ProfileCont.saveCase(description);
			Test.stopTest();
		}
		System.assertEquals('This is a case description', result.description, 'The case description should be updated to the new text');
	}

	@isTest
	private static void testUpdateEmail() {
		User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
		String newEmail = 'profilecont.test@dshlc.com';
		String result;
		System.runAs(communityUser) {
			Test.startTest();
			result = DSHLC_ProfileCont.updateEmail(newEmail);
			Test.stopTest();
		}

		System.assertEquals('', result, 'Empty string should be returned as we expect no error message to be returned');

		User resultUser = [
			SELECT Email, Username, arcshared__DSH_Email_Verified__c, arcshared__DSH_Email_Self_Updated__c
			FROM User
			WHERE Id = :communityUser.Id
		];
		System.assertEquals(newEmail, resultUser.Email, 'The email on the user record should be updated to the new email address');
		System.assertEquals(newEmail, resultUser.Username, 'The username on the user record should be updated to the new email address');
		System.assertEquals(false, resultUser.arcshared__DSH_Email_Verified__c, 'The user record should have email verified checkbox set to false so that user would need to verfiy email when login');
		System.assertEquals(true, resultUser.arcshared__DSH_Email_Self_Updated__c, 'The user record should have the email self updated checkbox set to true');
	}

	@isTest
	private static void testUpdateEmailWithError() {
		User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
		String newEmail = 'invalid.email';
		String result;
		Datetime startTime = System.now();
		System.runAs(communityUser) {
			Test.startTest();
			result = DSHLC_ProfileCont.updateEmail(newEmail);
			Test.stopTest();
		}

		System.assertEquals('Sorry, we were not able to change your address. Please try again later.', result, 'The specified error meesage should be returned as we expect an error occur');

		User resultUser = [SELECT LastModifiedDate FROM User WHERE Id = :communityUser.Id];
		System.assertEquals(true, startTime > resultUser.LastModifiedDate, 'User record last modified date should be before the start of the test since no update should happen when error occurs');
	}

	@isTest
	private static void testUpdatePhone() {
		User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
		String newPhone = '07894561230';
		String result;
		System.runAs(communityUser) {
			Test.startTest();
			result = DSHLC_ProfileCont.updatePhone(newPhone);
			Test.stopTest();
		}

		System.assertEquals('', result, 'Empty string should be returned as we expect no error message to be returned');

		Contact resultContact = [SELECT Phone FROM Contact WHERE Id = :communityUser.ContactId];
		System.assertEquals(newPhone, resultContact.Phone, 'The phone on the contact record should be updated to the new phone number');
	}

	@isTest
	private static void testUpdateMobile() {
		User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
		String newMobile = '07894561230';
		String result;
		System.runAs(communityUser) {
			Test.startTest();
			result = DSHLC_ProfileCont.updateMobile(newMobile);
			Test.stopTest();
		}

		System.assertEquals('', result, 'Empty string should be returned as we expect no error message to be returned');

		Contact resultContact = [SELECT MobilePhone FROM Contact WHERE Id = :communityUser.ContactId];
		System.assertEquals(newMobile, resultContact.MobilePhone, 'The mobile phone number on the contact record should be updated to the new mobile number');
	}

	@isTest
	private static void testUpdateName() {
		User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
		String newSalutation = 'Prof.';
		String newFirstName = 'Controller';
		String newLastName = 'Tester';
		String result;
		System.runAs(communityUser) {
			Test.startTest();
			result = DSHLC_ProfileCont.updateName(newSalutation, newFirstName, newLastName);
			Test.stopTest();
		}

		System.assertEquals('', result, 'Empty string should be returned as we expect no error message to be returned');

		Contact resultContact = [SELECT Salutation, FirstName, LastName FROM Contact WHERE Id = :communityUser.ContactId];
		System.assertEquals(newSalutation, resultContact.Salutation, 'The salutation on the contact record should be updated to the new salutation');
		System.assertEquals(newFirstName, resultContact.FirstName, 'The first name on the contact record should be updated to the new first name');
		System.assertEquals(newLastName, resultContact.LastName, 'The last name on the contact record should be updated to the new last name');
	}

	@isTest
	private static void testUpdateAddress() {
		arcusgazetteer__Location__c location1 = createLocation(1);
		arcusgazetteer__Location__c location2 = createLocation(2);
		List<arcusgazetteer__Location__c> locations = new List<arcusgazetteer__Location__c>{location1, location2};
		insert locations;

		User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
		updateContactLocation(communityUser.ContactId, location1.Id);

		String newAddressId = location2.Id;
		String result;
		System.runAs(communityUser) {
			Test.startTest();
			result = DSHLC_ProfileCont.updateAddress(newAddressId);
			Test.stopTest();
		}

		System.assertEquals('', result, 'Empty string should be returned as we expect no error message to be returned');

		Contact resultContact = [SELECT arcusgazetteer__Mailing_Address__c FROM Contact WHERE Id = :communityUser.ContactId];
		System.assertEquals(newAddressId, resultContact.arcusgazetteer__Mailing_Address__c, 'The mailing address on the contact record should be updated to the new address record');
	}

	@isTest
	private static void testUpdateAddressWithError() {
		arcusgazetteer__Location__c location = createLocation(1);
		insert location;

		User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
		updateContactLocation(communityUser.ContactId, location.Id);

		String newAddressId = arcusgazetteer__Location__c.sObjectType.getDescribe().getKeyPrefix() + '000000000991234';
		String result;
		Datetime startTime = System.now();
		System.runAs(communityUser) {
			Test.startTest();
			result = DSHLC_ProfileCont.updateAddress(newAddressId);
			Test.stopTest();
		}

		System.assertEquals('Sorry, we were not able to change your address. Please try again later.', result, 'The specified error meesage should be returned as we expect an error occur');

		Contact resultContact = [SELECT LastModifiedDate FROM Contact WHERE Id = :communityUser.ContactId];
		System.assertEquals(true, startTime > resultContact.LastModifiedDate, 'Contact record last modified date should be before the start of the test since no update should happen when error occurs');
	}

	/******************* helper methods *******************/
	private static arcusgazetteer__Location__c createLocation(Integer houseNumber) {
		arcusgazetteer__Location__c location = new arcusgazetteer__Location__c();
        location.arcusgazetteer__Address__c = houseNumber + ' test street, test city, AB1 2CD';
        location.arcusgazetteer__UPRN__c = '12345';
        location.arcusgazetteer__X_Coordinate__c = 1425;
        location.arcusgazetteer__Y_Coordinate__c = 87;
        location.arcusgazetteer__Ward__c = 'ward';
        location.arcusgazetteer__Valid_Postal_Address__c = true;

        return location;
	}

	private static void updateContactLocation(Id contactId, Id locationId) {
		Contact contact = new Contact(Id = contactId, arcusgazetteer__Mailing_Address__c = locationId);
		update contact;
	}
}