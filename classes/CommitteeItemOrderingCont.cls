public class CommitteeItemOrderingCont {
	public List<arcusbuiltenv__Committee_Item__c> records {get;set;}
    
    public CommitteeItemOrderingCont (ApexPages.StandardSetController controller) {
          // ARS2-620
          Id parentId = Apexpages.currentpage().getparameters().get('id');
          records = [
              SELECT 
              	Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, 
              	LastModifiedById, SystemModstamp, arcusbuiltenv__Agenda_Item__c, arcusbuiltenv__Asset__c, arcusbuiltenv__Committee_Visibility__c, 
              	arcusbuiltenv__Committee__c, arcusbuiltenv__Enforcement__c, arcusbuiltenv__Item_Name__c, arcusbuiltenv__Order__c, arcusbuiltenv__Planning_Application__c, 
              	arcusbuiltenv__Reason_for_Deferral__c, arcusbuiltenv__Reason_s_for_going_to_committee__c, arcusbuiltenv__Site_Visit_Reason__c, 
              	arcusbuiltenv__Site_Visit_Required__c, arcusbuiltenv__Tree_Preservation_Order__c, arcusbuiltenv__Type__c 
           	  FROM arcusbuiltenv__Committee_Item__c 
              WHERE arcusbuiltenv__Committee__c = :parentId
          ];
    }
}