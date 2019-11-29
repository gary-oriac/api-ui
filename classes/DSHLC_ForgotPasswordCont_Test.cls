/*
Company    :    Arcus Global
Product    :    Arcus DSH
Purpose    :    Test DSHLC_ForgotPasswordCont class 
Note       :    
*/
@IsTest
public class DSHLC_ForgotPasswordCont_Test {
    
    @testSetup static void setupTestData() {
        List<arcshared.AppConfigSupport.setting> sbcpFeatureConfigSettings = new List<arcshared.AppConfigSupport.setting>();
        Map<String, List<arcshared.AppConfigSupport.setting>> categoryToSettingsMap = new Map<String, List<arcshared.AppConfigSupport.setting>>();
        
        sbcpFeatureConfigSettings.add(new arcshared.AppConfigSupport.setting('DSH_PASSWORD_RESET_OPTION', 'String', 'internal', 'external', 3000, true, true));     
        
        // Map all the different category lists
        categoryToSettingsMap.put('DSHFeatureConfig',  sbcpFeatureConfigSettings);       
        
        // Insert the settings
        arcshared.AppConfigSupport.setCategoryRecords(categoryToSettingsMap, 'arcusdsh');
    }
    
    @IsTest static void testInternalForgotPassword() {
        //Arrange
        arcshared.AppConfigSupport.setSingleValue('DSHFeatureConfig', 'DSH_PASSWORD_RESET_OPTION', 'internal');
        
        //Act
        String validUser = DSHLC_ForgotPasswordCont.forgotPassword('test@test.com', 'http://a.com');
        String nullUser = DSHLC_ForgotPasswordCont.forgotPassword(null, 'http://a.com');
        String emptyUserAndCheckEmailUrl = DSHLC_ForgotPasswordCont.forgotPassword('', '');
        String invalidUser = DSHLC_ForgotPasswordCont.forgotPassword('a', '/home/home.jsp');
        
        //Assert
        System.assertEquals(null, validUser, 'Valid Username result');
        System.assertEquals(Label.Site.invalid_email, nullUser, 'Null email address result');
        System.assertEquals(Label.Site.invalid_email, emptyUserAndCheckEmailUrl, 'Empty user and check email url result');
        System.assertEquals(Label.Site.invalid_email, invalidUser, 'Invalid user result');
    }
    
    @IsTest static void testExternalForgotPassword() {
        //Arrange
        arcshared.AppConfigSupport.setSingleValue('DSHFeatureConfig', 'DSH_PASSWORD_RESET_OPTION', 'external');
        
        //Act
        String validUser = DSHLC_ForgotPasswordCont.forgotPassword('test@test.com', 'http://a.com');
        String nullUser = DSHLC_ForgotPasswordCont.forgotPassword(null, 'http://a.com');
        String emptyUserAndCheckEmailUrl = DSHLC_ForgotPasswordCont.forgotPassword('', '');
        String invalidUser = DSHLC_ForgotPasswordCont.forgotPassword('a', '/home/home.jsp');
        
        //Assert
        System.assertEquals(null, validUser, 'Valid Username result');
        System.assertEquals(Label.Site.invalid_email, nullUser, 'Null email address result');
        System.assertEquals(Label.Site.invalid_email, emptyUserAndCheckEmailUrl, 'Empty user and check email url result');
        System.assertEquals(Label.Site.invalid_email, invalidUser, 'Invalid user result');
    }
    
    @IsTest static void testForgotPasswordContConstructor() {
        //Act
        DSHLC_ForgotPasswordCont controller = new DSHLC_ForgotPasswordCont();
        
        //Assert
        System.assertNotEquals(controller, null, 'Testing the empty constructor');
    }
}