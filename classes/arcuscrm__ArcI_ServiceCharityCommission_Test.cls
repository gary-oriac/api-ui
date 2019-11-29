@isTest
public with sharing class ArcI_ServiceCharityCommission_Test
{
	//setup test data
	@testSetup
	public static void createTestData()
	{
		arcuscrm.ArcI_UtilityConfigSettings.insertCustomSettings();
		//refreshCache
		arcshared.AppConfigSupport.refreshCache();

		arcshared.AppConfigSupport.setSingleValue('Charity Commissions', 'CHARITY_COMMS_API_KEY', 'testKey123');
		//refreshCache
		arcshared.AppConfigSupport.refreshCache();
	}

	
	@isTest
	static void getCharityByRegNumber_success()
	{
		arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock getCharByNumberMock = new arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock();
		getCharByNumberMock.setAsTestMock();

		arcuscrm.ArcI_DataCharityCommission testCharityData = new arcuscrm.ArcI_DataCharityCommission();
		testCharityData.charityNumber = arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.REGISTERED_CHARITY_NUMBER;

		Test.startTest();
		arcuscrm.ArcI_ServiceCharityCommission.getCharityByRegNumber(testCharityData);
		Test.stopTest();

		System.assertEquals(true, testCharityData.isSuccess);

		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.REGISTERED_CHARITY_NUMBER, testCharityData.RegisteredCharityNumber);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.CHARITY_NAME, testCharityData.CharityName);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.REGISTERED_COMPANY_NUMBER, testCharityData.RegisteredCompanyNumber);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.ACTIVITIES, testCharityData.Activities);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.AREA_OF_OPERATION, testCharityData.AreaOfOperation);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.ORGANISATION_TYPE, testCharityData.OrganisationType);
		System.assertEquals(false, testCharityData.IsSuspended);
		System.assertEquals(false, testCharityData.Insolvent);
		System.assertEquals(true, testCharityData.DocumentsOverdue);

		//reg history
		System.assertNotEquals(null, testCharityData.RegistrationHistory);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.REGISTERATION_DATE, testCharityData.RegistrationHistory.RegistrationDate);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.REGISTERATION_REMOVAL_DATE, testCharityData.RegistrationHistory.RegistrationRemovalDate);

		///address
		System.assertNotEquals(null, testCharityData.CharityAddress);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.ADDRESS_LINE_1, testCharityData.CharityAddress.Line1);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.ADDRESS_LINE_2, testCharityData.CharityAddress.Line2);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.ADDRESS_LINE_3, testCharityData.CharityAddress.Line3);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.ADDRESS_LINE_4, testCharityData.CharityAddress.Line4);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.POSTCODE, testCharityData.CharityAddress.Postcode);

		//trustees
		System.assertNotEquals(null, testCharityData.Trustees);
		System.assert(testCharityData.Trustees.size() > 0);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.TRUSTEE_NUMBER, testCharityData.Trustees[0].TrusteeNumber);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.TRUSTEE_NAME, testCharityData.Trustees[0].TrusteeName);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.RELATED_CHARITIES_COUNT, testCharityData.Trustees[0].RelatedCharitiesCount);

		//acc submissions
		System.assertNotEquals(null, testCharityData.AccountingSubmissions);
		System.assert(testCharityData.AccountingSubmissions.size() > 0);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.MAILING_CYCLE, testCharityData.AccountingSubmissions[0].MailingCycle);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.FY_START, testCharityData.AccountingSubmissions[0].FyStart);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.FY_END, testCharityData.AccountingSubmissions[0].FyEnd);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.ANNUAL_RETURN_RECEIVED_DATE, testCharityData.AccountingSubmissions[0].AnnualReturnReceivedDate);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.ACCOUNTS_RETURN_RECEIVED_DATE, testCharityData.AccountingSubmissions[0].AccountsReturnReceivedDate);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.GROSS_INCOME, testCharityData.AccountingSubmissions[0].GrossIncome);
		System.assertEquals(arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock.TOTAL_EXPENDITURE, testCharityData.AccountingSubmissions[0].TotalExpenditure);
	}

	@isTest
	static void getCharityByRegNumber_fail_invalidReqData()
	{
		arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock getCharByNumberMock = new arcuscrm.ArcI_ConnCharityCommissionByRegNum_Mock();
		getCharByNumberMock.setAsTestMock();

		arcuscrm.ArcI_DataCharityCommission testCharityData = new arcuscrm.ArcI_DataCharityCommission();
		testCharityData.charityNumber = '';

		Test.startTest();
		arcuscrm.ArcI_ServiceCharityCommission.getCharityByRegNumber(testCharityData);
		Test.stopTest();

		System.assertEquals(false, testCharityData.isSuccess);
		System.assertEquals('Charity Number is required', testCharityData.errorMessage);
	}
}