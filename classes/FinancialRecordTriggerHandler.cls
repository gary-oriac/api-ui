global class FinancialRecordTriggerHandler extends arcshared.TriggerDispatcher.TriggerHandler{
    global override void MainEntry(List<SObject> newlist, Map<ID, SObject> newmap, List<SObject> oldlist, Map<ID,SObject> oldmap){
        
        if(Trigger.isInsert && Trigger.isBefore){
            List<arcshared__Financial_Transaction__c> newListFT = (List<arcshared__Financial_Transaction__c>) newlist;
            setParentIdField(newListFT); 
        } 
    } 
    
    private void setParentIdField(List<arcshared__Financial_Transaction__c> newListFT) {
        Set<String> lookupApiNames = new Set<String> {
            'arcusbuiltenv__Planning_Application__c', 
            'arcusbuiltenv__Appeal__c',
            'arcusbuiltenv__Enforcement__c',
            'Street_Naming_Numbering_Application__c',
            'arcusbuiltenv__Building_Control_Application__c',
            'arcusbuiltenv__Stage__c'
        };

        Map<String, Schema.SObjectField> fieldmap = Schema.getGlobalDescribe().get('arcshared__Financial_Transaction__c').getDescribe().fields.getMap();

        for (arcshared__Financial_Transaction__c ft : newListFT) {
            if (ft.arcshared__Parent_Id__c == null) {
                for (String lookupApiName : lookupApiNames) {
                    if (fieldmap.containsKey(lookupApiName) && ft.get(lookupApiName) != null) {
                        ft.arcshared__Parent_Id__c = String.valueOf( ft.get(lookupApiName) );
                    }
                }
            }
        }
    }   
}