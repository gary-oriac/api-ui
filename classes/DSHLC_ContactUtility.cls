/*
Author     :    Jonathan Dobbs
Company    :    Arcus Global
Product    :    Arcus Citizen
Date       :    
Purpose    :    Update Contact Email Address using User Email Address (once email has been verified by Login FLow)
Notes      :    
Modified   :    Cleaned by Rob
*/
public without sharing class DSHLC_ContactUtility {
    public static Process.PluginResult ProcessCon(string userId){
        Map<string,Object> result = new Map<string,Object>();
        result.put('UserID',userId);
        
        updateContactFromUser(userId);
        
        return new Process.PluginResult(result); 
    }
    
    @future 
    public static void updateContactFromUser(String userId) {
        User u = [SELECT ContactId, Email, FirstName, LastName, Title FROM User WHERE Id=:userId];
        System.debug('<ARCUS> UserId: ' + userId);

        if (u!=null && u.ContactId!=null) {
            Contact c = new Contact(Id=u.ContactId, Email=u.Email, FirstName=u.FirstName, LastName=u.LastName, Title=u.Title);
            update c; 
        }
    }
}