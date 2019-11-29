/*
Company    :    Arcus Global
Product    :    Arcus DSH
Purpose    :    DSH Lightning Deactivate controller
Notes      :           
*/
public with sharing class DSHLC_DeactivateCont {

    @AuraEnabled
	public static String getFullUrl() {
		return Site.getBaseUrl();
	}

    @AuraEnabled
    public static User deactivateUser() {
        User currentUser = new User(Id = UserInfo.getUserId());
        	currentUser.IsActive = false;
        	if(!Test.isRunningTest()) {
                update currentUser;    
             }
		return currentUser;
	}
}