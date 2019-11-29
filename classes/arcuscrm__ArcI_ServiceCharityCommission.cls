public with sharing class ArcI_ServiceCharityCommission
{
	public static string getCharityByRegNumber(arcuscrm.ArcI_DataCharityCommission pData)
	{
		try
		{
			if(pData.validate())
			{
				new arcuscrm.ArcI_ConnCharityCommissionByRegNumber().invoke(pData);
			}

			System.debug('<ARCUS CRM - ArcI_ServiceCharityCommission.getCharityByRegNumber()> pData: ' + JSON.serialize(pData));
		}
		catch(Exception ex){arcshared.ArcI_UtilityErrorManager.processErrorSpecificMessage('Something went wrong...', pData);}
		// {
		// 	//log the ex errors
		// 	System.debug('<ARCUS CRM - ArcI_ServiceCharityCommission.getCharityByRegNumber()> error: ' + ex.getMessage());
		// 	System.debug('<ARCUS CRM - ArcI_ServiceCharityCommission.getCharityByRegNumber()> error LineNumber: ' + ex.getLineNumber());
		// 	System.debug('<ARCUS CRM - ArcI_ServiceCharityCommission.getCharityByRegNumber()> error cause: ' + ex.getCause());
		// 	System.debug('<ARCUS CRM - ArcI_ServiceCharityCommission.getCharityByRegNumber()> error stack trace: ' + ex.getStackTraceString());
		// }
		return JSON.serialize(pData);
	}
}