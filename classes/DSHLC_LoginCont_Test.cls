/*
Company    :    Arcus Global
Product    :    Arcus DSH
Purpose    :    Apex test class for the apex controller of the login component, DSHLC_LoginCont.
Notes      :    
 */
@IsTest
private with sharing class DSHLC_LoginCont_Test {

	@IsTest
	private static void testLoginWithInvalidCredentials() {
		System.assertEquals('Argument 1 cannot be null', DSHLC_LoginCont.login('testUser', 'fakepwd', null));
	}

	@IsTest
	private static void testIsUsernamePasswordEnabled() {
		System.assertEquals(true, DSHLC_LoginCont.getIsUsernamePasswordEnabled());
	}

	@IsTest
	private static void testIsSelfRegistrationEnabled() {
		System.assertEquals(false, DSHLC_LoginCont.getIsSelfRegistrationEnabled());
	}

	@IsTest
	private static void testGetSelfRegistrationURL() {
		System.assertEquals(null, DSHLC_LoginCont.getSelfRegistrationUrl());
	}

	@IsTest
	private static void testAuthConfig() {
		Auth.AuthConfiguration authConfig = DSHLC_LoginCont.getAuthConfig();
		System.assertNotEquals(null, authConfig);
	}
}