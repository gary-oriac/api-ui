/*
Company : Arcus Global
Product : Arcus DSH
Purpose : Test DSHLC_UpdateMailingAddressWithLocationLink class
Notes :
 */
@isTest
public with sharing class DSHLC_UpdateMailingAddressWithLL_Test {
    
    @isTest
    private static void testUpdateMailingAddress(){   
        User sysAdminUser = DSHLC_TestUtility.createSysAdminUserWithRole();

        System.runAs(sysAdminUser){
            User testPortalUser = DSHLC_TestUtility.createCommunityUserWithoutCreateSysAdmin();

            Test.startTest();
            //Create a new location            
            arcusgazetteer__Location__c location = new arcusgazetteer__Location__c();
            location.arcusgazetteer__Address_Line__c = 'new address';
            location.arcusgazetteer__UPRN__c = '78910';
            location.arcusgazetteer__X_Coordinate__c = 1425;
            location.arcusgazetteer__Y_Coordinate__c = 87;
            location.arcusgazetteer__Ward__c = 'ward';
            try{
                insert location;
            }Catch(Exception ex){
                System.debug('<ARCUS> insert location failed '+ ex.getMessage());
            } 
            
            arcusgazetteer__Location_Link__c link = new arcusgazetteer__Location_Link__c();
            link.arcusgazetteer__Contact__c = testPortalUser.ContactId;
            link.arcusgazetteer__Location__c = location.Id;
            link.arcusgazetteer__Correspondence_Address__c = true;
            link.arcusgazetteer__Type__c = 'Mailing Address';
            insert link;
            
            Contact c = [SELECT arcusgazetteer__Mailing_Address__c FROM Contact WHERE Id=: testPortalUser.ContactId LIMIT 1];                       
            System.assertEquals(c.arcusgazetteer__Mailing_Address__c, location.id);

            Test.stopTest();
        } 
    }
}