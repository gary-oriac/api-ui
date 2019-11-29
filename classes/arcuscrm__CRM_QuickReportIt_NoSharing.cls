public without sharing class CRM_QuickReportIt_NoSharing {

    
    @AuraEnabled
    public static List<Case> findNearbyCases(Double myLat, Double myLng){
    	System.debug('myLat:' + myLat);
    	System.debug('myLng:' + myLng);
        // To do only return cases where RT = Street Scence
        List<Case> myCases = [SELECT Id, Type, Status,CaseNumber, Subject,IsClosed, arcuscrm__Date_Opened__c, arcuscrm__Date_Closed__c, arcuscrm__Reported_Location_Coordinates__Latitude__s, arcuscrm__Reported_Location_Coordinates__Longitude__s, CreatedDate,
                              DISTANCE(arcuscrm__Reported_Location_Coordinates__c, GEOLOCATION(:myLat, :myLng), 'km')  
                              FROM Case
                              WHERE arcuscrm__Reported_Location_Coordinates__Latitude__s != NULL
                              ORDER BY DISTANCE(arcuscrm__Reported_Location_Coordinates__c , GEOLOCATION(:myLat, :myLng), 'km')   
                              LIMIT 100];
        return myCases;
    }

    @AuraEnabled
    public static RecordType getRecordTypeByNameAndObject(String rtDevName, String objectName){
    	
        RecordType myRT = [SELECT Id, Name, DeveloperName, NamespacePrefix, Description, IsActive, SobjectType FROM RecordType 
                            WHERE DeveloperName = :rtDevName AND SobjectType = :objectName LIMIT 1  ];
        return myRT;
    }
    
    @AuraEnabled
    public static Case closeCase(Id caseId){
    	
        Case myCase = [SELECT Id, Type, Status,CaseNumber, Subject,IsClosed, arcuscrm__Reported_Location_Coordinates__Latitude__s, arcuscrm__Reported_Location_Coordinates__Longitude__s, CreatedDate 
                       FROM Case WHERE Id = :caseId LIMIT 1];
        myCase.Status = 'Closed';
        update myCase;
        return myCase;
        
    }

    @AuraEnabled
    public static List<ContentDocumentLink> linkDocuments(List<Id> contDocIds, Id caseId){
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
        for(Id i : contDocIds){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = caseId;
            cdl.ContentDocumentId = i;
            cdl.ShareType = 'V';
            cdl.Visibility = 'InternalUsers';
            cdls.add(cdl);
        }
        insert cdls;
        return cdls;
    }

    @AuraEnabled
    public static Map<String, arcshared__Council_Service__c> getCouncilServFromRef(String shortRef){
        Map<String, arcshared__Council_Service__c> councilServicesToReturnMap = new Map<String, arcshared__Council_Service__c>();
        List<arcshared__Council_Service__c> councilServicesToReturn = new List<arcshared__Council_Service__c>();
        if(String.isNotBlank(shortRef)){
            shortRef += '%';
            //Query for Council service with this particular short ref. If it is in the correct type
            //DO CRUD   
            councilServicesToReturn = [SELECT Id, Name, arcuscrm__Customer_Form_Introduction__c, arcuscrm__Case_Type__c, arcuscrm__Case_Subtype__c FROM arcshared__Council_Service__c WHERE arcuscrm__Short_Ref__c LIKE :shortRef AND arcuscrm__Available_for__c INCLUDES ('Quick Report It')];
        }
        else{
            //Query all council services of the correct type.
            //DO CRUD
            councilServicesToReturn = [SELECT Id, Name, arcuscrm__Customer_Form_Introduction__c, arcuscrm__Case_Type__c, arcuscrm__Case_Subtype__c FROM arcshared__Council_Service__c WHERE arcuscrm__Available_for__c INCLUDES ('Quick Report It')];
        }
        for(arcshared__Council_Service__c c : councilServicesToReturn){
            councilServicesToReturnMap.put(c.Name, c);
        }
        return councilServicesToReturnMap;
    }
    
    
}