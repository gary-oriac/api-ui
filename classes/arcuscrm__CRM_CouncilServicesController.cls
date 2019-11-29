public with sharing class CRM_CouncilServicesController {

    public static String CRM_ADMIN_PERMISSION_SET = 'Arcus_CRM_Admin';
    
    @AuraEnabled(Cacheable=true)
    public static arcshared__Council_Service__c[] getAllServices() {
        // Id recordId
        System.debug('----- getAllServices');
        //System.debug('----- getAllServices -- recordId = '+ recordId);

        return searchServices('','','');
    }

    @AuraEnabled(Cacheable=true)
    public static arcshared__Council_Service__c[] searchServices(String searchTerm, String contId, String context) {
        searchTerm = searchTerm.trim();
        
        System.debug('----- searchServices');
        System.debug('----- searchServices -- searchTerm = '+ searchTerm);
        System.debug('----- searchServices -- contId = '+ contId);
        
        //if (searchTerm == '') {
        //    return getAllServices();
        //}
        
        // Prepare query paramters
        searchTerm = '%'+ searchTerm +'%';
        context = convertContextToCommunity(context);
        // Execute search query
        return [SELECT Id, Name,arcshared__Ranking__c,  arcshared__Council_Service_Area__c, arcshared__Council_Service_Area__r.Name, arcuscrm__Short_Ref__c,
        arcshared__Status__c, arcshared__Service_URL__c,arcuscrm__External_Form_URL__c, arcuscrm__Customer_Form_Introduction__c,arcuscrm__Service_SLA_Working_Days__c, arcuscrm__Available_for__c, arcuscrm__Button_Type__c,arcuscrm__Button_Icon__c, arcuscrm__Flow_Name__c,arcuscrm__Lightning_Component_Name__c,arcuscrm__Object_to_Create__c,arcuscrm__Record_Type_for_Object__c   
            FROM arcshared__Council_Service__c WHERE ( Name LIKE :searchTerm OR arcshared__Council_Service_Area__r.Name LIKE :searchTerm )  AND arcshared__Council_Service_Area__r.arcuscrm__Used_in_CRM_Service_Selection__c = true 
            AND arcshared__Community__c INCLUDES (:context)
            ORDER BY Name LIMIT 500];
    }

    @AuraEnabled(Cacheable=true)
    public static arcshared__Council_Service_Area__c[] getServiceAreas(String context) {
        List<arcshared__Council_Service_Area__c> output = new List<arcshared__Council_Service_Area__c>();
        List<arcshared__Council_Service_Area__c> serviceAreas = new List<arcshared__Council_Service_Area__c>();
        context = convertContextToCommunity(context);
        if(String.isNotBlank(context)){
            serviceAreas = [SELECT Id, Name, arcshared__Community__c,arcshared__Ranking__c, arcuscrm__Service_Area_Default_SLA_Working_Days__c,
                    (SELECT Id, Name,arcshared__Ranking__c,  arcshared__Council_Service_Area__c, arcshared__Council_Service_Area__r.Name, 
                    arcshared__Status__c, arcshared__Service_URL__c,arcuscrm__External_Form_URL__c, arcuscrm__Customer_Form_Introduction__c,arcuscrm__Service_SLA_Working_Days__c, arcuscrm__Available_for__c, arcuscrm__Button_Type__c,arcuscrm__Button_Icon__c, arcuscrm__Flow_Name__c,arcuscrm__Lightning_Component_Name__c,arcuscrm__Object_to_Create__c,arcuscrm__Record_Type_for_Object__c   
                    FROM arcshared__Council_Services__r WHERE arcshared__Community__c INCLUDES (:context) ORDER BY Name ASC) 
                FROM arcshared__Council_Service_Area__c WHERE arcuscrm__Used_in_CRM_Service_Selection__c = true ORDER BY Name ASC];
        }
        for(arcshared__Council_Service_Area__c csa : serviceAreas){
            if(csa.arcshared__Council_Services__r.size() != 0) output.add(csa);
        }
        return output;
    }

    @AuraEnabled
    public static Case createCase(Id councilServiceId, Id contactId) {
        System.debug('CRM Unlocked: CRM_CouncilServicesController createCase councilServiceId = ' + councilServiceId);
        System.debug('CRM Unlocked: CRM_CouncilServicesController createCase contactId = ' + contactId);

        arcshared__Council_Service__c myService = [SELECT Id, Name,  arcshared__Council_Service_Area__c, arcshared__Council_Service_Area__r.Name, 
                                                 arcshared__Service_URL__c, arcuscrm__Customer_Form_Introduction__c,arcuscrm__Service_SLA_Working_Days__c, arcuscrm__Available_for__c, arcuscrm__Button_Type__c, arcuscrm__Flow_Name__c,arcuscrm__Lightning_Component_Name__c,arcuscrm__Object_to_Create__c,arcuscrm__Record_Type_for_Object__c 
                                                    FROM arcshared__Council_Service__c WHERE Id = :councilServiceId LIMIT 1  ];
        
        System.debug('CRM Unlocked: myService = ' + myService);
        System.debug('CRM Unlocked: myService.arcuscrm__Record_Type_for_Object__c = ' + myService.arcuscrm__Record_Type_for_Object__c);
        RecordType caseRT = [SELECT Id FROM RecordType WHERE IsActive=true AND SObjectType = 'Case' AND DeveloperName = :myService.arcuscrm__Record_Type_for_Object__c LIMIT 1];
        System.debug('CRM Unlocked: caseRT = ' + caseRT);
        Case newCase = new Case( Subject =  myService.arcshared__Council_Service_Area__r.Name + ': '+  myService.Name,
                                ContactId = contactId, 
                                RecordTypeId = caseRT.Id, 
                                arcuscrm__Target_Case_Resolution_Days__c = myService.arcuscrm__Service_SLA_Working_Days__c,
                                arcshared__Council_Service__c = myService.Id  );
        System.debug('CRM Unlocked: newCase = ' + newCase);
        // Set case assignment rules to fire. 
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        newCase.setOptions(dmo);

        insert newCase;
        System.debug('CRM Unlocked: AFTER INSERT newCase = ' + newCase);

        // Need to query the case back to get its case number to put this in the toast. 
        return [SELECT Id, CaseNumber FROM Case WHERE Id = :newCase.Id LIMIT 1];
    }

    @AuraEnabled
    public static Contact getContactDetails(String recordId){
        Contact contactToReturn;
        if(String.isNotBlank(recordId)){
            contactToReturn = [SELECT Id, RecordType.DeveloperName FROM Contact WHERE Id =: recordId LIMIT 1]; 
        }
        return contactToReturn;
    }

    @TestVisible
    private static String convertContextToCommunity(String context){
        String output;
        switch on context {
            when 'CUSTOMER_CONTACT' {
                output = 'Resident';
            }
            when 'OFFICER_CONTACT' {
                output = 'Staff';
            }
            when 'STAFF_HUB' {
                output = 'Staff';
            }
            when 'ANONYMOUS' {
                output = 'Anonymous';
            }
            when else {
                output = '';
            }
        }
        return output;
    }

    @AuraEnabled(Cacheable=true)
    public static boolean userHasAdminPermissionSet(){
        return ![SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSet.Name =: CRM_ADMIN_PERMISSION_SET].isEmpty();
    }
}