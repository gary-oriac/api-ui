public with sharing class CRM_ContactDetailController {
    
    @AuraEnabled(Cacheable=true)
    public static List<User> getLinkedUser(Id contactId) {
        System.debug('getLinkedUser, contactId = ' + contactId);
        return  [SELECT Id, Username, LastName, FirstName, Name, Email, UserType, ProfileId,Profile.Name, ContactId,Contact.Name, Contact.arcuscrm__Contact_is_Deceased__c, AccountId, Account.Name, CreatedDate, IsActive FROM User WHERE ContactId = :contactId LIMIT 10  ];
    }

}