global class TriggerHandlerProcess_ARCIMP_ShadowCase extends arcshared.TriggerDispatcher.TriggerHandler{
    
    global override void MainEntry(List<SObject> newlist, Map<ID, SObject> newmap, List<SObject> oldlist, Map<ID,SObject> oldmap)
    {
        System.debug('TriggerHandlerProcess_ARCIMP_ShadowCase ');
        System.debug('This is an interim solution to create a shadow case in response too a process record being inserted. It will be eventually depreacted by the Arcus Shared implementation of platform events. ');
        
        if(Trigger.IsDelete){return;}
        if(Trigger.IsUnDelete){return;}
        if(newList.size() > 1){return;}
        if(Trigger.IsBefore){return;}
        
        if(Trigger.IsUpdate){
            arcusregserv__RS_Activity__c newProcess = (arcusregserv__RS_Activity__c)newlist[0];
            arcusregserv__RS_Activity__c oldProcess = (arcusregserv__RS_Activity__c)oldMap.get(newProcess.Id);
            List<Case> shadowCases = HandleProcessRecordUpdate(newProcess , oldProcess );   
        }
                
        if(Trigger.IsInsert){
            arcusregserv__RS_Activity__c newProcess = (arcusregserv__RS_Activity__c)newlist[0];
            HandleProcessRecordInsert(newProcess);
        }
    }
    
    global override void InProgressEntry(List<String> triggerStack, List<SObject> newlist, Map<ID, SObject> newmap, List<SObject> oldlist, Map<ID,SObject> oldmap){
        // do nothing
    }
    
    private Case HandleProcessRecordInsert( arcusregserv__RS_Activity__c newProcess){

        System.debug('INSERT newProcess =  '+ newProcess);        
        
        if(newProcess.arcusregserv__Contact__c == null){return null;}
        
        if(newProcess.arcusregserv__Case__c != null){
            System.debug('New process record already has a case, do nothing.');
            return null;
        }
        
        Id shadowRTId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CRM_Shadow_Case' AND SobjectType = 'Case' LIMIT 1  ].Id;
        System.debug('shadowRTId =  '+ shadowRTId);
        
        Case newShadowCase = new Case( 
            RecordTypeId = shadowRTId,
            Subject      = 'Process Shadow Case',
            Description  = newProcess.arcusregserv__Complaint__c,
            arcusregserv__Process__c  = newProcess.Id,
            ContactId    = newProcess.arcusregserv__Contact__c,
            Type         = 'General Enquiry'
        );
        
        if(newProcess.Council_Service__c != null){
            arcshared__Council_Service__c cs = [SELECT Id, arcuscrm__Service_SLA_Working_Days__c FROM arcshared__Council_Service__c WHERE Id = :newProcess.Council_Service__c  LIMIT 1];
            newShadowCase.arcshared__Council_Service__c = cs.Id;
            newShadowCase.arcuscrm__Target_Case_Resolution_Days__c= cs.arcuscrm__Service_SLA_Working_Days__c;                 
        }
        
        // if process has gelocation populated copy these to the case
        if(newProcess.arcusregserv__Coordinates__Latitude__s != null && newProcess.arcusregserv__Coordinates__Longitude__s !=null){
            newShadowCase.arcshared__Coordinates__Latitude__s = newProcess.arcusregserv__Coordinates__Latitude__s;
            newShadowCase.arcshared__Coordinates__Longitude__s = newProcess.arcusregserv__Coordinates__Longitude__s;
            
            // temp in crm have location fields need to set also. 
            newShadowCase.arcuscrm__Reported_Location_Coordinates__Latitude__s = newProcess.arcusregserv__Coordinates__Latitude__s;
            newShadowCase.arcuscrm__Reported_Location_Coordinates__Longitude__s = newProcess.arcusregserv__Coordinates__Longitude__s;
        }
        
            
        // By default if the complaint field on process is set then this is what goes in desc field on case. But if it is blank then instead put in what is in description field on process. 
        if (newProcess.arcusregserv__Complaint__c == null || newProcess.arcusregserv__Complaint__c =='') newShadowCase.Description  = newProcess.arcusregserv__Description__c;
        
        // Setting the Origin of case. 
        newShadowCase.Origin='Web';
        if(newProcess.arcusregserv__Contact_Method__c != null){
            newShadowCase.Origin=newProcess.arcusregserv__Contact_Method__c;
        }
        else{
            if(newProcess.arcusregserv__Source__c == 'Online Submission') newShadowCase.Origin='Web';
            else if(newProcess.arcusregserv__Source__c == 'Telephone (Call Centre)') newShadowCase.Origin='Phone';
        }
        
        newShadowCase.Type        = 'Regulatory Services';
        
        
        // If the process has a record type find the name of that RT and set that to be the subject of the case.                                
        if(newProcess.RecordTypeId != null){
            RecordType newProcessRT =  [SELECT Id, Name FROM RecordType WHERE Id = :newProcess.RecordTypeId LIMIT 1  ];
            newShadowCase.Subject = newProcessRT.Name;
        }
        
        // Fire case assignment rule
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        newShadowCase.setOptions(dmo);
        
        System.debug('newShadowCase =  '+ newShadowCase);
        insert newShadowCase;
        System.debug('AFTER INSERT newShadowCase =  '+ newShadowCase);
        
        //System.debug('Schedule future call to create reverse link');
        //LinkProcessToCase(newShadowCase.Id , newProcess.Id);
        
        //System.debug('Schedule future call to set case owner');
        //SetCaseOwnerToProcessOwner(newShadowCase.Id , newProcess.Id);
        
        return newShadowCase;
    }
    
    private List<Case>  HandleProcessRecordUpdate( arcusregserv__RS_Activity__c newProcess, arcusregserv__RS_Activity__c oldProcess ){
        
        List<Case> shadowCases = [SELECT Id, CaseNumber, Status, ContactId FROM Case WHERE arcusregserv__Process__c = :newProcess.Id LIMIT 100 ];
        Boolean updatedNeeded = false;
        
        // If the process has had the Description field change then reflect this on the case description (this is needed as the DSH report it updates the complaint field post insert).
        if(newProcess.arcusregserv__Description__c != oldProcess.arcusregserv__Description__c ){
            for( Case cse : shadowCases ) cse.Description = newProcess.arcusregserv__Description__c;
            updatedNeeded = true;
        }
        
        // If the process has had its status changed then reflect this on the case status 
        if(newProcess.arcusregserv__Status__c != oldProcess.arcusregserv__Status__c ){
            
            if( newProcess.arcusregserv__Status__c == 'Completed' || newProcess.arcusregserv__Status__c == 'Closed'){
                for( Case cse : shadowCases ) cse.Status = 'Closed';
                updatedNeeded = true;
            }
            else{
                // Process has changed status after being created, move the case on from new to in progress. 
                for( Case cse : shadowCases ) {
                    if(cse.Status == 'New') cse.Status = 'In Progress';
                }
                updatedNeeded = true;
            }
        }
        
        // If the process has had DSH contact changed then reflect this on case
        if(newProcess.arcusregserv__Contact__c != oldProcess.arcusregserv__Contact__c && oldProcess.arcusregserv__Contact__c != null && newProcess.arcusregserv__Contact__c != null  ){
            for( Case cse : shadowCases ) {
                cse.ContactId = newProcess.arcusregserv__Contact__c;
            }
            updatedNeeded = true;
        }
        
        // If process repoted location changed then propogate to shadow cases. 
        if(newProcess.arcusregserv__Coordinates__Latitude__s != oldProcess.arcusregserv__Coordinates__Latitude__s ){
            for( Case cse : shadowCases ) {
                cse.arcshared__Coordinates__Latitude__s = newProcess.arcusregserv__Coordinates__Latitude__s;
                cse.arcshared__Coordinates__Longitude__s = newProcess.arcusregserv__Coordinates__Longitude__s;
                
                // temp in crm have location fields need to set also. 
                cse.arcuscrm__Reported_Location_Coordinates__Latitude__s = newProcess.arcusregserv__Coordinates__Latitude__s;
                cse.arcuscrm__Reported_Location_Coordinates__Longitude__s = newProcess.arcusregserv__Coordinates__Longitude__s;
            }
            updatedNeeded = true;
        }
        
        // Should handle the creation of a new shadow case if the process record has been set to a DSH contact and was null before. 
        
        if(updatedNeeded) update shadowCases;
        return shadowCases;
    }

}