public with sharing class CRM_CharityInfo
{
    @AuraEnabled(continuation=true cacheable=true)
    public static String getCharityInfo(String charityNumber)
    {
        //System.debug('<Arcus CRM - CRM_CharityInfo.getCharityInfo(charityNumber)> charityNumber >>> ' + charityNumber);
        arcuscrm.ArcI_DataCharityCommission pData = new arcuscrm.ArcI_DataCharityCommission();
        pData.charityNumber = charityNumber;
        //call the api
        return arcuscrm.ArcI_ServiceCharityCommission.getCharityByRegNumber(pData);
    }    
    
}