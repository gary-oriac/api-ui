@isTest
public class CommitteeItemOrderingCont_Test {
	@isTest 
    static void controller_retrievesOnlyCommitteeItemRecordsRelatedToContextCommitteeId() {
                              
        RecordType commItemRT = arcshared.Utils.getRecordTypeBysObjectAndDeveloperNameAndNamespacePrefix(Schema.SObjectType.arcusbuiltenv__Committee_Item__c.Name, 'Enforcement', 'arcusbuiltenv');
        RecordType planningRT = arcshared.Utils.getRecordTypeBysObjectAndDeveloperNameAndNamespacePrefix(Schema.SObjectType.arcusbuiltenv__Planning_Application__c.Name, 'Application', 'arcusbuiltenv');

        arcusbuiltenv__Planning_Application__c pl = new arcusbuiltenv__Planning_Application__c(RecordTypeId = planningRT.Id);
        insert pl;
               
        arcusbuiltenv__Committee__c committee = new arcusbuiltenv__Committee__c(arcusbuiltenv__Start_Date_Time__c = System.today(), arcusbuiltenv__End_Date_Time__c = System.today());
        insert committee;
             
        List< arcusbuiltenv__Committee_Item__c > commItems = new List< arcusbuiltenv__Committee_Item__c > ();
        commItems.add(new arcusbuiltenv__Committee_Item__c ( arcusbuiltenv__Planning_Application__c = pl.Id, arcusbuiltenv__Committee__c = committee.Id, RecordTypeId = commItemRT.Id ));
        commItems.add(new arcusbuiltenv__Committee_Item__c ( arcusbuiltenv__Planning_Application__c = pl.Id, arcusbuiltenv__Committee__c = committee.Id, RecordTypeId = commItemRT.Id ));   
        insert commItems;
                
         List<arcusbuiltenv__Committee__c> committeesQueried = [SELECT ID FROM arcusbuiltenv__Committee__c WHERE Id = :committee.Id];
         List<arcusbuiltenv__Committee_Item__c> commItemsQueried = [SELECT ID FROM arcusbuiltenv__Committee_Item__c WHERE arcusbuiltenv__Committee__c = :committee.Id];
        
        Test.startTest();
            PageReference testPageReference = new PageReference('/apex/ReorderCommitteeItems');
            testPageReference.getParameters().put('id', String.valueOf(committeesQueried[0].Id));
            Test.setCurrentPage(testPageReference);
        Test.stopTest();
                
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(commItemsQueried); 
        CommitteeItemOrderingCont cont = new CommitteeItemOrderingCont(sc);
 
        System.assertEquals(commItems.size(), cont.records.size(), 'The records should only return all the Committee Items that belongs to the Committee with the id ' + committee.Id);        
    }
}