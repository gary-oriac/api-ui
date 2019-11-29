@isTest
public class CRM_MAP_LeafletCont_Test {

    @TestSetup
    static void setup(){
        arcuscrm.CRM_DataUtilities.insertAllSettings();
        arcshared.appConfigSupport.refreshCache();
    }
    
    @isTest
    static void test_getMapDefaultCentre(){
        Map<String,String> expectedMap = new Map<String,String>();
        expectedMap.put('lat', arcshared.appConfigSupport.getSingleValue(arcuscrm.CRM_DataUtilities.QUICK_REPORT_IT_CATEGORY_NAME, arcuscrm.CRM_DataUtilities.QRI_LATITUDE_KEY));
        expectedMap.put('long', arcshared.appConfigSupport.getSingleValue(arcuscrm.CRM_DataUtilities.QUICK_REPORT_IT_CATEGORY_NAME, arcuscrm.CRM_DataUtilities.QRI_LONGITUDE_KEY));
        expectedMap.put('zoom', arcshared.appConfigSupport.getSingleValue(arcuscrm.CRM_DataUtilities.QUICK_REPORT_IT_CATEGORY_NAME, arcuscrm.CRM_DataUtilities.QRI_ZOOM_KEY));
        
        String expectedResult = JSON.serialize(expectedMap);

        Test.startTest();
            String actualResult = arcuscrm.CRM_MAP_LeafletCont.getMapDefaultCentre();
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'The method should return a string containing a serialized map of the QRI default values');
    }
}