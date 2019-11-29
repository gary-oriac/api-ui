@isTest
private class PR_SearchCont_Test {

    @TestSetup
    static void setup() {
        insert new List<arcshared__Configuration__c> {
            new arcshared__Configuration__c(
                arcshared__Public_JSON_Schema__c = searchableJson,
                arcshared__DeveloperName__c = 'searchable_resource'
            ),
            new arcshared__Configuration__c(
                arcshared__Public_JSON_Schema__c = categoryJson,
                arcshared__DeveloperName__c = 'category_resource'
            ),
            new arcshared__Configuration__c(
                arcshared__Public_JSON_Schema__c = weeklyListJson,
                arcshared__DeveloperName__c = 'weekly_list_resource'
            )
        };
    }

    @isTest
    private static void searchReturnsOneMatchingRecord() {
        List<Account> accountList = new List<Account> {
            new Account(
                Name = 'Moo'
            ),
            new Account(
                Name = 'Baa'
            )
        };
        insert accountList;

        Test.setFixedSearchResults(new List<Id>{accountList[0].Id});

        Test.startTest();
        String results = PR_SearchCont.search('searchable_resource', 'Account', 'moo');
        List<PR_SearchCont.Result> parsedResults = (List<PR_SearchCont.Result>)JSON.deserialize(results, List<PR_SearchCont.Result>.class);
        Test.stopTest();

        System.assertEquals(1, parsedResults.size());
        System.assertEquals(1, parsedResults[0].records.size());
    }

    @isTest
    private static void searchReturnsInvalidSearchWhenNoSearchTerm() {
        String results = PR_SearchCont.search('searchable_resource', 'Account', '');
        System.assertEquals('invalid_search', results);
    }

    @isTest
    private static void searchReturnsInvalidSearchWhenNoResults() {
        String results = PR_SearchCont.search('searchable_resource', 'Account', 'moo');
        System.assertEquals('invalid_search', results);
    }

    @isTest
    private static void oneWeeklyListIsReturned() {
        String result = PR_SearchCont.getAvailableWeeklyLists('weekly_list_resource');
        List<Map<String, String>> parsedResult = (List<Map<String, String>>)JSON.deserialize(result, List<Map<String, String>>.class);

        System.assertEquals(1, parsedResult.size());
    }

    @isTest
    private static void threeCategoriesAreReturned() {
        String result = PR_SearchCont.getCategoryData('category_resource');
        List<PR_Category> parsedResult = (List<PR_Category>)JSON.deserialize(result, List<PR_Category>.class);

        System.assertEquals(3, parsedResult.size());
    }

    @isTest
    private static void oneAccountIsReturnedForWeeklyQuery() {
        insert new List<Account> {
            new Account(
                Name = 'Moo',
                arcshared__Accounts_Next_Due__c = Date.today()
            ),
            new Account(
                Name = 'Baa',
                arcshared__Accounts_Next_Due__c = Date.today().addDays(10)
            )
        };

        String results = PR_SearchCont.weeklyQuery('searchable_resource', 'weekly_list_resource', 'Account', String.valueOf(Date.today()));
        PR_SearchCont.Result parsedResult = (PR_SearchCont.Result)JSON.deserialize(results, PR_SearchCont.Result.class);

        System.assertEquals(1, parsedResult.records.size());
    }

    @isTest
    private static void invalidSearchIsReturnedForWeeklyQueryWithoutResources() {
        String results = PR_SearchCont.weeklyQuery('searchable_resource', '', 'Account', String.valueOf(Date.today()));
        System.assertEquals('invalid_search', results);
    }

    @isTest
    private static void invalidSearchIsReturnedForWeeklyQueryWithoutResults() {
        String results = PR_SearchCont.weeklyQuery('searchable_resource', 'weekly_list_resource', 'Account', String.valueOf(Date.today()));
        System.assertEquals('invalid_search', results);
    }

    @isTest
    private static void twoAccountsAreReturnedForBaseQuery() {
        insert new List<Account> {
            new Account(
                Name = 'Moo'
            ),
            new Account(
                Name = 'Baa'
            )
        };

        String results = PR_SearchCont.baseQuery('searchable_resource', 'Account');
        PR_SearchCont.Result parsedResult = (PR_SearchCont.Result)JSON.deserialize(results, PR_SearchCont.Result.class);

        System.assertEquals(2, parsedResult.records.size());
    }

    @isTest
    private static void invalidSearchIsReturnedForBaseQueryWithoutResources() {
        String results = PR_SearchCont.baseQuery('', 'Account');
        System.assertEquals('invalid_search', results);
    }

    @isTest
    private static void invalidSearchIsReturnedForBaseQueryWithoutResults() {
        String results = PR_SearchCont.baseQuery('searchable_resource', 'Account');
        System.assertEquals('invalid_search', results);
    }

    @isTest
    private static void oneAccountIsReturnedForQuery() {
        insert new List<Account> {
            new Account(
                Name = 'Moo'
            ),
            new Account(
                Name = 'Baa'
            )
        };

        Map<String, String> criteria = new Map<String, String>{
            'Name' => 'Moo'
        };


        String results = PR_SearchCont.query('searchable_resource', 'category_resource', 'Account', criteria);
        PR_SearchCont.Result parsedResult = (PR_SearchCont.Result)JSON.deserialize(results, PR_SearchCont.Result.class);

        System.assertEquals(1, parsedResult.records.size());
    }

    @isTest
    private static void oneAccountIsReturnedForQueryWithDateTypeRestriction() {
        insert new List<Account> {
            new Account(
                Name = 'Moo',
                arcshared__Accounts_Next_Due__c = Date.today()
            ),
            new Account(
                Name = 'Baa'
            )
        };

        Map<String, String> criteria = new Map<String, String>{
            'arcshared__Accounts_Next_Due__c' => String.valueOf(Date.today())
        };


        String results = PR_SearchCont.query('searchable_resource', 'category_resource', 'Account', criteria);
        PR_SearchCont.Result parsedResult = (PR_SearchCont.Result)JSON.deserialize(results, PR_SearchCont.Result.class);

        System.assertEquals(1, parsedResult.records.size());
    }

    @isTest
    private static void oneAccountIsReturnedForQueryWithUknownTypeRestriction() {
        insert new List<Account> {
            new Account(
                Name = 'Moo',
                arcshared__Etag__c = '7'
            ),
            new Account(
                Name = 'Baa'
            )
        };

        Map<String, String> criteria = new Map<String, String>{
            'arcshared__Etag__c' => '7'
        };


        String results = PR_SearchCont.query('searchable_resource', 'category_resource', 'Account', criteria);
        PR_SearchCont.Result parsedResult = (PR_SearchCont.Result)JSON.deserialize(results, PR_SearchCont.Result.class);

        System.assertEquals(1, parsedResult.records.size());
    }

    @isTest
    private static void invalidSearchIsReturnedForQueryWithoutResources() {
        String results = PR_SearchCont.query('searchable_resource', '', 'Account', null);
        System.assertEquals('invalid_search', results);
    }

    @isTest
    private static void invalidSearchIsReturnedForQueryWithoutResults() {
        String results = PR_SearchCont.query('searchable_resource', 'category_resource', 'Account', new Map<String, String>());
        System.assertEquals('invalid_search', results);
    }

    private static string searchableJson = '[' +
        '{' +
            '"name": "Account",' +
            '"objectName": "Account",' +
            '"objectFields": [' +
                '{' +
                    '"path": "Id",' +
                    '"label": "Name",' +
                    '"type": "reference",' +
                    '"refLabel": "Name",' +
                    '"prefix": "pr/s/detail"' +
                '},' +
                '{' +
                    '"path": "arcshared__Etag__c",' +
                    '"label": "Etag",' +
                    '"type": "String"' +
                '},' +
                '{' +
                    '"path": "Type",' +
                    '"label": "Type",' +
                    '"type": "Picklist"' +
                '},' +
                '{' +
                    '"path": "arcshared__Accounts_Next_Due__c",' +
                    '"label": "Accounts next due",' +
                    '"type": "date"' +
                '}' +
            '],' +
            '"objectRestrictions": "",' +
            '"objectOrderBy": "",' +
            '"objectLabel": "Accounts",' +
            '"returnMessage": "No records found.",' +
            '"recordsPerPage": "5",' +
            '"iconName": "action:description"' +
        '},' +
        '{' +
            '"name": "WebComment",' +
            '"objectName": "arcshared__Web_Comment__c",' +
            '"objectFields": [' +
                '{' +
                    '"path": "Id",' +
                    '"label": "Name",' +
                    '"type": "reference",' +
                    '"refLabel": "Name",' +
                    '"prefix": "pr/s/detail"' +
                '},' +
                '{' +
                    '"path": "arcshared__Email__c",' +
                    '"label": "Email",' +
                    '"type": "String"' +
                '}' +
            '],' +
            '"objectRestrictions": "",' +
            '"objectOrderBy": "",' +
            '"objectLabel": "Contacts",' +
            '"returnMessage": "No records found.",' +
            '"recordsPerPage": "5",' +
            '"iconName": "action:description"' +
        '}' +
    ']';

    private static String categoryJson = '[' +
        '{' +
            '"name": "Account",' +
            '"value": "Account",' +
            '"label": "Account Filter",' +
            '"field_set": [' +
                '{' +
                    '"label": "Name",' +
                    '"field": "Name",' +
                    '"path": "Name",' +
                    '"type": "string"' +
                '},' +
                '{' +
                    '"label": "Etag",' +
                    '"field": "arcshared__Etag__c",' +
                    '"path": "arcshared__Etag__c",' +
                    '"Type": "number"' +
                '},' +
                '{' +
                    '"path": "arcshared__Accounts_Next_Due__c",' +
                    '"label": "Accounts next due",' +
                    '"field": "arcshared__Accounts_Next_Due__c",' +
                    '"type": "date",' +
                    '"operation": "="' +
                '},' +
                '{' +
                    '"label": "Account Type",' +
                    '"field": "Type",' +
                    '"path": "Type",' +
                    '"type": "picklist"' +
                '}' +
            ']' +
        '},' +
        '{' +
            '"name": "WebComment",' +
            '"value": "arcshared__Web_Comment__c",' +
            '"label": "WebComment Filter",' +
            '"field_set": [' +
                '{' +
                    '"label": "Email",' +
                    '"field": "arcshared__Email__c",' +
                    '"path": "arcshared__Email__c",' +
                    '"type": "string"' +
                '}' +
            ']' +
        '},' +
        '{' +
            '"name": "Financial Transaction",' +
            '"value": "arcshared__Financial_Transaction__c",' +
            '"label": "Financial Transaction Filter",' +
            '"field_set": [' +
                '{' +
                    '"label": "Record Type",' +
                    '"field": "RecordTypeId",' +
                    '"path": "RecordTypeId",' +
                    '"type": "picklist"' +
                '}' +
            ']' +
        '}' +
    ']';

    private static String weeklyListJson = '[' +
        '{' +
            '"name": "Account",' +
            '"label": "Accounts received this week",' +
            '"restriction_field": "arcshared__Accounts_Next_Due__c"' +
        '}' +
    ']';
}