@isTest
public class CRM_CouncilServicesController_Test {
    
    @TestSetup
    static void setup(){
        List<arcshared__Council_Service_Area__c> csasToInsert = new List<arcshared__Council_Service_Area__c>();
        arcshared__Council_Service_Area__c csa1 = new arcshared__Council_Service_Area__c(Name = 'Test1', arcuscrm__Used_in_CRM_Service_Selection__c = true);
        csasToInsert.add(csa1);
        arcshared__Council_Service_Area__c csa2 = new arcshared__Council_Service_Area__c(Name = 'Test2', arcuscrm__Used_in_CRM_Service_Selection__c = true);
        csasToInsert.add(csa2);
        insert csasToInsert;
    }

    @isTest
    static void getContactDetails_goodID(){
        RecordType contactRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' LIMIT 1];
        Contact contactToInsert = new Contact(RecordTypeId = contactRT.Id, LastName = 'BOBBINGTON', FirstName = 'BOB');
        insert contactToInsert;

        Test.startTest();
            Contact retrievedContact = CRM_CouncilServicesController.getContactDetails(contactToInsert.Id);
        Test.stopTest();

        System.assertEquals(contactRT.Id, retrievedContact.RecordTypeId, 'The retrieved contact should have the same RecordType as the inserted one.');
        System.assertEquals(contactToInsert.Id, retrievedContact.Id, 'The retrieved contact should have the same Id as the inserted one.');
    }

    @isTest
    static void searchServices_goodContext(){
        arcshared__Council_Service_Area__c csa = [SELECT Id FROM arcshared__Council_Service_Area__c LIMIT 1];

        List<arcshared__Council_Service__c> servicesToInsert = new List<arcshared__Council_Service__c>();
        arcshared__Council_Service__c s1 = new arcshared__Council_Service__c(Name = 'In Context', arcshared__Community__c = 'Staff', arcshared__Council_Service_Area__c = csa.Id);
        servicesToInsert.add(s1);
        arcshared__Council_Service__c s2 = new arcshared__Council_Service__c(Name = 'Out Context', arcshared__Community__c = 'Resident', arcshared__Council_Service_Area__c = csa.Id);
        servicesToInsert.add(s2);
        insert servicesToInsert;

        Integer expectedNumber = 1;

        Test.startTest();
            List<arcshared__Council_Service__c> output = CRM_CouncilServicesController.searchServices('','','STAFF_HUB');
        Test.stopTest();

        Integer actualNumber = output.size();

        System.assertEquals(expectedNumber, actualNumber, 'Method should only return services in correct context.');
        System.assertEquals(s1.Id, output[0].Id, 'Method should only return services in correct context.');
    }

    @isTest
    static void searchServices_noContext(){
        arcshared__Council_Service_Area__c csa = [SELECT Id FROM arcshared__Council_Service_Area__c LIMIT 1];

        List<arcshared__Council_Service__c> servicesToInsert = new List<arcshared__Council_Service__c>();
        arcshared__Council_Service__c s1 = new arcshared__Council_Service__c(Name = 'A Context', arcshared__Community__c = 'Staff', arcshared__Council_Service_Area__c = csa.Id);
        servicesToInsert.add(s1);
        arcshared__Council_Service__c s2 = new arcshared__Council_Service__c(Name = 'Another Context', arcshared__Community__c = 'Resident', arcshared__Council_Service_Area__c = csa.Id);
        servicesToInsert.add(s2);
        insert servicesToInsert;

        Integer expectedNumber = 0;

        Test.startTest();
            List<arcshared__Council_Service__c> output = CRM_CouncilServicesController.searchServices('','','');
        Test.stopTest();

        Integer actualNumber = output.size();

        System.assertEquals(expectedNumber, actualNumber, 'Method should only return services if in a correct context.');
    }

    @isTest
    static void searchServices_badContext(){
        arcshared__Council_Service_Area__c csa = [SELECT Id FROM arcshared__Council_Service_Area__c LIMIT 1];

        List<arcshared__Council_Service__c> servicesToInsert = new List<arcshared__Council_Service__c>();
        arcshared__Council_Service__c s1 = new arcshared__Council_Service__c(Name = 'A Context', arcshared__Community__c = 'Staff', arcshared__Council_Service_Area__c = csa.Id);
        servicesToInsert.add(s1);
        arcshared__Council_Service__c s2 = new arcshared__Council_Service__c(Name = 'Another Context', arcshared__Community__c = 'Resident', arcshared__Council_Service_Area__c = csa.Id);
        servicesToInsert.add(s2);
        insert servicesToInsert;

        Integer expectedNumber = 0;

        Test.startTest();
            List<arcshared__Council_Service__c> output = CRM_CouncilServicesController.searchServices('','','BOB');
        Test.stopTest();

        Integer actualNumber = output.size();

        System.assertEquals(expectedNumber, actualNumber, 'Method should only return services if in a correct context.');
    }

    @isTest
    static void getServiceAreas_goodContext(){
        List<arcshared__Council_Service_Area__c> csas = [SELECT Id FROM arcshared__Council_Service_Area__c];

        List<arcshared__Council_Service__c> servicesToInsert = new List<arcshared__Council_Service__c>();
        arcshared__Council_Service__c s1 = new arcshared__Council_Service__c(Name = 'In Context', arcshared__Community__c = 'Staff', arcshared__Council_Service_Area__c = csas[0].Id);
        servicesToInsert.add(s1);
        arcshared__Council_Service__c s2 = new arcshared__Council_Service__c(Name = 'Out Context', arcshared__Community__c = 'Resident', arcshared__Council_Service_Area__c = csas[1].Id);
        servicesToInsert.add(s2);
        insert servicesToInsert;

        Integer expectedNumber = 1;

        Test.startTest();
            List<arcshared__Council_Service_Area__c> output = CRM_CouncilServicesController.getServiceAreas('STAFF_HUB');
        Test.stopTest();

        Integer actualNumber = output.size();
        System.assertEquals(expectedNumber, actualNumber, 'Method should only return service areas that contain a service in the correct context.');
    }

    @isTest
    static void getServiceAreas_noContext(){
        List<arcshared__Council_Service_Area__c> csas = [SELECT Id FROM arcshared__Council_Service_Area__c];

        List<arcshared__Council_Service__c> servicesToInsert = new List<arcshared__Council_Service__c>();
        arcshared__Council_Service__c s1 = new arcshared__Council_Service__c(Name = 'A Context', arcshared__Community__c = 'Staff', arcshared__Council_Service_Area__c = csas[0].Id);
        servicesToInsert.add(s1);
        arcshared__Council_Service__c s2 = new arcshared__Council_Service__c(Name = 'Another Context', arcshared__Community__c = 'Resident', arcshared__Council_Service_Area__c = csas[1].Id);
        servicesToInsert.add(s2);
        insert servicesToInsert;

        Integer expectedNumber = 0;

        Test.startTest();
            List<arcshared__Council_Service_Area__c> output = CRM_CouncilServicesController.getServiceAreas('BOB_HUB');
        Test.stopTest();

        Integer actualNumber = output.size();
        System.assertEquals(expectedNumber, actualNumber, 'Method should only return service areas that contain a service in the correct context.');
    }

    @isTest
    static void convertContextToCommunity_goodInput(){
        String expectedoutput = 'Resident';
        String actualoutput = CRM_CouncilServicesController.convertContextToCommunity('CUSTOMER_CONTACT');
        System.assertEquals(expectedoutput, actualoutput, 'Method should convert context into correct community type.');
    }

    @isTest
    static void convertContextToCommunity_badInput(){
        String expectedoutput = '';
        String actualoutput = CRM_CouncilServicesController.convertContextToCommunity('BOB_WAS_ERE');
        System.assertEquals(expectedoutput, actualoutput, 'Method should return empty string if context is not recognised.');
    }

    @isTest
    private static void userHasAdminPermissionSet_userDoes(){
        User mr_user = CRM_StaffHubUtils.returnNewUsersWithoutProfile(1)[0];
        mr_user.ProfileId = CRM_StaffHubUtils.TEST_STAFF_PROFILEID;

        insert mr_user;

        PermissionSet crmAdmin = [SELECT Id FROM PermissionSet WHERE Name =: CRM_CouncilServicesController.CRM_ADMIN_PERMISSION_SET LIMIT 1];

        PermissionSetAssignment permSetToUser = new PermissionSetAssignment(AssigneeId = mr_user.Id, PermissionSetId = crmAdmin.Id);

        insert permSetToUser;

        System.runAs(mr_user){
            Test.startTest();
                Boolean output = CRM_CouncilServicesController.userHasAdminPermissionSet();
            Test.stopTest();

            System.assert(output, 'Method should output true if current user is assigned the permission set ' + CRM_CouncilServicesController.CRM_ADMIN_PERMISSION_SET);
        }
    }

    @isTest
    private static void userHasAdminPermissionSet_userDoesNot(){
        User mr_user = CRM_StaffHubUtils.returnNewUsersWithoutProfile(1)[0];
        mr_user.ProfileId = CRM_StaffHubUtils.TEST_STAFF_PROFILEID;

        insert mr_user;

        System.runAs(mr_user){
            Test.startTest();
                Boolean output = CRM_CouncilServicesController.userHasAdminPermissionSet();
            Test.stopTest();

            System.assert(!output, 'Method should output false if current user is not assigned the permission set ' + CRM_CouncilServicesController.CRM_ADMIN_PERMISSION_SET);
        }
    }
}