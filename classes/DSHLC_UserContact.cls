/*
Author     :   
Company    :    Arcus Global
Product    :    Arcus Citizen
Date       :    
Purpose    :    A static class to get User's Contact details
Notes      :    
Modified   :    Rahma Balghouthi DISH-201
*/
public with sharing class DSHLC_UserContact {

    public static User getUserContact() {
        User u = [
            SELECT 
                User.Username,
                User.Email,
                User.FirstName,
                User.LastName,
                User.Contact.Salutation,
                User.Contact.Name,
                User.Contact.FirstName,
                User.Contact.LastName,
                User.Contact.AccountId,
                User.Contact.arcusgazetteer__Mailing_Address__c,
                User.Contact.MailingStreet, 
                User.Contact.MailingCity, 
                User.Contact.MailingState,
                User.Contact.MailingPostalCode,
                User.Contact.MailingCountry,
                User.Contact.arcusgazetteer__Other_Address__c,
                User.Contact.OtherStreet, 
                User.Contact.OtherCity, 
                User.Contact.OtherState,
                User.Contact.OtherPostalCode,
                User.Contact.OtherCountry,
                User.Contact.Phone,
                User.Contact.MobilePhone,
                User.Contact.Birthdate,
                User.Contact.arcshared__Community__c,
                User.Contact.arcshared__Company_Name__c
            FROM 
                User 
            WHERE 
                Id = :UserInfo.getUserId() 
            LIMIT 1];
        return u;
    }
    public static String getUserContactAddress() {
        String address = '';
        User u = [
            SELECT 
                User.Contact.arcusgazetteer__Mailing_Address__c,
                User.Contact.MailingStreet, 
                User.Contact.MailingCity, 
                User.Contact.MailingState,
                User.Contact.MailingPostalCode,
                User.Contact.MailingCountry                
            FROM 
                User 
            WHERE 
                Id = :UserInfo.getUserId() 
            LIMIT 1];
        if(u.Contact.arcusgazetteer__Mailing_Address__c != null){
            arcusgazetteer__Location__c l = [
                SELECT 
                    Id, 
                    arcusgazetteer__Address__c
                FROM 
                    arcusgazetteer__Location__c 
                WHERE 
                    Id = :u.Contact.arcusgazetteer__Mailing_Address__c
                LIMIT 1];
            if(l.arcusgazetteer__Address__c != null){
                address = l.arcusgazetteer__Address__c;
                address = l.arcusgazetteer__Address__c; // duplicated code - needs removing (?)
            }           
        }else{
            if(u.Contact.MailingStreet != null){
                String[] MailingStreetList = u.Contact.MailingStreet.split('\n');
                for(String val : MailingStreetList){
                    if(address == ''){
                        address = val;
                    }else{
                        address += '\n'+val;
                    }
                }
            }            
            if(u.Contact.MailingCity != null){
                if(address == ''){
                    address = u.Contact.MailingCity;        
                }else{
                    address += '\n'+u.Contact.MailingCity;    
                }
            }
            if(u.Contact.MailingState != null){
                if(address == ''){
                    address = u.Contact.MailingState;        
                }else{
                    address += '\n'+u.Contact.MailingState;    
                }
            }
            if(u.Contact.MailingPostalCode != null){
                if(address == ''){
                    address = u.Contact.MailingPostalCode;        
                }else{
                    address += '\n'+u.Contact.MailingPostalCode;    
                }
            }
            if(u.Contact.MailingCountry != null){
                if(address == ''){
                    address = u.Contact.MailingCountry;        
                }else{
                    address += '\n'+u.Contact.MailingCountry;    
                }            
            }
        }
        return address;
    }    
}