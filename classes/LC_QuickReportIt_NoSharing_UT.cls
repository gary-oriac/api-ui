@isTest
public class LC_QuickReportIt_NoSharing_UT {

    
    @IsTest 
    public static void testfindNearbyCases() {
    	
        // Call before nay cases made, expect 0. 
        
        Double latIn = 51.0;
        Double lngIn = 1.0;    
        
        List<Case> emptList = LC_QuickReportIt_NoSharing.findNearbyCases(latIn,lngIn );
        
        System.assertEquals(emptList.size(), 0, 'No cases created yet');
        
        RecordType caseRT = LC_QuickReportIt_NoSharing.getRecordTypeByNameAndObject('Street_Scene_Report', 'Case');

        Case myCase1 = new Case(Subject = 'test', FHDC_Reported_Location__Latitude__s = latIn - 0.01 , FHDC_Reported_Location__Longitude__s = latIn, RecordtypeId = caseRT.Id );
        insert myCase1;
        List<Case> caseList1 = LC_QuickReportIt_NoSharing.findNearbyCases(latIn,lngIn );
        
        System.assertEquals(caseList1.size(), 1, 'One case created');
        
        Case myCase1Back = LC_QuickReportIt_NoSharing.closeCase(myCase1.Id);
        
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
        
        ContentDocumentLink cdlBack = LC_QuickReportIt_NoSharing.linkDocument( documents[0].Id, myCase1Back.Id );
        
        System.assertNotEquals(cdlBack.Id, null, 'A content document link should be returned linking case to the document');
        
        
    }
    
}