trigger CRM_CaseTrigger on Case (before insert, before update, after insert) {
    
    System.debug('CRM_CaseTrigger - Temp method to set SLAS on cases.');
    if(Trigger.IsBefore ){
        
        // System.debug('dmlOpts = ' + dmlOpts);

        // Get a list of council services and the default type on their council service area records
        List<arcshared__Council_Service__c> serviceList = [SELECT Id, Name, arcshared__Council_Service_Area__c, arcshared__Council_Service_Area__r.Name, arcshared__Council_Service_Area__r.arcuscrm__Case_Type_Field_Default_Value__c 
                                                            FROM arcshared__Council_Service__c
                                                            LIMIT 5000];


        for( Case myCase : Trigger.New ){
            System.debug('myCase = ' + myCase);
            if(Trigger.IsInsert &&  myCase.arcuscrm__Target_Case_Resolution_Days__c != null){
                myCase.arcuscrm__Target_Resolution_Date__c = CRM_TriggerHandlerCase.addWorkingDaysToDate( DateTime.now()  , (Integer)myCase.arcuscrm__Target_Case_Resolution_Days__c);
            }

            if(Trigger.IsInsert &&  myCase.Type == null && myCase.arcshared__Council_Service__c != null){
                myCase.Type = CRM_TriggerHandlerCase.getDefaultTypeForCase(myCase.arcshared__Council_Service__c, serviceList);
            }

            // DG attempt to in a before insert trigger set DML flag to run assignment rules. This does not work. 
            //myCase = CRM_TriggerHandlerCase.setCaseAssignmentToFire(myCase);
            // if(Trigger.IsInsert &&  myCase.arcuscrm__SYSTEM_Fire_Assignment_Rule_For_New_Case__c ){
            //     System.debug('Setting Assignment Rule to Fire for case');
            //     Database.DMLOptions dmo = new Database.DMLOptions();
            //     dmo.assignmentRuleHeader.useDefaultRule = true;
            //     myCase.setOptions(dmo);
            // }
            
            if(Trigger.IsUpdate && myCase.arcuscrm__Target_Case_Resolution_Days__c != Trigger.oldMap.get(myCase.Id).arcuscrm__Target_Case_Resolution_Days__c){
                if (myCase.arcuscrm__Target_Case_Resolution_Days__c == null) myCase.arcuscrm__Target_Resolution_Date__c = null;
                else  myCase.arcuscrm__Target_Resolution_Date__c = CRM_TriggerHandlerCase.addWorkingDaysToDate( myCase.CreatedDate  , (Integer)myCase.arcuscrm__Target_Case_Resolution_Days__c);
            }
            
        }               
    }

    if(Trigger.IsAfter && Trigger.isInsert ){
            
        Set<Id> caseIdsToFireAsmtRule = new Set<Id>();

        for( Case myCase : Trigger.New ){
            
            if(myCase.arcuscrm__SYSTEM_Fire_Assignment_Rule_For_New_Case__c ){
                System.debug('Setting Assignment Rule to Fire for case - using a future call');
                caseIdsToFireAsmtRule.add(myCase.Id);
            }
        }
        System.debug('caseIdsToFireAsmtRule = ' + caseIdsToFireAsmtRule);
        CRM_FireAssignmentRuleForCases updateCaseJob = new CRM_FireAssignmentRuleForCases(caseIdsToFireAsmtRule);
        Id jobId = System.enqueueJob(updateCaseJob);
    }
}