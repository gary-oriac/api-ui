public with sharing class CRM_MAP_LeafletCont {
    
    @AuraEnabled
    public static List<arcusgazetteer__Location__c> searchLocations(String queryString){
        List<arcusgazetteer__Location__c> listToReturn = new List<arcusgazetteer__Location__c>();
        queryString = '%' + queryString + '%';

        listToReturn = [SELECT Id, arcusgazetteer__Address__c, arcusgazetteer__GeoLocation__Latitude__s, arcusgazetteer__GeoLocation__Longitude__s FROM arcusgazetteer__Location__c WHERE arcusgazetteer__Address__c LIKE :queryString];

        return listToReturn;
    }

    @AuraEnabled
    public static string getMapDefaultCentre(){
        Map<String,String> results = new Map<String,String>();
        Map<String,String> qRISettings = arcshared.appConfigSupport.getCategoryValues(arcuscrm.CRM_DataUtilities.QUICK_REPORT_IT_CATEGORY_NAME);

        results.put('lat', qRISettings.get(arcuscrm.CRM_DataUtilities.QRI_LATITUDE_KEY));
        results.put('long', qRISettings.get(arcuscrm.CRM_DataUtilities.QRI_LONGITUDE_KEY));
        results.put('zoom', qRISettings.get(arcuscrm.CRM_DataUtilities.QRI_ZOOM_KEY));

        return JSON.serialize(results);
    }

    @AuraEnabled
    public static string getMapTiles(){
        String result;
        result = arcshared.appConfigSupport.getSingleValue(arcuscrm.CRM_DataUtilities.QUICK_REPORT_IT_CATEGORY_NAME, arcuscrm.CRM_DataUtilities.QRI_TILES_KEY);
        return result;
    }
}