public with sharing class ArcI_DataCompaniesHouse extends arcshared.ArcI_DataMain 
{
	//reqest
	public String companyNumber;
	public Boolean getOfficers;

	//response
    public CompaniesHouseData CompanyData;
    public CompaniesHouseOfficers CompanyOfficersData;

	//data validation
	public override Boolean validate()
	{
		if(String.isNotBlank(companyNumber))
		{
			return true;
		}
        else 
        {
            processError(arcshared.ArcI_UtilityErrorManager.ERR_COD_SPECIFIC, 'Company Number is required');
            return false;
        }
	}


    public class CompaniesHouseData
    {        
        public Boolean has_been_liquidated;//: false,
        public Boolean undeliverable_registered_office_address;//: false,
        public Boolean registered_office_is_in_dispute;//: false,
        public Boolean can_file;//: true
        public Boolean has_insolvency_history;//: false,
        public Boolean has_charges;//: true,

        public String type;//: ltd,
        public String date_of_creation;//: 2009-06-29,
        public List<String> sic_codes;//: [84110],
        public String company_number;//: 99999999,
        public String jurisdiction;//: england-wales,
        public String last_full_members_list_date;//: 2016-06-29,
        public Address registered_office_address;
        public Accounts accounts;
        public String company_name;//: ARCUS GLOBAL LIMITED,
        public String etag;//: f98633700c51afef707c475fc35004a43f21c4c0,
        public String company_status;//: active,
        public ConfirmationStatement confirmation_statement;
        public Links links;
    }

    public class Address
    {
        public String address_line_1;//: Future Business Centre,
        public String address_line_2;//: Kings Hedges Road,
        public String address_line_3;//
        public String address_line_4;//
        public String address_line_5;//
        public String locality;//: Cambridge
        public String region;//: Cambridgeshire,
        public String postal_code;//: CB4 2HY,
    }

    public class Accounts
    {
        public Boolean overdue;//: false,
        public String next_due;//: 2020-03-31,
        public String next_made_up_to;//: 2019-06-30,        
        public LastAccounts last_accounts;
        public NextAccounts next_accounts;
        public AccountingReferenceDate accounting_reference_date;
    }
    public class LastAccounts
    {
        public String period_end_on;//: 2018-06-30,
        public String period_start_on;//: 2017-07-01,
        public String type;//: full,
        public String made_up_to;//: 2018-06-30
    }
    public class NextAccounts
    {
        public Boolean overdue;//: false,
        public String due_on;//: 2020-03-31,
        public String period_end_on;//: 2019-06-30,
        public String period_start_on;//: 2018-07-01
    }
    public class AccountingReferenceDate
    {
        public String day;//: 30,
        public String month;//: 06
    }

    public class ConfirmationStatement
    {
        public String next_made_up_to;//: 2020-06-29,
        public Boolean overdue;//: false,
        public String last_made_up_to;//: 2019-06-29,
        public String next_due;//: 2020-07-13
    }

    public class Links
    {
        public String self;//: /company/99999999,
        public String filing_history;//: /company/99999999/filing-history,
        public String officers;//: /company/99999999/officers,
        public String charges;//: /company/99999999/charges,
        public String persons_with_significant_control;//: /company/99999999/persons-with-significant-control
    }

    //OFFICERS
    public class CompaniesHouseOfficers
    {
        public String active_count;
        public String inactive_count;
        public String resigned_count;
        public String total_results;
        public List<OfficerDetails> items;
    }

    public class OfficerDetails
    {   
        public String officer_role;//  director",
        public String nationality;//  Itelian",
        public String occupation;//  Company Director",
        public String name;//  DOE, John",
        public List<FormerName> former_names;
        public String resigned_on;//  2019-08-28",
        public String appointed_on;//  2009-06-29",
        public String country_of_residence;//  England",
        public OfficerDateOfBirth date_of_birth;
        public OfficerAddress address;
    }

    public class OfficerAddress
    {
        public String address_line_1;
        public String address_line_2;
        public String address_line_3;
        public String address_line_4;
        public String address_line_5;
        public String premises;
        public String locality;
        public String region;
        public String postal_code;
        public String country;
    }

    public class OfficerDateOfBirth
    {
        public String year;
        public String month;
    }

    public class FormerName
    {
        public String surname;
    }

}
        // "links": {
        //     "officer": {
        //         public String appointments;//  /officers/ITyTpq1LZ-FgucPLh6Lbsc2AHGg/appointments"
        //     }
        // },