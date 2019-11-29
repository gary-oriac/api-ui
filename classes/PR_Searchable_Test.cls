@isTest
private with sharing class PR_Searchable_Test {


    @isTest
    private static void jsonStructureIsParsed() {
        List<PR_Searchable> searchables = PR_Searchable.parse(jsonExample);

        System.assertEquals(2, searchables.size(), 'Incorrect number of searchables were parsed');

        System.assertEquals('Account', searchables[0].name, 'name variable was incorrect');
        System.assertEquals('Account', searchables[0].objectName, 'objectName variable was incorrect');
        System.assertEquals(4, searchables[0].objectFields.size(), 'objectFields held the wrong number of fields');
        System.assertEquals('name = \'test\'', searchables[0].objectRestrictions, 'objectRestrictions variable was incorrect');
        System.assertEquals('SLAExpirationDate__c', searchables[0].objectOrderBy, 'objectOrderBy variable was incorrect');
        System.assertEquals('Accounts', searchables[0].objectLabel, 'objectLabel variable was incorrect');
        System.assertEquals('No records found.', searchables[0].returnMessage, 'returnMessage variable was incorrect');
        System.assertEquals('5', searchables[0].recordsPerPage, 'recordsPerPage variable was incorrect');
        System.assertEquals('action:description', searchables[0].iconName, 'iconName variable was incorrect');
    }

    @isTest
    private static void isAccessibleReturnsFalseForUserWithoutObjectPermission() {
        User guest = PR_TestUtils.guestUser();
        Boolean accessibility;

        System.runAs(guest){ 
            List<PR_Searchable> searchables = PR_Searchable.parse(jsonExample);
            accessibility = searchables[1].isAccessible();
        }

        System.assertEquals(false, accessibility);
    }

    @isTest
    private static void isAccessibleReturnsFalseForUserWithoutFieldPermission() {
        User guest = PR_TestUtils.guestUser();
        PR_TestUtils.createAndAssignPermissionSet(
            guest.Id,
            webCommentObjectRead(),
            new List<FieldPermissions>{}
        );

        Boolean accessibility;

        System.runAs(guest){ 
            List<PR_Searchable> searchables = PR_Searchable.parse(jsonExample);
            accessibility = searchables[1].isAccessible();
        }

        System.assertEquals(false, accessibility);
    }

    @isTest
    private static void isAccessibleReturnsTrueForUserWithRelivantPermissions() {
        User guest = PR_TestUtils.guestUser();
        PR_TestUtils.createAndAssignPermissionSet(
            guest.Id,
            webCommentObjectRead(),
            webCommentFieldsRead()
        );

        Boolean accessibility;

        System.runAs(guest){ 
            List<PR_Searchable> searchables = PR_Searchable.parse(jsonExample);
            accessibility = searchables[1].isAccessible();
        }

        System.assertEquals(true, accessibility);
    }

    @isTest
    private static void fieldsTheUserCannotReadAreRemoved() {
        User guest = PR_TestUtils.guestUser();
        PR_TestUtils.createAndAssignPermissionSet(
            guest.Id,
            webCommentObjectRead(),
            new List<FieldPermissions>{}
        );

        PR_Searchable searchable;

        System.runAs(guest){ 
            List<PR_Searchable> searchables = PR_Searchable.parse(jsonExample);
            searchables[1].removeInAccessibleFields();
            searchable = searchables[1];
        }

        System.assertEquals(1, searchable.objectFields.size());
    }

    @isTest
    private static void referenceFieldIsAddedWhenRetrievingQueryFieldsForReferenceType() {
        List<PR_Searchable> searchables = PR_Searchable.parse(jsonExample);
        Set<String> queryFields = searchables[0].queryFields();

        System.assert(queryFields.contains('Id'));
    }

    @isTest
    private static void toLabelFormulaIsAddedWhenRetrievingQueryFieldsForPicklistType() {
        List<PR_Searchable> searchables = PR_Searchable.parse(jsonExample);
        Set<String> queryFields = searchables[0].queryFields();

        System.assert(queryFields.contains('toLabel(Type)'));
    }

    private static List<ObjectPermissions> webCommentObjectRead() {
        return new List<ObjectPermissions> {
            new ObjectPermissions(
                SobjectType = 'arcshared__Web_Comment__c',
                PermissionsRead = true, 
                PermissionsCreate = false
            )
        };
    }

    private static List<FieldPermissions> webCommentFieldsRead() {
        return new List<FieldPermissions>{
            new FieldPermissions(
                SobjectType = 'arcshared__Web_Comment__c', 
                Field = 'arcshared__Web_Comment__c.arcshared__Email__c',
                PermissionsRead = true, 
                PermissionsEdit = false
            )
        };
    }

    private static string jsonExample = '[' +
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
}