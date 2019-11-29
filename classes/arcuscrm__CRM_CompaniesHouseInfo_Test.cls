@isTest
public with sharing class CRM_CompaniesHouseInfo_Test {
    
    @testSetup static void setup() {
        Account myAcc = new Account(Name='Arcus Global', arcshared__Company_Number__c = '06946606' );
        insert myAcc;
    }
    
    @isTest static void testLocationQueries(){
     
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new arcuscrm.CRM_CompaniesHouseInfo_Mock());
        
        String baseUrl = 'https://api.companieshouse.gov.uk/company';
        String compNo = '06946606';
        
        String url = baseUrl+  '/' + compNo ;
        
        Map < String, Object > resp = CRM_CompaniesHouseInfo.getCalloutResponseContents(url);
        
        System.assertNotEquals(resp, null, 'Companies house method should return not null when given valid data');

        Test.stopTest();
    }

    @isTest static void testGetCompanyInfo_success()
    {
        //Arrange
        Account acc = [SELECT Id, arcshared__Company_Number__c FROM Account WHERE Name = 'Arcus Global' Limit 1];
        System.assertNotEquals(null, acc.Id);
        System.assert(String.isNotEmpty(acc.arcshared__Company_Number__c));
     
		arcuscrm.ArcI_ConnCompaniesHouseMain_Mock compHouseDataRespMock = new arcuscrm.ArcI_ConnCompaniesHouseMain_Mock();
		compHouseDataRespMock.setAsTestMock();

        //Act
        Test.startTest();
        String respData = CRM_CompaniesHouseInfo.getCompanyInfo(acc.arcshared__Company_Number__c);
        Test.stopTest();
        
        //Assert
        System.assert(String.isNotEmpty(respData), 'arcuscrm.CRM_CompaniesHouseInfo.getCompanyInfo() method should return a valid data when given valid company number');

    }

    @isTest static void testGetCompanyOfficers_success()
    {
        //Arrange
        Account acc = [SELECT Id, arcshared__Company_Number__c FROM Account WHERE Name = 'Arcus Global' Limit 1];
        System.assertNotEquals(null, acc.Id);
        System.assert(String.isNotEmpty(acc.arcshared__Company_Number__c));
     
		arcuscrm.ArcI_ConnCompaniesHouse_Officers_Mock compHouseOfficersRespMock = new arcuscrm.ArcI_ConnCompaniesHouse_Officers_Mock();
		compHouseOfficersRespMock.setAsTestMock();

        //Act
        Test.startTest();
        String respData = CRM_CompaniesHouseInfo.getCompanyOfficers(acc.arcshared__Company_Number__c);
        Test.stopTest();
        
        //Assert
        System.assert(String.isNotEmpty(respData), 'arcuscrm.CRM_CompaniesHouseInfo.getCompanyOfficers() method should return a valid data when given valid company number');

    }
    
}