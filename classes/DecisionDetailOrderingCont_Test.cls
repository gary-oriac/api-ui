@isTest
public class DecisionDetailOrderingCont_Test {
	@isTest 
    static void controller_retrievesOnlyDecisionDetailsRecordsRelatedToContextRecsAndDecsId() {
                              
        RecordType recAndDecRT = arcshared.Utils.getRecordTypeBysObjectAndDeveloperNameAndNamespacePrefix(Schema.SObjectType.arcusbuiltenv__Recommendation_and_Decision__c.Name, 'Planning_Application', 'arcusbuiltenv');
        RecordType detailRT = arcshared.Utils.getRecordTypeBysObjectAndDeveloperNameAndNamespacePrefix(Schema.SObjectType.arcusbuiltenv__Decision_Detail__c.Name, 'Condition', 'arcusbuiltenv');
        RecordType planningRT = arcshared.Utils.getRecordTypeBysObjectAndDeveloperNameAndNamespacePrefix(Schema.SObjectType.arcusbuiltenv__Planning_Application__c.Name, 'Application', 'arcusbuiltenv');

        arcusbuiltenv__Planning_Application__c pl = new arcusbuiltenv__Planning_Application__c(RecordTypeId = planningRT.Id);
        insert pl;
               
        arcusbuiltenv__Recommendation_and_Decision__c recAndDec = new arcusbuiltenv__Recommendation_and_Decision__c(arcusbuiltenv__Planning_Application__c = pl.Id, RecordTypeId = recAndDecRT.Id);
        insert recAndDec;
             
        List< arcusbuiltenv__Decision_Detail__c > details = new List< arcusbuiltenv__Decision_Detail__c > ();
        details.add(new arcusbuiltenv__Decision_Detail__c ( arcusbuiltenv__Recommendation_and_Decision__c = recAndDec.Id, RecordTypeId = detailRT.Id ));
        details.add(new arcusbuiltenv__Decision_Detail__c ( arcusbuiltenv__Recommendation_and_Decision__c = recAndDec.Id, RecordTypeId = detailRT.Id ));   
        insert details;
                
         List<arcusbuiltenv__Recommendation_and_Decision__c> recsAndDecsQueried = [SELECT ID FROM arcusbuiltenv__Recommendation_and_Decision__c WHERE Id = :recAndDec.Id];
         List<arcusbuiltenv__Decision_Detail__c> decsQueried = [SELECT ID FROM arcusbuiltenv__Decision_Detail__c WHERE arcusbuiltenv__Recommendation_and_Decision__c = :recAndDec.Id];
        
        Test.startTest();
            PageReference testPageReference = new PageReference('/apex/ReorderDecisionDetails');
            testPageReference.getParameters().put('id', String.valueOf(recsAndDecsQueried[0].Id));
            Test.setCurrentPage(testPageReference);
        Test.stopTest();
                
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(decsQueried); 
        DecisionDetailOrderingCont cont = new DecisionDetailOrderingCont(sc);
 
        System.assertEquals(details.size(), cont.records.size(), 'The records should only return all the Details that belongs to the Recommendation and Decision with the id ' + recAndDec.Id);        
    }
}