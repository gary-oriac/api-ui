/*
Company : Arcus Global
Product : Arcus Integration
Purpose : Data structure for the Capita Portal Profile service
Notes :
 */
public with sharing class ArcI_DataSignOnProfile extends arcshared.ArcI_DataMain
{
    //IN/OUT (only one is IN, the other is OUT)
    public String username {get; set;}
    public String email {get; set;}
    
    //OUT
    public String ssid {get; set;}
    public String title {get; set;}
    public String forename {get; set;}
    public String middlename {get; set;}
    public String surname {get; set;}
    public String companyName {get; set;}

    /**
     * General validation logic
     */
    public override Boolean validate()
    {
        if (
            (String.isNotBlank(username) && String.isBlank(email))
             ||
            (String.isBlank(username) && String.isNotBlank(email))
           )
        {
            return true;
        }
        else
        {
            processError(arcshared.ArcI_UtilityErrorManager.ERR_COD_GENERIC, 'It is mandatory to set ONLY username or email');
            return false;
        }
    }

}