@isTest
public with sharing class CRM_ShadowCaseUtils_Test {

    private static Id shadowCaseRTId = arcshared.Utils.getRecordTypeIdByNamespacedsObjectAndDeveloperNameAndNamespacePrefix('Case', 'CRM_Shadow_Case', 'arcuscrm');

    private static arcshared__Product_Data_Change__e makeEvent(List<Id> recordIds, List<Id> contactIds, List<String> statusList, String type) {
        arcshared__Product_Data_Change__e testEvent = new arcshared__Product_Data_Change__e();
        testEvent.arcshared__Record_Id__c = String.join(recordIds, ',');
        if (contactIds != null) testEvent.arcshared__Contact_Id__c = String.join(contactIds, ',');
        testEvent.arcshared__Type__c = type;
        testEvent.arcshared__Description__c = 'This event is lovely, smelling of pecan pie and happiness.';
        if (statusList != null) testEvent.arcshared__Record_Status__c =  String.join(statusList, ',');

        return testEvent;
    }

    private static List<Id> makeAccounts(Integer numberToCreate) {
        List<Account> accountList = new List<Account>();
        for (Integer i = 0; i < numberToCreate; i++) {
            accountList.add(new Account(Name = 'Jolly Fats Wehawkin Temp Agency ' + i + ' Avenue'));
        }
        insert accountList;

        List<Id> accountIds = new List<Id>();
        for (Account testAccount : accountList) accountIds.add(testAccount.Id);
        return accountIds;
    }

    private static List<Id> makeContacts(Integer numberToCreate) {
        List<Contact> contactList = new List<Contact>();
        for (Integer i = 0; i < numberToCreate; i++) {
            contactList.add(new Contact(FirstName = 'The Middleman', 
                                        LastName = 'Number ' + i));
        }
        insert contactList;

        List<Id> contactIds = new List<Id>();
        for (Contact testContact : contactList) contactIds.add(testContact.Id);
        return contactIds;
    }

    @isTest
    static void shadowCaseIsCreatedOnNewRecord() {
        List<Id> accountIdList = makeAccounts(1);
        List<Id> contactIdList = makeContacts(1);

        arcshared__Product_Data_Change__e testEvent = makeEvent(accountIdList, contactIdList, null, 'RECORD_CREATED');
        Test.startTest();
        Database.SaveResult eventSaveResult = EventBus.publish(testEvent);
        Test.stopTest();

        List<Case> shadowCaseList = [SELECT Id, RecordTypeId, ContactId, arcshared__Master_Record_Id__c, Subject 
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId];

        System.assertEquals(1, shadowCaseList.size());
        System.assertEquals(accountIdList[0], shadowCaseList[0].arcshared__Master_Record_Id__c); 
        System.assertEquals(contactIdList[0], shadowCaseList[0].ContactId);  
        System.assert(shadowCaseList[0].Subject.contains('pecan pie'));     
    }

    @isTest
    static void manyShadowCasesAreCreatedOnNewRecord() {
        List<Id> accountIdList = makeAccounts(10);
        List<Id> contactIdList = makeContacts(1);

        arcshared__Product_Data_Change__e testEvent = makeEvent(accountIdList, contactIdList, null, 'RECORD_CREATED');
        Test.startTest();
        Database.SaveResult eventSaveResult = EventBus.publish(testEvent);
        Test.stopTest();        
        
        List<Case> shadowCaseList = [SELECT Id, ContactId, arcshared__Master_Record_Id__c, Subject
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId];

        System.assertEquals(10, shadowCaseList.size());
        Set<Id> masterRecordAccountIds = new Set<Id>();
        for (Case shadowCase : shadowCaseList) {
            System.assertEquals(contactIdList[0], shadowCase.ContactId);   
            System.assert(shadowCase.Subject.contains('pecan pie'));   
            masterRecordAccountIds.add(shadowCase.arcshared__Master_Record_Id__c);   
        }

        System.assert(masterRecordAccountIds.containsAll(accountIdList));
    }    

    @isTest
    static void manyShadowCasesAreCreatedOnNewRecordWithMultipleContacts() {
        List<Id> accountIdList = makeAccounts(1);
        List<Id> contactIdList = makeContacts(10);

        arcshared__Product_Data_Change__e testEvent = makeEvent(accountIdList, contactIdList, null, 'RECORD_CREATED');
        Test.startTest();
        Database.SaveResult eventSaveResult = EventBus.publish(testEvent);
        Test.stopTest();        
        
        List<Case> shadowCaseList = [SELECT Id, ContactId, arcshared__Master_Record_Id__c, Subject
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId];

        System.assertEquals(10, shadowCaseList.size());
    }    


    @isTest
    static void manyShadowCasesAndContactsAreCreatedOnNewRecord() {
        List<Id> accountIdList = makeAccounts(10);
        List<Id> contactIdList = makeContacts(10);

        arcshared__Product_Data_Change__e testEvent = makeEvent(accountIdList, contactIdList, null, 'RECORD_CREATED');
        Test.startTest();
        Database.SaveResult eventSaveResult = EventBus.publish(testEvent);
        Test.stopTest();        
        
        List<Case> shadowCaseList = [SELECT Id, ContactId, arcshared__Master_Record_Id__c 
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId];

        System.assertEquals(10, shadowCaseList.size());

        Map<Id, Id> accountToContactIdMap = new Map<Id, Id>();
        for (Integer i = 0; i < 10; i++) accountToContactIdMap.put(accountIdList[i], contactIdList[i]);
        for (Case shadowCase : shadowCaseList) {
            System.assertEquals(accountToContactIdMap.get(shadowCase.arcshared__Master_Record_Id__c), shadowCase.ContactId);
        }
    }    

    @isTest
    static void shadowCaseIsCreatedForNewContacts() {
        List<Id> accountIdList = makeAccounts(1);
        List<Id> contactIdList = makeContacts(2);

        Id mainCaseContactId = contactIdList.remove(0);
        Case mainCase = new Case();
        mainCase.RecordTypeId = shadowCaseRTId;
        mainCase.arcshared__Master_Record_Id__c = accountIdList[0];
        mainCase.ContactId = mainCaseContactId;
        mainCase.Status = 'In Progress';
        insert mainCase;

        arcshared__Product_Data_Change__e testEvent = makeEvent(accountIdList, contactIdList, null, 'CONTACTS_ADDED');
        Test.startTest();
        Database.SaveResult eventSaveResult = EventBus.publish(testEvent);
        Test.stopTest();           

        List<Case> shadowCaseList = [SELECT Id, ContactId, Status, arcshared__Master_Record_Id__c 
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId 
                                        AND ContactId != :mainCaseContactId];

        System.assertEquals(1, shadowCaseList.size());
        System.assertEquals('In Progress', shadowCaseList[0].Status);
        System.assertEquals(contactIdList[0], shadowCaseList[0].ContactId);
        System.assertEquals(accountIdList[0], shadowCaseList[0].arcshared__Master_Record_Id__c);
    }

    @isTest
    static void manyShadowCasesAreCreatedForNewContacts() {
        List<Id> accountIdList = makeAccounts(1);
        List<Id> contactIdList = makeContacts(21);

        Id mainCaseContactId = contactIdList.remove(0);
        Case mainCase = new Case();
        mainCase.RecordTypeId = shadowCaseRTId;
        mainCase.arcshared__Master_Record_Id__c = accountIdList[0];
        mainCase.ContactId = mainCaseContactId;
        mainCase.Status = 'In Progress';
        insert mainCase;

        arcshared__Product_Data_Change__e testEvent = makeEvent(accountIdList, contactIdList, null, 'CONTACTS_ADDED');
        Test.startTest();
        Database.SaveResult eventSaveResult = EventBus.publish(testEvent);
        Test.stopTest();           

        List<Case> shadowCaseList = [SELECT Id, ContactId, Status, arcshared__Master_Record_Id__c 
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId 
                                        AND ContactId != :mainCaseContactId];

        System.assertEquals(20, shadowCaseList.size());
        for (Case shadowCase : shadowCaseList) {
            System.assertEquals('In Progress', shadowCase.Status);
            System.assert(contactIdList.contains(shadowCase.ContactId));           
            System.assertEquals(accountIdList[0], shadowCase.arcshared__Master_Record_Id__c);
        }
    }    

    @isTest
    static void manyShadowCasesAreCreatedForNewContactsOnManyParents() {
        List<Id> accountIdList = makeAccounts(10);
        List<Id> contactIdList = makeContacts(11);

        Id mainCaseContactId = contactIdList.remove(0);
        List<Case> mainCaseList = new List<Case>();
        for (Integer i = 0; i < accountIdList.size(); i++) {
            Case mainCase = new Case();
            mainCase.RecordTypeId = shadowCaseRTId;
            mainCase.arcshared__Master_Record_Id__c = accountIdList[i];
            mainCase.ContactId = mainCaseContactId;
            mainCase.Status = 'In Progress';
            mainCaseList.add(mainCase);
        }
        insert mainCaseList;    

        arcshared__Product_Data_Change__e testEvent = makeEvent(accountIdList, contactIdList, null, 'CONTACTS_ADDED');
        Test.startTest();
        Database.SaveResult eventSaveResult = EventBus.publish(testEvent);
        Test.stopTest();

        List<Case> shadowCaseList = [SELECT Id, ContactId, Status, arcshared__Master_Record_Id__c 
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId 
                                        AND ContactId != :mainCaseContactId];

        System.assertEquals(10, shadowCaseList.size());

        for (Case shadowCase : shadowCaseList) {
            System.assertEquals('In Progress', shadowCase.Status);           
        }        
    }

    @isTest
    static void manyShadowCasesAreCreatedForContactOnManyParents() {
        List<Id> accountIdList = makeAccounts(10);
        List<Id> contactIdList = makeContacts(2);

        Id mainCaseContactId = contactIdList.remove(0);
        List<Case> mainCaseList = new List<Case>();
        for (Integer i = 0; i < accountIdList.size(); i++) {
            Case mainCase = new Case();
            mainCase.RecordTypeId = shadowCaseRTId;
            mainCase.arcshared__Master_Record_Id__c = accountIdList[i];
            mainCase.ContactId = mainCaseContactId;
            mainCase.Status = 'In Progress';
            mainCaseList.add(mainCase);
        }
        insert mainCaseList;    

        arcshared__Product_Data_Change__e testEvent = makeEvent(accountIdList, contactIdList, null, 'CONTACTS_ADDED');
        Test.startTest();
        Database.SaveResult eventSaveResult = EventBus.publish(testEvent);
        Test.stopTest();

        List<Case> shadowCaseList = [SELECT Id, ContactId, Status, arcshared__Master_Record_Id__c 
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId 
                                        AND ContactId != :mainCaseContactId];

        System.assertEquals(10, shadowCaseList.size());        
    }

    @isTest
    static void shadowCaseIsDeleted() {
        List<Id> accountIdList = makeAccounts(10);
        List<Id> contactIdList = makeContacts(1);

        List<Case> mainCaseList = new List<Case>();
        for (Integer i = 0; i < accountIdList.size(); i++) {
            Case mainCase = new Case();
            mainCase.RecordTypeId = shadowCaseRTId;
            mainCase.arcshared__Master_Record_Id__c = accountIdList[i];
            mainCase.ContactId = contactIdList[0];
            mainCase.Status = 'In Progress';
            mainCaseList.add(mainCase);
        }
        insert mainCaseList;

        accountIdList.remove(0);

        arcshared__Product_Data_Change__e testEvent = makeEvent(accountIdList, null, null, 'RECORD_DELETED');
        Test.startTest();
        Database.SaveResult eventSaveResult = EventBus.publish(testEvent);
        Test.stopTest(); 

        List<Case> shadowCaseList = [SELECT Id 
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId];

        System.assertEquals(1, shadowCaseList.size());
    }

    @isTest
    static void shadowCaseIsDeletedWhenContactRemoved() {
        List<Id> accountIdList = makeAccounts(1);
        List<Id> contactIdList = makeContacts(1);

        Case mainCase = new Case();
        mainCase.RecordTypeId = shadowCaseRTId;
        mainCase.arcshared__Master_Record_Id__c = accountIdList[0];
        mainCase.ContactId = contactIdList[0];
        mainCase.Status = 'In Progress';
        insert mainCase;

        arcshared__Product_Data_Change__e testEvent = makeEvent(accountIdList, contactIdList, null, 'CONTACTS_REMOVED');
        Test.startTest();
        Database.SaveResult eventSaveResult = EventBus.publish(testEvent);
        Test.stopTest(); 

        List<Case> shadowCaseList = [SELECT Id 
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId];    

        System.assertEquals(0, shadowCaseList.size());
    }

    @isTest
    static void manyShadowCasesAreDeletedWhenContactRemoved() {
        List<Id> accountIdList = makeAccounts(1);
        List<Id> contactIdList = makeContacts(10);

        List<Case> mainCaseList = new List<Case>();
        for (Integer i = 0; i < contactIdList.size(); i++) {
            Case mainCase = new Case();
            mainCase.RecordTypeId = shadowCaseRTId;
            mainCase.arcshared__Master_Record_Id__c = accountIdList[0];
            mainCase.ContactId = contactIdList[i];
            mainCase.Status = 'In Progress';
            mainCaseList.add(mainCase);
        }
        insert mainCaseList; 

        arcshared__Product_Data_Change__e testEvent = makeEvent(accountIdList, contactIdList, null, 'CONTACTS_REMOVED');
        Test.startTest();
        Database.SaveResult eventSaveResult = EventBus.publish(testEvent);
        Test.stopTest(); 

        List<Case> shadowCaseList = [SELECT Id 
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId];    

        System.assertEquals(0, shadowCaseList.size());                
    }

    @isTest
    static void manyShadowCasesAreDeletedWhenContactRemovedFromManyParents() {
        List<Id> accountIdList = makeAccounts(10);
        List<Id> contactIdList = makeContacts(10);

        List<Case> mainCaseList = new List<Case>();
        for (Integer i = 0; i < contactIdList.size(); i++) {
            Case mainCase = new Case();
            mainCase.RecordTypeId = shadowCaseRTId;
            mainCase.arcshared__Master_Record_Id__c = accountIdList[i];
            mainCase.ContactId = contactIdList[i];
            mainCase.Status = 'In Progress';
            mainCaseList.add(mainCase);
        }
        insert mainCaseList; 

        accountIdList.remove(0);
        contactIdList.remove(0);

        arcshared__Product_Data_Change__e testEvent = makeEvent(accountIdList, contactIdList, null, 'CONTACTS_REMOVED');
        Test.startTest();
        Database.SaveResult eventSaveResult = EventBus.publish(testEvent);
        Test.stopTest(); 

        List<Case> shadowCaseList = [SELECT Id 
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId];    

        System.assertEquals(1, shadowCaseList.size());                
    }

   @isTest
    static void manyShadowCasesAreDeletedWhenSameContactRemovedFromManyParents() {
        List<Id> accountIdList = makeAccounts(10);
        List<Id> contactIdList = makeContacts(1);

        List<Case> mainCaseList = new List<Case>();
        for (Integer i = 0; i < contactIdList.size(); i++) {
            Case mainCase = new Case();
            mainCase.RecordTypeId = shadowCaseRTId;
            mainCase.arcshared__Master_Record_Id__c = accountIdList[i];
            mainCase.ContactId = contactIdList[0];
            mainCase.Status = 'In Progress';
            mainCaseList.add(mainCase);
        }
        insert mainCaseList; 

        arcshared__Product_Data_Change__e testEvent = makeEvent(accountIdList, contactIdList, null, 'CONTACTS_REMOVED');
        Test.startTest();
        Database.SaveResult eventSaveResult = EventBus.publish(testEvent);
        Test.stopTest(); 

        List<Case> shadowCaseList = [SELECT Id 
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId];    

        System.assertEquals(0, shadowCaseList.size());                
    }

    @isTest
    static void shadowCasesStatusIsUpdatedWithOneRecord() {
        List<Id> accountIdList = makeAccounts(1);
        List<Id> contactIdList = makeContacts(1);

        Case mainCase = new Case();
        mainCase.RecordTypeId = shadowCaseRTId;
        mainCase.arcshared__Master_Record_Id__c = accountIdList[0];
        mainCase.ContactId = contactIdList[0];
        mainCase.Status = 'New';
        insert mainCase;

        arcshared__Product_Data_Change__e testEvent = makeEvent(accountIdList, null, new List<String>{'In Progress'}, 'STATUS_CHANGED');
        Test.startTest();
        Database.SaveResult eventSaveResult = EventBus.publish(testEvent);
        Test.stopTest(); 

        List<Case> shadowCaseList = [SELECT Id, Status 
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId];    

        for (Case shadowCase : shadowCaseList) {
            System.assertEquals('In Progress', shadowCase.Status);
        }
    }

    @isTest
    static void shadowCasesStatusIsUpdatedWithMultipleStatusesAndParents() {
        List<Id> accountIdList = makeAccounts(10);
        List<Id> contactIdList = makeContacts(1);

        List<Case> mainCaseList = new List<Case>();
        for (Integer i = 0; i < accountIdList.size(); i++) {
            Case mainCase = new Case();
            mainCase.RecordTypeId = shadowCaseRTId;
            mainCase.arcshared__Master_Record_Id__c = accountIdList[i];
            mainCase.ContactId = contactIdList[0];
            mainCase.Status = 'New';
            mainCaseList.add(mainCase);
        }
        insert mainCaseList; 

        List<String> statusList = new List<String>();
        for (Integer i = 0; i < accountIdList.size() - 1; i++) statusList.add('In Progress');
        statusList.add('Closed');

        arcshared__Product_Data_Change__e testEvent = makeEvent(accountIdList, null, statusList, 'STATUS_CHANGED');
        Test.startTest();
        Database.SaveResult eventSaveResult = EventBus.publish(testEvent);
        Test.stopTest(); 

        List<Case> shadowCaseList = [SELECT Id, Status 
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId];    

        Integer inProgressCount = 0;
        Integer closedCount = 0;
        for (Case shadowCase : shadowCaseList) {
            if (shadowCase.Status == 'In Progress') inProgressCount++;
            if (shadowCase.Status == 'Closed') closedCount++;
        }

        System.assertEquals(9, inProgressCount);
        System.assertEquals(1, closedCount);
    }

    @isTest
    static void shadowCasesStatusIsUpdatedWithOneStatusAndMultipleParents() {
        List<Id> accountIdList = makeAccounts(10);
        List<Id> contactIdList = makeContacts(1);

        List<Case> mainCaseList = new List<Case>();
        for (Integer i = 0; i < accountIdList.size(); i++) {
            Case mainCase = new Case();
            mainCase.RecordTypeId = shadowCaseRTId;
            mainCase.arcshared__Master_Record_Id__c = accountIdList[i];
            mainCase.ContactId = contactIdList[0];
            mainCase.Status = 'New';
            mainCaseList.add(mainCase);
        }
        insert mainCaseList; 

        arcshared__Product_Data_Change__e testEvent = makeEvent(accountIdList, null, new List<String>{'In Progress'}, 'STATUS_CHANGED');
        Test.startTest();
        Database.SaveResult eventSaveResult = EventBus.publish(testEvent);
        Test.stopTest(); 

        List<Case> shadowCaseList = [SELECT Id, Status 
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId];    

        System.assertEquals(10, shadowCaseList.size());
        for (Case shadowCase : shadowCaseList) {
            System.assertEquals('In Progress', shadowCase.Status);
        }
    }    

    @isTest
    static void shadowCaseStatusIsUpdatedForAllRelatedToParent() {
        List<Id> accountIdList = makeAccounts(1);
        List<Id> contactIdList = makeContacts(10);

        List<Case> mainCaseList = new List<Case>();
        for (Integer i = 0; i < accountIdList.size(); i++) {
            Case mainCase = new Case();
            mainCase.RecordTypeId = shadowCaseRTId;
            mainCase.arcshared__Master_Record_Id__c = accountIdList[i];
            mainCase.ContactId = contactIdList[0];
            mainCase.Status = 'New';
            mainCaseList.add(mainCase);
        }
        insert mainCaseList; 

        arcshared__Product_Data_Change__e testEvent = makeEvent(accountIdList, null, new List<String>{'In Progress'}, 'STATUS_CHANGED');
        Test.startTest();
        Database.SaveResult eventSaveResult = EventBus.publish(testEvent);
        Test.stopTest(); 

        List<Case> shadowCaseList = [SELECT Id, Status 
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId];    

        for (Case shadowCase : shadowCaseList) {
            System.assertEquals('In Progress', shadowCase.Status);
        }
    }

    @isTest
    static void recordCreatedThenContactsAddedInSameEventCorrectlyInserts() {
        List<Id> accountIdList = makeAccounts(1);
        List<Id> contactIdList = makeContacts(2);

        arcshared__Product_Data_Change__e testEventCreation = makeEvent(accountIdList, new List<String>{contactIdList[0]}, null, 'RECORD_CREATED');
        arcshared__Product_Data_Change__e testEventNewContact = makeEvent(accountIdList, new List<String>{contactIdList[1]}, null, 'CONTACTS_ADDED');

        Test.startTest();
        Database.SaveResult eventSaveResultCreation = EventBus.publish(testEventCreation);
        Database.SaveResult eventSaveResultNewContact = EventBus.publish(testEventNewContact);        
        Test.stopTest();

        List<Case> shadowCaseList = [SELECT Id, RecordTypeId, ContactId, arcshared__Master_Record_Id__c, Status
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId];

        System.assertEquals(2, shadowCaseList.size());
        System.assertNotEquals(shadowCaseList[0].ContactId, shadowCaseList[1].ContactId);
    }

    @isTest
    static void recordCreatedThenContactsRemovedInSameEventDoesNotInsert() {
        List<Id> accountIdList = makeAccounts(1);
        List<Id> contactIdList = makeContacts(1);

        arcshared__Product_Data_Change__e testEventCreation = makeEvent(accountIdList, contactIdList, null, 'RECORD_CREATED');
        arcshared__Product_Data_Change__e testEventDeleteContact = makeEvent(accountIdList, contactIdList, null, 'CONTACTS_REMOVED');

        Test.startTest();
        Database.SaveResult eventSaveResultCreation = EventBus.publish(testEventCreation);
        Database.SaveResult eventSaveResultDeleteContact = EventBus.publish(testEventDeleteContact);        
        Test.stopTest();

        List<Case> shadowCaseList = [SELECT Id, RecordTypeId, ContactId, arcshared__Master_Record_Id__c, Status
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId];

        System.assertEquals(0, shadowCaseList.size());
    }    

    @isTest
    static void recordCreatedThenDeletedInSameEventDoesNotInsert() {
        List<Id> accountIdList = makeAccounts(1);
        List<Id> contactIdList = makeContacts(1);

        arcshared__Product_Data_Change__e testEventCreation = makeEvent(accountIdList, contactIdList, null, 'RECORD_CREATED');
        arcshared__Product_Data_Change__e testEventDelete = makeEvent(accountIdList, null, null, 'RECORD_DELETED');

        Test.startTest();
        Database.SaveResult eventSaveResultCreation = EventBus.publish(testEventCreation);
        Database.SaveResult eventSaveResultDelete = EventBus.publish(testEventDelete);        
        Test.stopTest();

        List<Case> shadowCaseList = [SELECT Id, RecordTypeId, ContactId, arcshared__Master_Record_Id__c, Status
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId];

        System.assertEquals(0, shadowCaseList.size());
    }       

    @isTest
    static void recordCreatedThenStatusUpdatedInSameEventCorrectlyInserts() {
        List<Id> accountIdList = makeAccounts(1);
        List<Id> contactIdList = makeContacts(1);

        arcshared__Product_Data_Change__e testEventCreation = makeEvent(accountIdList, contactIdList, null, 'RECORD_CREATED');
        arcshared__Product_Data_Change__e testEventStatus = makeEvent(accountIdList, null, new List<String>{'In Progress'}, 'STATUS_CHANGED');

        Test.startTest();
        Database.SaveResult eventSaveResultCreation = EventBus.publish(testEventCreation);
        Database.SaveResult eventSaveResultStatus = EventBus.publish(testEventStatus);        
        Test.stopTest();

        List<Case> shadowCaseList = [SELECT Id, RecordTypeId, ContactId, arcshared__Master_Record_Id__c, Status
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId];

        System.assertEquals('In Progress', shadowCaseList[0].Status);
    }    

    @isTest
    static void existingCaseAndCaseToBeCreatedHaveStatusUpdated() {
        List<Id> accountIdList = makeAccounts(1);
        List<Id> contactIdList = makeContacts(2);

        Case mainCase = new Case();
        mainCase.RecordTypeId = shadowCaseRTId;
        mainCase.arcshared__Master_Record_Id__c = accountIdList[0];
        mainCase.ContactId = contactIdList.remove(0);
        mainCase.Status = 'New';
        insert mainCase;

        arcshared__Product_Data_Change__e testEventCreation = makeEvent(accountIdList, contactIdList, null, 'CONTACTS_ADDED');
        arcshared__Product_Data_Change__e testEventStatus = makeEvent(accountIdList, null, new List<String>{'In Progress'}, 'STATUS_CHANGED');

        Test.startTest();
        Database.SaveResult eventSaveResultCreation = EventBus.publish(testEventCreation);
        Database.SaveResult eventSaveResultStatus = EventBus.publish(testEventStatus);        
        Test.stopTest();

        List<Case> shadowCaseList = [SELECT Id, RecordTypeId, ContactId, arcshared__Master_Record_Id__c, Status
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId];

        System.assertEquals(2, shadowCaseList.size()); 
        for (Case shadowCase : shadowCaseList) {
            System.assertEquals('In Progress', shadowCase.Status);       
        }
    }

    @isTest
    static void systemLogIsGeneratedOnError() {
        List<Id> accountIdList = makeAccounts(1);
        List<Id> fakeContactList = new List<String>{'003000000000000000'};

        arcshared__Product_Data_Change__e testEvent = makeEvent(accountIdList, fakeContactList, null, 'RECORD_CREATED');
        Test.startTest();
        Database.SaveResult eventSaveResult = EventBus.publish(testEvent);
        Test.stopTest();

        List<Case> shadowCaseList = [SELECT Id, RecordTypeId, ContactId, arcshared__Master_Record_Id__c 
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId];

        List<arcshared__System_Log__c> systemLogList = [SELECT Id, arcshared__Log_Info__c, arcshared__Debug_Data__c
                                                        FROM arcshared__System_Log__c];

        System.assertEquals(0, shadowCaseList.size());
        System.assertEquals(1, systemLogList.size());
        System.assert(systemLogList[0].arcshared__Log_Info__c.contains('CRM_ShadowCaseUtils'));
    }

    @isTest
    static void shadowCaseIsDeletedThenUndeleted() {
        List<Id> accountIdList = makeAccounts(1);
        List<Id> contactIdList = makeContacts(1);

        Case mainCase = new Case();
        mainCase.RecordTypeId = shadowCaseRTId;
        mainCase.arcshared__Master_Record_Id__c = accountIdList[0];
        mainCase.ContactId = contactIdList[0];
        mainCase.Status = 'New';
        insert mainCase;

        arcshared__Product_Data_Change__e testEventDeletion = makeEvent(accountIdList, null, null, 'RECORD_DELETED');
        arcshared__Product_Data_Change__e testEventCreation = makeEvent(accountIdList, contactIdList, null, 'RECORD_CREATED');

        Test.startTest();
        Database.SaveResult eventSaveResultDeletion = EventBus.publish(testEventDeletion);
        Database.SaveResult eventSaveResultCreation = EventBus.publish(testEventCreation);        
        Test.stopTest();      

        List<Case> shadowCaseList = [SELECT Id, RecordTypeId, ContactId, arcshared__Master_Record_Id__c 
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId];        

        System.assertEquals(1, shadowCaseList.size());
    }

    @isTest
    static void contactIsRemovedAndReadded() {
        List<Id> accountIdList = makeAccounts(1);
        List<Id> contactIdList = makeContacts(1);

        Case mainCase = new Case();
        mainCase.RecordTypeId = shadowCaseRTId;
        mainCase.arcshared__Master_Record_Id__c = accountIdList[0];
        mainCase.ContactId = contactIdList[0];
        mainCase.Status = 'New';
        insert mainCase;

        arcshared__Product_Data_Change__e testEventContactRemoved = makeEvent(accountIdList, contactIdList, null, 'CONTACTS_REMOVED');
        arcshared__Product_Data_Change__e testEventContactAdded = makeEvent(accountIdList, contactIdList, null, 'CONTACTS_ADDED');

        Test.startTest();
        Database.SaveResult eventSaveResultRemoved = EventBus.publish(testEventContactRemoved);
        Database.SaveResult eventSaveResultContactAdded = EventBus.publish(testEventContactAdded);        
        Test.stopTest();      

        List<Case> shadowCaseList = [SELECT Id, RecordTypeId, ContactId, arcshared__Master_Record_Id__c 
                                     FROM Case 
                                     WHERE RecordTypeId = :shadowCaseRTId];        

        System.assertEquals(1, shadowCaseList.size());        
    }    
 

    @isTest
    static void badEventCreatesErrorLog() {
        arcshared__Product_Data_Change__e badEvent = new arcshared__Product_Data_Change__e();

        Test.startTest();
        Database.SaveResult badEventResult = EventBus.publish(badEvent);
        Test.stopTest();        

        List<arcshared__System_Log__c> systemLogList = [SELECT Id, arcshared__Log_Info__c, arcshared__Debug_Data__c
                                                        FROM arcshared__System_Log__c];

        System.assertEquals(1, systemLogList.size());
        System.assert(systemLogList[0].arcshared__Debug_Data__c.contains('The following errors happened when validating the Product Data Change Events in the Trigger'));
    }

}