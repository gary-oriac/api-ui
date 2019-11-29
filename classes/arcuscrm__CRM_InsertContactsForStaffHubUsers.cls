public class CRM_InsertContactsForStaffHubUsers implements Queueable{

    private List<Contact> contactsToInsert;

    public CRM_InsertContactsForStaffHubUsers(List<Contact> contactsToInsert) {
        this.contactsToInsert = contactsToInsert;
    }

    public void execute(QueueableContext context){
        Map<Id,Id> userIdToContactIdMap = new Map<Id,Id>();

        insert contactsToInsert;

        for(Contact c : contactsToInsert){
            userIdToContactIdMap.put(c.arcuscrm__Linked_Internal_User__c, c.Id);
        }

        if(!Test.isRunningTest()){
            CRM_UpdateStaffHubUsersWithContactId updateUserJob = new CRM_UpdateStaffHubUsersWithContactId(userIdToContactIdMap);
            Id jobId = System.enqueueJob(updateUserJob);
        }
    }
}