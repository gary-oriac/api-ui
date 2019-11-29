@isTest
public class TriggerHandlerProcess_ShadowCase_Test {

    @testSetup static void setup() {
        
        
        List<String> returnStrList1 = arcshared.TriggerDispatcher.constructValues('TriggerHandlerProcess_ARCIMP_ShadowCase', 'arcusregserv__RS_Activity__c', 100, null);
        String returnStr1 = returnStrList1[0];
        arcshared.AppConfigSupport.setting newSetting1 = new arcshared.AppConfigSupport.setting('IMP.TriggerHandlerProcess', 'TriggerSetting', returnStr1 , returnStr1 , 100, true, false);
        arcshared.AppConfigSupport.setSingleRecord('TriggerHandlers', newSetting1, null );
        
        Account newAcc = New Account(name = 'Arcus Global');
        insert newAcc;
        
        Contact cont = New Contact(LastName = 'Test', FirstName = 'Test', Phone = '01223 715 715');
        Contact cont2 = New Contact(LastName = 'Test2', FirstName = 'Test', Phone = '01223 715 715');
        insert cont;
        insert cont2;
    }
    
    
    @isTest static void validateShadowCaseCreation() {
        
        
        Test.startTest();
        
        Contact cont = [SELECT Id FROM Contact WHERE LastName = 'Test' LIMIT 1 ];
        
        Id compRTId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Complaint' AND SobjectType = 'arcusregserv__RS_Activity__c' LIMIT 1  ].Id;
        System.debug('compRTId =  '+ compRTId);
        
        arcusregserv__RS_Activity__c myTestProcess1 = new arcusregserv__RS_Activity__c(arcusregserv__Description__c = 'Test', RecordTypeId = compRTId, arcusregserv__Contact__c = cont.Id); 
        insert myTestProcess1;
        System.debug('validateShadowCaseCreation: myTestProcess1 =  ' + myTestProcess1);
        List<Case> shadowCases1 = [SELECT Id, CaseNumber, Status, ContactId FROM Case WHERE arcusregserv__Process__c = :myTestProcess1.Id LIMIT 100 ];
        System.assertEquals(1,shadowCases1.size(), 'There should be a single shadow case created that is linked to the related process (as it had a contact linked)');
        
        arcusregserv__RS_Activity__c myTestProcess2 = new arcusregserv__RS_Activity__c(arcusregserv__Description__c = 'Test', RecordTypeId = compRTId); 
        insert myTestProcess2;
        List<Case> shadowCases2 = [SELECT Id, CaseNumber, Status, ContactId FROM Case WHERE arcusregserv__Process__c = :myTestProcess2.Id LIMIT 100 ];
        System.assertEquals(0,shadowCases2.size(),  'There should no shadow cases created for related process2 (as it had no contact linked)');
        
        
        System.debug('myTestProcess1 = ' + myTestProcess1);
        //List<Case> myShadowCaseList1 = [SELECT Id, CaseNumber, ContactId, AccountId FROM Case WHERE Process__c = :myTestProcess1.Id ];
        
        Test.stopTest();
        
    }
    
    @isTest static void validateShadowCaseUpdate() {
        
        Test.startTest();
        
        Contact cont = [SELECT Id FROM Contact WHERE LastName = 'Test' LIMIT 1 ];
        
        Id compRTId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Complaint' AND SobjectType = 'arcusregserv__RS_Activity__c' LIMIT 1  ].Id;
        System.debug('compRTId =  '+ compRTId);
        
        arcusregserv__RS_Activity__c myTestProcess1 = new arcusregserv__RS_Activity__c(arcusregserv__Description__c = 'Test', RecordTypeId = compRTId, arcusregserv__Contact__c = cont.Id); 
        insert myTestProcess1;
        List<Case> shadowCases1 = [SELECT Id, CaseNumber, Status, ContactId FROM Case WHERE arcusregserv__Process__c = :myTestProcess1.Id LIMIT 100 ];
        
        // Update 1 - Desc
        myTestProcess1.arcusregserv__Description__c = 'Testing';
        update myTestProcess1;
        Case shadowBack1 = [SELECT Id, CaseNumber,Description, Status, ContactId FROM Case WHERE arcusregserv__Process__c = :myTestProcess1.Id LIMIT 1 ];
        System.assertEquals(shadowBack1.Description , myTestProcess1.arcusregserv__Description__c,  'The process description should be kept up to date on the case');
        
        // Update 2 - Status
        myTestProcess1.arcusregserv__Status__c = 'Inspection Started';
        update myTestProcess1;
        shadowBack1 = [SELECT Id, CaseNumber,Description, Status, ContactId FROM Case WHERE arcusregserv__Process__c = :myTestProcess1.Id LIMIT 1 ];
        System.assertEquals(shadowBack1.Status , 'In Progress',  'When process status changes then case should be updated to in progess');
        
        myTestProcess1.arcusregserv__Status__c = 'Closed';
        update myTestProcess1;
        shadowBack1 = [SELECT Id, CaseNumber,Description, Status, ContactId FROM Case WHERE arcusregserv__Process__c = :myTestProcess1.Id LIMIT 1 ];
        System.assertEquals(shadowBack1.Status , 'Closed',  'When process status changes to closed then case should be closed');
            
        // update 3 - DSH contact
        Contact cont2 = [SELECT Id FROM Contact WHERE LastName = 'Test2' LIMIT 1 ];
        
        myTestProcess1.arcusregserv__Contact__c = cont2.Id;
        update myTestProcess1;
        shadowBack1 = [SELECT Id, CaseNumber,Description, Status, ContactId FROM Case WHERE arcusregserv__Process__c = :myTestProcess1.Id LIMIT 1 ];
        System.assertEquals(myTestProcess1.arcusregserv__Contact__c, shadowBack1.ContactId ,  'When process changes DSH contact then case should be updated accordingly');
        
        Test.stopTest();
        
    }
}