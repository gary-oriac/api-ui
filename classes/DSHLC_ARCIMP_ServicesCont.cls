/*
Company    :    Arcus Global
Product    :    Arcus DSH
Purpose    :    Controller for Services
Notes      :    
*/
public with sharing class DSHLC_ARCIMP_ServicesCont  { 
    @AuraEnabled public String serviceCommunity {get;set;} 
    @AuraEnabled public static List<ServiceAreaWrapper> serviceAreaWrapper {get;set;}

    @AuraEnabled
    public static String getCommunityName() {
        return DSHLC_CommunityInfo.getCommunity().LC;
    }

    @AuraEnabled
    public static String getLightningCommunityPath() {
        String communityLC = DSHLC_CommunityInfo.getCommunity().LC;
        String lightningCommunity = '/' + communityLC + '/s/';
        return lightningCommunity;
    }

    @AuraEnabled
    public static String getVisualforceCommunityPath() {
        String communityLC = DSHLC_CommunityInfo.getCommunity().LC;
        String visualforceCommunity = '/' + communityLC.removeEnd('2') + '/';
        return visualforceCommunity;
    }

    @AuraEnabled
    public static String getCouncilCMSWebsiteURL() {
        String councilCMSWebsiteURL = DSHLC_ConfigSettings.getCouncilCMSWebsiteURL();
        return councilCMSWebsiteURL;
    }

    @AuraEnabled
    public static String makeQueryString() {
        if (UserInfo.getUserType() != 'Guest') {
            return '?firstname='+ UserInfo.getFirstName() +'&sessionexpires='+ String.valueof(DateTime.now().getTime())+'&community='+ DSHLC_CommunityInfo.getCommunity().LC;
        } else {
            return '?logout=true&community=' + DSHLC_CommunityInfo.getCommunity().LC;
        }
    }
    
    @AuraEnabled
    public static List<ServiceAreaWrapper> getCouncilServiceArea() {
        String serviceCommunity = DSHLC_CommunityInfo.getCommunityType();
        List<arcshared__Council_Service_Area__c> serviceAreas = [SELECT 
                Name, 
                Icon_Class__c, 
                arcshared__Description__c,   
                (SELECT 
                    Name,
                    arcshared__Service_URL__c,
                    arcshared__Process_Type__c,
                    arcshared__Description__c,
                 	arcuscrm__Flow_Name__c
                FROM 
                    arcshared__Council_Services__r
                WHERE
                    arcshared__Status__c = 'Active'
                AND
                    arcshared__Community__c includes (:serviceCommunity)
                ORDER BY 
                    arcshared__Ranking__c ASC
                LIMIT 100
                ) 
            FROM 
                arcshared__Council_Service_Area__c 
            WHERE
                arcshared__Status__c = 'Active'
            AND
                arcshared__Community__c includes (:serviceCommunity)
            AND
                (NOT Name LIKE '%Navigation%')
            ORDER BY 
                arcshared__Ranking__c ASC
            LIMIT 20
        ];
        serviceAreaWrapper = new List<ServiceAreaWrapper>();
        for(arcshared__Council_Service_Area__c serviceArea:serviceAreas) {
            serviceAreaWrapper.add(new ServiceAreaWrapper(serviceArea));
        }
        return serviceAreaWrapper;
    }
 
    public class ServiceAreaWrapper {
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public String IconClass {get;set;}
        @AuraEnabled public String Description {get;set;}
        @AuraEnabled public List<ServiceWrapper> services {get;set;}
        public ServiceAreaWrapper(arcshared__Council_Service_Area__c serviceArea){
            Name = serviceArea.Name;
            IconClass = serviceArea.Icon_Class__c;
            Description = serviceArea.arcshared__Description__c; 
            services = new List<ServiceWrapper>();
            for(arcshared__Council_Service__c service:serviceArea.arcshared__Council_Services__r) {
                services.add(new ServiceWrapper(service));
            }
        }

    }

    public class ServiceWrapper {
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public String ServiceURL {get;set;}
        @AuraEnabled public String Description {get;set;}
        
        public ServiceWrapper(arcshared__Council_Service__c service){
            Name = service.Name;
            ServiceURL = getServiceUrlPath(service.arcshared__Service_URL__c, service.arcshared__Process_Type__c, service.Id, service.arcuscrm__Flow_Name__c);
            Description = service.arcshared__Description__c;   
        }

        public String getServiceUrlPath(String serviceUrl, String processType, Id serviceId, String serviceRef) {
            String serviceUrlPath = '';
            if (processType == 'Lightning DSH') {
                serviceUrlPath = getLightningCommunityPath() + serviceUrl;
                // Logic added by Doug in copied class - add to the service URL the council service Id and service ref as URI params. 
                if(serviceUrl != null){
                    String additionalParams;
                    if( serviceUrlPath.contains('?') ){
                        additionalParams = '&council_service_id=' + serviceId;
                    }
                    else {
                        additionalParams = '?council_service_id=' + serviceId;
                    }
                    
                    if( !serviceUrlPath.contains('service_ref') && serviceRef!= null ){
                        additionalParams += + '&service_ref=' + serviceRef ;
                    }
                    serviceUrlPath += additionalParams;
                }
                
				
            } else if (processType == 'Visualforce DSH') {
                serviceUrlPath = getVisualforceCommunityPath() + serviceUrl;
            } else if (processType == 'External') {
                serviceUrlPath = serviceUrl;
            } else if (processType == 'CMS Website') {
                serviceUrlPath = getCouncilCMSWebsiteURL() + serviceUrl + makeQueryString();
            }
            return serviceUrlPath;
        }

    }

}