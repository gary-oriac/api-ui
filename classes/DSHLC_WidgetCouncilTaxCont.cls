/*
Company    :    Arcus Global
Product    :    Arcus DSH (Lightning DSH Core)
Purpose    :    Apex controller for Council Tax Homepage Widget
Notes      :           
*/
public with sharing class DSHLC_WidgetCouncilTaxCont extends DSHLC_ConfigSettings {
    
    @AuraEnabled
    public static List<Council_Tax_Band__c> getCouncilTaxBandDetails(String recordId) {
        List<Council_Tax_Band__c> bandDetails = new List<Council_Tax_Band__c>();

        String band;

        if(String.isNotBlank(recordId)) {       
            List<Contact> contacts = [SELECT arcusgazetteer__Mailing_Address__r.arcusgazetteer__BLPU__r.Council_Tax_Band__c FROM Contact WHERE Id = :recordId AND arcusgazetteer__Mailing_Address__c != NULL LIMIT 1];

            if (!contacts.isEmpty()) {
              band = contacts[0].arcusgazetteer__Mailing_Address__r.arcusgazetteer__BLPU__r.Council_Tax_Band__c;
            }
        } else {
            User loggedInUser = DSHLC_UserContact.getUserContact();
            
            if (loggedInUser.ContactId != null && loggedInUser.Contact.arcusgazetteer__Mailing_Address__c != null) {
              band = [
                SELECT arcusgazetteer__BLPU__r.Council_Tax_Band__c 
                FROM arcusgazetteer__Location__c 
                WHERE Id = :loggedInUser.Contact.arcusgazetteer__Mailing_Address__c
                ].arcusgazetteer__BLPU__r.Council_Tax_Band__c;
            }
        }

        if (String.isNotBlank(band)) {
            bandDetails = [
                SELECT 
                    Id, 
                    Name, 
                    Council_Tax_Band__c, 
                    Council_Tax_Year__c,
                    Council_Tax_Amount__c, 
                    County_Council_Amount__c, 
                    District_Council_Amount__c, 
                    Fire_And_Rescue_Amount__c, 
                    Police_And_Crime_Amount__c, 
                    Social_Care_Amount__c, 
                    Special_1_Amount__c, 
                    Town_Council_Amount__c 

                FROM Council_Tax_Band__c 
                WHERE Council_Tax_Band__c = :band

            ];

        }

        return bandDetails;
    }

}