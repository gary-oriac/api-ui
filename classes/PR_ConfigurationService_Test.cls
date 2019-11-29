@isTest
private with sharing class PR_ConfigurationService_Test {

    @isTest
    private static void fetchSearchablesFromConfiguration() {
        arcshared__Configuration__c configuration = new arcshared__Configuration__c(
            arcshared__Public_JSON_Schema__c = searchableJson,
            arcshared__DeveloperName__c = 'searchable_resource'
        );

        insert configuration;

        List<PR_Searchable> searchables = PR_ConfigurationService.fetchSearchables(new List<String>{'searchable_resource'});

        System.assertEquals(2, searchables.size());
    }

    @isTest
    private static void fetchSearchableFromConfigurationByName() {
        arcshared__Configuration__c configuration = new arcshared__Configuration__c(
            arcshared__Public_JSON_Schema__c = searchableJson,
            arcshared__DeveloperName__c = 'searchable_resource'
        );

        insert configuration;

        PR_Searchable searchable = PR_ConfigurationService.fetchSearchable(new List<String>{'searchable_resource'}, 'Account');

        System.assertEquals('Account', searchable.name);
    }

    @isTest
    private static void fetchSearchableFromConfigurationByNameReturnsNullForInvalidName() {
        arcshared__Configuration__c configuration = new arcshared__Configuration__c(
            arcshared__Public_JSON_Schema__c = searchableJson,
            arcshared__DeveloperName__c = 'searchable_resource'
        );

        insert configuration;

        PR_Searchable searchable = PR_ConfigurationService.fetchSearchable(new List<String>{'searchable_resource'}, 'GIBBERISH');

        System.assertEquals(null, searchable);
    }

    @isTest
    private static void fetchCategoriesFromConfiguration() {
        arcshared__Configuration__c configuration = new arcshared__Configuration__c(
            arcshared__Public_JSON_Schema__c = categoryJson,
            arcshared__DeveloperName__c = 'category_resource'
        );

        insert configuration;

        List<PR_Category> categories = PR_ConfigurationService.fetchCategories(new List<String>{'category_resource'});

        System.assertEquals(3, categories.size());
    }

    @isTest
    private static void fetchCategoryFromConfigurationByName() {
        arcshared__Configuration__c configuration = new arcshared__Configuration__c(
            arcshared__Public_JSON_Schema__c = categoryJson,
            arcshared__DeveloperName__c = 'category_resource'
        );

        insert configuration;

        PR_Category category = PR_ConfigurationService.fetchCategory(new List<String>{'category_resource'}, 'Account');

        System.assertEquals('Account', category.name);
    }

    @isTest
    private static void fetchCategoryFromConfigurationByNameReturnsNullForInvalidName() {
        arcshared__Configuration__c configuration = new arcshared__Configuration__c(
            arcshared__Public_JSON_Schema__c = categoryJson,
            arcshared__DeveloperName__c = 'category_resource'
        );

        insert configuration;

        PR_Category category = PR_ConfigurationService.fetchCategory(new List<String>{'category_resource'}, 'GIBBERISH');

        System.assertEquals(null, category);
    }

    @isTest
    private static void fetchWeeklyListsFromConfiguration() {
        arcshared__Configuration__c configuration = new arcshared__Configuration__c(
            arcshared__Public_JSON_Schema__c = weeklyListJson,
            arcshared__DeveloperName__c = 'weekly_list_resource'
        );

        insert configuration;

        List<PR_WeeklyList> weeklyLists = PR_ConfigurationService.fetchWeeklyLists(new List<String>{'weekly_list_resource'});

        System.assertEquals(1, weeklyLists.size());
    }

    @isTest
    private static void fetchWeeklyListFromConfigurationByName() {
        arcshared__Configuration__c configuration = new arcshared__Configuration__c(
            arcshared__Public_JSON_Schema__c = weeklyListJson,
            arcshared__DeveloperName__c = 'weekly_list_resource'
        );

        insert configuration;

        PR_WeeklyList weeklyList = PR_ConfigurationService.fetchWeeklyList(new List<String>{'weekly_list_resource'}, 'Account');

        System.assertEquals('Account', weeklyList.name);
    }

    @isTest
    private static void fetchWeeklyListFromConfigurationByNameReturnsNullForInvalidName() {
        arcshared__Configuration__c configuration = new arcshared__Configuration__c(
            arcshared__Public_JSON_Schema__c = weeklyListJson,
            arcshared__DeveloperName__c = 'weekly_list_resource'
        );

        insert configuration;

        PR_WeeklyList weeklyList = PR_ConfigurationService.fetchWeeklyList(new List<String>{'weekly_list_resource'}, 'GIBBERISH');

        System.assertEquals(null, weeklyList);
    }

    @isTest
    private static void describeFieldWithSimplePath() {
        PR_ConfigurationService.Describe describe = PR_ConfigurationService.describeFieldByPath('Account', 'Name');

        System.assertEquals('Name', describe.fieldDescribe.getName());
    }

    @isTest
    private static void describeFieldWithComplexPath() {
        PR_ConfigurationService.Describe describe = PR_ConfigurationService.describeFieldByPath('Contact', 'Account.Name');

        System.assertEquals('Name', describe.fieldDescribe.getName());
    }

    @isTest
    private static void fieldWithSimplePathReturnsParentObject() {
        PR_ConfigurationService.Describe describe = PR_ConfigurationService.describeFieldByPath('Account', 'Name');

        System.assertEquals('Account', describe.objectName);
    }

    @isTest
    private static void fieldWithComplexPathReturnsParentObject() {
        PR_ConfigurationService.Describe describe = PR_ConfigurationService.describeFieldByPath('Contact', 'Account.Name');

        System.assertEquals('Account', describe.objectName);
    }

    @isTest
    private static void fieldWithBrokenPathReturnsNull() {
        PR_ConfigurationService.Describe describe = PR_ConfigurationService.describeFieldByPath('Contact', 'Account.GIBBERISH');

        System.assertEquals(null, describe);
    }

    private static String searchableJson = '[' +
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
                    '"path": "AccountNumber",' +
                    '"label": "Account Number",' +
                    '"type": "String"' +
                '},' +
                '{' +
                    '"path": "Type",' +
                    '"label": "Type",' +
                    '"type": "Picklist"' +
                '},' +
                '{' +
                    '"path": "SLAExpirationDate__c",' +
                    '"label": "SLA Expiration Date",' +
                    '"type": "date"' +
                '}' +
            '],' +
            '"objectRestrictions": "name = \'test\'",' +
            '"objectOrderBy": "SLAExpirationDate__c",' +
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
                    '"label": "Account Number",' +
                    '"field": "AccountNumber",' +
                    '"path": "AccountNumber",' +
                    '"Type": "String"' +
                '},' +
                '{' +
                    '"path": "SLAExpirationDate__c",' +
                    '"label": "SLA Expiration Date",' +
                    '"field": "AccountNumber",' +
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
            '"restriction_field": "SLAExpirationDate__c"' +
        '}' +
    ']';
}