/*
Author     :    James Yu
Company    :    Arcus Global
Product    :    Arcus DSHLC
Date       :    14/11/17
Purpose    :    Test class for DSHLC_UserContact_Test
Modified   :    
*/
@isTest
public with sharing class DSHLC_UserContact_Test {

    @testSetup
    private static void setupTestData() {
        System.runAs(DSHLC_TestUtility.createSysAdminUserWithRole()) {
            //insert locations
            arcusgazetteer__Location__c location = new arcusgazetteer__Location__c();
            location.arcusgazetteer__Address__c = '111 Street, testCity, testCounty, AB123CD, UK';   
            location.arcusgazetteer__UPRN__c = '12345';
            location.arcusgazetteer__X_Coordinate__c = 1425;
            location.arcusgazetteer__Y_Coordinate__c = 87;
            location.arcusgazetteer__Ward__c = 'ward';
            location.arcusgazetteer__Postcode__c = 'AB1 1CD';
            location.arcusgazetteer__Street__c = 'test street';
            insert location;

            DSHLC_TestUtility.createCommunityUserWithoutCreateSysAdmin();
        }
    }

    @isTest
    private static void getUserContactTest() {
        User portalUser = DSHLC_TestUtility.getExistingCommunityUser();
        System.runAs(portalUser) {

            // For the created user, use the DSHLC_UserContact.getUserContact() method to return the user.
            Test.startTest();
            User result = DSHLC_UserContact.getUserContact();
            Test.stopTest();

            System.assertEquals(portalUser.Contact.FirstName, result.Contact.FirstName);
        }
    }

    @isTest
    private static void getUserContactAddressTest_LinkedToExistingLocation() {
        User testUser = DSHLC_TestUtility.getExistingCommunityUser();

        arcusgazetteer__Location__c location = [Select Id, arcusgazetteer__Address__c From arcusgazetteer__Location__c Limit 1];

        //update the user contact's mailing address details
        Contact testDSHLC_UserContact = [Select Id From Contact Where Id = :testUser.ContactId];
        testDSHLC_UserContact.arcusgazetteer__Mailing_Address__c = location.Id;
        update testDSHLC_UserContact;

        System.runAs(testUser) {
            Test.startTest();
            String DSHLC_UserContactAddress = DSHLC_UserContact.getUserContactAddress();
            Test.stopTest();

            System.assertEquals(location.arcusgazetteer__Address__c, DSHLC_UserContactAddress);
        }
    }

    @isTest
    private static void getUserContactAddressTest_NotLinkedToExistingLocation() {
        User testUser = DSHLC_TestUtility.getExistingCommunityUser();
        System.assertNotEquals(null, testUser.Id);

        arcusgazetteer__Location__c location = [Select Id From arcusgazetteer__Location__c Limit 1];

        //update the user contact's mailing address details
        Contact testDSHLC_UserContact = [Select Id From Contact Where Id = :testUser.ContactId];
        
        String street = '123Street';
        String city = 'testCity';
        String state = 'testState';
        String postcode = 'QQ999ZZ';
        String country = 'UK';
        testDSHLC_UserContact.MailingStreet = street;
        testDSHLC_UserContact.MailingCity = city;
        testDSHLC_UserContact.MailingState = state;
        testDSHLC_UserContact.MailingPostalCode = postcode;
        testDSHLC_UserContact.MailingCountry = country;
        update testDSHLC_UserContact;

        System.runAs(testUser) {
            String DSHLC_UserContactAddress = DSHLC_UserContact.getUserContactAddress();
            System.assert(DSHLC_UserContactAddress.containsIgnoreCase(street));
            System.assert(DSHLC_UserContactAddress.containsIgnoreCase(city));
            System.assert(DSHLC_UserContactAddress.containsIgnoreCase(state));
            System.assert(DSHLC_UserContactAddress.containsIgnoreCase(postcode));
            System.assert(DSHLC_UserContactAddress.containsIgnoreCase(country));
        }

        // set the parts of the mailing address details to be empty strings
        // blank mailing street
        testDSHLC_UserContact.MailingStreet = '';         
        update testDSHLC_UserContact;

        System.runAs(testUser) {
            String DSHLC_UserContactAddress = DSHLC_UserContact.getUserContactAddress();
            System.assert(!DSHLC_UserContactAddress.containsIgnoreCase(street));
            System.assert(DSHLC_UserContactAddress.containsIgnoreCase(city));
            System.assert(DSHLC_UserContactAddress.containsIgnoreCase(state));
            System.assert(DSHLC_UserContactAddress.containsIgnoreCase(postcode));
            System.assert(DSHLC_UserContactAddress.containsIgnoreCase(country));
        }

        // blank mailing city
        testDSHLC_UserContact.MailingCity = '';
        update testDSHLC_UserContact;

        System.runAs(testUser) {
            String DSHLC_UserContactAddress = DSHLC_UserContact.getUserContactAddress();
            System.assert(!DSHLC_UserContactAddress.containsIgnoreCase(street));
            System.assert(!DSHLC_UserContactAddress.containsIgnoreCase(city));
            System.assert(DSHLC_UserContactAddress.containsIgnoreCase(state));
            System.assert(DSHLC_UserContactAddress.containsIgnoreCase(postcode));
            System.assert(DSHLC_UserContactAddress.containsIgnoreCase(country));
        }

        // blank mailing state
        testDSHLC_UserContact.MailingState = '';
        update testDSHLC_UserContact;

        System.runAs(testUser) {
            String DSHLC_UserContactAddress = DSHLC_UserContact.getUserContactAddress();
            System.assert(!DSHLC_UserContactAddress.containsIgnoreCase(street));
            System.assert(!DSHLC_UserContactAddress.containsIgnoreCase(city));
            System.assert(!DSHLC_UserContactAddress.containsIgnoreCase(state));
            System.assert(DSHLC_UserContactAddress.containsIgnoreCase(postcode));
            System.assert(DSHLC_UserContactAddress.containsIgnoreCase(country));
        }

        // blank mailing postal code
        testDSHLC_UserContact.MailingPostalCode = '';
        update testDSHLC_UserContact;

        System.runAs(testUser) {
            String DSHLC_UserContactAddress = DSHLC_UserContact.getUserContactAddress();
            System.assert(!DSHLC_UserContactAddress.containsIgnoreCase(street));
            System.assert(!DSHLC_UserContactAddress.containsIgnoreCase(city));
            System.assert(!DSHLC_UserContactAddress.containsIgnoreCase(state));
            System.assert(!DSHLC_UserContactAddress.containsIgnoreCase(postcode));
            System.assert(DSHLC_UserContactAddress.containsIgnoreCase(country));
        }

        // blank mailing country
        testDSHLC_UserContact.MailingCountry = '';
        update testDSHLC_UserContact;

        System.runAs(testUser) {
            String DSHLC_UserContactAddress = DSHLC_UserContact.getUserContactAddress();
            System.assert(!DSHLC_UserContactAddress.containsIgnoreCase(street));
            System.assert(!DSHLC_UserContactAddress.containsIgnoreCase(city));
            System.assert(!DSHLC_UserContactAddress.containsIgnoreCase(state));
            System.assert(!DSHLC_UserContactAddress.containsIgnoreCase(postcode));
            System.assert(!DSHLC_UserContactAddress.containsIgnoreCase(country));
        }
    }
}