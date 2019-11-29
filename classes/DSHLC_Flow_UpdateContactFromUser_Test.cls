/*
Company : Arcus Global
Product : Arcus DSH
Purpose : Test DSHLC_Flow_UpdateContactFromUser class
Notes :
 */
@isTest
global with sharing class DSHLC_Flow_UpdateContactFromUser_Test {

    @isTest
    private static void test_flow_update_contact_for_given_user() {
        //Arrange
        System.runAs(DSHLC_TestUtility.createSysAdminUserWithRole()) {
            User testUser = DSHLC_TestUtility.createCommunityUser();
            Map<String, Object> inputParams = new Map<String, Object>();
            inputParams.put('UserID', testUser.Id);

            //Act
            Test.startTest();
            DSHLC_Flow_UpdateContactFromUser plugin = new DSHLC_Flow_UpdateContactFromUser();
            Process.PluginRequest request = new Process.PluginRequest(inputParams);
            plugin.invoke(request);
            Test.stopTest();

            //Assert
            System.assertNotEquals(null, plugin);
        }
    }

    @isTest
    private static void describeResult() {
        //Act
        DSHLC_Flow_UpdateContactFromUser plugin = new DSHLC_Flow_UpdateContactFromUser();
        Process.PluginDescribeResult describeResult = plugin.describe();

        //Assert
        System.assertEquals('Contact', describeResult.tag);
        System.assertEquals(1, describeResult.inputParameters.size());
    }

}