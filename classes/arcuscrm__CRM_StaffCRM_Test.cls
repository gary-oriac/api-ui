@isTest
public with sharing class CRM_StaffCRM_Test {

    @testSetup static void setup() {

        // For the current user create a number of cases. 
        Integer noCasesToCreate = 12;
        List<Case> newCases = new List<Case>();
        for(Integer i = 0; i<noCasesToCreate; i++){
            Case cse = new Case( Subject='Test '+i, Origin = 'Web');
            newCases.add(cse);
        }
        insert newCases;

        Integer noTasksToCreate = 12;
        List<Task> newTasks = new List<Task>();
        for(Integer i = 0; i<noTasksToCreate; i++){
            Task tsk = new Task( Subject='Test '+i, WhatId = newCases[0].Id );
            newTasks.add(tsk);
        }
        insert newTasks;

        CollaborationGroup grp = new CollaborationGroup(Name = 'test', CollaborationType='Public');
        insert grp;

        List<FeedItem> newPosts = new List<FeedItem>();
        Integer noPostsToCreate = 4;
        
        for(Integer i = 0; i<noPostsToCreate; i++){
            FeedItem fi = new FeedItem( Body = 'Test Message', ParentId = grp.Id);
            newPosts.add(fi);
        }
        insert newPosts;
    }

    @isTest
    static void test_MyAlertsGetters(){

        Test.startTest();

        Case[] casesAssigned = CRM_StaffCRM.getCurrOfficerCasesAssigned();
        Case[] casesCreated = CRM_StaffCRM.getCurrOfficerCasesRaised();
        Task[] tasksAssigned = CRM_StaffCRM.getCurrOfficerTasksAssigned();

        System.assertEquals( 12 , casesAssigned.size() , 'Should have correct no of assigned cases');
        //System.assertEquals( 12 , casesCreated.size() , 'Should have correct no of created cases');
        System.assertEquals( 12 , tasksAssigned.size() , 'Should have correct no of assigned tasks');

        Test.stopTest();
    
    }

    @isTest
    static void test_ChatterGroupQueries(){

        Test.startTest();

        List<FeedItem> fiList1 = CRM_StaffCRM.getChatterPosts('Test');
        List<FeedItem> fiList2 = CRM_StaffCRM.getChatterPosts('Bad Name');

        System.assertEquals( 4 , fiList1.size() , 'Should find 4 chatter posts for valid group name');
        System.assertEquals( 0 , fiList2.size() , 'Should find no posts for bad name');

        Test.stopTest();
    
    }
}