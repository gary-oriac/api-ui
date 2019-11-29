/*
Company : Arcus Global
Product : Arcus Integration Architecture
Purpose : A common data class used by the ModGov API integration classes. It is part of the unlocked 'arcus-integration' package
Notes :
 */
global abstract with sharing class ArcI_DataMODGOVCommon extends arcshared.ArcI_DataMain 
{    
	//data validation
	public virtual override Boolean validate(){ return true; }

    //helper classes & methods
    global class Member
    {
        global String memberId;
        global String fullUsername;
        global String photoSmallUrl;
        global String photoBigUrl;
        global String politicalPartyTitle;
        global String districtTitle;
        global String representing;
        global String keyPosts;
        global Address workAddress;
        global Address homeAddress;
        global List<TermOfOffice> termsOfOffice;
    }

    global class Address
    {
        global String line1;
        global String line2;
        global String line3;
        global String line4;
        global String postcode;
        global String phone;
        global String mobile;
        global String email;
    }

    global class TermOfOffice
    {
        global String startDate;
        global String endDate;
    }

}