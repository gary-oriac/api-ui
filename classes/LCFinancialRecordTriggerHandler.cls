global class LCFinancialRecordTriggerHandler extends arcshared.TriggerDispatcher.TriggerHandler{
    global override void MainEntry(List<SObject> newlist, Map<ID, SObject> newmap, List<SObject> oldlist, Map<ID,SObject> oldmap){
        
        if(Trigger.isInsert && Trigger.isBefore){
            List<arcshared__Financial_Transaction__c> newListFT = (List<arcshared__Financial_Transaction__c>) newlist;
            setParentIdField(newListFT); 
        } 
    } 
    
    private void setParentIdField(List<arcshared__Financial_Transaction__c> newListFT) {
        for (arcshared__Financial_Transaction__c ft : newListFT) {

            if (ft.arcshared__Parent_Id__c == null) {
            
                if (ft.arcuslandcharge__Land_Charge_Register__c != null) {
                    ft.arcshared__Parent_Id__c = ft.arcuslandcharge__Land_Charge_Register__c;
                }
                else if (ft.arcuslandcharge__LC_Search__c != null) {
                    ft.arcshared__Parent_Id__c = ft.arcuslandcharge__LC_Search__c;
                }                
            }
        }
    }   
}