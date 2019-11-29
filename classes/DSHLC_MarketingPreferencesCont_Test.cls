@isTest
private class DSHLC_MarketingPreferencesCont_Test {
	@testSetup
	private static void setup() {
		DSHLC_TestUtility.createCommunityUser();
	}


	@isTest
	private static void testGetCouncilLongName() {
		String result;
        System.runAs(DSHLC_TestUtility.createSysAdminUserWithRole()) {
			DSHLC_ConfigSettingsInstall.insertAllSettings();
            
			Test.startTest();
			result = DSHLC_MarketingPreferencesCont.getCouncilLongName();
			System.debug('<ARCUS> The council long name: ' + result );
			Test.stopTest();
		}
		System.assertEquals('Arcus Borough Council', result, 'Council long name should be Arcus Borough Council which is the default. It should be in title case.');
	}

	@isTest
    private static void testCurrentMarketingPrefs() {
        List<DSHLC_MarketingPreferencesCont.CurrentMarketingPrefsWrapper> result;
        User testUser;

        User communityUser = DSHLC_TestUtility.getExistingCommunityUser();

            User resultUser = [SELECT Contact.arcshared__Marketing_Preferences_Council_Newsletter__c		
         						FROM User 
         						WHERE Id = :communityUser.Id 
         						LIMIT 1];

	        	resultUser.Contact.arcshared__Marketing_Preferences_Council_Newsletter__c = 'yes';

			update resultUser.Contact;

			System.runAs(resultUser) {
            	Test.startTest();
            	result = DSHLC_MarketingPreferencesCont.currentMarketingPrefs();
            	Test.stopTest();
        	}

			System.assertEquals('yes', resultUser.Contact.arcshared__Marketing_Preferences_Council_Newsletter__c, 'The marketing preference for Council newsletter should be yes');
    }
	
    @isTest
	private static void testupdateMarketingCouncilNewsletterSuccess() {
		User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
		String newsletter = 'yes';
		String result;
		System.runAs(communityUser) {
			Test.startTest();
			result = DSHLC_MarketingPreferencesCont.updateMarketingcouncilNewsletter(newsletter);
			Test.stopTest();
		}
		System.assertEquals('', result, 'Empty string should be returned');
	}
	 
	@isTest
	private static void testupdateMarketingCouncilNewsletterFail() {
		String newsletter = '';
		String result;
			Test.startTest();
        try {
            result = DSHLC_MarketingPreferencesCont.updateMarketingcouncilNewsletter(newsletter);
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Sorry, we were not able to change your marketing prefernces. Please try again later.'));
        }
			Test.stopTest();
	}

	@isTest
	private static void testUpdateMarketingCouncilOnly() {
		User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
		String councilOnly = 'yes';
		String result;
		System.runAs(communityUser) {
			Test.startTest();
			result = DSHLC_MarketingPreferencesCont.updateMarketingCouncilOnly(councilOnly);
			Test.stopTest();
		}
		System.assertEquals('', result, 'Empty string should be returned');
	}
	@isTest
	private static void testUpdateMarketingCouncilOnlyFail() {
		String councilOnly = '';
		String result;
			Test.startTest();
			try {
            	result = DSHLC_MarketingPreferencesCont.updateMarketingCouncilOnly(councilOnly);
       		} catch (AuraHandledException e) {
	            System.assert(e.getMessage().contains('Sorry, we were not able to change your marketing prefernces. Please try again later.'));
	        }
			Test.stopTest();

	}

	@isTest
	private static void testUpdateMarketingCouncilOwned() {
		User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
		String councilOwned = 'yes';
		String result;
		System.runAs(communityUser) {
			Test.startTest();
			result = DSHLC_MarketingPreferencesCont.updateMarketingCouncilOwned(councilOwned);
			Test.stopTest();
		}
		System.assertEquals('', result, 'Empty string should be returned');
	}
	@isTest
	private static void testUpdateMarketingCouncilOwnedFail() {
		String councilOwned = '';
		String result;
		Test.startTest();
		try {
        	result = DSHLC_MarketingPreferencesCont.updateMarketingCouncilOwned(councilOwned);
   		} catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Sorry, we were not able to change your marketing prefernces. Please try again later.'));
        }
        Test.stopTest();

	}



	@isTest
	private static void testUpdateMarketingCouncilEmail() {
		User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
		String councilEmail = 'yes';
		String result;
		System.runAs(communityUser) {
			Test.startTest();
			result = DSHLC_MarketingPreferencesCont.updateMarketingCouncilEmail(councilEmail);
			Test.stopTest();
		}
		System.assertEquals('', result, 'Empty string should be returned');
	}
	@isTest
	private static void testUpdateMarketingCouncilEmailFail() {
		String councilEmail = '';
		String result;
		Test.startTest();
		try {
        	result = DSHLC_MarketingPreferencesCont.updateMarketingCouncilEmail(councilEmail);
   		} catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Sorry, we were not able to change your marketing prefernces. Please try again later.'));
        }
        Test.stopTest();

	}

	@isTest
	private static void testUpdateMarketingCouncilLetter() {
		User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
		String councilPost = 'yes';
		String result;
		System.runAs(communityUser) {
			Test.startTest();
			result = DSHLC_MarketingPreferencesCont.updateMarketingCouncilLetter(councilPost);
			Test.stopTest();
		}
		System.assertEquals('', result, 'Empty string should be returned');
	}
	@isTest
	private static void testUpdateMarketingCouncilLetterFail() {
		String councilPost = '';
		String result;
		Test.startTest();
		try {
        	result = DSHLC_MarketingPreferencesCont.updateMarketingCouncilLetter(councilPost);
   		} catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Sorry, we were not able to change your marketing prefernces. Please try again later.'));
        }
        Test.stopTest();
	}

	@isTest
	private static void testUpdateMarketingCouncilPhone() {
		User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
		String councilPhone = 'yes';
		String result;
		System.runAs(communityUser) {
			Test.startTest();
			result = DSHLC_MarketingPreferencesCont.updateMarketingCouncilPhone(councilPhone);
			Test.stopTest();
		}
		System.assertEquals('', result, 'Empty string should be returned');
	}
	@isTest
	private static void testUpdateMarketingCouncilPhoneFail() {
		String councilPhone = '';
		String result;
		Test.startTest();
		try {
        	result = DSHLC_MarketingPreferencesCont.updateMarketingCouncilPhone(councilPhone);
   		} catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Sorry, we were not able to change your marketing prefernces. Please try again later.'));
        }
        Test.stopTest();

	}

	@isTest
	private static void testUpdateMarketingCouncilSMS() {
		User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
		String councilSMS = 'yes';
		String result;
		System.runAs(communityUser) {
			Test.startTest();
			result = DSHLC_MarketingPreferencesCont.updateMarketingCouncilSMS(councilSMS);
			Test.stopTest();
		}
		System.assertEquals('', result, 'Empty string should be returned');

	}
	@isTest
	private static void testUpdateMarketingCouncilSMSFail() {
		String councilSMS = '';
		String result;
		Test.startTest();
		try {
        	result = DSHLC_MarketingPreferencesCont.updateMarketingCouncilSMS(councilSMS);
   		} catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Sorry, we were not able to change your marketing prefernces. Please try again later.'));
        }
        Test.stopTest();
	}


	
}