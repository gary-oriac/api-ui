public class CRM_UpdateStaffHubUsersWithContactId implements Queueable{

    private Map<Id,Id> userToContactMap;
    private Set<Id> userIds;

    public CRM_UpdateStaffHubUsersWithContactId(Map<Id,Id> inputUserToContactMap) {
        this.userToContactMap = inputUserToContactMap;
        this.userIds = inputUserToContactMap.keySet();

    }

    public void execute(QueueableContext context){
        List<User> usersToUpdate = [SELECT Id, arcuscrm__Employee_Contact_Id__c FROM User WHERE Id IN :userIds];

        for(User u : usersToUpdate){
            u.arcuscrm__Employee_Contact_Id__c = userToContactMap.get(u.Id);
        }

        update usersToUpdate;
    }
}