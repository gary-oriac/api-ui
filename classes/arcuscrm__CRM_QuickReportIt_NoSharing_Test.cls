@isTest
public class CRM_QuickReportIt_NoSharing_Test {

    
    @IsTest 
    public static void testfindNearbyCases() {
    	
        // Call before nay cases made, expect 0. 
        
        Double latIn = 51.0;
        Double lngIn = 1.0;    
        
        List<Case> emptList = arcuscrm.CRM_QuickReportIt_NoSharing.findNearbyCases(latIn,lngIn );
        System.assertEquals(emptList.size(), 0, 'No cases created yet');
        
        RecordType caseRT = arcuscrm.CRM_QuickReportIt_NoSharing.getRecordTypeByNameAndObject('CRM_Street_Scene_Report', 'Case');

        Case myCase1 = new Case(Subject = 'test', arcuscrm__Reported_Location_Coordinates__Latitude__s = latIn - 0.01 , arcuscrm__Reported_Location_Coordinates__Longitude__s = latIn, RecordtypeId = caseRT.Id );
        insert myCase1;
        List<Case> caseList1 = arcuscrm.CRM_QuickReportIt_NoSharing.findNearbyCases(latIn,lngIn );
        
        System.assertEquals(caseList1.size(), 1, 'One case created');
        
        Case myCase1Back = arcuscrm.CRM_QuickReportIt_NoSharing.closeCase(myCase1.Id);
        
        System.assertEquals(myCase1Back.Status, 'Closed', 'Case should be closed');
        
        // Test document linking 
        
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
 
        // Test INSERT
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertEquals(documents.size(), 1);
        
        List<Id> documentIds = new List<Id>();
        documentIds.add(documents[0].Id);

        List<ContentDocumentLink> cdlsBack = arcuscrm.CRM_QuickReportIt_NoSharing.linkDocuments( documentIds, myCase1Back.Id );
        
        System.assertNotEquals(cdlsBack.size(), 0, 'At least one content document link should be returned linking case to the document');
        
        
    }

    @isTest
    public static void getCouncilServFromRef_noRef_allReturned(){
        List<arcshared__Council_Service__c> councilServicesToInsert = new List<arcshared__Council_Service__c>();

        councilServicesToInsert.add(new arcshared__Council_Service__c(Name = 'Test 1', arcuscrm__Short_Ref__c = 'abc_123', arcuscrm__Available_for__c='Quick Report It'));
        councilServicesToInsert.add(new arcshared__Council_Service__c(Name = 'Test 2', arcuscrm__Short_Ref__c = 'abc_456', arcuscrm__Available_for__c='Quick Report It'));
        councilServicesToInsert.add(new arcshared__Council_Service__c(Name = 'Test 3', arcuscrm__Short_Ref__c = 'def_123', arcuscrm__Available_for__c='Quick Report It'));

        insert councilServicesToInsert;
        Integer expectedNoCouncilServices = councilServicesToInsert.size();

        Test.startTest();
            Map<String,arcshared__Council_Service__c> councilServicesReturned = arcuscrm.CRM_QuickReportIt_NoSharing.getCouncilServFromRef(null);
        Test.stopTest();

        Integer actualNoCouncilServices = councilServicesReturned.size();

        System.assertEquals(expectedNoCouncilServices, actualNoCouncilServices, 'If no short ref is provided, all council services should be returned');
        
    }

    @isTest
    public static void getCouncilServFromRef_partialRef_someReturned(){
        List<arcshared__Council_Service__c> councilServicesToInsert = new List<arcshared__Council_Service__c>();

        councilServicesToInsert.add(new arcshared__Council_Service__c(Name = 'Test 1', arcuscrm__Short_Ref__c = 'abc_123', arcuscrm__Available_for__c='Quick Report It'));
        councilServicesToInsert.add(new arcshared__Council_Service__c(Name = 'Test 2', arcuscrm__Short_Ref__c = 'abc_456', arcuscrm__Available_for__c='Quick Report It'));
        councilServicesToInsert.add(new arcshared__Council_Service__c(Name = 'Test 3', arcuscrm__Short_Ref__c = 'def_123', arcuscrm__Available_for__c='Quick Report It'));

        insert councilServicesToInsert;

        Integer expectedNoCouncilServices = 2;

        Test.startTest();
            Map<String,arcshared__Council_Service__c> councilServicesReturned = arcuscrm.CRM_QuickReportIt_NoSharing.getCouncilServFromRef('abc');
        Test.stopTest();

        Integer actualNoCouncilServices = councilServicesReturned.size();

        System.assertEquals(expectedNoCouncilServices, actualNoCouncilServices, 'If a short ref is provided, but several council services contain this as part of their short ref, a subset of council services is returned');
        
    }

    @isTest
    public static void getCouncilServFromRef_specficRef_oneReturned(){
        List<arcshared__Council_Service__c> councilServicesToInsert = new List<arcshared__Council_Service__c>();

        councilServicesToInsert.add(new arcshared__Council_Service__c(Name = 'Test 1', arcuscrm__Short_Ref__c = 'abc_123', arcuscrm__Available_for__c='Quick Report It'));
        councilServicesToInsert.add(new arcshared__Council_Service__c(Name = 'Test 2', arcuscrm__Short_Ref__c = 'abc_456', arcuscrm__Available_for__c='Quick Report It'));
        councilServicesToInsert.add(new arcshared__Council_Service__c(Name = 'Test 3', arcuscrm__Short_Ref__c = 'def_123', arcuscrm__Available_for__c='Quick Report It'));

        insert councilServicesToInsert;

        Integer expectedNoCouncilServices = 1;

        Test.startTest();
            Map<String,arcshared__Council_Service__c> councilServicesReturned = arcuscrm.CRM_QuickReportIt_NoSharing.getCouncilServFromRef('abc_123');
        Test.stopTest();

        Integer actualNoCouncilServices = councilServicesReturned.size();

        System.assertEquals(expectedNoCouncilServices, actualNoCouncilServices, 'If a short ref is provided, and it matches exactly that of a council service (and is not part of others), only one council service should be returned');
        
    }
    
}