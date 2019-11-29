/*
Company    :    Arcus Global
Product    :    Arcus DSH
Purpose    :    Test class for DSHLC_HealthCheckCont
Modified   :    
*/
@isTest
private class DSHLC_HealthCheckCont_Test {

    private static void setupGetWardAccounts() {
        System.runAs(DSHLC_TestUtility.createSysAdminUserWithRole()) {
            Id profileId = DSHLC_TestUtility.getProfileId('System Administrator');
            Id userRoleId = [SELECT Id FROM UserRole LIMIT 1].Id;
            User userWithRole = DSHLC_TestUtility.createUser('Roland', 'Rolson', 'roland.rolson@arcusglobal.com', 'roland.rolson@arcusglobal.com', profileId, userRoleId, null, false);
            User userWithoutRole = DSHLC_TestUtility.createUser('Beckah', 'Carroll', 'beckah.carroll@arcusglobal.com', 'beckah.carroll@arcusglobal.com', profileId, null, null, false);
            List<User> userList = new List<User> {userWithRole, userWithoutRole};
            insert userList;

            /* 
                You'll notice that the base accounts are missing.
                Iniitally this method was a @testSetup method.
                This is not allowed by Salesforce when you have a SeeAllData method within the class.
                Currently the 'Ward_Account' validation rule prevents the base accounts from being created within the context of a test setup.
                That's why we currently are using the SeeAllData.
            */
            Account accountChesterton = DSHLC_TestUtility.createAccount('Resident - Chesterton', userWithRole, false);
            accountChesterton.arcusgazetteer__Ward_Code__c = 'ABCDE4';
            Account accountTrumpington = DSHLC_TestUtility.createAccount('Resident - Trumpington', userWithRole, false);
            Account accountArbury = DSHLC_TestUtility.createAccount('Resident - Arbury', userWithoutRole, false);
            Account accountCastle = DSHLC_TestUtility.createAccount('Resident -Castle', userWithoutRole, false);
            Account accountAbbey = DSHLC_TestUtility.createAccount('Resident- Abbey', userWithoutRole, false);
            Account accountNewnham = DSHLC_TestUtility.createAccount('Resident-Newnham', userWithoutRole, false);
            Account accountHyphen = DSHLC_TestUtility.createAccount('Resident-', userWithoutRole, false);
            Account accountNothing = DSHLC_TestUtility.createAccount('Resident', userWithoutRole, false);

            System.runAs(userWithRole) {
                List<Account> accountList = new List<Account> {accountChesterton, accountTrumpington};
                insert accountList;
            }

            System.runAs(userWithoutRole) {
                List<Account> accountList = new List<Account> {accountArbury, accountCastle, accountAbbey, accountNewnham, accountHyphen, accountNothing};
                insert accountList;
            }
        }
    }

    @isTest
    private static void testIsLoggedInUser() {
        System.runAs(DSHLC_TestUtility.createSysAdminUserWithRole()) {
            Test.startTest();
            Boolean result = DSHLC_HealthCheckCont.isLoggedInUser();
            Test.stopTest();

            System.assertEquals(true, result, 'Test User is not logged in.');
        }
    }

    @isTest
    private static void testHasClearance() {
        System.runAs(DSHLC_TestUtility.createSysAdminUserWithRole()) {
            Test.startTest();
            Boolean result = DSHLC_HealthCheckCont.hasClearance();
            Test.stopTest();

            System.assertEquals(true, result, 'Test User is not a System Administrator.');
        }
    }

    @isTest(SeeAllData=true)
    private static void testGetBaseAccounts() {
        System.runAs(DSHLC_TestUtility.createSysAdminUserWithRole()) {
            Test.startTest();
            List<DSHLC_HealthCheckCont.BaseAccountListWrapper> accountListWrapper = DSHLC_HealthCheckCont.getBaseAccounts();
            Test.stopTest();

            System.assertEquals(3, accountListWrapper.size(), 'The org is missing of the following Accounts: Business - New, Resident - New, Resident - Non LLPG');
    
        }
    }

    @isTest
    private static void testGetWardAccounts() {
        setupGetWardAccounts();
        System.runAs(DSHLC_TestUtility.createSysAdminUserWithRole()) {
            Test.startTest();
            List<DSHLC_HealthCheckCont.WardAccountListWrapper> results = DSHLC_HealthCheckCont.getWardAccounts();
            Test.stopTest();
            System.assertEquals(8, results.size(), 'There should be 8 Accounts in the setup.');
            System.assertEquals('ABCDE4', results[0].WardCode, 'Ward Code has not been setup on Account.');
            System.assertEquals(null, results[1].WardCode, 'Ward Code should be empty for this Account.');
            System.assertEquals(null, results[2].WardCode, 'Ward Code should be empty for this Account.');
            System.assertNotEquals(null, results[0].Role, 'This Account should have a Role.');
            System.assertNotEquals(null, results[1].Role, 'This Account should have a Role.');
            System.assertEquals(null, results[2].Role, 'This Account should not have a Role.');
            System.assertEquals(true, results[0].ValidFormat, 'The name of this Account should follow a valid format.');
            System.assertEquals(true, results[1].ValidFormat, 'The name of this Account should follow a valid format.');
            System.assertEquals(true, results[2].ValidFormat, 'The name of this Account should follow a valid format.');
            System.assertEquals(false, results[3].ValidFormat, 'The name of this Account should follow an invalid format.');
            System.assertEquals(false, results[4].ValidFormat, 'The name of this Account should follow an invalid format.');
            System.assertEquals(false, results[5].ValidFormat, 'The name of this Account should follow an invalid format.');
            System.assertEquals(false, results[6].ValidFormat, 'The name of this Account should follow an invalid format.');
            System.assertEquals(false, results[7].ValidFormat, 'The name of this Account should follow an invalid format.');
        }
    }
}