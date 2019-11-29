/*
Company : Arcus Global
Product : Arcus DSH
Purpose : Test DSHCustomisationCont controller class
Notes :
 */
@isTest
public with sharing class DSHLC_CustomisationCont_Test{
    private static testMethod void testCategories(){
        DSHLC_CustomisationCont thisController = new DSHLC_CustomisationCont(); 
        List<String> retrievedList = thisController.getCategoryList();
        System.assertNotEquals(0, retrievedList.size());
    }
}