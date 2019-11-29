@isTest
public class CRM_InsertContactsForStaffHubUsers_Test {
    @isTest
    private static void testQueueable(){
        List<Contact> contactsToInsert = new List<Contact>();
        contactsToInsert.add(new Contact(LastName = 'Test'));

        List<Contact> contactsBefore = [SELECT Id FROM Contact];

        Integer expectedNumberContacts = contactsBefore.size() + contactsToInsert.size();

        Test.startTest();
            CRM_InsertContactsForStaffHubUsers insertContactsJob = new CRM_InsertContactsForStaffHubUsers(contactsToInsert);
            Id jobId = System.enqueueJob(insertContactsJob);
        Test.stopTest();

        List<Contact> contactsAfter = [SELECT Id FROM Contact];

        Integer actualNumberContacts = contactsAfter.size();

        System.AssertEquals(expectedNumberContacts, actualNumberContacts, 'Queueable should insert the number of contacts provided to it.');
    }
}