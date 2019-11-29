/*
Author     :    James Yu
Company    :    Arcus Global
Product    :    Arcus DSHLC
Date       :    13/11/17
Purpose    :    Utilities for test classes
Modified   :    
*/
public with sharing class DSHLC_TestUtility {
	@TestVisible private static final String COMMUNITY_PROFILE_NAME_RESIDENT = 'Custom: Customer Community User - Resident';
	@TestVisible private static final String COMMUNITY_PROFILE_NAME_BUSINESS = 'Custom: Customer Community User - Business';
	private static final String COMMUNITY_USER_USERNAME_DEFAULT = 'tester.community@test.dsh';

	@TestVisible
	private static User createCommunityUser() {
		return createCommunityUser(COMMUNITY_PROFILE_NAME_RESIDENT);
	}

	@TestVisible
	private static User createCommunityUser(String profileName) {
		User portalUser;
		User sysAdminUser = createSysAdminUserWithRole();
		System.runAs(sysAdminUser) {
			portalUser = createCommunityUserWithoutCreateSysAdmin(profileName);
		}

		return portalUser;
	}

	@TestVisible
	private static User createCommunityUserWithoutCreateSysAdmin() {
		return createCommunityUserWithoutCreateSysAdmin(COMMUNITY_PROFILE_NAME_RESIDENT);
	}

	@TestVisible
	private static User createCommunityUserWithoutCreateSysAdmin(String profileName){
        Account account = createAccount('Test Account', null, true);

        Contact contact = createContact(account.Id, 'testerFirst', 'testerLast', 'tester.community@test.dsh', 'community', true);

        Id profileId = getProfileId(profileName);

        User portalUser = createUser(contact.FirstName, contact.Lastname, contact.Email, contact.Email, profileId, null, (String)contact.Id, true);
        return portalUser;
    }

	@TestVisible
	private static User createSysAdminUserWithRole() {
		User sysAdminUser;

		Id sysAdminProfileId = getProfileId('System Administrator');
		List<User> existingSysAdmin = [
            SELECT Id, Username, Email, FirstName, LastName, ProfileId 
            FROM User 
            WHERE IsActive = true AND ProfileId = :sysAdminProfileId AND UserRoleId != null AND UserRole.PortalType = 'None'
            LIMIT 1
        ];

        if (existingSysAdmin.size() > 0) {
        	sysAdminUser = existingSysAdmin.get(0);
        } else {
        	List<UserRole> nonPortalRoles = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];

        	if (nonPortalRoles.size() > 0) {
        		sysAdminUser = createUser('TestSysAdminFirst', 'TestSysAdminLast', 'testSystemAdmin@testEmail.dsh', 'testSystemAdmin@test.dsh', sysAdminProfileId, nonPortalRoles.get(0).Id, null, true);
	        }
        }

        return sysAdminUser;
	}

	@TestVisible
	private static User createUser(String firstName, String lastName, String email, String username, String profileId, String userRoleId, String contactId, Boolean doInsert) {
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = false;

        User testUser = new User(
        	FirstName = firstName,
        	LastName = lastName,
        	Email = email,
        	Username = username,
        	ProfileId = profileId,
        	EmailEncodingKey = 'ISO-8859-1',
        	LanguageLocaleKey = 'en_US',
        	TimeZoneSidKey = 'Europe/London',
        	LocaleSidKey = 'en_GB',
        	Alias = 'testUser',
        	IsActive = true,
            arcshared__DSH_Email_Verified__c = true
        );

        if (String.isNotBlank(contactId)) {
        	testUser.ContactId = contactId;
        }

        if (String.isNotBlank(userRoleId)) {
        	testUser.UserRoleId = userRoleId;
        }

		testUser.setOptions(dmo);

        if (doInsert) {
            insert testUser;

            testUser = [
                SELECT Username, Email, FirstName, LastName, ProfileId, EmailEncodingKey, LanguageLocaleKey, TimeZoneSidKey, LocaleSidKey,
                Alias, IsActive, UserRoleId, ContactId, Contact.AccountId, Contact.FirstName, Contact.LastName, Contact.Email,
                Contact.arcshared__Community__c, arcshared__DSH_Email_Verified__c
                FROM User WHERE Id = :testUser.Id LIMIT 1
            ];
        }

        return testUser;
    }

    @TestVisible
    private static Account createAccount(String name, User userWithRole, Boolean doInsert) {
        Account testAccount = new Account(Name = name);
        if(userWithRole != null) testAccount.Owner = userWithRole;

        if (doInsert) {
            insert testAccount;
        }

        return testAccount;
    }

    @TestVisible
    private static Contact createContact(Id accountId, String firstName, String lastName, String email, String communityName, Boolean doInsert) {
        Contact testContact = new Contact(
        	AccountId = accountId,
        	FirstName = firstName,
        	LastName = lastName,
        	Email = email,
            arcshared__Community__c = communityName
        );

        if (doInsert) {
            insert testContact;
        }

        return testContact;
    }

    @TestVisible
    private static Id getProfileId(String profileName) {
        return [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1].Id;
    }

    @TestVisible
    private static User getExistingCommunityUser() {
    	return getExistingUser(COMMUNITY_USER_USERNAME_DEFAULT);
    }

    @TestVisible
    private static User getExistingUser(String username) {
    	User communityUser = [
    		SELECT Id, Username, Email, FirstName, LastName, ProfileId, EmailEncodingKey, LanguageLocaleKey, TimeZoneSidKey, LocaleSidKey,
        	Alias, IsActive, ContactId, Contact.AccountId, Contact.FirstName, Contact.LastName, Contact.Email,
            Contact.arcshared__Community__c, arcshared__DSH_Email_Verified__c
        	FROM User WHERE Username = :username LIMIT 1
        ];

        return communityUser;
    }
}