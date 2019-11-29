/*
    Author     :    James Yu
    Company    :    Arcus Global
    Product    :    DSH Lightning Community
    Date       :    04/12/2017
    Purpose    :    Test class for the Contact trigger handler class, DSHLC_ContactTriggerHandler
    Notes      :    
    Modified   :    
*/
@isTest
private class DSHLC_ContactTriggerHandler_Test {
    @testSetup
    private static void setup() {
        System.runAs(DSHLC_TestUtility.createSysAdminUserWithRole()) {
            List<arcshared.AppConfigSupport.setting> dispatcherSettings = new List<arcshared.AppConfigSupport.setting>();
            Map<String, List<arcshared.AppConfigSupport.setting>> categoryToSettingsMap = new Map<String, List<arcshared.AppConfigSupport.setting>>();
            dispatcherSettings.add(new arcshared.AppConfigSupport.setting('DSH_CONTACT_TRIGGER_HANDLER', 'TriggerSetting', 'DSHLC_ContactTriggerHandler,Contact,10000', 'DSHLC_ContactTriggerHandler,Contact,10000', 10000, true, false));
            categoryToSettingsMap.put('TriggerHandlers', dispatcherSettings);
            arcshared.AppConfigSupport.setCategoryRecords(categoryToSettingsMap, 'arcusdsh');

            Account account = DSHLC_TestUtility.createAccount('Test Account', null, true);
            Id profileId = DSHLC_TestUtility.getProfileId(DSHLC_TestUtility.COMMUNITY_PROFILE_NAME_RESIDENT);

            Contact contact1 = DSHLC_TestUtility.createContact(account.Id, 'testerAFirst', 'testerALast', 'tester.a@test.dsh', 'community', false);
            Contact contact2 = DSHLC_TestUtility.createContact(account.Id, 'testerBFirst', 'testerBLast', 'tester.b@test.dsh', 'community', false);
            Contact contact3 = DSHLC_TestUtility.createContact(account.Id, 'testerCFirst', 'testerCLast', 'tester.c@test.dsh', 'community', false);
            List<Contact> contactList = new List<Contact> {contact1, contact2, contact3};
            insert contactList;

            User user1 = DSHLC_TestUtility.createUser(contactList[0].FirstName, contactList[0].Lastname, contactList[0].Email, contactList[0].Email, profileId, null, (String)contactList[0].Id, false);
            User user2 = DSHLC_TestUtility.createUser(contactList[1].FirstName, contactList[1].Lastname, contactList[1].Email, contactList[1].Email, profileId, null, (String)contactList[1].Id, false);
            User user3 = DSHLC_TestUtility.createUser(contactList[2].FirstName, contactList[2].Lastname, contactList[2].Email, contactList[2].Email, profileId, null, (String)contactList[2].Id, false);
            List<User> userList = new List<User> {user1, user2, user3};
            insert userList;
        }
    }

    @isTest
    private static void testUpdateContactDetails() {
        List<User> communityUsers = [SELECT Id, ContactId FROM User WHERE Email = 'tester.a@test.dsh' OR Email = 'tester.b@test.dsh' ORDER BY Email ASC];

        List<Contact> contactList = new List<Contact>();
        contactList.add(new Contact(Id = communityUsers[0].ContactId, Firstname = 'NewFirstNameA', Lastname = 'NewLastNameA', Email = 'new.email.a@test.com'));
        contactList.add(new Contact(Id = communityUsers[1].ContactId, Firstname = 'NewFirstNameB', Lastname = 'NewLastNameB', Email = 'new.email.b@test.com'));

        System.runAs(DSHLC_TestUtility.createSysAdminUserWithRole()) {
            Test.startTest();
            update contactList;
            Test.stopTest();

            List<User> results = [SELECT Firstname, Lastname, Email, Username, arcshared__DSH_Email_Verified__c FROM User WHERE Id IN :communityUsers ORDER BY Email ASC];
            System.assertEquals('NewFirstNameA', results[0].Firstname, 'Firstname not updated on User record');
            System.assertEquals('NewLastNameA', results[0].Lastname, 'Lastname not updated on User record');
            System.assertEquals('new.email.a@test.com', results[0].Email, 'Email not updated on User record');
            System.assertEquals('new.email.a@test.com', results[0].Username, 'Username not updated on User record, it should be the new email');
            System.assertEquals(false, results[0].arcshared__DSH_Email_Verified__c, 'Email verification should be set to false on the User record to request new verification');

            System.assertEquals('NewFirstNameB', results[1].Firstname, 'Firstname not updated on User record');
            System.assertEquals('NewLastNameB', results[1].Lastname, 'Lastname not updated on User record');
            System.assertEquals('new.email.b@test.com', results[1].Email, 'Email not updated on User record');
            System.assertEquals('new.email.b@test.com', results[1].Username, 'Username not updated on User record, it should be the new email');
            System.assertEquals(false, results[1].arcshared__DSH_Email_Verified__c, 'Email verification should be set to false on the User record to request new verification');
        }
    }

    @isTest
    private static void testContactDetailsNotUpdatedDueToEmailAlreadyUsed() {
        User communityUser = [SELECT Id, ContactId, Firstname, Lastname, Email, Username FROM User WHERE Email = 'tester.a@test.dsh' LIMIT 1];

        Contact communityContact = new Contact(Id = communityUser.ContactId);
        communityContact.Firstname = 'NewFirstName';
        communityContact.Lastname = 'NewLastName';
        communityContact.Email = 'tester.b@test.dsh';

        System.runAs(DSHLC_TestUtility.createSysAdminUserWithRole()) {
            Test.startTest();
            Database.SaveResult dmlResult = Database.update(communityContact, false);
            Test.stopTest();

            System.assertEquals(false, dmlResult.isSuccess(), 'User should not be updated due to custom error on email already been used');
            System.assertEquals('This Email is already allocated to another user', dmlResult.getErrors()[0].getMessage(), 'Error message does not include the message about email already been used');

            User userResult = [SELECT Firstname, Lastname, Email, Username, arcshared__DSH_Email_Verified__c FROM User WHERE Id = :communityUser.Id];
            System.assertEquals(communityUser.Firstname, userResult.Firstname, 'Firstname should not be updated on User record');
            System.assertEquals(communityUser.Lastname, userResult.Lastname, 'Lastname should not be updated on User record');
            System.assertEquals(communityUser.Email, userResult.Email, 'Email should not be updated on User record');
            System.assertEquals(communityUser.Username, userResult.Username, 'Username should not be updated on User record');
            System.assertEquals(true, userResult.arcshared__DSH_Email_Verified__c, 'Email verification should remain true as email is not allowed to be changed');
        }
    }

    @isTest
    private static void testUpdateContactDetailsForPartialPortionOfRecords() {
        List<User> communityUsers = [SELECT Id, ContactId, Firstname, Lastname, Email, Username FROM User WHERE Email = 'tester.a@test.dsh' OR Email = 'tester.b@test.dsh' ORDER BY Email ASC];

        List<Contact> contactList = new List<Contact>();
        contactList.add(new Contact(Id = communityUsers[0].ContactId, Firstname = 'NewFirstNameA', Lastname = 'NewLastNameA', Email = 'tester.c@test.dsh'));
        contactList.add(new Contact(Id = communityUsers[1].ContactId, Firstname = 'NewFirstNameB', Lastname = 'NewLastNameB', Email = 'tester.d@test.dsh'));

        System.runAs(DSHLC_TestUtility.createSysAdminUserWithRole()) {
            Test.startTest();
            List<Database.SaveResult> dmlResults = Database.update(contactList, false);
            Test.stopTest();

            System.assertEquals(false, dmlResults[0].isSuccess(), 'Update for the first contact should fail due to email already used');
            System.assertEquals('This Email is already allocated to another user', dmlResults[0].getErrors()[0].getMessage(), 'Custom error message for email already used is not added as an error');

            System.assertEquals(true, dmlResults[1].isSuccess(), 'Update for the second contact should succeed');

            List<User> userResults = [SELECT Firstname, Lastname, Email, Username, arcshared__DSH_Email_Verified__c FROM User WHERE Id IN :communityUsers ORDER BY Email ASC];

            System.assertEquals(communityUsers[0].Firstname, userResults[0].Firstname, 'Firstname should not be updated on User record');
            System.assertEquals(communityUsers[0].Lastname, userResults[0].Lastname, 'Lastname should not be updated on User record');
            System.assertEquals(communityUsers[0].Email, userResults[0].Email, 'Email should not be updated on User record');
            System.assertEquals(communityUsers[0].Username, userResults[0].Username, 'Username should not be updated on User record');
            System.assertEquals(true, userResults[0].arcshared__DSH_Email_Verified__c, 'Email verification should remain true as email is not allowed to be changed');

            System.assertEquals('NewFirstNameB', userResults[1].Firstname, 'Firstname not updated on User record');
            System.assertEquals('NewLastNameB', userResults[1].Lastname, 'Lastname not updated on User record');
            System.assertEquals('tester.d@test.dsh', userResults[1].Email, 'Email not updated on User record');
            System.assertEquals('tester.d@test.dsh', userResults[1].Username, 'Username not updated on User record, it should be the new email');
            System.assertEquals(false, userResults[1].arcshared__DSH_Email_Verified__c, 'Email verification should be set to false on the User record to request new verification');
        }
    }
}