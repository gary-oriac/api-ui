@isTest
public class CRM_DocumentManagement_Test {

    @testSetup static void setup() {
        
        // Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        // User sysAdminUser = [SELECT Id FROM User WHERE isActive = true AND ProfileId = :adminProfile.Id LIMIT 1];
    	// // Create some content workspaces
    	
        // System.runAs(sysAdminUser){
        //     ContentWorkspace ctaxWkspace1 = new ContentWorkspace(Name = 'Council Tax TEST');
        //     ContentWorkspace ctaxWkspace2 = new ContentWorkspace(Name = 'Benefits TEST');
        //     insert ctaxWkspace1;
        //     insert ctaxWkspace2;
        // }
        
        // // make the content workspaces
        // List<String> libsToCreate = new List<String>{'Unindexed - Council Tax', 'Unindexed - Business Rates', 'Unindexed - Benefits', 'Unindexed - Development Management', 'Unindexed - Planning Enforcement', 'Unindexed - Environmental Health', 'Unindexed - Customer Care'};
        // List<ContentWorkspace> myCWs = new List<ContentWorkspace>();    
        // for(String str : libsToCreate ){
        //     ContentWorkspace myCW = new ContentWorkspace( name =str);
        //     myCWs.add(myCW);
        // }
        // System.debug('myCW BEFORE INSERT = ' + myCWs);
        // insert myCWs;   
        // System.debug('myCW AFTER INSERT= ' + myCWs); 

        // // add some dummy docs
        
        // Integer docsToMake = 10;

        // list<ContentVersion> newCVs = new list<ContentVersion>();
        // for (Integer i = 0; i < docsToMake; i++) {
        //     ContentVersion testContentInsert = new ContentVersion();
        //     testContentInsert.ContentURL='http://www.google.com/';
        //     testContentInsert.Title ='Google.com ' + i;
        //     newCVs.add(testContentInsert);
        // }
        
        // insert newCVs;
        
        
    }
        
    @IsTest 
    public static void basicDocumentMgmtTest() {
        
        Test.startTest();
        
        	System.debug('Starting Tests');
        
        Test.stopTest();
        
    }
}