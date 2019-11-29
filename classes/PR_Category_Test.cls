@isTest
private with sharing class PR_Category_Test {
    
    @isTest
    private static void jsonStructureIsParsed() {
        List<PR_Category> categories = PR_Category.parse(jsonExample);

        System.assertEquals(3, categories.size(), 'Incorrect number of categories were parsed');

        System.assertEquals('Account', categories[0].name, 'name variable was incorrect');
        System.assertEquals('Account', categories[0].value, 'value variable was incorrect');
        System.assertEquals('Account Filter', categories[0].label, 'label variable was incorrect');
        System.assertEquals(4, categories[0].field_set.size(), 'field_set held the wrong number of fields');
    }

    @isTest
    private static void optionsAreSetForPicklistField() {
        List<PR_Category> categories = PR_Category.parse(jsonExample);

        System.assert(categories[0].field_set[3].options.size() > 0);
    }

    @isTest
    private static void optionsAreSetForRecordTypeIdField() {
        List<PR_Category> categories = PR_Category.parse(jsonExample);

        System.assert(categories[2].field_set[0].options.size() > 0);
    }

    @isTest
    private static void isAccessibleReturnsFalseForUserWithoutObjectPermission() {
        User guest = PR_TestUtils.guestUser();
        Boolean accessibility;

        System.runAs(guest){ 
            List<PR_Category> categories = PR_Category.parse(jsonExample);
            accessibility = categories[1].isAccessible();
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
            List<PR_Category> categories = PR_Category.parse(jsonExample);
            accessibility = categories[1].isAccessible();
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
            List<PR_Category> categories = PR_Category.parse(jsonExample);
            accessibility = categories[1].isAccessible();
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

        PR_Category category;

        System.runAs(guest){ 
            List<PR_Category> categories = PR_Category.parse(jsonExample);
            categories[1].removeInAccessibleFields();
            category = categories[1];
        }

        System.assertEquals(0, category.field_set.size());
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

    private static String jsonExample = '[' +
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
                    '"field": "SLAExpirationDate__c",' +
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
}