/*
Company    :    Arcus Global
Product    :    Arcus DSH 
Purpose    :    Test DSHLC_CaseHistoryCont controller class
Notes      :     
*/
@isTest
private with sharing class DSHLC_CaseHistoryCont_Test {
    @isTest
    private static void testGetCaseDetail() {
        List<DSHLC_CaseHistoryCont.CaseListWrapper> result;
        List<Case> testCases;

        User communityUser = DSHLC_TestUtility.createCommunityUser();
        System.runAs(communityUser) {
            Case testCase1 = new Case(ContactId = communityUser.ContactId, Status = 'New', Subject = 'Testing 1', Description = 'Testing 1');
            Case testCase2 = new Case(ContactId = communityUser.ContactId, Status = 'New', Subject = 'Testing 2', Description = 'Testing 2');
            testCases = new List<Case> {testCase1, testCase2};
            insert testCases;

            testCases = [SELECT CaseNumber FROM Case WHERE Id IN :testCases ORDER BY Subject];

            Test.startTest();
            result = DSHLC_CaseHistoryCont.getCases();
            Test.stopTest();
        }

        System.assertEquals(2, result.size(), 'Should get two case wrappers since we have two cases belong to the community user');
        System.assertEquals(testCases[0].CaseNumber, result[0].CaseNumber, 'Expected case not returned as the case number is incorrect');
        System.assertEquals(testCases[1].CaseNumber, result[1].CaseNumber, 'Expected case not returned as the case number is incorrect');

        System.assertEquals(true, String.isNotBlank(result[0].createdDate), 'Created date should be returned');
        System.assertEquals(true, String.isNotBlank(result[0].Status), 'Status should be returned');
        System.assertEquals(true, String.isNotBlank(result[0].Subject), 'Subject should be returned');
        System.assertEquals(true, String.isNotBlank(result[0].Description), 'Description should be returned');
    }
}