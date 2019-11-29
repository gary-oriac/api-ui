global class CRM_TriggerHandlerCase extends arcshared.TriggerDispatcher.TriggerHandler{
     
    public override void MainEntry(List<SObject> newlist, Map<ID, SObject> newmap, List<SObject> oldlist, Map<ID,SObject> oldmap)
    {
        // Not used now as cant get the MainEntry to be registered and called properly by the trigger dispatcher. (due to namespace??)
        // Instead the logic that would go here is in a direct trigger on CRM_CaseTrigger
    }
    
    global override void InProgressEntry(List<String> triggerStack, List<SObject> newlist, Map<ID, SObject> newmap, List<SObject> oldlist, Map<ID,SObject> oldmap){
        
        // Do Nothing
    }
    
    public static BusinessHours defaultHours
    {
        get
        {
            if (defaultHours == null)
                defaultHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
            return defaultHours;
        }
        private set;
    }
    
    public static Datetime addWorkingDaysToDateTime(Datetime pointer, Integer days)
    {
        pointer = BusinessHours.nextStartDate(defaultHours.Id, pointer);
        // make sure you're starting at a Datetime within BusinessHours

        for (Integer elapsed = 0; elapsed < days; elapsed++)
        {
            pointer = pointer.addDays(1);
            if (!BusinessHours.isWithin(defaultHours.Id, pointer))
                pointer = BusinessHours.nextStartDate(defaultHours.Id, pointer);
        }
        return pointer;
    }
    
    public static Date addWorkingDaysToDate(Datetime pointer, Integer days)
    {
        Datetime dT = addWorkingDaysToDateTime(pointer, days);
        return date.newinstance(dT.year(), dT.month(), dT.day());
    }

    public static String getDefaultTypeForCase(Id serviceId, List<arcshared__Council_Service__c> serviceList)
    {
        for(arcshared__Council_Service__c currServ : serviceList) {
            if(currServ.Id == serviceId ) return currServ.arcshared__Council_Service_Area__r.arcuscrm__Case_Type_Field_Default_Value__c;
        }
        return null;
    }
    
    @InvocableMethod
    public static List<Case> setCaseAssignmentToFire( List<Case> myCaseList)
    {
        for (Case myCase : myCaseList){
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            myCase.setOptions(dmo);
            myCase.Description = 'in apex';
        }
        return myCaseList;
    }

}