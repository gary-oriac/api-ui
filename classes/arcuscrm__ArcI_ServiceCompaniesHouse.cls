public with sharing class ArcI_ServiceCompaniesHouse
{
    public static String getCompaniesHouseData(arcuscrm.ArcI_DataCompaniesHouse pData)
	{
		try
		{
			if(pData.validate())
			{
				System.debug('<ARCUS CRM - ArcI_ServiceCompaniesHouse.getCompaniesHouseData()> we are good to call the external ws');

				new arcuscrm.ArcI_ConnCompaniesHouseMain().invoke(pData);
			}

			System.debug('<ARCUS CRM - ArcI_ServiceCompaniesHouse.getCompaniesHouseData()> pData: ' + JSON.serialize(pData));
		}
		catch(Exception ex) {arcshared.ArcI_UtilityErrorManager.processErrorSpecificMessage('Something went wrong...', pData);}
		// {
		// 	//log the ex errors
		// 	System.debug('<ARCUS CRM - ArcI_ServiceCompaniesHouse.getCompaniesHouseData()> error: ' + ex.getMessage());
		// 	System.debug('<ARCUS CRM - ArcI_ServiceCompaniesHouse.getCompaniesHouseData()> error LineNumber: ' + ex.getLineNumber());
		// 	System.debug('<ARCUS CRM - ArcI_ServiceCompaniesHouse.getCompaniesHouseData()> error cause: ' + ex.getCause());
		// 	System.debug('<ARCUS CRM - ArcI_ServiceCompaniesHouse.getCompaniesHouseData()> error stack trace: ' + ex.getStackTraceString());
		// }
		return JSON.serialize(pData);
	}
}