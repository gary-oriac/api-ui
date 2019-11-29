public without sharing class CRM_StaffCRM {
    
    @AuraEnabled(Cacheable=true)
    public static Case[] getCurrOfficerCasesAssigned() {
        return [SELECT Id, CaseNumber, Subject, Status, RecordType.Name,CreatedDate, LastModifiedDate FROM Case WHERE IsClosed = false AND OwnerId = :UserInfo.getUserId() ORDER BY CreatedDate ASC];
    }

    @AuraEnabled(Cacheable=true)
    public static Case[] getCurrOfficerCasesRaised() {
        User currUser = [SELECT Id, arcuscrm__Employee_Contact_Id__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if(currUser != null && currUser.arcuscrm__Employee_Contact_Id__c != null){
            return [SELECT Id, CaseNumber, Subject, Status, RecordType.Name,CreatedDate, LastModifiedDate FROM Case WHERE IsClosed = false AND ContactId = :currUser.arcuscrm__Employee_Contact_Id__c ORDER BY CreatedDate ASC];
        } 
        else return null;
    }

    @AuraEnabled(Cacheable=true)
    public static Task[] getCurrOfficerTasksAssigned() {
        return [SELECT Id, WhoId, WhatId,What.Name,What.Type, Subject, ActivityDate, Status, IsHighPriority, IsClosed 
                FROM Task 
                WHERE IsClosed = false AND OwnerId = :UserInfo.getUserId() 
                ORDER BY ActivityDate ASC NULLS LAST ];
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<FeedItem> getChatterPosts(String groupName) {
        Integer postLimit = 5;
        return [SELECT Id, Title, Body, LinkUrl, Type, RelatedRecordId, ParentId, Parent.Name , CreatedDate, CreatedById,  CreatedBy.Name
				FROM FeedItem 
                WHERE ParentId IN (SELECT Id from CollaborationGroup where Name = :groupName)
                AND Type != 'TrackedChange'
                ORDER BY CreatedDate DESC
                LIMIT :postLimit];
    }


}