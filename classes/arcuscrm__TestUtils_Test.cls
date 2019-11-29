@isTest
private with sharing class TestUtils_Test {
    
    @isTest
    private static void newUserIsCreated() {
        Test.startTest();
        User newUser = TestUtils.createUser();
        Test.stopTest();

        List<User> users = [SELECT Id FROM User WHERE Id =: newUser.Id];
        System.assertEquals(1, users.size());
    }
    
}