@isTest
public class CriteriaMatcherClone_Test {
    @isTest
    private static void testMatch(){
        String JSONString = '{"Authority": "test authority"}';
        Map<String,Object> objectToMatch = (Map<String,Object>) JSON.deserializeUntyped(JSONString);

        List<CriteriaMatcherClone.Rule> listOfRules = new List<CriteriaMatcherClone.Rule>();

        CriteriaMatcherClone.Rule rule = new CriteriaMatcherClone.Rule();
        rule.field = 'Authority';
        rule.firstValue = 'test authority';
        rule.type = 'string';
        rule.comparator = 'equals';
        listOfRules.add(rule);

        Test.startTest();
        CriteriaMatcherClone matcher = new CriteriaMatcherClone();
        Boolean isMatch = matcher.match(objectToMatch, listOfRules);
        Test.stopTest();

        System.assertEquals(true, isMatch, 'The testMatch method should return true as the specified value and the object values are equal');
    }

    @isTest
    private static void testMatchException(){
        String JSONString = '{"Authority": "test authority"}';
        Map<String,Object> objectToMatch = (Map<String,Object>) JSON.deserializeUntyped(JSONString);

        List<CriteriaMatcherClone.Rule> listOfRules = new List<CriteriaMatcherClone.Rule>();

        CriteriaMatcherClone.Rule rule = new CriteriaMatcherClone.Rule();
        rule.field = 'Authority';
        rule.firstValue = 'test authority';
        rule.type = 'string';
        rule.comparator = 'Test';
        listOfRules.add(rule);

        String exceptionMessage;

        Test.startTest();
        try {
            CriteriaMatcherClone matcher = new CriteriaMatcherClone();
            Boolean isMatch = matcher.match(objectToMatch, listOfRules);
        }
        catch (Exception e){
            exceptionMessage = e.getMessage();
        }

        Test.stopTest();

        System.assertEquals('Criteria contained an invalid Comparator', exceptionMessage, 'The testMatchException should throw an exception for invalid comparator');
    }

    @isTest
    private static void testCheckRuleDate(){
        String JSONString = '{"Date_of_creation": "2017-07-26 00:00:00"}';
        Map<String,Object> objectToMatch = (Map<String,Object>) JSON.deserializeUntyped(JSONString);

        List<CriteriaMatcherClone.Rule> listOfRules = new List<CriteriaMatcherClone.Rule>();

        CriteriaMatcherClone.Rule rule = new CriteriaMatcherClone.Rule();
        rule.field = 'Date_of_creation';
        rule.firstValue = '2017-07-26 00:00:00';
        rule.type = 'date';
        rule.comparator = 'equals';
        listOfRules.add(rule);

        Test.startTest();
        CriteriaMatcherClone matcher = new CriteriaMatcherClone();
        Boolean isMatch = matcher.match(objectToMatch, listOfRules);
        Test.stopTest();

        System.assertEquals(true, isMatch, 'The testCheckRuleDate method should return true as the specified value and the object values are equal');
    }

    @isTest
    private static void testCheckRuleMultipicklist(){
        String JSONString = '{"Type_of_houses": "One Bedroom;Two Bedroom;Three bedroom"}';
        Map<String,Object> objectToMatch = (Map<String,Object>) JSON.deserializeUntyped(JSONString);

        List<CriteriaMatcherClone.Rule> listOfRules = new List<CriteriaMatcherClone.Rule>();

        CriteriaMatcherClone.Rule rule = new CriteriaMatcherClone.Rule();
        rule.field = 'Type_of_houses';
        rule.firstValue = 'One Bedroom';
        rule.type = 'multipicklist';
        rule.comparator = 'contains';
        listOfRules.add(rule);

        Test.startTest();
        CriteriaMatcherClone matcher = new CriteriaMatcherClone();
        Boolean isContain = matcher.match(objectToMatch, listOfRules);
        Test.stopTest();

        System.assertEquals(true, isContain, 'The testCheckRuleMultipicklist method should return true as the object values contain the specified value');
    }

    @isTest
    private static void testCheckRuleNumericType(){
        String JSONString = '{"Number": "4"}';
        Map<String,Object> objectToMatch = (Map<String,Object>) JSON.deserializeUntyped(JSONString);

        List<CriteriaMatcherClone.Rule> listOfRules = new List<CriteriaMatcherClone.Rule>();

        CriteriaMatcherClone.Rule rule = new CriteriaMatcherClone.Rule();
        rule.field = 'Number';
        rule.firstValue = '5';
        rule.type = 'integer';
        rule.comparator = 'lesser';
        listOfRules.add(rule);

        Test.startTest();
        CriteriaMatcherClone matcher = new CriteriaMatcherClone();
        Boolean isLesser = matcher.match(objectToMatch, listOfRules);
        Test.stopTest();

        System.assertEquals(true, isLesser, 'The testCheckRuleNumericType method should return true as the specified value is greater than the object field value');
    }

    @isTest
    private static void testCheckRuleDateTime(){
        String JSONString = '{"Date_Time": "2017-07-25 00:00:00"}';
        Map<String,Object> objectToMatch = (Map<String,Object>) JSON.deserializeUntyped(JSONString);

        List<CriteriaMatcherClone.Rule> listOfRules = new List<CriteriaMatcherClone.Rule>();

        CriteriaMatcherClone.Rule rule = new CriteriaMatcherClone.Rule();
        rule.field = 'Date_Time';
        rule.firstValue = '2019-01-03T00:26:01.711-02:00';
        rule.type = 'datetime';
        rule.comparator = 'greaterthan';
        listOfRules.add(rule);

        Test.startTest();
        CriteriaMatcherClone matcher = new CriteriaMatcherClone();
        Boolean isGreater = matcher.match(objectToMatch, listOfRules);
        Test.stopTest();

        System.assertEquals(false, isGreater, 'The testCheckRuleDateTime method should return false as the specified value is greater than the object field value');
    }

    @isTest
    private static void testCheckNumericTypeLesser(){
        Test.startTest();
        CriteriaMatcherClone matcher = new CriteriaMatcherClone();
        Boolean isLesser = matcher.checkNumericType('lesser', '4', '5', '');
        Test.stopTest();

        System.assertEquals(true, isLesser, 'The testCheckNumericTypeLesser method should return true as the specified value is greater than the object field value');
    }

    @isTest
    private static void testCheckNumericTypeBetween(){
        Test.startTest();
        CriteriaMatcherClone matcher = new CriteriaMatcherClone();
        Boolean isBetween = matcher.checkNumericType('between', '4', '5', '6');
        Test.stopTest();

        System.assertEquals(false, isBetween, 'The testCheckNumericTypeBetween method should return false as the object value is not between specified values');
    }
    
    @isTest
    private static void testCheckNumericTypeNotBetween(){
        Test.startTest();
        CriteriaMatcherClone matcher = new CriteriaMatcherClone();
        Boolean isNotBetween = matcher.checkNumericType('notbetween', '4', '5', '6');
        Test.stopTest();

        System.assertEquals(true, isNotBetween, 'The testCheckNumericTypeNotBetween method should return true as the object value is not between specified values');
    }

    @isTest
    private static void testCheckNumericTypeEquals(){
        Test.startTest();
        CriteriaMatcherClone matcher = new CriteriaMatcherClone();
        Boolean isEquals = matcher.checkNumericType('equals', '4', '4', '');
        Test.stopTest();

        System.assertEquals(true, isEquals, 'The testCheckNumericTypeEquals method should return true as the object value is not between specified values');
    }

    @isTest
    private static void testCheckNumericTypeNotEquals(){
        Test.startTest();
        CriteriaMatcherClone matcher = new CriteriaMatcherClone();
        Boolean isNotEqual = matcher.checkNumericType('notequals', '4', '5', '');
        Test.stopTest();

        System.assertEquals(true, isNotEqual, 'The testCheckNumericTypeNotEquals method should return true as the object value does not equal to the specified values');
    }

    @isTest
    private static void testCheckDateTypeNotEquals(){
        Test.startTest();
        CriteriaMatcherClone matcher = new CriteriaMatcherClone();
        Boolean isNotEquals = matcher.checkDateType('notequals', '2017-07-25 00:00:00', '2017-07-26 00:00:00');
        Test.stopTest();

        System.assertEquals(true, isNotEquals, 'The testCheckDateTypeNotEquals method should return true as the object value does not equal the specified value');
    }

    @isTest
    private static void testCheckDateTypeGreater(){
        Test.startTest();
        CriteriaMatcherClone matcher = new CriteriaMatcherClone();
        Boolean isGreater = matcher.checkDateType('greaterthan', '2017-07-26 00:00:00', '2017-07-24 00:00:00');
        Test.stopTest();

        System.assertEquals(true, isGreater, 'The testCheckDateTypeGreater method should return true as the object value is greater than the specified value');
    }

    @isTest
    private static void testCheckDateTypeLesser(){
        Test.startTest();
        CriteriaMatcherClone matcher = new CriteriaMatcherClone();
        Boolean isLesser = matcher.checkDateType('lesser', '2017-07-25 00:00:00', '2017-07-28 00:00:00');
        Test.stopTest();

        System.assertEquals(true, isLesser, 'The testCheckDateTypeLesser method should return true as the object value is lesser than the specified value');
    }

    @isTest
    private static void testCheckDateTimeTypeLesser(){
        Test.startTest();
        CriteriaMatcherClone matcher = new CriteriaMatcherClone();
        Boolean isLesser = matcher.checkDateTimeType('lesser', '2017-07-25 00:00:00', '2019-01-03T00:26:01.711-02:00');
        Test.stopTest();

        System.assertEquals(true, isLesser, 'The testCheckDateTimeTypeLesser method should return true as the object value is lesser than the specified value');
    }

    @isTest
    private static void testCheckSimpleTypeLesser(){
        Test.startTest();
        CriteriaMatcherClone matcher = new CriteriaMatcherClone();
        Boolean isLesser = matcher.checkSimpleType('lesser', '2147483628L', '2147483648L');
        Test.stopTest();

        System.assertEquals(true, isLesser, 'The testCheckSimpleTypeLesser method should return true as the object value is lesser than the specified value');
    }

    @isTest
    private static void testCheckSimpleTypeDoesNotContain(){
        Test.startTest();
        CriteriaMatcherClone matcher = new CriteriaMatcherClone();
        Boolean isContain = matcher.checkSimpleType('doesnotcontain', '2147483628LLL', 'L');
        Test.stopTest();

        System.assertEquals(false, isContain, 'The testCheckSimpleTypeDoesNotContain method should return false as the object value contains the specified value');
    }

    @isTest
    private static void testCheckMultiPicklistEquals(){
        Test.startTest();
        CriteriaMatcherClone matcher = new CriteriaMatcherClone();
        Boolean isEqual = matcher.checkMultiPicklist('equals', 'Test; Test1; Test2', 'Test L; Test L2');
        Test.stopTest();

        System.assertEquals(false, isEqual, 'The testCheckMultiPicklistEquals method should return false as the object values is not equal to the specified values');
    }

    @isTest
    private static void testCheckMultiPicklistContains(){
        Test.startTest();
        CriteriaMatcherClone matcher = new CriteriaMatcherClone();
        Boolean isContains = matcher.checkMultiPicklist('contains', 'Test; Test1; Test2', 'Test L; Test L2');
        Test.stopTest();

        System.assertEquals(false, isContains, 'The testCheckMultiPicklistContains method should return false as the object values does not contain the specified values');
    }

    @isTest
    private static void testCheckMultiPicklistNotContains(){
        Test.startTest();
        CriteriaMatcherClone matcher = new CriteriaMatcherClone();
        Boolean isNotContains = matcher.checkMultiPicklist('doesnotcontain', 'Test; Test1; Test2', 'Test L; Test L2');
        Test.stopTest();

        System.assertEquals(true, isNotContains, 'The testCheckMultiPicklistNotContains method should return true as the object values does not contain the specified values');
    }
}