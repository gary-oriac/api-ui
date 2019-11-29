/*
Company    :    Arcus Global
Product    :    Arcus DSH
Purpose    :    Test class for DSHLC_DeactivateCont
Notes   :    
*/
@isTest
private class DSHLC_DeactivateCont_Test {
    
    @testSetup
	private static void setup() {
		System.runAs(DSHLC_TestUtility.createSysAdminUserWithRole()) {
			DSHLC_TestUtility.createCommunityUserWithoutCreateSysAdmin();
			DSHLC_ConfigSettingsInstall.insertAllSettings();
		}
	}
	
	@isTest
	private static void testGetFullUrl() {
            Test.startTest();
            String result = DSHLC_DeactivateCont.getFullUrl();
            System.debug('<ARCUS>'+ result);
            Test.stopTest();
            
            System.assertEquals('', result, 'Should return empty. Community url cant be returned in test');	
	}
	
	@isTest
	private static void testDeactivateUser() {
        System.runAs(DSHLC_TestUtility.getExistingCommunityUser()) {
            
            Test.startTest();
            	User result = DSHLC_DeactivateCont.deactivateUser();
            Test.stopTest();
            
            System.assertEquals(false, result.IsActive, 'Should return a user with IsActive state of false');
        }
	}
}