/*
    Author     :    James Yu
    Company    :    Arcus Global
    Product    :    DSH Lightning Community
    Date       :    04/12/2017
    Purpose    :    Trigger handler on Contacts that checks if the current user is of type Standard and if so it updates the contact
                    details on the corresponding User record, firstname, lastname, email and username; Error is thrown if an email is
                    changed to an email already been used by another user in the same community
    Notes      :    
    Modified   :    
*/
global with sharing class DSHLC_ContactTriggerHandler extends arcshared.TriggerDispatcher.TriggerHandler {
    private static String USER_TYPE_STANDARD = 'Standard';
    private static String USER_TYPE_COMMUNITY = 'CspLitePortal';

    global override void MainEntry(List<SObject> newList, Map<ID, SObject> newMap, List<SObject> oldList, Map<ID,SObject> oldMap) {
        if (Trigger.isBefore && Trigger.isUpdate) {
            if (UserInfo.getUserType().equals(USER_TYPE_STANDARD))  {

                Map<Id, User> usersRelatedByContact = new Map<Id, User>([SELECT Id, ContactId FROM User WHERE IsActive = true AND Usertype=:USER_TYPE_COMMUNITY AND ContactId IN :newList]);

                if (usersRelatedByContact.size() > 0) {
                    Map<Id, User> relatedContactIdToUserMap = new Map<Id, User>();
                    for (User user : usersRelatedByContact.values()) {
                        relatedContactIdToUserMap.put(user.ContactId, user);
                    }

                    Set<String> contactEmailSet = new Set<String>();
                    for (SObject contactObj : newList) {
                        contactEmailSet.add(((Contact)contactObj).Email);
                    }

                    Set<String> emailsAlreadyInUse = getEmailsAlreadyInUse(contactEmailSet);

                    List<User> needUpdateUsers = new List<User>();
                    Set<Id> userIdsNeedUsernameUpdate = new Set<Id>();

                    for (SObject newContactObj : newList) {
                        Contact newContact = (Contact)newContactObj;
                        Contact oldContact = (Contact)(oldMap.get(newContact.Id));

                        User needUpdateUser = new User();
                        needUpdateUser.Id = relatedContactIdToUserMap.get(newContact.Id).Id;

                        Boolean needUpdate = false;
                        
                        if (newContact.FirstName != oldContact.FirstName) {
                            needUpdateUser.FirstName = newContact.FirstName;
                            needUpdate = true;
                        }

                        if (newContact.LastName != oldContact.LastName) {
                            needUpdateUser.LastName = newContact.LastName;
                            needUpdate = true;
                        }

                        if (newContact.Email != oldContact.Email) {

                            if (emailsAlreadyInUse.contains(newContact.Email)) {
                                needUpdate = false;
                                newContact.addError('This Email is already allocated to another user');
                            } else {
                                needUpdateUser.Email = newContact.Email;
                                userIdsNeedUsernameUpdate.add(needUpdateUser.Id);
                                needUpdate = true;
                            }
                        }

                        if (needUpdate) {
                            needUpdateUsers.add(needUpdateUser);
                        }
                    }

                    if (needUpdateUsers.size() > 0) {

                        List<Database.SaveResult> dmlResults = Database.update(needUpdateUsers, false);

                        for (Integer i = 0; i < needUpdateUsers.size(); i++) {
                            Database.SaveResult dmlResult = dmlResults[i];
                            if (!dmlResult.isSuccess()) {
                                Id failedUserId = needUpdateUsers[i].Id;
                                userIdsNeedUsernameUpdate.remove(failedUserId);

                                Id failedContactId = usersRelatedByContact.get(failedUserId).ContactId;
                                SObject failedContact = newMap.get(failedContactId);
                                addErrorsToRecord(failedContact, dmlResult.getErrors());
                            }
                        }

                        updateUsernames(userIdsNeedUsernameUpdate);
                    }

                }
            }

        }
    }

    private static Set<String> getEmailsAlreadyInUse(Set<String> emails) {
        List<User> usersRelatedByEmail = [SELECT Id, Email FROM User WHERE IsActive = true AND Usertype=:USER_TYPE_COMMUNITY AND Email IN :emails];

        Set<String> emailsAlreadyInUse = new Set<String>();
        for (User user : usersRelatedByEmail) {
            emailsAlreadyInUse.add(user.Email);
        }

        return emailsAlreadyInUse;
    }

    @future
    public static void updateUsernames(Set<Id> userIds) {
        List<User> users = [SELECT Id, Username, Email FROM User WHERE Id in :userIds];
        
        if (users.size() > 0) {
            for (User user : users) {
                user.Username = user.Email;
                user.arcshared__DSH_Email_Verified__c = false;
            }

            Database.update(users, false);
        }
    }

    global override void InProgressEntry(List<String> triggerStack, List<SObject> newlist, Map<ID, SObject> newmap, List<SObject> oldlist, Map<ID,SObject> oldmap){
        if(triggerStack.size() < 2 || triggerStack[triggerStack.size() - 2] != triggerStack[triggerStack.size() - 1]) MainEntry(newList, newMap, oldList, oldMap);
    }

    private static SObject addErrorsToRecord(SObject record, List<Database.Error> errors) {
        for (Database.Error error : errors) {
            record.addError(error.getMessage());
        }

        return record;
    }
}