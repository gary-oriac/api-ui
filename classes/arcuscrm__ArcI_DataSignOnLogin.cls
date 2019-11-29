/*
Company : Arcus Global
Product : Arcus Integration
Purpose : Data structure for the Capita Portal login service
Notes :
 */
public with sharing class ArcI_DataSignOnLogin extends arcshared.ArcI_DataMain {
    //IN
    public String username {get; set;}
    
    /**
     * General validation logic
     */
    public override Boolean validate()
    {
        if (String.isNotBlank(username))
        {
            return true;
        }
        else 
        {
            processError(arcshared.ArcI_UtilityErrorManager.ERR_COD_GENERIC, 'username is mandatory');
            return false;
        }
    }
}