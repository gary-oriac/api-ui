/*
Company : Arcus Global
Product : Arcus DSH
Purpose : Test CaseDetailCont controller class
Notes :
 */
@isTest
private with sharing class DSHLC_CaseDetailCont_Test {

    @testSetup
    private static void setup() {
        DSHLC_TestUtility.createCommunityUser();
    }

    @isTest
    private static void testGetCaseDetail() {
        List<DSHLC_CaseDetailCont.CaseListWrapper> result;
        Case testCase;

        User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
        System.runAs(communityUser) {
            testCase = new Case(ContactId = communityUser.ContactId, Status = 'New', Subject = 'Testing', Description = 'Testing');
            insert testCase;

            testCase = [SELECT CaseNumber FROM Case WHERE Id = :testCase.Id LIMIT 1];

            Test.startTest();
            result = DSHLC_CaseDetailCont.getCaseDetail(testCase.CaseNumber);
            Test.stopTest();
        }

        System.assertEquals(1, result.size(), 'Should get one case wrapper since we only expected details for one case');
        System.assertEquals(testCase.CaseNumber, result[0].CaseNumber, 'The case number on the returned wrapper should be the same as the given one');
        System.assertEquals(true, String.isNotBlank(result[0].createdDate), 'Created date should be returned');
        System.assertEquals(true, String.isNotBlank(result[0].Status), 'Status should be returned');
        System.assertEquals(true, String.isNotBlank(result[0].Subject), 'Subject should be returned');
        System.assertEquals(true, String.isNotBlank(result[0].Description), 'Description should be returned');
    }

    @isTest
    private static void testGetCaseDetailWithNoCaseExist() {
        List<DSHLC_CaseDetailCont.CaseListWrapper> result;

        User communityUser = DSHLC_TestUtility.getExistingCommunityUser();
        System.runAs(communityUser) {

            Test.startTest();
            result = DSHLC_CaseDetailCont.getCaseDetail(null);
            Test.stopTest();
        }

        System.assertEquals(null, result, 'Should get null since the case number is not valid hence no case details is expected');
    }

}