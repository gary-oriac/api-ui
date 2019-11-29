public without sharing  class LC_QuickReportIt_NoSharing {

    @AuraEnabled
    public static List<Case> findNearbyCases(Double myLat, Double myLng){
    	
        List<Case> myCases = [SELECT Id, Type, Status,CaseNumber, Subject,IsClosed,SuppliedName, FHDC_Reported_Location__Latitude__s, FHDC_Reported_Location__Longitude__s, CreatedDate,
                              DISTANCE(FHDC_Reported_Location__c, GEOLOCATION(:myLat, :myLng), 'km')  
                              FROM Case
                              WHERE FHDC_Reported_Location__Latitude__s != NULL
                              ORDER BY DISTANCE(FHDC_Reported_Location__c , GEOLOCATION(:myLat, :myLng), 'km')   
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
    	
        Case myCase = [SELECT Id, Type, Status,CaseNumber, Subject,IsClosed,SuppliedName, FHDC_Reported_Location__Latitude__s, FHDC_Reported_Location__Longitude__s, CreatedDate FROM Case WHERE Id = :caseId LIMIT 1];
        myCase.Status = 'Closed';
        update myCase;
        return myCase;
        
    }
    
    @AuraEnabled
    public static ContentDocumentLink linkDocument(Id contDocId, Id caseId){
    	
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = caseId;
        cdl.ContentDocumentId = contDocId;
        cdl.ShareType = 'V';
		cdl.Visibility = 'InternalUsers';
        insert cdl;
        return cdl;
        
    }
    

      
}