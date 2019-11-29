/*
Company : Arcus Global
Product : Arcus Integration
Purpose : Data structure for the Capita Portal requestservicetoken service
Notes :
 */
public with sharing class ArcI_DataSignOnGetServiceToken extends arcshared.ArcI_DataMain
{
    //IN
    //the session token is requred and is already in the parent (ArcI_DataMain) class
    public String referenceNumber {get; set;}
    public String applicationId {get; set;}

    //OUT
    public String serviceToken {get; set;}
    

    /**
     * General validation logic
     */
    public override Boolean validate()
    {
        if (String.isNotBlank(token) && String.isNotBlank(referenceNumber) && String.isNotBlank(applicationId))
        {
            return true;
        }
        else
        {
            processError(arcshared.ArcI_UtilityErrorManager.ERR_COD_GENERIC, 'session token, referenceNumber & applicationId are mandatory');
            return false;
        }
    }
}