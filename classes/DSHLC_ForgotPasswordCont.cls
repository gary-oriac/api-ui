/*  
Company    :    Arcus Global
Product    :    Arcus DSH   
Purpose    :    DSH Forgot password controller
Notes      :    
*/
public class DSHLC_ForgotPasswordCont extends DSHLC_ConfigSettings {
    
    public DSHLC_ForgotPasswordCont() {}
    
    @AuraEnabled
    public static String forgotPassword(String username, String checkEmailUrl) {
        try {
            if(DSHLC_ConfigSettings.getPasswordResetOption() == 'external') {
                Site.forgotPassword(username);
            }
            else {
                new DSHLC_ForgotPasswordHelper().reset(username);
            }
            ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl);
            if(!Site.isValidUsername(username)) {
                return Label.Site.invalid_email;
            }
            if(!Test.isRunningTest()){
                aura.redirect(checkEmailRef);
            }
            return null;
        }
        catch (Exception ex) {
            return ex.getMessage();
        }
    }

    /*@AuraEnabled
    global static String setExperienceId(String expId) {    
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);               
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }        
    }*/
}