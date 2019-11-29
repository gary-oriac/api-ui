global with sharing class CRM_DataUtilities {

    public static final String APPCONFIG_CATEGORY_FOR_TRIGGER_DEFINITIONS = 'TriggerHandlers';

    public static final String QRI_LATITUDE_KEY = 'DEFAULT_LATITUDE';
    public static final String QRI_LONGITUDE_KEY = 'DEFAULT_LONGITUDE';
    public static final String QRI_ZOOM_KEY = 'DEFAULT_ZOOM';
    public static final String QRI_TILES_KEY = 'DEFAULT_TILES';
    public static final String QUICK_REPORT_IT_CATEGORY_NAME = 'QuickReportItSettings';
    public static final String PACKAGE_NAME = 'arcuscrm';

    global static void insertAllSettings(){
        insertQRICustomSettings();
        insertStaffHubCustomSettings();
    }
    
    global static List<arcshared__Configuration__c>  createDefaultDateSchedules() {

        System.debug('CRM_DataUtilities' );
        Integer maxNoSLADays = 50;
        
        List<arcshared__Configuration__c> newConfigs = new List<arcshared__Configuration__c>();
        Id dateSheduleRTID = [SELECT Id FROM RecordType WHERE DeveloperName = 'Date_Schedule' AND SobjectType = 'arcshared__Configuration__c' LIMIT 1].Id;
        for(Integer i = 1; i<maxNoSLADays; i++){
            System.debug('i ' + i ); 
            arcshared__Configuration__c newConfig = new arcshared__Configuration__c();
            newConfig.arcshared__Action__c = '[{"target":"arcuscrm__Target_Resolution_Date__c","amount":'+ i + ',"type":"working","source":"today"}]';
            // newConfig.arcshared__Apply_on__c = 'status match';
            newConfig.arcshared__Criteria__c = '{"rules":[{"field":"arcuscrm__Target_Case_Resolution_Days__c","type":"DOUBLE","firstValue":'+i+',"secondValue":"","comparator":"equals"}],"logic":"","parsedLogic":[]}';
            newConfig.arcshared__Description__c = 'When a new case is created and has a '+i+' day SLA set the target date';
            newConfig.arcshared__DeveloperName__c = 'CRM set target resolution date ('+i+' day(s))';
            // newConfig.arcshared__Enabled__c = true;
            newConfig.arcshared__Object__c = 'Case';
            newConfig.arcshared__RecordTypeId_Mapping__c = '{"arcshared__Action__c":[],"arcshared__Criteria__c":[]}';
            newConfig.arcshared__Rule__c = 'arcshared.DateSchedule';
            newConfig.arcshared__Status__c = 'New';
            newConfig.RecordTypeId = dateSheduleRTID;
            System.debug('newConfig ' + newConfig ); 
            newConfigs.add(newConfig);

        }
        System.debug('newConfigs ' + newConfigs ); 
        insert newConfigs;
        return newConfigs;
    }

    global static void insertQRICustomSettings(){
        List<arcshared.AppConfigSupport.setting> settingsList = new List<arcshared.AppConfigSupport.setting>();

        arcshared.AppConfigSupport.setting quickReportDefaultLatitude = new arcshared.AppConfigSupport.setting();
        quickReportDefaultLatitude.key = QRI_LATITUDE_KEY;
        quickReportDefaultLatitude.editable = true;
        quickReportDefaultLatitude.valueType = 'String';
        quickReportDefaultLatitude.defaultValue = '50.96921';
        quickReportDefaultLatitude.currentValue = quickReportDefaultLatitude.defaultValue;
        quickReportDefaultLatitude.available = true;
        quickReportDefaultLatitude.description = 'The default latitude used to set the view when opening Quick Report It map if no location services are established';
        settingsList.add(quickReportDefaultLatitude);
        
        arcshared.AppConfigSupport.setting quickReportDefaultLongitude = new arcshared.AppConfigSupport.setting();
        quickReportDefaultLongitude.key = QRI_LONGITUDE_KEY;
        quickReportDefaultLongitude.editable = true;
        quickReportDefaultLongitude.valueType = 'String';
        quickReportDefaultLongitude.defaultValue = '-1.3500488';
        quickReportDefaultLongitude.currentValue = quickReportDefaultLongitude.defaultValue;
        quickReportDefaultLongitude.available = true;
        quickReportDefaultLongitude.description = 'The default longitude used to set the view when opening Quick Report It map if no location services are established';
        settingsList.add(quickReportDefaultLongitude);

        arcshared.AppConfigSupport.setting quickReportDefaultZoom = new arcshared.AppConfigSupport.setting();
        quickReportDefaultZoom.key = QRI_ZOOM_KEY;
        quickReportDefaultZoom.editable = true;
        quickReportDefaultZoom.valueType = 'String';
        quickReportDefaultZoom.defaultValue = '14';
        quickReportDefaultZoom.currentValue = quickReportDefaultZoom.defaultValue;
        quickReportDefaultZoom.available = true;
        quickReportDefaultZoom.description = 'The default zoom level used to set the view when opening Quick Report It map if no location services are established';
        settingsList.add(quickReportDefaultZoom);

        arcshared.AppConfigSupport.setting quickReportDefaultTiles = new arcshared.AppConfigSupport.setting();
        quickReportDefaultTiles.key = QRI_TILES_KEY;
        quickReportDefaultTiles.editable = true;
        quickReportDefaultTiles.valueType = 'String';
        quickReportDefaultTiles.defaultValue = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
        quickReportDefaultTiles.currentValue = quickReportDefaultTiles.defaultValue;
        quickReportDefaultTiles.available = true;
        quickReportDefaultTiles.description = 'The default map tiles used for the Quick Report It';
        settingsList.add(quickReportDefaultTiles);

        arcshared.AppConfigSupport.setCategoryRecords(QUICK_REPORT_IT_CATEGORY_NAME, settingsList, PACKAGE_NAME);
    }

    global static void insertStaffHubCustomSettings(){
        Map<String, List<arcshared.AppConfigSupport.setting>> settings = new Map<String, List<arcshared.AppConfigSupport.setting>>();
        List<arcshared.AppConfigSupport.setting> triggerSettingsList = new List<arcshared.AppConfigSupport.setting>();

        // Add all trigger settings
        triggerSettingsList.addAll(CRM_StaffHubUserTriggerHandler.TRIGGER_SETTINGS);

        settings.put(APPCONFIG_CATEGORY_FOR_TRIGGER_DEFINITIONS, triggerSettingsList);

        // Add other custom settings

        // Insert all the settings
        arcshared.AppConfigSupport.setCategoryRecords(settings, PACKAGE_NAME);
    }
}