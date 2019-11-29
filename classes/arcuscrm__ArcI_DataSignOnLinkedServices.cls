/*
Company : Arcus Global
Product : Arcus Integration
Purpose : Data structure for the Capita Portal Get Linked Services service
Notes :
 */
public with sharing class ArcI_DataSignOnLinkedServices extends arcshared.ArcI_DataMain
{
	//OUT
	public List<PortalService> linkedServices {get; set;}

	public class PortalService
	{
	    public String referenceNumber {get; set;}
	    public String applicationId {get; set;}
	    public String applicationName {get; set;}
	    public String address {get; set;}
	    public String status {get; set;}		
	    public String link {get; set;}		
	}
    
    /**
     * General validation logic
     */
    public override Boolean validate()
    {
        if (String.isNotBlank(token))
        {
            return true;
        }
        else
        {
            processError(arcshared.ArcI_UtilityErrorManager.ERR_COD_GENERIC, 'token is mandatory');
            return false;
        }
    }

}