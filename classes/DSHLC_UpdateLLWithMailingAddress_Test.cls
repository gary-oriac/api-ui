/*
Company : Arcus Global
Product : Arcus DSH
Purpose : Test DSHLC_UpdateLLWihMailingAddress class
Notes :
 */
@isTest
public with sharing class DSHLC_UpdateLLWithMailingAddress_Test {

    @isTest
    private static void testUpdateLL() {
        System.runAs(DSHLC_TestUtility.createSysAdminUserWithRole()){
            User testPortalUser = DSHLC_TestUtility.createCommunityUserWithoutCreateSysAdmin();

            Test.startTest();
            //Create a new location            
            arcusgazetteer__Location__c location = new arcusgazetteer__Location__c();
            location.arcusgazetteer__Address_Line__c = 'new address';        
            location.arcusgazetteer__UPRN__c = '78910';
            location.arcusgazetteer__X_Coordinate__c = 1425;
            location.arcusgazetteer__Y_Coordinate__c = 87;
            location.arcusgazetteer__Ward__c = 'ward';
            insert location;
            Contact c = [SELECT arcusgazetteer__Mailing_Address__c, MailingAddress FROM Contact WHERE Id = :testPortalUser.ContactId LIMIT 1]; 
            c.arcusgazetteer__Mailing_Address__c = location.Id;
            update c;
            List<arcusgazetteer__Location_Link__c> links = [
                SELECT arcusgazetteer__Location__c 
                FROM arcusgazetteer__Location_Link__c
                WHERE arcusgazetteer__Contact__c = : c.Id LIMIT 1
            ];
            System.assertEquals(1, links.size());

            Contact updatedContact1 = [SELECT MailingAddress FROM Contact WHERE Id = :c.Id LIMIT 1];
            System.assertNotEquals(null, updatedContact1.MailingAddress);
            
            arcusgazetteer__Location__c newLocation = new arcusgazetteer__Location__c();
            newLocation.arcusgazetteer__Address_Line__c = 'new other address';        
            newLocation.arcusgazetteer__UPRN__c = '78910';
            newLocation.arcusgazetteer__X_Coordinate__c = 1425;
            newLocation.arcusgazetteer__Y_Coordinate__c = 87;
            newLocation.arcusgazetteer__Ward__c = 'ward';
            insert newLocation;

            c.arcusgazetteer__Mailing_Address__c = newLocation.Id;
            update c;

            Contact updatedContact2 = [SELECT MailingAddress FROM Contact WHERE Id = :c.Id LIMIT 1];
            System.assertNotEquals(null, updatedContact2.MailingAddress);
            System.assertNotEquals(updatedContact1.MailingAddress, updatedContact2.MailingAddress);
            Test.stopTest();
        }
    }
}