/*
Company : Arcus Global
Product : Arcus Integration Architecture
Purpose : A 'one-stop-shop' Service class for utilising the ModGov APIs integration. It is part of the unlocked 'arcus-integration' package
Notes :
 */
global with sharing class ArcI_ServiceMODGOV
{
    global static String getCountyCouncillors(ArcI_DataMODGOVCountyCouncillors pData)
    {
        if(pData.validate())
        {
            new ArcI_ConnMODGOVCountyCouncillors().invoke(pData);
        }

        System.debug('<ArcI_ServiceMODGOV.getCountyCouncillors()> pData: ' + JSON.serialize(pData));

   		return JSON.serialize(pData);
    }

    global static String getWardCouncillors(ArcI_DataMODGOVWardCouncillors pData)
    {
        if(pData.validate())
        {
            new ArcI_ConnMODGOVWardCouncillors().invoke(pData);
        }

        System.debug('<ArcI_ServiceMODGOV.getWardCouncillors()> pData: ' + JSON.serialize(pData));

   		return JSON.serialize(pData);
    }

    global static String getMps(ArcI_DataMODGOVMps pData)
    {
        if(pData.validate())
        {
            new ArcI_ConnMODGOVMps().invoke(pData);
        }

        System.debug('<ArcI_ServiceMODGOV.getMps()> pData: ' + JSON.serialize(pData));

   		return JSON.serialize(pData);
    }
}