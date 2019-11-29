public without sharing class DSHLC_ForgotPasswordHelper {
    public Boolean reset(String username) {
        List<User> userRecord = new List<User>([SELECT Id, UserName FROM User WHERE UserName =:username AND IsActive = TRUE LIMIT 1]);
        System.ResetPasswordResult resetResult = (userRecord.size() > 0 ? System.resetPassword(userRecord[0].Id, true) : null);
        return (resetResult != null && resetResult.getPassword() != null ? true : false);
    }
}