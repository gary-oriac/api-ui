@isTest
public class StaffHubMonitoring_Test {
    @TestSetup
    static void setup(){
        List<User> us = new List<User>();
    User u1 = new User(Alias = 'testFO', 
                Email='testuser' +'@test.com',
                EmailEncodingKey='UTF-8', 
                LastName='Testing', 
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_GB',
                UserName = 'StaffHubUser'+'@test.com', 
                TimeZoneSidKey='America/Los_Angeles',
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id);
        User u2 = new User(Alias = 'testFO2', 
                Email='testuser' +'@test.com',
                EmailEncodingKey='UTF-8', 
                LastName='Testing', 
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_GB',
                UserName = 'StaffHubUser2'+'@test.com', 
                TimeZoneSidKey='America/Los_Angeles',
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id);
        us.add(u1);
        us.add(u2);
    insert us;
    }

	@isTest
    private static void testAnalyse(){
        List<User> u = [SELECT Id FROM User WHERE LastName='Testing'];
        Contact c = new Contact(LastName = 'TestBob', arcuscrm__Linked_Internal_User__c = u[0].Id);
        insert c; 
        System.debug('uId:' + u);
        System.runAs(u[0]){
            Case caseToInsert = new Case(Description='test', ContactId = c.Id, OwnerId = u[1].Id);
            system.debug('TEST case: '+ caseToInsert);
            insert caseToInsert;
            
            Case caseToInsert2 = new Case(Description='test', ContactId = c.Id, OwnerId = u[0].Id);
            system.debug('TEST case: '+ caseToInsert2);
            insert caseToInsert2;

            Test.startTest();
                Map<Id,Case> output = StaffHubMonitoring.analyse();
            Test.stopTest();
            
            System.assertEquals(1, output.size(), 'No cases should be returned as no broken cases inserted');
        }
    }
    
    @isTest
    private static void testRepair(){
        Map<Id,Case> input = new Map<Id,Case>();
        Test.startTest();
        	StaffHubMonitoring.repair(input);
        Test.stopTest();
    }
    
    @isTest
    private static void testRepairAll(){
        Test.startTest();
        	StaffHubMonitoring.repairAll();
        Test.stopTest();
    }
}