/*
Author     :    Rahma Balghouthi
Company    :    Arcus Global
Product    :    Arcus Citizen
Date       :    08-04-2016
Purpose    :    updates mailing address lookup when location link is updated
Notes      :    
Modified   :  
*/
public with sharing class DSHLC_UpdateMailingAddressWithLL {
    
    private static final boolean LOG_THIS_CLASS = true;   
    
    @InvocableMethod
    public static void updateMailingAddressWithLocationLink(List<arcusgazetteer__Location_Link__c> links){
        List<Contact> contacts = [SELECT arcusgazetteer__Mailing_Address__c FROM Contact WHERE Id =:links[0].arcusgazetteer__Contact__c LIMIT 10];
        if(contacts.size()>0){
            contacts[0].arcusgazetteer__Mailing_Address__c = links[0].arcusgazetteer__Location__c;
            try{
                update contacts[0];
            }catch(Exception ex){
                System.debug('Error occured when updating mailing address with location link ' + ex.getMessage());
            }
        }
    }
}