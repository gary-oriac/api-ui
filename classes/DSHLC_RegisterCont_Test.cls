/*
Company    :    Arcus Global
Product    :    Arcus DSH
Purpose    :    Test DSHLC_RegisterCont class 
Note       :    The method Site.createPortalUser always returns null,
                should be tested as Guest user, but if tested with the 
                profile Guest the profileId in the PortalRegister class
                generates an error (field not writable).
                ==>Suggestion: Site.createPortalUser and user creation should be in different classes 
*/
@isTest
public with sharing class DSHLC_RegisterCont_Test {
    private static final String DEFAULT_RESIDENT_TEST_ACCOUNT_NAME = DSHLC_RegisterCont.RESIDENT_NEW_ACCOUNT + ' - DSHLC_RegisterCont_Test';
    private static final String DEFAULT_BUSINESS_TEST_ACCOUNT_NAME = DSHLC_RegisterCont.BUSINESS_NEW_ACCOUNT + ' - DSHLC_RegisterCont_Test';

    @testSetup
    private static void setup() {
        arcusgazetteer__Location__c location = new arcusgazetteer__Location__c();
        location.arcusgazetteer__Address__c = '1 test street, test city, AB1 2CD';
        location.arcusgazetteer__UPRN__c = '12345';
        location.arcusgazetteer__X_Coordinate__c = 1425;
        location.arcusgazetteer__Y_Coordinate__c = 87;
        location.arcusgazetteer__Ward_Name__c = 'TestWard1';
        location.arcusgazetteer__Valid_Postal_Address__c = true;
        insert location;

        List<Account> accounts = new List<Account> {
            new Account(Name = DSHLC_RegisterCont.RESIDENT_NEW_ACCOUNT + ' - DSHLC_RegisterCont_Test'),
            new Account(Name = DSHLC_RegisterCont.BUSINESS_NEW_ACCOUNT + ' - DSHLC_RegisterCont_Test')
        };
        insert accounts;

        DSHLC_TestUtility.createCommunityUser();

        arcshared.AppConfigSupport.setSingleValue('DSHFeatureConfig','DSH_COUNCIL_PRIVACY_POLICY_URL', 'TestPrivacyPolicyURL');
        arcshared.AppConfigSupport.setSingleValue('DSHFeatureConfig', 'DSH_COUNCIL_TERMS_AND_CONDITIONS_URL', 'TestTermsAndConditionsURL');
        arcshared.AppConfigSupport.setSingleValue('DSHFeatureConfig', 'DSH_MISC_POSSESSIVE_DETERMINER', 'My');
        arcshared.AppConfigSupport.setSingleValue('DSHFeatureConfig', 'DSH_COUNCIL_LONG_NAME', 'Arcus Borough Council');
        arcshared.AppConfigSupport.setSingleValue('DSHFeatureConfig', 'DSH_COUNCIL_SHORT_NAME', 'AGC');
        arcshared.AppConfigSupport.refreshCache();
    }

    @isTest
    private static void testGetCommunityName() {
        Test.startTest();
        String result = DSHLC_RegisterCont.getCommunityName();
        Test.stopTest();

        System.assertEquals('resident', result, 'Wrong community name returned, it should be the default "resident" in lower case');
    }

    @isTest
    private static void testSelectAccountId() {
        Account residentAccount = [SELECT Id FROM Account WHERE Name = :DEFAULT_RESIDENT_TEST_ACCOUNT_NAME LIMIT 1];

        arcusgazetteer__Location__c location = [SELECT Id FROM arcusgazetteer__Location__c LIMIT 1];
        String mailingAddressId = (String)location.Id;

        Test.startTest();
        String result = DSHLC_RegisterCont.selectAccountId(mailingAddressId);
        Test.stopTest();

        System.assert(String.isNotBlank(result), 'Returned account Id should not be empty');
        System.assertEquals(residentAccount.Id, Id.valueOf(result), 'Incorrect account Id returned, should be the default one for Resident community');
    }

    @isTest
    private static void testSelectAccountIdCannotFoundAccount() {
        Account residentAccount = [SELECT Id FROM Account WHERE Name = :DEFAULT_RESIDENT_TEST_ACCOUNT_NAME LIMIT 1];
        delete residentAccount;

        arcusgazetteer__Location__c location = [SELECT Id FROM arcusgazetteer__Location__c LIMIT 1];
        String mailingAddressId = (String)location.Id;

        Test.startTest();
        String result;
        try {
            String accountId = DSHLC_RegisterCont.selectAccountId(mailingAddressId);
        } catch (DSHLC_RegisterCont.RegisterContException ex) {
            result = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals('Sorry, you are not able to create an account. Please contact us for more details. REG001', result, 'Custom error message not returned stating the account cannot be created with error code for account cannot be found');
    }

    @isTest
    private static void testSelectAccountIdWithIncorrectCommunity() {
        String originalCommunity = DSHLC_CommunityInfo.defaultCommunity;
        DSHLC_CommunityInfo.defaultCommunity = 'Invalid Community';

        arcusgazetteer__Location__c location = [SELECT Id FROM arcusgazetteer__Location__c LIMIT 1];
        String mailingAddressId = (String)location.Id;

        Test.startTest();
        String result;
        try {
            String accountId = DSHLC_RegisterCont.selectAccountId(mailingAddressId);
        } catch (DSHLC_RegisterCont.RegisterContException ex) {
            result = ex.getMessage();
        }
        Test.stopTest();

        DSHLC_CommunityInfo.defaultCommunity = originalCommunity;

        System.assertEquals('Sorry, you are not able to create an account. Please contact us for more details. REG002', result, 'Custom error message not returned stating the account cannot be created with the error code for incorrect community');
    }

    @isTest
    private static void testSelectAccountIdForBusinessRates() {
        String originalCommunity = DSHLC_CommunityInfo.defaultCommunity;
        DSHLC_CommunityInfo.defaultCommunity = DSHLC_CommunityInfo.DEFAULT_LIGHTNING_COMMUNITY_BUSINESS;

        Account businessAccount = [SELECT Id FROM Account WHERE Name = :DEFAULT_BUSINESS_TEST_ACCOUNT_NAME LIMIT 1];

        Test.startTest();
        String result = DSHLC_RegisterCont.selectAccountId('abc123');
        Test.stopTest();

        DSHLC_CommunityInfo.defaultCommunity = originalCommunity;

        System.assertEquals(true, String.isNotBlank(result), 'Returned account Id should not be empty');
        System.assertEquals(businessAccount.Id, Id.valueOf(result), 'Incorrect account Id returned, should be the default one for Business community');
    }

    @isTest
    private static void testSelectAccountIdForWardAccount() {
        String originalCommunity = DSHLC_CommunityInfo.defaultCommunity;
        DSHLC_CommunityInfo.defaultCommunity = DSHLC_CommunityInfo.DEFAULT_LIGHTNING_COMMUNITY_RESIDENT;

        arcusgazetteer__Location__c location = [SELECT Id, arcusgazetteer__Ward_Name__c FROM arcusgazetteer__Location__c LIMIT 1];
        String mailingAddressId = (String)location.Id;

        Account wardAccount = new Account(
            Name = 'DSHLC_RegisterCont_Test',
            arcusgazetteer__Ward_Code__c = location.arcusgazetteer__Ward_Name__c
        );
        insert wardAccount;

        Test.startTest();
        String result = DSHLC_RegisterCont.selectAccountId(mailingAddressId);
        Test.stopTest();

        DSHLC_CommunityInfo.defaultCommunity = originalCommunity;

        System.assertEquals(true, String.isNotBlank(result), 'Returned account Id should not be empty');
        System.assertEquals(wardAccount.Id, Id.valueOf(result), 'Incorrect account Id returned, should be the one corresponding to the ward of the address');
    }

    @isTest
    private static void testValidateEmailWithCorrectEmailFormat() {
        String correctEmail = 'register.class@test.com';

        Test.startTest();
        Boolean result = DSHLC_RegisterCont.validateEmail(correctEmail);
        Test.stopTest();

        System.assertEquals(true, result, 'Validation result incorrect, validation should pass for a valid email');
    }

    @isTest
    private static void testValidateEmailWithIncorrectEmailFormat() {
        String correctEmail = 'register.class.email.com';

        Test.startTest();
        Boolean result = DSHLC_RegisterCont.validateEmail(correctEmail);
        Test.stopTest();

        System.assertEquals(false, result, 'Validation result incorrect, validation should fail for an invalid email');
    }

    @isTest
    private static void testValidateUserDetailsWithAllInputsValid() {
        String communityNameLC = 'resident';
        String firstname = 'Arcus';
        String lastname = 'Global';
        String email = 'arcus.global@testclass.com';
        String password = 'abcd1234';
        String passwordRetype = 'abcd1234';
        Boolean isRetypePasswordShown = false;
        String mailingAddressText = '1 test street, test city, AB1 2CD';
        Boolean termsAndConditionsAccept = true;
        Boolean privacyPolicy = true;
        String companyName = 'Arcus Global';

        Test.startTest();
        List<String> resultErrors = DSHLC_RegisterCont.validateUserDetails(communityNameLC, firstname, lastname, email, password, passwordRetype, isRetypePasswordShown, mailingAddressText, termsAndConditionsAccept, privacyPolicy, companyName);
        Test.stopTest();

        System.assertEquals(true, resultErrors.isEmpty(), 'No error messages should be returned as all user details are valid');
    }

    @isTest
    private static void testValidateUserDetailsWithNoCompanyNameForResident() {
        String communityNameLC = 'resident';
        String firstname = 'Arcus';
        String lastname = 'Global';
        String email = 'arcus.global@testclass.com';
        String password = 'abcd1234';
        String passwordRetype = 'abcd1234';
        Boolean isRetypePasswordShown = false;
        String mailingAddressText = '1 test street, test city, AB1 2CD';
        Boolean termsAndConditionsAccept = true;
        Boolean privacyPolicy = true;
        String companyName = '';

        Test.startTest();
        List<String> resultErrors = DSHLC_RegisterCont.validateUserDetails(communityNameLC, firstname, lastname, email, password, passwordRetype, isRetypePasswordShown, mailingAddressText, termsAndConditionsAccept, privacyPolicy, companyName);
        Test.stopTest();

        System.assertEquals(true, resultErrors.isEmpty(), 'There should be no error messages since company name is not required for resdient community');
    }

    @isTest
    private static void testValidateUserDetailsWithNoCompanyNameForBusiness() {
        String communityNameLC = 'business';
        String firstname = 'Arcus';
        String lastname = 'Global';
        String email = 'arcus.global@testclass.com';
        String password = 'abcd1234';
        String passwordRetype = 'abcd1234';
        Boolean isRetypePasswordShown = false;
        String mailingAddressText = '1 test street, test city, AB1 2CD';
        Boolean termsAndConditionsAccept = true;
        Boolean privacyPolicy = true;
        String companyName = '';

        Test.startTest();
        List<String> resultErrors = DSHLC_RegisterCont.validateUserDetails(communityNameLC, firstname, lastname, email, password, passwordRetype, isRetypePasswordShown, mailingAddressText, termsAndConditionsAccept, privacyPolicy, companyName);
        Test.stopTest();

        System.assertEquals(true, resultErrors.contains('Please enter your business name'), 'Should receive error message about company name is required.');
    }

    @isTest
    private static void testValidateUserDetailsWithNoFirstname() {
        String communityNameLC = 'resident';
        String firstname = '';
        String lastname = 'Global';
        String email = 'arcus.global@testclass.com';
        String password = 'abcd1234';
        String passwordRetype = 'abcd1234';
        Boolean isRetypePasswordShown = false;
        String mailingAddressText = '1 test street, test city, AB1 2CD';
        Boolean termsAndConditionsAccept = true;
        Boolean privacyPolicy = true;
        String companyName = 'Arcus Global';

        Test.startTest();
        List<String> resultErrors = DSHLC_RegisterCont.validateUserDetails(communityNameLC, firstname, lastname, email, password, passwordRetype, isRetypePasswordShown, mailingAddressText, termsAndConditionsAccept, privacyPolicy, companyName);
        Test.stopTest();

        System.assertEquals(true, resultErrors.contains('Please enter your first name'), 'Should receive error message about firstname is required');
    }

    @isTest
    private static void testValidateUserDetailsWithNoLastname() {
        String communityNameLC = 'resident';
        String firstname = 'Arcus';
        String lastname = '';
        String email = 'arcus.global@testclass.com';
        String password = 'abcd1234';
        String passwordRetype = 'abcd1234';
        Boolean isRetypePasswordShown = false;
        String mailingAddressText = '1 test street, test city, AB1 2CD';
        Boolean termsAndConditionsAccept = true;
        Boolean privacyPolicy = true;
        String companyName = 'Arcus Global';

        Test.startTest();
        List<String> resultErrors = DSHLC_RegisterCont.validateUserDetails(communityNameLC, firstname, lastname, email, password, passwordRetype, isRetypePasswordShown, mailingAddressText, termsAndConditionsAccept, privacyPolicy, companyName);
        Test.stopTest();

        System.assertEquals(true, resultErrors.contains('Please enter your last name'), 'Should receive error message about lastname is required');
    }

    @isTest
    private static void testValidateUserDetailsWithNoEmail() {
        String communityNameLC = 'resident';
        String firstname = 'Arcus';
        String lastname = 'Global';
        String email = '';
        String password = 'abcd1234';
        String passwordRetype = 'abcd1234';
        Boolean isRetypePasswordShown = false;
        String mailingAddressText = '1 test street, test city, AB1 2CD';
        Boolean termsAndConditionsAccept = true;
        Boolean privacyPolicy = true;
        String companyName = 'Arcus Global';

        Test.startTest();
        List<String> resultErrors = DSHLC_RegisterCont.validateUserDetails(communityNameLC, firstname, lastname, email, password, passwordRetype, isRetypePasswordShown, mailingAddressText, termsAndConditionsAccept, privacyPolicy, companyName);
        Test.stopTest();

        System.assertEquals(true, resultErrors.contains('Please enter your email'), 'Should receive error message about email is required');
    }

    @isTest
    private static void testValidateUserDetailsWithEmailInWrongFormat() {
        String communityNameLC = 'resident';
        String firstname = 'Arcus';
        String lastname = 'Global';
        String email = 'arcus.global.testclass.com';
        String password = 'abcd1234';
        String passwordRetype = 'abcd1234';
        Boolean isRetypePasswordShown = false;
        String mailingAddressText = '1 test street, test city, AB1 2CD';
        Boolean termsAndConditionsAccept = true;
        Boolean privacyPolicy = true;
        String companyName = 'Arcus Global';

        Test.startTest();
        List<String> resultErrors = DSHLC_RegisterCont.validateUserDetails(communityNameLC, firstname, lastname, email, password, passwordRetype, isRetypePasswordShown, mailingAddressText, termsAndConditionsAccept, privacyPolicy, companyName);
        Test.stopTest();

        System.assertEquals(true, resultErrors.contains('Please enter an email address in the correct format, like name@example.com'), 'Should receive error message about email should be valid');
    }

    @isTest
    private static void testValidateUserDetailsWithTooLongEmail() {
        String communityNameLC = 'resident';
        String firstname = 'Arcus';
        String lastname = 'Global';
        String email = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa@testclass.com';
        String password = 'abcd1234';
        String passwordRetype = 'abcd1234';
        Boolean isRetypePasswordShown = false;
        String mailingAddressText = '1 test street, test city, AB1 2CD';
        Boolean termsAndConditionsAccept = true;
        Boolean privacyPolicy = true;
        String companyName = 'Arcus Global';

        Test.startTest();
        List<String> resultErrors = DSHLC_RegisterCont.validateUserDetails(communityNameLC, firstname, lastname, email, password, passwordRetype, isRetypePasswordShown, mailingAddressText, termsAndConditionsAccept, privacyPolicy, companyName);
        Test.stopTest();

        System.assertEquals(true, resultErrors.contains('Please enter a shorter email'), 'Should receive error message about email is being too long');
    }

    @isTest
    private static void testValidateUserDetailsWithNoAddress() {
        String communityNameLC = 'resident';
        String firstname = 'Arcus';
        String lastname = 'Global';
        String email = 'arcus.global@testclass.com';
        String password = 'abcd1234';
        String passwordRetype = 'abcd1234';
        Boolean isRetypePasswordShown = false;
        String mailingAddressText = '';
        Boolean termsAndConditionsAccept = true;
        Boolean privacyPolicy = true;
        String companyName = 'Arcus Global';

        Test.startTest();
        List<String> resultErrors = DSHLC_RegisterCont.validateUserDetails(communityNameLC, firstname, lastname, email, password, passwordRetype, isRetypePasswordShown, mailingAddressText, termsAndConditionsAccept, privacyPolicy, companyName);
        Test.stopTest();

        System.assertEquals(true, resultErrors.contains('Please enter your postcode'), 'Should receive error message about address is required');
    }

    @isTest
    private static void testValidateUserDetailsWithNoPassword() {
        String communityNameLC = 'resident';
        String firstname = 'Arcus';
        String lastname = 'Global';
        String email = 'arcus.global@testclass.com';
        String password = '';
        String passwordRetype = '';
        Boolean isRetypePasswordShown = false;
        String mailingAddressText = '1 test street, test city, AB1 2CD';
        Boolean termsAndConditionsAccept = true;
        Boolean privacyPolicy = true;
        String companyName = 'Arcus Global';

        Test.startTest();
        List<String> resultErrors = DSHLC_RegisterCont.validateUserDetails(communityNameLC, firstname, lastname, email, password, passwordRetype, isRetypePasswordShown, mailingAddressText, termsAndConditionsAccept, privacyPolicy, companyName);
        Test.stopTest();

        System.assertEquals(true, resultErrors.contains('Please enter a valid password'), 'Should receive error message about password is required');
    }

    @isTest
    private static void testValidateUserDetailsWithNoRetypePassword() {
        String communityNameLC = 'resident';
        String firstname = 'Arcus';
        String lastname = 'Global';
        String email = 'arcus.global@testclass.com';
        String password = 'abcd1234';
        String passwordRetype = '';
        Boolean isRetypePasswordShown = true;
        String mailingAddressText = '1 test street, test city, AB1 2CD';
        Boolean termsAndConditionsAccept = true;
        Boolean privacyPolicy = true;
        String companyName = 'Arcus Global';

        Test.startTest();
        List<String> resultErrors = DSHLC_RegisterCont.validateUserDetails(communityNameLC, firstname, lastname, email, password, passwordRetype, isRetypePasswordShown, mailingAddressText, termsAndConditionsAccept, privacyPolicy, companyName);
        Test.stopTest();

        System.assertEquals(true, resultErrors.contains('Please retype your password'), 'Should receive error message about password being required');
    }

    @isTest
    private static void testValidateUserDetailsWithMismatchPasswordAndRetypePassword() {
        String communityNameLC = 'resident';
        String firstname = 'Arcus';
        String lastname = 'Global';
        String email = 'arcus.global@testclass.com';
        String password = 'abcd1234';
        String passwordRetype = 'bcde2345';
        Boolean isRetypePasswordShown = true;
        String mailingAddressText = '1 test street, test city, AB1 2CD';
        Boolean termsAndConditionsAccept = true;
        Boolean privacyPolicy = true;
        String companyName = 'Arcus Global';

        Test.startTest();
        List<String> resultErrors = DSHLC_RegisterCont.validateUserDetails(communityNameLC, firstname, lastname, email, password, passwordRetype, isRetypePasswordShown, mailingAddressText, termsAndConditionsAccept, privacyPolicy, companyName);
        Test.stopTest();

        System.assertEquals(true, resultErrors.contains('Please make sure the passwords match'), 'Should receive error message about passwords have to match');
    }

    @isTest
    private static void testValidateUserDetailsWithTermsAndConditionsNotAccepted() {
        String communityNameLC = 'resident';
        String firstname = 'Arcus';
        String lastname = 'Global';
        String email = 'arcus.global@testclass.com';
        String password = 'abcd1234';
        String passwordRetype = 'abcd1234';
        Boolean isRetypePasswordShown = false;
        String mailingAddressText = '1 test street, test city, AB1 2CD';
        Boolean termsAndConditionsAccept = false;
        Boolean privacyPolicy = true;
        String companyName = 'Arcus Global';

        Test.startTest();
        List<String> resultErrors = DSHLC_RegisterCont.validateUserDetails(communityNameLC, firstname, lastname, email, password, passwordRetype, isRetypePasswordShown, mailingAddressText, termsAndConditionsAccept, privacyPolicy, companyName);
        Test.stopTest();

        System.assertEquals(true, resultErrors.contains('Please agree to the terms and conditions'), 'Should receive error message about terms and conditions must be accepted');
    }

    @isTest
    private static void testValidateUserDetailsWithPrivacyPolicyNotAccepted() {
        String communityNameLC = 'resident';
        String firstname = 'Arcus';
        String lastname = 'Global';
        String email = 'arcus.global@testclass.com';
        String password = 'abcd1234';
        String passwordRetype = 'abcd1234';
        Boolean isRetypePasswordShown = false;
        String mailingAddressText = '1 test street, test city, AB1 2CD';
        Boolean termsAndConditionsAccept = true;
        Boolean privacyPolicy = false;
        String companyName = 'Arcus Global';

        Test.startTest();
        List<String> resultErrors = DSHLC_RegisterCont.validateUserDetails(communityNameLC, firstname, lastname, email, password, passwordRetype, isRetypePasswordShown, mailingAddressText, termsAndConditionsAccept, privacyPolicy, companyName);
        Test.stopTest();

        System.assertEquals(true, resultErrors.contains('Please ensure you have read the privacy policy'), 'Should receive error message about Privacy Policy must be accepted');
    }

    @isTest
    private static void testSelfRegisterWithInvalidUserDetails() {
        arcusgazetteer__Location__c location = [SELECT Id, arcusgazetteer__Address__c FROM arcusgazetteer__Location__c LIMIT 1];

        String firstname = '';
        String lastname = 'Global';
        String email = 'arcus.global@testclass.com';
        String password = 'abcd1234';
        String passwordRetype = 'abcd1234';
        Boolean isRetypePasswordShown = false;
        String mailingAddressText = location.arcusgazetteer__Address__c;
        String mailingAddressId = (String)location.Id;
        Boolean termsAndConditionsAccept = true;
        Boolean privacyPolicy = true;
        String regConfirmUrl = '/confirm-testclass';
        String startUrl = '/start-testclass';
        String companyName = 'Arcus Global';

        Test.startTest();
        List<String> resultErrors = DSHLC_RegisterCont.selfRegister(firstname, lastname, email, password, passwordRetype, isRetypePasswordShown, mailingAddressText, mailingAddressId, termsAndConditionsAccept, privacyPolicy, regConfirmUrl, startUrl, companyName);
        Test.stopTest();

        System.assertEquals(true, resultErrors.contains('Please enter your first name'), 'Should return an error that says firstname is required');
    }

    @isTest
    private static void testSelfRegisterWithUsernameAlreadyExist() {
        User existingUser = DSHLC_TestUtility.getExistingCommunityUser();
        existingUser.Username = existingUser.Email;
        update existingUser;

        arcusgazetteer__Location__c location = [SELECT Id, arcusgazetteer__Address__c FROM arcusgazetteer__Location__c LIMIT 1];

        String firstname = 'Arcus';
        String lastname = 'Global';
        String email = existingUser.Email;
        String password = 'abcd1234';
        String passwordRetype = 'abcd1234';
        Boolean isRetypePasswordShown = false;
        String mailingAddressText = location.arcusgazetteer__Address__c;
        String mailingAddressId = (String)location.Id;
        Boolean termsAndConditionsAccept = true;
        Boolean privacyPolicy = true;
        String regConfirmUrl = '/confirm-testclass';
        String startUrl = '/start-testclass';
        String companyName = 'Arcus Global';

        Test.startTest();
        List<String> resultErrors = DSHLC_RegisterCont.selfRegister(firstname, lastname, email, password, passwordRetype, isRetypePasswordShown, mailingAddressText, mailingAddressId, termsAndConditionsAccept, privacyPolicy, regConfirmUrl, startUrl, companyName);
        Test.stopTest();

        System.assertEquals(1, resultErrors.size(), 'Expect one error message to return');
        System.assertEquals('Sorry, you are not able to create an account. Please contact us for more details. REG007', resultErrors[0], 'Incorrect error message returned, it should say the user cannot be created since the username already exist');
    }

    @isTest
    private static void testSelfRegisterWithAccountNotFound() {
        String originalCommunity = DSHLC_CommunityInfo.defaultCommunity;
        DSHLC_CommunityInfo.defaultCommunity = 'Invalid Community';

        arcusgazetteer__Location__c location = [SELECT Id, arcusgazetteer__Ward_Name__c, arcusgazetteer__Address__c FROM arcusgazetteer__Location__c LIMIT 1];

        User communityUser = DSHLC_TestUtility.getExistingCommunityUser();

        String firstname = 'Arcus';
        String lastname = communityUser.LastName;
        String email = 'test.register1@DSHLC.RegisterCont.Test.com';
        String password = 'AbcD1234';
        String passwordRetype = 'AbcD1234';
        Boolean isRetypePasswordShown = false;
        String mailingAddressText = location.arcusgazetteer__Address__c;
        String mailingAddressId = (String)location.Id;
        Boolean termsAndConditionsAccept = true;
        Boolean privacyPolicy = true;
        String regConfirmUrl = '/confirm-testclass';
        String startUrl = '/start-testclass';
        String companyName = 'Arcus Global';

        Test.startTest();
        List<String> resultErrors = DSHLC_RegisterCont.selfRegister(firstname, lastname, email, password, passwordRetype, isRetypePasswordShown, mailingAddressText, mailingAddressId, termsAndConditionsAccept, privacyPolicy, regConfirmUrl, startUrl, companyName);
        Test.stopTest();

        DSHLC_CommunityInfo.defaultCommunity = originalCommunity;

        System.assertEquals(1, resultErrors.size(), 'Expect one error message to return');
        System.assertEquals('Sorry, you are not able to create an account. Please contact us for more details. REG002', resultErrors[0], 'Incorrect error message returned, it should state the account cannot be created with the error code for incorrect community');
    }

    @isTest
    private static void testSelfRegisterWithMismatchLastnameOnExistingContact() {
        arcusgazetteer__Location__c location = [SELECT Id, arcusgazetteer__Ward_Name__c, arcusgazetteer__Address__c FROM arcusgazetteer__Location__c LIMIT 1];

        String firstname = 'Arcus';
        String lastname = 'Tester';
        String email = 'test.register1@DSHLC.RegisterCont.Test.com';
        String password = 'AbcD1234';
        String passwordRetype = 'AbcD1234';
        Boolean isRetypePasswordShown = false;
        String mailingAddressText = location.arcusgazetteer__Address__c;
        String mailingAddressId = (String)location.Id;
        Boolean termsAndConditionsAccept = true;
        Boolean privacyPolicy = true;
        String regConfirmUrl = '/confirm-testclass';
        String startUrl = '/start-testclass';
        String companyName = 'Arcus Global';

        Account residentAccount = [SELECT Id FROM Account WHERE Name = :DEFAULT_RESIDENT_TEST_ACCOUNT_NAME LIMIT 1];
        Contact existingContact = new Contact(Lastname = 'Other', Email = email, AccountId = residentAccount.Id);
        insert existingContact;

        Test.startTest();
        List<String> resultErrors = DSHLC_RegisterCont.selfRegister(firstname, lastname, email, password, passwordRetype, isRetypePasswordShown, mailingAddressText, mailingAddressId, termsAndConditionsAccept, privacyPolicy, regConfirmUrl, startUrl, companyName);
        Test.stopTest();

        System.assertEquals(true, !resultErrors.isEmpty(), 'An error should be returned as we expect one when trying to register an email that matches an existing contact under the same account record');
        System.assertEquals('Sorry, you are not able to create an account. Please contact us for more details. REG010', resultErrors[0], 'Incorrect error returned, we expect an error stating account cannot be returned with the corresponding error code REG010');
    }

    @isTest
    private static void testSelfRegister() {
        arcusgazetteer__Location__c location = [SELECT Id, arcusgazetteer__Ward_Name__c, arcusgazetteer__Address__c FROM arcusgazetteer__Location__c LIMIT 1];

        User communityUser = DSHLC_TestUtility.getExistingCommunityUser();

        Account communityAccount = [SELECT Id FROM Account WHERE Id = :communityUser.Contact.AccountId];
        communityAccount.arcusgazetteer__Ward_Code__c = location.arcusgazetteer__Ward_Name__c;
        update communityAccount;

        String firstname = 'Arcus';
        String lastname = communityUser.LastName;
        String email = 'test.register1@DSHLC.RegisterCont.Test.com';
        String password = 'AbcD1234';
        String passwordRetype = 'AbcD1234';
        Boolean isRetypePasswordShown = false;
        String mailingAddressText = location.arcusgazetteer__Address__c;
        String mailingAddressId = (String)location.Id;
        Boolean termsAndConditionsAccept = true;
        Boolean privacyPolicy = true;
        String regConfirmUrl = '/confirm-testclass';
        String startUrl = '/start-testclass';
        String companyName = 'Arcus Global';

        List<String> resultErrors;

        Test.startTest();
        System.runAs(communityUser) { // Just to simulate the communityUser have been created if it ever get to the point to create a new user
            resultErrors = DSHLC_RegisterCont.selfRegister(firstname, lastname, email, password, passwordRetype, isRetypePasswordShown, mailingAddressText, mailingAddressId, termsAndConditionsAccept, privacyPolicy, regConfirmUrl, startUrl, companyName);
        }
        Test.stopTest();

        System.assertEquals(null, resultErrors, 'No errors should be returned');
        Contact contactResult = [SELECT arcshared__Company_Name__c, arcshared__Community__c, arcusgazetteer__Mailing_Address__c FROM Contact WHERE Id = :communityUser.ContactId];
        System.assertEquals('Arcus Global', contactResult.arcshared__Company_Name__c, 'Company name not set correctly on registered contact record');
        System.assertEquals('Resident', contactResult.arcshared__Community__c, 'Community name not set correctly in sentence case on registered contact record');
        System.assertEquals(mailingAddressId, contactResult.arcusgazetteer__Mailing_Address__c, 'Mailing address not set correctly on registered contact record');
    }

    @isTest
    private static void testGetCouncilPrivacyPolicyURL(){
        Test.startTest();
        String result = DSHLC_RegisterCont.getCouncilPrivacyPolicyURL();
        Test.stopTest();

        System.assertEquals('TestPrivacyPolicyURL', result, 'Should return correct custom setting');
    }

    @isTest
    private static void testGetCouncilTermsAndConditionsURL(){
        Test.startTest();
        String result = DSHLC_RegisterCont.getCouncilTermsAndConditionsURL();
        Test.stopTest();

        System.assertEquals('TestTermsAndConditionsURL', result, 'Should return correct custom setting');
    }

    @isTest
    private static void testAssembleUser() {
        Account residentAccount = [SELECT Id FROM Account WHERE Name = :DEFAULT_RESIDENT_TEST_ACCOUNT_NAME LIMIT 1];

        String firstname = 'Arcus';
        String lastname = 'Global';
        String email = 'arcus.global@testclass.com';
        String password = 'abcd1234';

        Boolean termsAndConditionsAccept = true;
        Boolean privacyPolicy = true;

        Test.startTest();
        User u = DSHLC_RegisterCont.assembleUserObject(email, firstname, lastname, termsAndConditionsAccept,  privacyPolicy);
        
        System.Assert(u !=  null);
        Test.stopTest();
    }

    @isTest
    private static void testQueryMatchingContacts() {
        String communityNameSC = 'Resident';
        String firstname = 'Arcus';
        String lastname = 'Global';
        String email = 'arcus.global@testclass.com';

        Account account = new Account(Name = 'Test Account');
        insert account;
        String accountId = account.Id;

        Contact contact = new Contact(
            FirstName = firstname, 
            LastName = lastname, 
            Email = email,
            AccountId = account.Id
        );
        insert contact;

        Test.startTest();
        List<Contact> result = DSHLC_RegisterCont.queryMatchingContacts(email, accountId);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should be able to find contacts by email.');
    }

    @isTest
    private static void testUpdateContact() {
        User communityUser = DSHLC_TestUtility.getExistingCommunityUser();

        String userId = communityUser.Id;

        String firstname = 'Arcus';
        String companyName = 'Test Register';
        String community = DSHLC_CommunityInfo.defaultCommunity.toLowerCase().capitalize().removeEnd('2');

        arcusgazetteer__Location__c location = [SELECT Id, arcusgazetteer__Ward_Name__c FROM arcusgazetteer__Location__c LIMIT 1];
        String mailingAddressId = (String)location.Id;

        Account communityAccount = [SELECT Id FROM Account WHERE Id = :communityUser.Contact.AccountId];
        communityAccount.arcusgazetteer__Ward_Code__c = location.arcusgazetteer__Ward_Name__c;
        update communityAccount;

        Test.startTest();
        DSHLC_RegisterCont.updateContact(userId, firstname, companyName, mailingAddressId);
        Test.stopTest();

        Contact result = [SELECT Id, FirstName, arcshared__Company_Name__c, arcshared__Community__c, arcusgazetteer__Mailing_Address__c FROM Contact WHERE Id = :communityUser.ContactId];
        System.assertEquals('Arcus', result.FirstName, 'First name not updated');
        System.assertEquals('Test Register', result.arcshared__Company_Name__c, 'Company name not updated');
        System.assertEquals(community, result.arcshared__Community__c, 'Community not updated');
        System.assertEquals(mailingAddressId, result.arcusgazetteer__Mailing_Address__c, 'Community not updated');
    }
    
    @isTest
    private static void testSendConfirmationEmailForLinkingContactsForResident() {
        String firstname = 'Arcus';
        String lastname = 'Global';
        String email = 'arcus.global@testclass.com';
        Test.startTest();
        String result = DSHLC_RegisterCont.sendConfirmationEmailForLinkingContacts(firstname, lastname, email);
        Test.stopTest();

        System.assertEquals(true, String.isNotBlank(result), 'Email body should not be empty');

        String expectedEmailBody = 'Dear Arcus Global,';
        expectedEmailBody += '<br/><br/>Thank you for completing the registration for your AGC My Account.';
        expectedEmailBody += '<br/><br/>As you previously had an online account with Arcus Borough Council, your details ';
        expectedEmailBody += '<br/>have been transferred to your new AGC My Account. Please review the "My ';
        expectedEmailBody += 'Details" section of your My Account to ensure these are up to date.';
        System.assertEquals(expectedEmailBody, result, 'Email body is incorrect');
    }

    @isTest
    private static void testSendConfirmationEmailForLinkingContactsForBusiness() {
        String originalCommunity = DSHLC_CommunityInfo.defaultCommunity;
        DSHLC_CommunityInfo.defaultCommunity = DSHLC_CommunityInfo.DEFAULT_LIGHTNING_COMMUNITY_BUSINESS;

        String firstname = 'Arcus';
        String lastname = 'Global';
        String email = 'arcus.global@testclass.com';
        Test.startTest();
        String result = DSHLC_RegisterCont.sendConfirmationEmailForLinkingContacts(firstname, lastname, email);
        Test.stopTest();

        DSHLC_CommunityInfo.defaultCommunity = originalCommunity;

        System.assertEquals(true, String.isNotBlank(result), 'Email body should not be empty');

        String expectedEmailBody = 'Dear Arcus Global,';
        expectedEmailBody += '<br/><br/>Thank you for completing the registration for your online Business Account.';
        expectedEmailBody += '<br/><br/>As you previously had an online account with Arcus Borough Council, your details ';
        expectedEmailBody += '<br/>have been transferred to your new online Business Account. Please review the "My ';
        expectedEmailBody += 'Details" section of your account to ensure these are up to date.';
        System.assertEquals(expectedEmailBody, result, 'Email body is incorrect');
    }

    @isTest
    private static void testSendEmail(){
         String fakeEmailAddress = 'fake@arcus.mail';
         String emailBody = 'fake email body';
         String subject = 'fake subject';

        Test.startTest();
            Boolean result = DSHLC_RegisterCont.sendEmail(fakeEmailAddress,subject,emailBody);
            System.assertEquals(true, result, 'Should return true if mail is sent');
        Test.stopTest();

    }

}