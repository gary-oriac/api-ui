/* 
Company    :    Arcus Global
Product    :    Arcus DSH  
Purpose    :    Profile page controller
Notes      :    
*/
public without sharing class DSHLC_ProfileCont extends DSHLC_ConfigSettings {

    @AuraEnabled
    public static String getCommunityName() {
        return DSHLC_CommunityInfo.getCommunity().LC;
    }
    @AuraEnabled
    public static String getBaseUrl() {
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm() +'/';
      return baseUrl;
    }

     @AuraEnabled
     public static User getBusinessName() {
        User u = [
            SELECT 
                User.Contact.arcshared__Company_Name__c
            FROM 
                User 
            WHERE 
                Id = :UserInfo.getUserId() 
            LIMIT 1];
        return u;
    }

    @AuraEnabled
    public static User getContactDetails() {
        User userContact = DSHLC_UserContact.getUserContact();  
        return userContact;
    }
    
    /* 
    This method updates the User's email address and username.  A flow (DSHLC_Email_Verification) then takes care of things.
    */
    /*@future*/
    @AuraEnabled
    public static String updateEmail (String Email){
        User userToUpdate = [SELECT Id, Email, Username, arcshared__DSH_Email_Verified__c FROM User WHERE Id=: UserInfo.getUserId() LIMIT 1];
        userToUpdate.Email = Email;
        userToUpdate.Username = Email;
        userToUpdate.arcshared__DSH_Email_Verified__c = false;
        userToUpdate.arcshared__DSH_Email_Self_Updated__c = true;
        try {
            update userToUpdate;
            return '';
        }
        catch(Exception e){
             System.debug('<ARCUS> error in address update '+ e.getMessage());
            return 'Sorry, we were not able to change your address. Please try again later.';
        }
           
    }

     @AuraEnabled
    public static String updateBusinessName(String businessName) {
        User userToUpdate;
        userToUpdate = [SELECT Id, Contact.arcshared__Company_Name__c FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];  

        if (businessName != '' && businessName != null) {
            userToUpdate.Contact.arcshared__Company_Name__c = businessName;
        }

        try {
            update userToUpdate.Contact;
            return '';
        } catch(Exception e) {
             System.debug('<ARCUS> error in phone update '+ e.getMessage());
            return 'Sorry, we were not able to change your business name. Please try again later.';
        }
    }

    @AuraEnabled
    public static String updatePhone(String Phone) {
        User userToUpdate;
        userToUpdate = [SELECT Id, Contact.Phone FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];  

        if (Phone != '' && Phone != null) {
            userToUpdate.Contact.Phone = Phone;
        }

        try {
            update userToUpdate.Contact;
            return '';
        } catch(Exception e) {
             System.debug('<ARCUS> error in phone update '+ e.getMessage());
            return 'Sorry, we were not able to change your phone number. Please try again later.';
        }
    }

    @AuraEnabled
    public static String updateMobile(String MobilePhone) {
        User userToUpdate;
        userToUpdate = [SELECT Id, Contact.MobilePhone FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];  

        if (MobilePhone != '' && MobilePhone != null) {            
            userToUpdate.Contact.MobilePhone = MobilePhone;
        }
        try {
            update userToUpdate.Contact;
            return '';
        } catch(Exception e) {
             System.debug('<ARCUS> error in mobile update '+ e.getMessage());
            return 'Sorry, we were not able to change your mobile number. Please try again later.';
        }
    }

    @AuraEnabled
    public static Case saveCase(String description) {
        
        Id RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'DSH_Profile_Update' LIMIT 1].Id;

        Case c = new Case(
            Subject = 'Profile updated',
            Status = 'New',
            Origin = 'Web',
            Description = description,
            RecordTypeId = RecordTypeId);

        // Fetching the assignment rules on case
        List<AssignmentRule> AR = new List<AssignmentRule>();
        AR = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT 1];

        // Creating the DMLOptions for "Assign using active assignment rules" checkbox
        if (!AR.isEmpty()) {
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR[0].Id;

            c.setOptions(dmlOpts);  
        }

        insert c;
        return c; 
    }

    @AuraEnabled
    public static String updateName(String Salutation, String FirstName, String LastName) {
        User userToUpdate;
        userToUpdate = [SELECT Id, Contact.Salutation, Contact.FirstName, Contact.LastName FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];  

        if (Salutation != '' && Salutation != null) {
            userToUpdate.Contact.Salutation = Salutation;
        }
        if (FirstName != '' && FirstName != null) {            
            userToUpdate.Contact.FirstName = FirstName;
        }
        if (LastName != '' && LastName != null) {            
            userToUpdate.Contact.LastName = LastName;
        }
        try {
            update userToUpdate.Contact;
            return '';
        } catch(Exception e) {
             System.debug('<ARCUS> error in salutation/first/last name update '+ e.getMessage());
            return 'Sorry, we were not able to change your name. Please try again later.';
        }
    }

    @AuraEnabled
    public static String updateAddress(String MailingAddressId) {
        User userToUpdate;
        userToUpdate = [SELECT Id, Contact.MailingAddress FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];  
        if (MailingAddressId != '' && MailingAddressId != null) {
            userToUpdate.Contact.arcusgazetteer__Mailing_Address__c = MailingAddressId;
        }
        try {
            update userToUpdate.Contact;
            return '';
        } catch(Exception e) {
            System.debug('<ARCUS> error in address update '+ e.getMessage());
            return 'Sorry, we were not able to change your address. Please try again later.';
        }
    }

}