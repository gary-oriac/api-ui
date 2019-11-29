@isTest
public with sharing class CRM_CharityInfo_Test
{
    @testSetup static void setup()
    {
        arcuscrm.ArcI_ServiceCharityCommission_Test.createTestData();
        //create test acc with char number populated
        Account myAcc = new Account(Name='Arcus Global', arcuscrm__Registered_Charity_Number__c = arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.REGISTERED_CHARITY_NUMBER );
        insert myAcc;
    }
    
    @isTest static void testGetCharityInfo_success()
    {     
        Test.startTest();
        
        arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock getCharByNumberMock = new arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock();
		getCharByNumberMock.setAsTestMock();

        Account acc = [SELECT Id, arcuscrm__Registered_Charity_Number__c FROM Account WHERE Name = 'Arcus Global' Limit 1];
        System.assertNotEquals(null, acc.Id);
        System.assert(String.isNotEmpty(acc.arcuscrm__Registered_Charity_Number__c));

        String respData = CRM_CharityInfo.getCharityInfo(acc.arcuscrm__Registered_Charity_Number__c);
        
        System.assert(String.isNotEmpty(respData), 'arcuscrm.CRM_CharityInfo.getCharityInfo() method should return a valid data when given valid charity number');

        Test.stopTest();
    }
    
}