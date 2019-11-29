public with sharing class CRM_ShadowCaseUtils {

    private static Map<Id, List<Case>> masterRecordIdToExistingShadowCasesMap = new Map<Id, List<Case>>();
    private static Set<Id> masterRecordIdSet = new Set<Id>();

    private static Map<String, Case> parentIdAndContactIdToShadowCaseUpsertMap = new Map<String, Case>();
    private static Map<String, Case> parentIdAndContactIdToShadowCaseDeleteMap = new Map<String, Case>();

    private static Id shadowCaseRTId = arcshared.Utils.getRecordTypeIdByNamespacedsObjectAndDeveloperNameAndNamespacePrefix('Case', 'CRM_Shadow_Case', 'arcuscrm');

    public static void processProductDataChangeEventList(List<arcshared__Product_Data_Change__e> productDataChangeEventList) {
        try {
            findAllExistingShadowCasesByMasterRecordId(productDataChangeEventList);
            processEachDataChangeEventByType(productDataChangeEventList);

            List<Database.UpsertResult> upsertResultList;
            if (parentIdAndContactIdToShadowCaseUpsertMap.values().size() > 0) {
                upsertResultList = Database.upsert(parentIdAndContactIdToShadowCaseUpsertMap.values(), false);
            }

            List<Database.DeleteResult> deleteResultList;
            if (parentIdAndContactIdToShadowCaseDeleteMap.values().size() > 0) {
                deleteResultList = Database.delete(parentIdAndContactIdToShadowCaseDeleteMap.values(), false);
            }

            addErrorToSystemLog(upsertResultList, deleteResultList);

        } catch (Exception e) {
            addErrorToSystemLog(e.getStackTraceString(), 'CRM_ShadowCaseUtils (called from CRM_ProductDataChangeTriggerHandler) failed.');
        }
    }

    private static void findAllExistingShadowCasesByMasterRecordId(List<arcshared__Product_Data_Change__e> productDataChangeEventList) {
        Set<Id> parentRecordId = new Set<Id>();
        for (arcshared__Product_Data_Change__e productDataChangeEvent : productDataChangeEventList) {
            parentRecordId.addAll((List<Id>)productDataChangeEvent.arcshared__Record_Id__c.split(','));
        }

        List<Case> existingShadowCaseList = [SELECT Id, Status, arcshared__Master_Record_Id__c, ContactId
                                             FROM Case
                                             WHERE RecordTypeId =: shadowCaseRTId
                                                AND arcshared__Master_Record_Id__c IN :parentRecordId];

        for (Case existingShadowCase : existingShadowCaseList) {
            if (!masterRecordIdToExistingShadowCasesMap.containsKey(existingShadowCase.arcshared__Master_Record_Id__c)) {
                masterRecordIdToExistingShadowCasesMap.put(existingShadowCase.arcshared__Master_Record_Id__c, new List<Case>()); 
            }
            masterRecordIdToExistingShadowCasesMap.get(existingShadowCase.arcshared__Master_Record_Id__c).add(existingShadowCase);
        }                 
    }

    private static void processEachDataChangeEventByType(List<arcshared__Product_Data_Change__e> productDataChangeEventList) {
        for (arcshared__Product_Data_Change__e productDataChangeEvent : productDataChangeEventList) {
            if (productDataChangeEvent.arcshared__Type__c == 'RECORD_CREATED') {
                createNewShadowCase(productDataChangeEvent);
            } else if (productDataChangeEvent.arcshared__Type__c == 'RECORD_DELETED') {
                deleteShadowCase(productDataChangeEvent);
            } else if (productDataChangeEvent.arcshared__Type__c == 'STATUS_CHANGED') {
                updateStatusOnShadowCase(productDataChangeEvent);
            } else if (productDataChangeEvent.arcshared__Type__c == 'CONTACTS_ADDED') {
                addContactAndCreateShadowCase(productDataChangeEvent);                
            } else if (productDataChangeEvent.arcshared__Type__c == 'CONTACTS_REMOVED') {
                deleteShadowCaseByParentsAndContacts(productDataChangeEvent);
            }  
        }
    }

    private static Case makeShadowCase(Id masterRecordId, Id contactId, String status, String description) {
        Case shadowCase = new Case();
        shadowCase.RecordTypeId = shadowCaseRTId;
        shadowCase.arcshared__Master_Record_Id__c = masterRecordId;
        shadowCase.ContactId = contactId;
        shadowCase.Status = status;
        if (String.isNotBlank(description)) shadowCase.Subject = description;
        return shadowCase;
    }

    private static void createNewShadowCase(arcshared__Product_Data_Change__e productDataChangeEvent) {
        List<String> parentIdList = productDataChangeEvent.arcshared__Record_Id__c.split(',');
        List<String> contactIdList = productDataChangeEvent.arcshared__Contact_Id__c.split(',');
        
        if (parentIdList.size() == contactIdList.size()) {
            for (Integer i = 0; i < parentIdList.size(); i ++) {
                checkForShadowCaseInDeletionMapAndAddToUpsertMap(makeShadowCase(parentIdList[i], contactIdList[i], 'New', productDataChangeEvent.arcshared__Description__c), false);
            }
        } else if (contactIdList.size() == 1 && parentIdList.size() > 0) {
            for (String parentId : parentIdList) {              
                checkForShadowCaseInDeletionMapAndAddToUpsertMap(makeShadowCase(parentId, contactIdList[0], 'New', productDataChangeEvent.arcshared__Description__c), false);
            }
        } else if (contactIdList.size() > 1 && parentIdList.size() == 1) {
            for (String contactId : contactIdList) {
                checkForShadowCaseInDeletionMapAndAddToUpsertMap(makeShadowCase(parentIdList[0], contactId, 'New', productDataChangeEvent.arcshared__Description__c), false);
            }
        }
    }

    private static void deleteShadowCase(arcshared__Product_Data_Change__e productDataChangeEvent) {
        List<String> parentIdList = productDataChangeEvent.arcshared__Record_Id__c.split(',');
        for (Id parentId : parentIdList) {
            if (masterRecordIdToExistingShadowCasesMap.containsKey(parentId)) {
                for (Case shadowCase : masterRecordIdToExistingShadowCasesMap.get(parentId)) {
                    checkForShadowCaseInUpsertAndAddToDeletionMap(shadowCase);
                }
            }
            
            deleteAllShadowCasesAboutToBeInsertedByMasterRecordId(parentId);
        }
    }

    private static void deleteAllShadowCasesAboutToBeInsertedByMasterRecordId(Id parentId) {
        for (String parentAndContactKey : parentIdAndContactIdToShadowCaseUpsertMap.keySet()) {
            if (parentAndContactKey.startsWith(parentId)) {
                parentIdAndContactIdToShadowCaseUpsertMap.remove(parentAndContactKey);
            }
        }        
    }

    private static void updateStatusOnShadowCase(arcshared__Product_Data_Change__e productDataChangeEvent) {        
        List<String> parentIdList = productDataChangeEvent.arcshared__Record_Id__c.split(',');        
        List<String> newStatusList = productDataChangeEvent.arcshared__Record_Status__c.split(',');

        if (newStatusList.size() == parentIdList.size()) { 
            for (Integer i = 0; i < newStatusList.size(); i++) {
                updateAllShadowCasesOnParent(parentIdList[i], newStatusList[i]);
            }
        } else if (parentIdList.size() > 1 && newStatusList.size() == 1) {
            for (String parentId : parentIdList) {
                updateAllShadowCasesOnParent(parentId, newStatusList[0]);
            }
        }
    }

    private static void updateAllShadowCasesOnParent(Id parentId, String newStatus) {
        if (masterRecordIdToExistingShadowCasesMap.containsKey(parentId)) {
            for (Case shadowCase : masterRecordIdToExistingShadowCasesMap.get(parentId)) {
                if (shadowCase.Status != newStatus) {
                    shadowCase.Status = newStatus;
                    checkForShadowCaseInDeletionMapAndAddToUpsertMap(shadowCase, true);
                }
            } 
        } 
            
        checkForShadowCaseBeingCreatedAndIfFoundUpdateStatus(parentId, newStatus);     
    }

    private static void checkForShadowCaseBeingCreatedAndIfFoundUpdateStatus(Id parentId, String newStatus) {
        Case shadowCase;
        for (String parentAndContactKey : parentIdAndContactIdToShadowCaseUpsertMap.keySet()) {
            if (parentAndContactKey.startsWith(parentId)) {
                shadowCase = parentIdAndContactIdToShadowCaseUpsertMap.get(parentAndContactKey);
                if (parentIdAndContactIdToShadowCaseDeleteMap.containsKey(parentAndContactKey)) parentIdAndContactIdToShadowCaseDeleteMap.remove(parentAndContactKey);
                if (shadowCase.Status != newStatus) shadowCase.Status = newStatus; 
            }
        }
    }

    private static void addContactAndCreateShadowCase(arcshared__Product_Data_Change__e productDataChangeEvent) {
        List<String> parentIdList = productDataChangeEvent.arcshared__Record_Id__c.split(',');
        List<String> contactIdList = productDataChangeEvent.arcshared__Contact_Id__c.split(','); 

        if (contactIdList.size() == parentIdList.size()) { 
            for (Integer i = 0; i < contactIdList.size(); i++) {
                createNewShadowCaseForNewContact(parentIdList[i], contactIdList[i], productDataChangeEvent.arcshared__Description__c);
            }
        } else if (contactIdList.size() == 1 && parentIdList.size() > 0) {
            for (String parentId : parentIdList) {
                createNewShadowCaseForNewContact(parentId, contactIdList[0], productDataChangeEvent.arcshared__Description__c);
            }
        } else if (contactIdList.size() > 1 && parentIdList.size() == 1) {
            for (String contactId : contactIdList) {
                createNewShadowCaseForNewContact(parentIdList[0], contactId, productDataChangeEvent.arcshared__Description__c);
            }
        }         
    }

    private static void createNewShadowCaseForNewContact(Id parentId, Id contactId, String description) {
        String status = 'New';
        if (masterRecordIdToExistingShadowCasesMap.containsKey(parentId)) {
            if(String.isNotBlank(masterRecordIdToExistingShadowCasesMap.get(parentId)[0].Status)) status = masterRecordIdToExistingShadowCasesMap.get(parentId)[0].Status;
        }
        checkForShadowCaseInDeletionMapAndAddToUpsertMap(makeShadowCase(parentId, contactId, status, description), false);
    }

    private static void deleteShadowCaseByParentsAndContacts(arcshared__Product_Data_Change__e productDataChangeEvent) {
        List<String> parentIdList = productDataChangeEvent.arcshared__Record_Id__c.split(',');
        List<String> contactIdList = productDataChangeEvent.arcshared__Contact_Id__c.split(',');   
        
        if (contactIdList.size() == parentIdList.size()) { 
            for (Integer i = 0; i < contactIdList.size(); i++) {
                findAndDeleteShadowCaseByParentAndContactId(parentIdList[i], contactIdList[i]);
            }
        } else if (contactIdList.size() == 1 && parentIdList.size() > 0) {
            for (String parentId : parentIdList) {
                findAndDeleteShadowCaseByParentAndContactId(parentId, contactIdList[0]);
            }            
        } else if (contactIdList.size() > 1 && parentIdList.size() == 1) {
            for (String contactId : contactIdList) {
                findAndDeleteShadowCaseByParentAndContactId(parentIdList[0], contactId);
            }
        }              
    }

    private static void findAndDeleteShadowCaseByParentAndContactId(Id parentId, Id contactId) {
        Case existingShadowCase = findShadowCaseWithParentIdAndContact(parentId, contactId);
        if (existingShadowCase != null) checkForShadowCaseInUpsertAndAddToDeletionMap(existingShadowCase);

        String parentAndContactKey = '' + parentId + contactId;
        if (parentIdAndContactIdToShadowCaseUpsertMap.containsKey(parentAndContactKey)) {
            parentIdAndContactIdToShadowCaseUpsertMap.remove(parentAndContactKey);
        } 
    }

    private static Case findShadowCaseWithParentIdAndContact(Id parentId, Id contactId) {
        if (masterRecordIdToExistingShadowCasesMap.containsKey(parentId)) {
            for (Case shadowCase : masterRecordIdToExistingShadowCasesMap.get(parentId)) {
                if (shadowCase.ContactId == contactId) {
                    return shadowCase;
                } 
            }
        }
        return null;
    }

    private static void checkForShadowCaseInDeletionMapAndAddToUpsertMap(Case shadowCase, Boolean isStatusUpdate) {  
        String parentAndContactKey = '' + Id.valueOf(shadowCase.arcshared__Master_Record_Id__c) + Id.valueOf(shadowCase.ContactId);
        if (parentIdAndContactIdToShadowCaseDeleteMap.containsKey(parentAndContactKey)) {
            parentIdAndContactIdToShadowCaseDeleteMap.remove(parentAndContactKey);
        }

        if (isStatusUpdate || findShadowCaseWithParentIdAndContact(shadowCase.arcshared__Master_Record_Id__c, shadowCase.ContactId) == null) {
            parentIdAndContactIdToShadowCaseUpsertMap.put(parentAndContactKey, shadowCase);
        }
    }

    private static void checkForShadowCaseInUpsertAndAddToDeletionMap(Case shadowCase) {   
        String parentAndContactKey = '' + Id.valueOf(shadowCase.arcshared__Master_Record_Id__c) + Id.valueOf(shadowCase.ContactId);
        if (parentIdAndContactIdToShadowCaseUpsertMap.containsKey(parentAndContactKey)) {
            parentIdAndContactIdToShadowCaseUpsertMap.remove(parentAndContactKey);
        }
        parentIdAndContactIdToShadowCaseDeleteMap.put(parentAndContactKey, shadowCase);
    }

    public static void addErrorToSystemLog(String debugDataString, String logInfo) {
        arcshared__System_Log__c systemLogRecord = new arcshared__System_Log__c();
        systemLogRecord.arcshared__Triggering_User__c = UserInfo.getUserId();
        systemLogRecord.arcshared__Debug_Data__c = debugDataString;
        systemLogRecord.arcshared__Debug_Data_Rich__c = debugDataString;
        systemLogRecord.arcshared__Log_Info__c = logInfo;
        systemLogRecord.arcshared__Log_Source__c = 'Asynchronous (Product Data Change Platform Event)';
        systemLogRecord.arcshared__Severity__c = 'ERROR';
        systemLogRecord.arcshared__Source_Organisation__c = UserInfo.getOrganizationId() + ' ' + UserInfo.getOrganizationName();     
        insert systemLogRecord;
    }

    public static void addErrorToSystemLog(List<Database.UpsertResult> upsertResultList, List<Database.DeleteResult> deleteResultList) {
        String upsertResultString = makeReadableUpsertErrorsText(upsertResultList);
        String deleteResultString = makeReadableDeleteErrorsText(deleteResultList);
        
        String failureDetails = '';
        if (String.isNotBlank(upsertResultString)) {
            failureDetails += 'The following errors happened on insert or update of a shadow case\n' + 
                              '------------------------------------------------------------------\n' + 
                              upsertResultString;
        }
        if (String.isNotBlank(deleteResultString)) {
            if (String.isNotBlank(failureDetails)) failureDetails += '\n\n';
            failureDetails += 'The following errors happened on delete of a shadow case\n' + 
                              '--------------------------------------------------------\n' + 
                              deleteResultString;
        }
        if (String.isNotBlank(failureDetails)) addErrorToSystemLog(failureDetails, 'CRM_ShadowCaseUtils (called from CRM_ProductDataChangeTriggerHandler) failed.');
    }

    private static String makeReadableUpsertErrorsText(List<Database.UpsertResult> upsertResultList) {
        String upsertResultString = '';
        if (upsertResultList != null) {
            Database.UpsertResult upsertResult;
            List<Case> shadowCasesInUpsertMap = parentIdAndContactIdToShadowCaseUpsertMap.values();

            String parentAndContactString = '';
            for (Integer i = 0; i < shadowCasesInUpsertMap.size(); i++) {
                if (!upsertResultList[i].isSuccess()) {
                    parentAndContactString = 'Parent record Id: ' + shadowCasesInUpsertMap[i].arcshared__Master_Record_Id__c + ' with ' + 
                                             'Contact id: ' + shadowCasesInUpsertMap[i].ContactId + '.';
                    upsertResultString += '\n' + parentAndContactString + '\n';

                    upsertResult = upsertResultList[i];
                    for(Database.Error error : upsertResult.getErrors()) {
                        upsertResultString += '\t' + error.getMessage() + '\n';
                    }                                 
                }
            }
        }   
        return upsertResultString;
    }

    private static String makeReadableDeleteErrorsText(List<Database.DeleteResult> deleteResultList) {
        String deleteResultString = '';
        if (deleteResultList != null) {   
            Database.DeleteResult deleteResult;
            List<Case> shadowCasesInDeleteMap = parentIdAndContactIdToShadowCaseDeleteMap.values();

            String parentAndContactString = '';
            for (Integer i = 0; i < shadowCasesInDeleteMap.size(); i++) {
                if (!deleteResultList[i].isSuccess()) {
                    parentAndContactString = 'Parent record Id: ' + shadowCasesInDeleteMap[i].arcshared__Master_Record_Id__c + ' with ' + 
                                             'Contact id: ' + shadowCasesInDeleteMap[i].ContactId + '.';
                    deleteResultString += '\n' + parentAndContactString + '\n';

                    deleteResult = deleteResultList[i];
                    for(Database.Error error : deleteResult.getErrors()) {
                        deleteResultString += '\t' + error.getMessage() + '\n';
                    }                                             
                }
            }
        }
        return deleteResultString;
    }

}