@isTest
private with sharing class PR_WeeklyList_Test {
    
    @isTest
    private static void jsonStructureIsParsed() {
        List<PR_WeeklyList> weeklyLists = PR_WeeklyList.parse(jsonExample);

        System.assertEquals(1, weeklyLists.size(), 'Incorrect number of weekly lists were parsed');

        System.assertEquals('Account', weeklyLists[0].name, 'name variable was incorrect');
        System.assertEquals('Accounts received this week', weeklyLists[0].label, 'label variable was incorrect');
        System.assertEquals('SLAExpirationDate__c', weeklyLists[0].restriction_field, 'restriction_field variable was incorrect');
    }

    private static String jsonExample = '[' +
        '{' +
            '"name": "Account",' +
            '"label": "Accounts received this week",' +
            '"restriction_field": "SLAExpirationDate__c"' +
        '}' +
    ']';
}