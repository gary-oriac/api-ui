/*
Company    :    Arcus Global
Product    :    Arcus DSH
Purpose    :    DSH Lightning Marketing Prefernces controller
Notes      :           
*/
public with sharing class DSHLC_MarketingPreferencesCont extends DSHLC_ConfigSettings 
{
    
    @AuraEnabled
    public static String getCouncilLongName() {
        String councilLongName = DSHLC_ConfigSettings.getCouncilLongName();
        return councilLongName;
    }

    @AuraEnabled
    public static List<CurrentMarketingPrefsWrapper> currentMarketingPrefs() {
        User loggedInUser = DSHLC_UserContact.getUserContact();
        Id ContactId = loggedInUser.Contact.Id;
        if( ContactId != null) {
            List<User> prefsList = [
                SELECT 
                    Id,
                    Contact.arcshared__Marketing_Preferences_Council_Newsletter__c, 
                    Contact.arcshared__Marketing_Preferences_Council_Only__c,
                    Contact.arcshared__Marketing_Preferences_Council_Owned__c,

                    Contact.arcshared__Marketing_Preferences_Email__c,
                    Contact.arcshared__Marketing_Preferences_Phone__c,
                    Contact.arcshared__Marketing_Preferences_SMS__c,
                    Contact.arcshared__Marketing_Preferences_Letter__c
                FROM 
                    User 
                WHERE 
                    Id=:UserInfo.getUserId()
                LIMIT 1 
            ];


            List<CurrentMarketingPrefsWrapper> currentMarketingPrefsWrapper = new List<CurrentMarketingPrefsWrapper>();
            for(User prefsDetail:prefsList) {
                currentMarketingPrefsWrapper.add(new CurrentMarketingPrefsWrapper(prefsDetail));
            }
            return currentMarketingPrefsWrapper;
        } else {
            return null;
        }
    }

    public class CurrentMarketingPrefsWrapper {
        @AuraEnabled public String councilNewsletter;
        @AuraEnabled public String councilOnly;
        @AuraEnabled public String councilOwned;
        @AuraEnabled public String councilEmail;
        @AuraEnabled public String councilPhone;
        @AuraEnabled public String councilSMS;
        @AuraEnabled public String councilLetter;

        public CurrentMarketingPrefsWrapper(User prefsDetail) {
            councilNewsletter = prefsDetail.Contact.arcshared__Marketing_Preferences_Council_Newsletter__c;
            councilOnly = prefsDetail.Contact.arcshared__Marketing_Preferences_Council_Only__c;
            councilOwned = prefsDetail.Contact.arcshared__Marketing_Preferences_Council_Owned__c;

            councilEmail = prefsDetail.Contact.arcshared__Marketing_Preferences_Email__c;
            councilPhone = prefsDetail.Contact.arcshared__Marketing_Preferences_Phone__c;
            councilSMS = prefsDetail.Contact.arcshared__Marketing_Preferences_SMS__c;
            councilLetter = prefsDetail.Contact.arcshared__Marketing_Preferences_Letter__c;
        }
    }


    @AuraEnabled
    public static String updateMarketingcouncilNewsletter(String newsletter) {
        User userToUpdate;
        userToUpdate = [SELECT Id, Contact.arcshared__Marketing_Preferences_Council_Newsletter__c FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];  

        if (newsletter != '' && newsletter != null) {
            userToUpdate.Contact.arcshared__Marketing_Preferences_Council_Newsletter__c = newsletter;
        }
        try {
            update userToUpdate.Contact;
            return '';
        } catch(Exception e) {
            System.debug('<ARCUS> error in marketing prefernces update '+ e.getMessage());
            e = new AuraHandledException('Sorry, we were not able to change your marketing prefernces. Please try again later.');
            e.setMessage('Sorry, we were not able to change your marketing prefernces. Please try again later.');      
           throw e;
        }
    }

    @AuraEnabled
    public static String updateMarketingCouncilOnly(String councilOnly) {
        User userToUpdate;
        userToUpdate = [SELECT Id, Contact.arcshared__Marketing_Preferences_Council_Only__c FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];  

        if (councilOnly != '' && councilOnly != null) {
            userToUpdate.Contact.arcshared__Marketing_Preferences_Council_Only__c = councilOnly;
        }
        try {
            update userToUpdate.Contact;
            return '';
        } catch(Exception e) {
            System.debug('<ARCUS> error in marketing prefernces update '+ e.getMessage());
            e = new AuraHandledException('Sorry, we were not able to change your marketing prefernces. Please try again later.');
            e.setMessage('Sorry, we were not able to change your marketing prefernces. Please try again later.');
            throw e;
        }
    }

    @AuraEnabled
    public static String updateMarketingCouncilOwned(String councilOwned) {
        User userToUpdate;
        userToUpdate = [SELECT Id, Contact.arcshared__Marketing_Preferences_Council_Owned__c FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];  

        if (councilOwned != '' && councilOwned != null) {
            userToUpdate.Contact.arcshared__Marketing_Preferences_Council_Owned__c = councilOwned;
        }
        try {
            update userToUpdate.Contact;
            return '';
        } catch(Exception e) {
            System.debug('<ARCUS> error in marketing prefernces update '+ e.getMessage());
            e = new AuraHandledException('Sorry, we were not able to change your marketing prefernces. Please try again later.');
            e.setMessage('Sorry, we were not able to change your marketing prefernces. Please try again later.');
            throw e;
        }
    }

    @AuraEnabled
    public static String updateMarketingCouncilEmail(String councilEmail) {
        User userToUpdate;
        userToUpdate = [SELECT Id, Contact.arcshared__Marketing_Preferences_Email__c FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];  

        if (councilEmail != '' && councilEmail != null) {
            userToUpdate.Contact.arcshared__Marketing_Preferences_Email__c = councilEmail;
        }
        try {
            update userToUpdate.Contact;
            return '';
        } catch(Exception e) {
            System.debug('<ARCUS> error in marketing prefernces update '+ e.getMessage());
            e = new AuraHandledException('Sorry, we were not able to change your marketing prefernces. Please try again later.');
            e.setMessage('Sorry, we were not able to change your marketing prefernces. Please try again later.');
            throw e;
        }
    }

    @AuraEnabled
    public static String updateMarketingCouncilLetter(String councilPost) {
        User userToUpdate;
        userToUpdate = [SELECT Id, Contact.arcshared__Marketing_Preferences_Letter__c FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];  

        if (councilPost != '' && councilPost != null) {
            userToUpdate.Contact.arcshared__Marketing_Preferences_Letter__c = councilPost;
        }
        try {
            update userToUpdate.Contact;
            return '';
        } catch(Exception e) {
            System.debug('<ARCUS> error in marketing prefernces update '+ e.getMessage());
            e = new AuraHandledException('Sorry, we were not able to change your marketing prefernces. Please try again later.');
            e.setMessage('Sorry, we were not able to change your marketing prefernces. Please try again later.');
            throw e;
        }
    }

    @AuraEnabled
    public static String updateMarketingCouncilPhone(String councilPhone) {
        User userToUpdate;
        userToUpdate = [SELECT Id, Contact.arcshared__Marketing_Preferences_Phone__c FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];  

        if (councilPhone != '' && councilPhone != null) {
            userToUpdate.Contact.arcshared__Marketing_Preferences_Phone__c = councilPhone;
        }
        try {
            update userToUpdate.Contact;
            return '';
        } catch(Exception e) {
            System.debug('<ARCUS> error in marketing prefernces update '+ e.getMessage());
            e = new AuraHandledException('Sorry, we were not able to change your marketing prefernces. Please try again later.');
                e.setMessage('Sorry, we were not able to change your marketing prefernces. Please try again later.');
            throw e;
        }
    }

    @AuraEnabled
    public static String updateMarketingCouncilSMS(String councilSMS) {
        User userToUpdate;
        userToUpdate = [SELECT Id, Contact.arcshared__Marketing_Preferences_SMS__c FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];  

        if (councilSMS != '' && councilSMS != null) {
            userToUpdate.Contact.arcshared__Marketing_Preferences_SMS__c = councilSMS;
        }
        try {
            update userToUpdate.Contact;
            return '';
        } catch(Exception e) {
            System.debug('<ARCUS> error in marketing prefernces update '+ e.getMessage());
            e = new AuraHandledException('Sorry, we were not able to change your marketing prefernces. Please try again later.');
            e.setMessage('Sorry, we were not able to change your marketing prefernces. Please try again later.');
            throw e;
        }
    }
    

}