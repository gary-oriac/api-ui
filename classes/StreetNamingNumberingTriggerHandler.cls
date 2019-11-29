global class StreetNamingNumberingTriggerHandler extends arcshared.TriggerDispatcher.TriggerHandler {
    global override void MainEntry(List<SObject> newlist, Map<ID, SObject> newmap, List<SObject> oldlist, Map<ID,SObject> oldmap){
        if(Trigger.isBefore && Trigger.isUpdate){            
            for(SObject snn : newlist){
                Street_Naming_Numbering_Application__c newSNN = (Street_Naming_Numbering_Application__c)snn;
                Street_Naming_Numbering_Application__c oldSNN = (Street_Naming_Numbering_Application__c)oldmap.get(newSNN.Id);
 
                if(newSNN.Status__c!= oldSNN.Status__c){
                    String history = String.isNotBlank(newSNN.Status_History__c) ? newSNN.Status_History__c: '';
                    if(String.isNotBlank(history)) history += ';';
                    newSNN.Status_History__c= history + oldSNN.Status__c;
                }
            }
        }
    }
}