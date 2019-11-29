@isTest
public with sharing class ArcI_ServiceCompaniesHouse_Test
{
    //setup test data
	@testSetup
	public static void createTestData()
	{
		arcuscrm.ArcI_UtilityConfigSettings.insertCustomSettings();
		//refreshCache
		arcshared.AppConfigSupport.refreshCache();
	}

    @isTest
    static void getCompaniesHouseData_success()
    {
        //Arrange
		arcuscrm.ArcI_ConnCompaniesHouseMain_Mock compHouseDataRespMock = new arcuscrm.ArcI_ConnCompaniesHouseMain_Mock();
		compHouseDataRespMock.setAsTestMock();

        arcuscrm.ArcI_DataCompaniesHouse pData = new arcuscrm.ArcI_DataCompaniesHouse();
        pData.companyNumber = arcuscrm.ArcI_ConnCompaniesHouseMain_Mock.REGISTERED_COMPANY_NUMBER;
        pData.getOfficers = false;
        
        //Act
        Test.startTest();
        arcuscrm.ArcI_ServiceCompaniesHouse.getCompaniesHouseData(pData);
        Test.stopTest();

        //Assert
        System.assertEquals(true, pData.isSuccess, 'the callout should be successful but insted we got the following error >>> ' + pData.errorMessage);
        System.assertNotEquals(null, pData.CompanyData);

        System.assertEquals(false, pData.CompanyData.has_been_liquidated);//: false,
        System.assertEquals(false, pData.CompanyData.undeliverable_registered_office_address);//: false,
        System.assertEquals(false, pData.CompanyData.registered_office_is_in_dispute);//: false,
        System.assertEquals(true, pData.CompanyData.can_file);//: true
        System.assertEquals(false, pData.CompanyData.has_insolvency_history);//: false,
        System.assertEquals(true, pData.CompanyData.has_charges);//: true,

        System.assert(String.isNotBlank(pData.CompanyData.type));//: ltd,
        System.assert(String.isNotBlank(pData.CompanyData.date_of_creation));//: 2009-06-29,
        System.assert(pData.CompanyData.sic_codes.size() > 0);//: [84110],
        System.assert(String.isNotBlank(pData.CompanyData.company_number));//: 99999999,
        System.assert(String.isNotBlank(pData.CompanyData.jurisdiction));//: england-wales,
        System.assert(String.isNotBlank(pData.CompanyData.last_full_members_list_date));//: 2016-06-29,
        System.assert(String.isNotBlank(pData.CompanyData.company_name));//: ARCUS GLOBAL LIMITED,
        System.assert(String.isNotBlank(pData.CompanyData.etag));//: f98633700c51afef707c475fc35004a43f21c4c0,
        System.assert(String.isNotBlank(pData.CompanyData.company_status));//: active,


        System.assertNotEquals(null, pData.CompanyData.registered_office_address);
        System.assert(String.isNotBlank(pData.CompanyData.registered_office_address.address_line_1));//: Future Business Centre,
        System.assert(String.isNotBlank(pData.CompanyData.registered_office_address.address_line_2));//: Kings Hedges Road,
        System.assert(String.isBlank(pData.CompanyData.registered_office_address.address_line_3));//
        System.assert(String.isBlank(pData.CompanyData.registered_office_address.address_line_4));//
        System.assert(String.isBlank(pData.CompanyData.registered_office_address.address_line_5));//
        System.assert(String.isNotBlank(pData.CompanyData.registered_office_address.locality));//: Cambridge
        System.assert(String.isNotBlank(pData.CompanyData.registered_office_address.region));//: Cambridgeshire,
        System.assert(String.isNotBlank(pData.CompanyData.registered_office_address.postal_code));//: CB4 2HY,

        System.assertNotEquals(null, pData.CompanyData.accounts);
        System.assertEquals(false, pData.CompanyData.accounts.overdue);//: false,
        System.assert(String.isNotBlank(pData.CompanyData.accounts.next_due));//: 2020-03-31,
        System.assert(String.isNotBlank(pData.CompanyData.accounts.next_made_up_to));//: 2019-06-30,        

        System.assertNotEquals(null, pData.CompanyData.accounts.last_accounts);
        System.assert(String.isNotBlank(pData.CompanyData.accounts.last_accounts.period_end_on));//: 2018-06-30,
        System.assert(String.isNotBlank(pData.CompanyData.accounts.last_accounts.period_start_on));//: 2017-07-01,
        System.assert(String.isNotBlank(pData.CompanyData.accounts.last_accounts.type));//: full,
        System.assert(String.isNotBlank(pData.CompanyData.accounts.last_accounts.made_up_to));//: 2018-06-30

        System.assertNotEquals(null, pData.CompanyData.accounts.next_accounts);
        System.assertEquals(false, pData.CompanyData.accounts.next_accounts.overdue);//: false,
        System.assert(String.isNotBlank(pData.CompanyData.accounts.next_accounts.due_on));//: 2020-03-31,
        System.assert(String.isNotBlank(pData.CompanyData.accounts.next_accounts.period_end_on));//: 2019-06-30,
        System.assert(String.isNotBlank(pData.CompanyData.accounts.next_accounts.period_start_on));//: 2018-07-01
        //
        System.assertNotEquals(null, pData.CompanyData.accounts.accounting_reference_date);
        System.assert(String.isNotBlank(pData.CompanyData.accounts.accounting_reference_date.day));//: 30,
        System.assert(String.isNotBlank(pData.CompanyData.accounts.accounting_reference_date.month));//: 06

        System.assertNotEquals(null, pData.CompanyData.confirmation_statement);
        System.assert(String.isNotBlank(pData.CompanyData.confirmation_statement.next_made_up_to));//: 2020-06-29,
        System.assertEquals(false, pData.CompanyData.confirmation_statement.overdue);//: false,
        System.assert(String.isNotBlank(pData.CompanyData.confirmation_statement.last_made_up_to));//: 2019-06-29,
        System.assert(String.isNotBlank(pData.CompanyData.confirmation_statement.next_due));//: 2020-07-13

        System.assertNotEquals(null, pData.CompanyData.links);
        System.assert(String.isNotBlank(pData.CompanyData.links.self));//: /company/99999999,
        System.assert(String.isNotBlank(pData.CompanyData.links.filing_history));//: /company/99999999/filing-history,
        System.assert(String.isNotBlank(pData.CompanyData.links.officers));//: /company/99999999/officers,
        System.assert(String.isNotBlank(pData.CompanyData.links.charges));//: /company/99999999/charges,
        System.assert(String.isNotBlank(pData.CompanyData.links.persons_with_significant_control));//: /company/99999999/persons-with-significant-control
    }

    @isTest
    static void getCompaniesHouseData_fail_invalidReqData()
    {
        //Arrange
		arcuscrm.ArcI_ConnCompaniesHouseMain_Mock compHouseDataRespMock = new arcuscrm.ArcI_ConnCompaniesHouseMain_Mock();
		compHouseDataRespMock.setAsTestMock();

        arcuscrm.ArcI_DataCompaniesHouse pData = new arcuscrm.ArcI_DataCompaniesHouse();
        pData.companyNumber = '';
        
        //Act
        Test.startTest();
        arcuscrm.ArcI_ServiceCompaniesHouse.getCompaniesHouseData(pData);
        Test.stopTest();
        
        //Assert
        System.assertEquals(false, pData.isSuccess, 'the callout should be successful but insted we got the following error >>> ' + pData.errorMessage);
        System.assertEquals('Company Number is required', pData.errorMessage);
    }

    @isTest
    static void getCompaniesHouseData_Officers_success()
    {
        //Arrange
		arcuscrm.ArcI_ConnCompaniesHouse_Officers_Mock compHouseDataRespMock = new arcuscrm.ArcI_ConnCompaniesHouse_Officers_Mock();
		compHouseDataRespMock.setAsTestMock();

        arcuscrm.ArcI_DataCompaniesHouse pData = new arcuscrm.ArcI_DataCompaniesHouse();
        pData.companyNumber = arcuscrm.ArcI_ConnCompaniesHouse_Officers_Mock.REGISTERED_COMPANY_NUMBER;
        pData.getOfficers = true;
        
        //Act
        Test.startTest();
        arcuscrm.ArcI_ServiceCompaniesHouse.getCompaniesHouseData(pData);
        Test.stopTest();

        //Assert
        System.assertEquals(true, pData.isSuccess, 'the callout should be successful but insted we got the following error >>> ' + pData.errorMessage);
        System.assertNotEquals(null, pData.CompanyOfficersData);

        System.assert(String.isNotBlank(pData.CompanyOfficersData.active_count));
        System.assert(String.isNotBlank(pData.CompanyOfficersData.inactive_count));
        System.assert(String.isNotBlank(pData.CompanyOfficersData.resigned_count));
        System.assert(String.isNotBlank(pData.CompanyOfficersData.total_results));

        System.assert(pData.CompanyOfficersData.items.size() > 0);

        System.assert(String.isNotBlank(pData.CompanyOfficersData.items[0].officer_role));
        System.assert(String.isNotBlank(pData.CompanyOfficersData.items[0].nationality));
        System.assert(String.isNotBlank(pData.CompanyOfficersData.items[0].occupation));
        System.assert(String.isNotBlank(pData.CompanyOfficersData.items[0].name));
        System.assert(String.isNotBlank(pData.CompanyOfficersData.items[0].resigned_on));
        System.assert(String.isNotBlank(pData.CompanyOfficersData.items[0].appointed_on));
        System.assert(String.isNotBlank(pData.CompanyOfficersData.items[0].country_of_residence));

        System.assert(String.isNotBlank(pData.CompanyOfficersData.items[0].country_of_residence));

        System.assertNotEquals(null, pData.CompanyOfficersData.items[0].address);
        System.assert(String.isNotBlank(pData.CompanyOfficersData.items[0].address.address_line_1));
        System.assert(String.isNotBlank(pData.CompanyOfficersData.items[0].address.address_line_2));
        System.assert(String.isNotBlank(pData.CompanyOfficersData.items[0].address.address_line_3));
        System.assert(String.isNotBlank(pData.CompanyOfficersData.items[0].address.address_line_4));
        System.assert(String.isNotBlank(pData.CompanyOfficersData.items[0].address.address_line_5));
        System.assert(String.isNotBlank(pData.CompanyOfficersData.items[0].address.locality));
        System.assert(String.isNotBlank(pData.CompanyOfficersData.items[0].address.region));
        System.assert(String.isNotBlank(pData.CompanyOfficersData.items[0].address.postal_code));
        System.assert(String.isNotBlank(pData.CompanyOfficersData.items[0].address.country));
        System.assert(String.isNotBlank(pData.CompanyOfficersData.items[0].address.premises));

        System.assertNotEquals(null, pData.CompanyOfficersData.items[0].date_of_birth);
        System.assert(String.isNotBlank(pData.CompanyOfficersData.items[0].date_of_birth.year));
        System.assert(String.isNotBlank(pData.CompanyOfficersData.items[0].date_of_birth.month));
    }
}