/*
Author     :    Rahma Balghouthi
Company    :    Arcus Global
Product    :    Arcus Citizen
Date       :    07-04-2016
Purpose    :    updates location link when mailing address is updated
Notes      :    
Modified   :  
*/
public with sharing class DSHLC_UpdateLLWithMailingAddress {
    
    private static final boolean LOG_THIS_CLASS = true;
    private static final String MAILING_ADDRESS = 'Mailing Address';    
    
    @InvocableMethod
    public static void updateLocationLink(List<Contact> contactUpdated){
        if(LOG_THIS_CLASS) System.debug('<Arcus> the contact is ' + contactUpdated);
        List<arcusgazetteer__Location_Link__c> links = [SELECT Id, arcusgazetteer__Location__c, arcusgazetteer__Correspondence_Address__c, arcusgazetteer__Type__c  
                                                        FROM arcusgazetteer__Location_Link__c 
                                                        WHERE arcusgazetteer__Contact__c = :contactUpdated[0].Id AND arcusgazetteer__Type__c =:MAILING_ADDRESS LIMIT 100];
        if(links.size()>0){
            for(arcusgazetteer__Location_Link__c l: links){              
                    l.arcusgazetteer__Correspondence_Address__c = true;
                    l.arcusgazetteer__Location__c = contactUpdated[0].arcusgazetteer__Mailing_Address__c;                           
            }
            try{
                update links;
            }catch(Exception ex){
                System.debug('<Arcus> error occured when updating location link ' + ex.getMessage());
            }
        }else{
            arcusgazetteer__Location_Link__c newLink = new arcusgazetteer__Location_Link__c();
            newLink.arcusgazetteer__Contact__c = contactUpdated[0].Id;            
            newLink.arcusgazetteer__Type__c = MAILING_ADDRESS;
            newLink.arcusgazetteer__Correspondence_Address__c = true;
            newLink.arcusgazetteer__Location__c = contactUpdated[0].arcusgazetteer__Mailing_Address__c;                           
            try{
                insert newLink;
            }catch(Exception ex){
                System.debug('<Arcus> error occured when inserting a new location link ' + ex.getMessage());
            }
        }                
        
    }
    
   
}