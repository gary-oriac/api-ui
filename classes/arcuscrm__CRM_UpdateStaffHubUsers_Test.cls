@isTest
public class CRM_UpdateStaffHubUsers_Test {

    @isTest
    private static void testWithOnePair(){
        User u = CRM_StaffHubUtils.returnNewUsersWithoutProfile(1)[0];
        u.ProfileId = CRM_StaffHubUtils.TEST_STAFF_PROFILEID;
        insert u;

        Contact c = new Contact(LastName = 'Test');
        insert c;

        Map<Id,Id> userToContactMap = new Map<Id,Id>{u.Id => c.Id};

        Test.startTest();
            CRM_UpdateStaffHubUsersWithContactId updateUserJob = new CRM_UpdateStaffHubUsersWithContactId(userToContactMap);
            Id jobId = System.enqueueJob(updateUserJob);
        Test.stopTest();

        User userAfter = [SELECT Id, arcuscrm__Employee_Contact_Id__c FROM User WHERE Id =: u.Id LIMIT 1];

        System.assertEquals(c.Id, userAfter.arcuscrm__Employee_Contact_Id__c, 'The user should be linked to the contact.');
    }

    @isTest
    private static void testWithMultiplePairs(){
        Integer numberOfUsers = 2;
        List<User> us = CRM_StaffHubUtils.returnNewUsersWithoutProfile(numberOfUsers);
        for(User u : us){
            u.ProfileId = CRM_StaffHubUtils.TEST_STAFF_PROFILEID;
        }
        insert us;

        List<Contact> cs = new List<Contact>();
        for(Integer i = 0; i < numberOfUsers; i++){
            Contact c = new Contact(LastName = 'Test' + i);
            cs.add(c);
        }
        insert cs;

        Map<Id,Id> userToContactMap = new Map<Id,Id>();
        for(Integer i = 0; i < numberOfUsers; i++){
            userToContactMap.put(us[i].Id, cs[i].Id);
        }

        Test.startTest();
            CRM_UpdateStaffHubUsersWithContactId updateUserJob = new CRM_UpdateStaffHubUsersWithContactId(userToContactMap);
            Id jobId = System.enqueueJob(updateUserJob);
        Test.stopTest();

        List<User> usersAfter = [SELECT Id, arcuscrm__Employee_Contact_Id__c FROM User WHERE Id =: userToContactMap.keySet()];

        System.assertEquals(userToContactMap.get(usersAfter[0].Id), usersAfter[0].arcuscrm__Employee_Contact_Id__c, 'The user should be linked to the relevant contact.');
    }

}