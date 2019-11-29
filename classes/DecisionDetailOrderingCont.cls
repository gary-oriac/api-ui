public class DecisionDetailOrderingCont {
	 public List<arcusbuiltenv__Decision_Detail__c> records {get;set;}
    
    public DecisionDetailOrderingCont (ApexPages.StandardSetController controller) {
          // ARS2-620
          Id parentId = Apexpages.currentpage().getparameters().get('id');
          records = [
              SELECT 
              	Id, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, 
                LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, 
              	LastViewedDate, LastReferencedDate, arcusbuiltenv__Recommendation_and_Decision__c, 
              	arcusbuiltenv__Appeal__c, arcusbuiltenv__Category__c, arcusbuiltenv__Code__c, arcusbuiltenv__Description__c, 
              	arcusbuiltenv__Discharge_Date__c, arcusbuiltenv__Discharge_Status__c, arcusbuiltenv__Discharge_of_Condition_Application__c, 
              	arcusbuiltenv__Ordering__c, arcusbuiltenv__Reason__c, arcusbuiltenv__Source__c, arcusbuiltenv__Status__c, arcusbuiltenv__Summary__c, 
              	arcusbuiltenv__Title__c, arcusbuiltenv__Type__c 
           	  FROM arcusbuiltenv__Decision_Detail__c 
              WHERE arcusbuiltenv__Recommendation_and_Decision__c = :parentId
          ];
    }
}