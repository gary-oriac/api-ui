public with sharing class ArcI_ConnCharityCommissionByRegNum_Mock extends arcshared.ArcI_ConnMain_Mock
{
	public static final String CHARITY_NAME = 'test name';
	public static final String REGISTERED_CHARITY_NUMBER = '12345';
	public static final String REGISTERED_COMPANY_NUMBER = '9999';
	public static final String REGISTERATION_DATE = '22/06/1971';
	public static final String REGISTERATION_REMOVAL_DATE = '22/06/1999';
	public static final String DOCUMENTS_OVERDUE = '';	//where to find it??????!!!?
	public static final String ACTIVITIES = 'test activity';
	public static final String AREA_OF_OPERATION = 'some area';
	public static final String ORGANISATION_TYPE = 'some org type';
	public static final String IS_SUSPENDED = 'false';
	public static final String INSOLVENT = '0';
	public static final String TRUSTEE_NUMBER = '666';
	public static final String TRUSTEE_NAME = 'Mr Burns';
	public static final String RELATED_CHARITIES_COUNT = '5';
	public static final String ADDRESS_LINE_1 = 'line 1';
	public static final String ADDRESS_LINE_2 = 'line 2';
	public static final String ADDRESS_LINE_3 = 'line 3';
	public static final String ADDRESS_LINE_4 = 'line 4';
	public static final String POSTCODE = 'cb1 1bc';
	public static final String MAILING_CYCLE = 'AR18';
	public static final String FY_START = '01 Jul 2017(estimated)';
	public static final String FY_END = '01 Jul 2018(estimated)';
	public static final String ANNUAL_RETURN_RECEIVED_DATE = '01/09/2018';
	public static final String ACCOUNTS_RETURN_RECEIVED_DATE = '01/09/2018';
	public static final String GROSS_INCOME = '1000.95';
	public static final String TOTAL_EXPENDITURE = '9.99';

	public override String getResponseBody(ResponseType pResponseType)
    {
    	return '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
    				   +'<soap:Body>'
    				      +'<GetCharityByRegisteredCharityNumberResponse xmlns="http://www.charitycommission.gov.uk/">'
    				         +'<GetCharityByRegisteredCharityNumberResult>'
    				            +'<CharityNumber>300712</CharityNumber>'
    				            +'<HasAccountsToDisplay>false</HasAccountsToDisplay>'
    				            +'<RegisteredCharityNumber>'+REGISTERED_CHARITY_NUMBER+'</RegisteredCharityNumber>'
    				            +'<SubsidiaryNumber>0</SubsidiaryNumber>'
    				            +'<CharityName>'+CHARITY_NAME+'</CharityName>'
    				            +'<RegistrationHistory>'
    				               +'<RegistrationDate>'+REGISTERATION_DATE+'</RegistrationDate>'
    				               +'<RegistrationRemovalDate>'+REGISTERATION_REMOVAL_DATE+'</RegistrationRemovalDate>'
    				               +'<RemovalReason/>'
    				            +'</RegistrationHistory>'
    				            +'<WorkingNames>26TH CAMBRIDGE GROUP</WorkingNames>'
    				            +'<AreaOfBenefit>CAMBRIDGE</AreaOfBenefit>'
    				            +'<GoverningDocument>THE SCOUT TRUST DEED 1969 LEASE DATED 28TH APRIL 1971</GoverningDocument>'
    				            +'<CharitableObjects>UNIT OF THE SCOUT ASSOCIATION</CharitableObjects>'
    				            +'<RegisteredCompanyNumber>'+REGISTERED_COMPANY_NUMBER+'</RegisteredCompanyNumber>'
    				            +'<ContactName>'
    				               +'<CharityRoleName/>'
    				            +'</ContactName>'
    				            +'<Address>'
    				               +'<Line1>'+ADDRESS_LINE_1+'</Line1>'
    				               +'<Line2>'+ADDRESS_LINE_2+'</Line2>'
    				               +'<Line3>'+ADDRESS_LINE_3+'</Line3>'
    				               +'<Line4>'+ADDRESS_LINE_4+'</Line4>'
    				               +'<Line5/>'
    				               +'<Postcode>'+POSTCODE+'</Postcode>'
    				            +'</Address>'
    				            +'<PublicTelephoneNumber>0122364040</PublicTelephoneNumber>'
    				            +'<PublicFaxNumber/>'
    				            +'<EmailAddress/>'
    				            +'<WebsiteAddress>www.26cambridge.org.uk</WebsiteAddress>'
    				            +'<Activities>'+ACTIVITIES+'</Activities>'
    				            +'<AreaOfOperation>'+AREA_OF_OPERATION+'</AreaOfOperation>'
    				            +'<Classification>'
    				               +'<What>Education/training</What>'
    				               +'<What>Religious Activities</What>'
    				               +'<What>Arts/culture/heritage/science</What>'
    				               +'<What>Amateur Sport</What>'
    				               +'<What>Environment/conservation/heritage</What>'
    				               +'<Who>Children/young People</Who>'
    				               +'<How>Provides Human Resources</How>'
    				               +'<How>Provides Buildings/facilities/open Space</How>'
    				               +'<How>Provides Services</How>'
    				            +'</Classification>'
    				            +'<Trustees>'
    				               +'<TrusteeNumber>'+TRUSTEE_NUMBER+'</TrusteeNumber>'
    				               +'<TrusteeName>'+TRUSTEE_NAME+'</TrusteeName>'
    				               +'<RelatedCharitiesCount>'+RELATED_CHARITIES_COUNT+'</RelatedCharitiesCount>'
    				            +'</Trustees>'
    				            +'<Submission>'
    				               +'<MailingCycle>'+MAILING_CYCLE+'</MailingCycle>'
    				               +'<FyStart>'+FY_START+'</FyStart>'
    				               +'<FyEnd>'+FY_END+'</FyEnd>'
    				               +'<AnnualReturnReceivedDate>'+ANNUAL_RETURN_RECEIVED_DATE+'</AnnualReturnReceivedDate>'
    				               +'<AccountsReturnReceivedDate>'+ACCOUNTS_RETURN_RECEIVED_DATE+'</AccountsReturnReceivedDate>'
    				               +'<GrossIncome>'+GROSS_INCOME+'</GrossIncome>'
    				               +'<TotalExpenditure>'+TOTAL_EXPENDITURE+'</TotalExpenditure>'
    				            +'</Submission>'
    				            +'<ExtendedRegistrationHistory>'
    				               +'<CharityEventID>195548</CharityEventID>'
    				               +'<OrganisationNumber>300712</OrganisationNumber>'
    				               +'<DateOfEvent>1971-06-22T00:00:00</DateOfEvent>'
    				               +'<AssociatedOrganisationNumber>-1</AssociatedOrganisationNumber>'
    				               +'<CharityGroupID>-1</CharityGroupID>'
    				               +'<GroupSubsidarySuffix>0</GroupSubsidarySuffix>'
    				               +'<CharityEventReasonCode/>'
    				               +'<CharityEventTypeCode>STD</CharityEventTypeCode>'
    				               +'<RegisteredCharityNumber>300712</RegisteredCharityNumber>'
    				               +'<AssociatedRegisteredCharityNumber>-1</AssociatedRegisteredCharityNumber>'
    				               +'<AssociatedCharityName/>'
    				               +'<CharityEventClassCode>REG</CharityEventClassCode>'
    				               +'<CharityEventTypeNameEnglish>STANDARD REGISTRATION</CharityEventTypeNameEnglish>'
    				               +'<CharityEventTypeNameWelsh>COFRESTRU SAFONOL</CharityEventTypeNameWelsh>'
    				            +'</ExtendedRegistrationHistory>'
    				            +'<CharityMainGroupType/>'
    				            +'<LatestFiling>'
    				               +'<AnnualReturnPeriod>30/06/2017</AnnualReturnPeriod>'
    				               +'<AnnualReturnReceived>06/02/2019 13:43:00</AnnualReturnReceived>'
    				               +'<AccountsPeriod>30/06/2017</AccountsPeriod>'
    				               +'<AccountsReceived>01/01/1900</AccountsReceived>'
    				               +'<HasRecieveAnnualReturn>1</HasRecieveAnnualReturn>'
    				               +'<HasRecieveAccounts>false</HasRecieveAccounts>'
    				               +'<Message>NotR</Message>'
    				               +'<Inactive_Status>0</Inactive_Status>'
    				               +'<AccountsPeriodForDue>30/06/2017</AccountsPeriodForDue>'
    				               +'<AccountsReceivedForDue>01/01/1900</AccountsReceivedForDue>'
    				               +'<AnnualReturnReceivedForDue>06/02/2019 13:43:00</AnnualReturnReceivedForDue>'
    				               +'<HasRecieveAccountsForDue>false</HasRecieveAccountsForDue>'
    				               +'<HasRecieveAnnualReturnForDue>1</HasRecieveAnnualReturnForDue>'
    				               +'<EarliestMissingAR>30/06/2018</EarliestMissingAR>'
    				               +'<EarliestMissingAccounts>30/06/2018</EarliestMissingAccounts>'
    				               +'<LatestAccQualiifed>0</LatestAccQualiifed>'
    				            +'</LatestFiling>'
    				            +'<OrganisationType>'+ORGANISATION_TYPE+'</OrganisationType>'
    				            +'<WasExempt>false</WasExempt>'
    				            +'<CIOIndicator/>'
    				            +'<CIODateConstituted/>'
    				            +'<CIODissolutionDate/>'
    				            +'<IsCIODissolutionReceived>false</IsCIODissolutionReceived>'
    				            +'<IsCIOAdminDissolution>false</IsCIOAdminDissolution>'
    				            +'<IsSuspended>'+IS_SUSPENDED+'</IsSuspended>'
    				            +'<IsInsolvencyActDocsReceived>false</IsInsolvencyActDocsReceived>'
    				            +'<IsCIOOnAmalgamationNotice>false</IsCIOOnAmalgamationNotice>'
    				            +'<LastRegistrationEvent>'
    				               +'<CharityEventID>195548</CharityEventID>'
    				               +'<OrganisationNumber>300712</OrganisationNumber>'
    				               +'<DateOfEvent>1971-06-22T00:00:00</DateOfEvent>'
    				               +'<AssociatedOrganisationNumber>-1</AssociatedOrganisationNumber>'
    				               +'<CharityGroupID>-1</CharityGroupID>'
    				               +'<GroupSubsidarySuffix>0</GroupSubsidarySuffix>'
    				               +'<CharityEventReasonCode/>'
    				               +'<CharityEventTypeCode>STD</CharityEventTypeCode>'
    				               +'<RegisteredCharityNumber>300712</RegisteredCharityNumber>'
    				               +'<AssociatedRegisteredCharityNumber>-1</AssociatedRegisteredCharityNumber>'
    				               +'<AssociatedCharityName/>'
    				               +'<CharityEventClassCode>REG</CharityEventClassCode>'
    				               +'<CharityEventTypeNameEnglish>STANDARD REGISTRATION</CharityEventTypeNameEnglish>'
    				               +'<CharityEventTypeNameWelsh>COFRESTRU SAFONOL</CharityEventTypeNameWelsh>'
    				            +'</LastRegistrationEvent>'
    				            +'<Insolvent>'+INSOLVENT+'</Insolvent>'
    				            +'<InAdministration>0</InAdministration>'
    				            +'<CIOConversionStatus>0</CIOConversionStatus>'
    				            +'<ClassInquiry>0</ClassInquiry>'
    				            +'<InSuspense>0</InSuspense>'
    				         +'</GetCharityByRegisteredCharityNumberResult>'
    				      +'</GetCharityByRegisteredCharityNumberResponse>'
    				   +'</soap:Body>'
    				+'</soap:Envelope>';
    }
}