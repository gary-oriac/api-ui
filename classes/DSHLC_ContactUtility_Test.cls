/*
Company : Arcus Global
Product : Arcus DSH
Purpose : Test DSHLC_ContactUtility class
Notes :
 */
@isTest
public with sharing class DSHLC_ContactUtility_Test {

    @isTest
    private static void usertest() {
        User pu;
        System.runAs(DSHLC_TestUtility.createSysAdminUserWithRole()) {
            pu = DSHLC_TestUtility.createCommunityUserWithoutCreateSysAdmin();
        
            Test.startTest();

            DSHLC_ContactUtility.ProcessCon(pu.Id);
            DSHLC_ContactUtility.updateContactFromUser(pu.Id);

            Test.stopTest();
        }

        //Assert
        Contact c = [SELECT Id FROM Contact WHERE Id = :pu.ContactId];
        System.assertEquals(c.Id, pu.ContactId);
    }
}