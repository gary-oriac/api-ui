public class ArcI_DataCharityCommission extends arcshared.ArcI_DataMain 
{
	//reqest
	public String charityNumber;

	//response
	public String CharityName;
	public String WorkingNames;
	public String RegisteredCharityNumber;
	public String RegisteredCompanyNumber;
	public RegistrationHistory RegistrationHistory;
	public String Activities;
	public String AreaOfOperation;
	public String OrganisationType;
	public Boolean IsSuspended;
	public Boolean Insolvent;
	public Boolean DocumentsOverdue;	//where to find it???
	public CharityAddress CharityAddress;
	public List<Trustee> Trustees;
	public List<Submission> AccountingSubmissions;



	//data validation
	public override Boolean validate()
	{
		if(String.isNotBlank(charityNumber))
		{
			return true;
		}
        else 
        {
            processError(arcshared.ArcI_UtilityErrorManager.ERR_COD_SPECIFIC, 'Charity Number is required');
            return false;
        }
	}


	public class RegistrationHistory
	{
		public String RegistrationDate;
		public String RegistrationRemovalDate;
	}

	public class Trustee
	{
		public String TrusteeNumber;
		public String TrusteeName;
		public String RelatedCharitiesCount;
	}

	public class CharityAddress
	{
		public String Line1;
		public String Line2;
		public String Line3;
		public String Line4;
		public String Line5;
		public String Postcode;
	}

	
	public class Submission
	{
       public String MailingCycle;	
       public String FyStart;
       public String FyEnd;
       public String AnnualReturnReceivedDate;
       public String AccountsReturnReceivedDate;
       public String GrossIncome;
       public String TotalExpenditure;
	}
 

}