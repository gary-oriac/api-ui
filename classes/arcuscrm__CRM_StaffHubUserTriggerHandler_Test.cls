@isTest
public class CRM_StaffHubUserTriggerHandler_Test {

    @TestSetup
    static void setup(){
        insertCustomSettings();
    }

    private static void insertCustomSettings(){
        arcshared.AppConfigSupport.setCategoryRecords(CRM_DataUtilities.APPCONFIG_CATEGORY_FOR_TRIGGER_DEFINITIONS, CRM_StaffHubUserTriggerHandler.TRIGGER_SETTINGS);
        arcshared.AppConfigSupport.refreshCache();
    }

/* 
 .d8888b.                                             888      88888888888                888             
d88P  Y88b                                            888          888                    888             
888    888                                            888          888                    888             
888         .d88b.  88888b.   .d88b.  888d888 8888b.  888          888   .d88b.  .d8888b  888888 .d8888b  
888  88888 d8P  Y8b 888 "88b d8P  Y8b 888P"      "88b 888          888  d8P  Y8b 88K      888    88K      
888    888 88888888 888  888 88888888 888    .d888888 888          888  88888888 "Y8888b. 888    "Y8888b. 
Y88b  d88P Y8b.     888  888 Y8b.     888    888  888 888          888  Y8b.          X88 Y88b.       X88 
 "Y8888P88  "Y8888  888  888  "Y8888  888    "Y888888 888          888   "Y8888   88888P'  "Y888  88888P' 
 */

    @isTest
    private static void insertTrigger_NewStaffHubUser_ContactCreatedAndLinked(){
        User userToInsert = CRM_StaffHubUtils.returnNewUsersWithoutProfile(1)[0];
        userToInsert.profileId = CRM_StaffHubUtils.TEST_STAFF_PROFILEID;
        userToInsert.arcuscrm__Should_Have_Linked_Staff_Contact__c = true;

        List<Contact> contactsBefore = [SELECT Id FROM Contact];

        Integer expectedNumberOfContacts = 1;

        Test.startTest();
            insert userToInsert;
        Test.stopTest();

        List<Contact> contactsAfter = [SELECT Id, LastName, arcuscrm__Linked_Internal_User__c FROM Contact ORDER BY CreatedDate DESC];
        Integer actualNumberOfContacts = contactsAfter.size() - contactsBefore.size();

        User userAfter = [SELECT Id, LastName, arcuscrm__Employee_Contact_Id__c FROM User WHERE Id =: userToInsert.Id LIMIT 1];

        System.assertEquals(expectedNumberOfContacts, actualNumberOfContacts, 'When a new staff hub user is inserted, a matching contact record should be inserted.');
        System.assertEquals(userToInsert.Id, contactsAfter[0].arcuscrm__Linked_Internal_User__c, 'When a new staff hub user is inserted, a matching contact record should be inserted looking up to the user.');
        // System.assertEquals(contactsAfter[0].Id, userAfter.arcuscrm__Employee_Contact_Id__c, 'When a new staff hub user is inserted, a matching contact record should be inserted and the user should then lookup to the contact.');
        System.assertEquals(contactsAfter[0].LastName, userAfter.LastName, 'When a new staff hub user is inserted, a matching contact record should be inserted.');
    }

    @isTest
    private static void insertTrigger_NewUserCorrectProfile_setCheckboxToTrue(){
        User userToInsert = CRM_StaffHubUtils.returnNewUsersWithoutProfile(1)[0];
        userToInsert.profileId = CRM_StaffHubUtils.TEST_STAFF_PROFILEID;

        Test.startTest();
            insert userToInsert;
        Test.stopTest();

        User userAfter = [SELECT Id, LastName, arcuscrm__Should_Have_Linked_Staff_Contact__c FROM User WHERE Id =: userToInsert.Id LIMIT 1];

        System.assert(!userToInsert.arcuscrm__Should_Have_Linked_Staff_Contact__c, 'Before being inserted, the user should not have Should_Have_Linked_Staff_Contact ticked.');
        System.assert(userAfter.arcuscrm__Should_Have_Linked_Staff_Contact__c, 'After being inserted, the user should have Should_Have_Linked_Staff_Contact ticked.');
    }

/* 
888b     d888          888    888                    888      88888888888                888             
8888b   d8888          888    888                    888          888                    888             
88888b.d88888          888    888                    888          888                    888             
888Y88888P888  .d88b.  888888 88888b.   .d88b.   .d88888          888   .d88b.  .d8888b  888888 .d8888b  
888 Y888P 888 d8P  Y8b 888    888 "88b d88""88b d88" 888          888  d8P  Y8b 88K      888    88K      
888  Y8P  888 88888888 888    888  888 888  888 888  888          888  88888888 "Y8888b. 888    "Y8888b. 
888   "   888 Y8b.     Y88b.  888  888 Y88..88P Y88b 888          888  Y8b.          X88 Y88b.       X88 
888       888  "Y8888   "Y888 888  888  "Y88P"   "Y88888          888   "Y8888   88888P'  "Y888  88888P' 
 */

    @isTest
    private static void markUsersAsStaffHub_oneUser(){
        List<User> input = new List<User>();
        input.add(new User(arcuscrm__Should_Have_Linked_Staff_Contact__c = false));

        Test.startTest();
            CRM_StaffHubUserTriggerHandler.markUsersAsStaffHub(input);
        Test.stopTest();

        System.assert(input[0].arcuscrm__Should_Have_Linked_Staff_Contact__c, 'Method should tick the Should_Have_Linked_Staff_Contact checkbox on any user record passed in');
    }

    @isTest
    private static void filterUsersWithEligibleProfiles_3Users_2Elgible(){
        List<User> input = new List<User>();

        User ineligibleUser = CRM_StaffHubUtils.returnNewUsersWithoutProfile(1)[0];
        ineligibleUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Read Only' LIMIT 1].Id;
        input.add(ineligibleUser);

        Integer expectedNumberOfElegibleUsers = 2;

        List<User> eligibleUsers = CRM_StaffHubUtils.returnNewUsersWithoutProfile(expectedNumberOfElegibleUsers);
        for(User u : eligibleUsers) u.ProfileId = CRM_StaffHubUtils.TEST_STAFF_PROFILEID;
        input.addAll(eligibleUsers);

        Test.startTest();
            List<User> output = CRM_StaffHubUserTriggerHandler.filterUsersWithEligibleProfiles(input);
        Test.stopTest();

        Integer actualNumberOfElegibleUsers = output.size();

        System.assertEquals(expectedNumberOfElegibleUsers, actualNumberOfElegibleUsers, 'Method should return a list of users that have valid profiles as defined in the Profile_For_Staff_Hub custom metadata');
    }

    @isTest
    private static void filterStaffHubUsersWithNoContact_2Users_1WithoutContactButCheckboxTicked(){
        Contact c = new Contact(LastName = 'Test');
        insert c;

        List<User> input = CRM_StaffHubUtils.returnNewUsersWithoutProfile(2);
        for(User u : input) {
            u.ProfileId = CRM_StaffHubUtils.TEST_STAFF_PROFILEID;
            u.arcuscrm__Should_Have_Linked_Staff_Contact__c = true;
        }
        input[0].arcuscrm__Employee_Contact_Id__c = c.Id;

        Integer expectedNumberOfUsers = 1;

        Test.startTest();
            List<User> output = CRM_StaffHubUserTriggerHandler.filterStaffHubUsersWithNoContact(input);
        Test.stopTest();

        Integer actualNumberOfUsers = output.size();

        System.assertEquals(expectedNumberOfUsers, actualNumberOfUsers, 'Only Users without a contact but with Should_Have_Linked_Staff_Contact ticked should be returned.');
    }

}