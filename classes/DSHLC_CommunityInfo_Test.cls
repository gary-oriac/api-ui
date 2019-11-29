/*
Company : Arcus Global
Product : Arcus DSH
Purpose : Test DSHLC_CommunityInfo class
Notes :
 */
@isTest
private with sharing class DSHLC_CommunityInfo_Test {
    
    static testMethod void getCommunityTest() 
    {
        // Pull the default community name from the static method
        DSHLC_CommunityInfo.StringWrapper net = DSHLC_CommunityInfo.getCommunity();
        
        // Compare the above result, to the default set in the class
        System.AssertEquals(DSHLC_CommunityInfo.DEFAULT_LIGHTNING_COMMUNITY_RESIDENT, net.ORIGINAL);  
        System.AssertEquals(DSHLC_CommunityInfo.DEFAULT_LIGHTNING_COMMUNITY_RESIDENT.toUpperCase(), net.UC);
        System.AssertEquals(DSHLC_CommunityInfo.DEFAULT_LIGHTNING_COMMUNITY_RESIDENT.toLowerCase(), net.LC);
        String testSC = DSHLC_CommunityInfo.DEFAULT_LIGHTNING_COMMUNITY_RESIDENT.subString( 0 , 1 ).toUpperCase() + DSHLC_CommunityInfo.DEFAULT_LIGHTNING_COMMUNITY_RESIDENT.substring(1).toLowerCase();
        System.AssertEquals(testSC, net.SC);
    }
    
    static testMethod void obtainCommunityTest()
    {
        DSHLC_CommunityInfo.StringWrapper nonet = DSHLC_CommunityInfo.obtainCommunity();
        System.AssertEquals(nonet.ORIGINAL,'resident2'); 
    }

}