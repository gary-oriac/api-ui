@isTest
public with sharing class CRM_ContactDetailController_Test {

    @testSetup static void setup() {

    }

    @isTest
    static void test_getLineUsers(){
        

        Test.startTest();
            
            Account myAcc = new Account(Name = 'Test Acc');
            insert myAcc;
            Contact myCont = new Contact(Firstname = 'Bob', Lastname = 'Test', AccountId = myAcc.Id );
            insert myCont;

            List<User> emptyList = CRM_ContactDetailController.getLinkedUser( myCont.Id );
            System.assert(emptyList.size() == 0, 'Should not have found any users');

        Test.stopTest();

    }

}