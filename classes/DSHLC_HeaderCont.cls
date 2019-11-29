/*
Company    :    Arcus Global
Product    :    Arcus DSH
Purpose    :    DSH Lightning header controller
Notes      :           
*/
public with sharing class DSHLC_HeaderCont extends DSHLC_ConfigSettings 
{
    
	@AuraEnabled
	public static String getCommunityName() {
		return DSHLC_CommunityInfo.getCommunity().LC;
	}

    @AuraEnabled
    public static String getCommunityPath() {
        return DSHLC_CommunityInfo.getCommunity().LC + '/s/';
    }

    @AuraEnabled
    public static String getCopyrightYear() {
        Integer year = Date.Today().Year();
        String yearString = String.valueOf(year);
        return yearString;
    }

    @AuraEnabled
    public static Boolean isLoggedInUser() {
        if (UserInfo.getUserType() != 'Guest') {
            return true;
        } else {
            return false;
        }
    }

    @AuraEnabled
    public static String getUserId() {
        Id userId = UserInfo.getUserId();
        return userId;
    }

    @AuraEnabled
    public static String getFirstName() {
        if (UserInfo.getUserType() != 'Guest') {
            return UserInfo.getFirstName();
        } else {
            return '';
        }
    }

    @AuraEnabled
    public static Id getContactId() {
        Id loggedInContact = DSHLC_UserContact.getUserContact().ContactId;	
        return loggedInContact;
    }

    @AuraEnabled
    public static String getCouncilLongName() {
        String councilLongName = DSHLC_ConfigSettings.getCouncilLongName();
        return councilLongName;
    }

    @AuraEnabled
    public static String getCouncilCMSWebsiteURL() {
        String councilCMSWebsiteURL = DSHLC_ConfigSettings.getCouncilCMSWebsiteURL();
        return councilCMSWebsiteURL;
    }

	@AuraEnabled
	public static String makeQueryString() {
	  	if (UserInfo.getUserType() != 'Guest') {
	    	return '?firstname='+ UserInfo.getFirstName() +'&sessionexpires='+ String.valueof(DateTime.now().getTime())+'&community='+ DSHLC_CommunityInfo.getCommunity().LC;
	    } else {
	        return '?logout=true&community=' + DSHLC_CommunityInfo.getCommunity().LC;
	    }
	}
}