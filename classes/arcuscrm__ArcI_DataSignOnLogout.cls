/*
Company : Arcus Global
Product : Arcus Integration
Purpose : Data structure for the Capita Portal logout service
Notes :
 */
public with sharing class ArcI_DataSignOnLogout extends arcshared.ArcI_DataMain{
    
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