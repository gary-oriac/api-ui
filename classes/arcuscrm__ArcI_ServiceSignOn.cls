/*
Company : Arcus Global
Product : Arcus Integration
Purpose : Main service class to access single-sign-on integrations
Notes :
 */
public with sharing class ArcI_ServiceSignOn 
{
    public static String login(arcuscrm.ArcI_DataSignOnLogin pData)
    {
        if(pData.validate()) new arcuscrm.ArcI_ConnSignOnCAPLogin().invoke(pData);
        return JSON.serialize(pData);
    }

    public static String getProfile(arcuscrm.ArcI_DataSignOnProfile pData)
    {
        if(pData.validate()) new arcuscrm.ArcI_ConnSignOnCAPProfile().invoke(pData);
        return JSON.serialize(pData);
    }

    public static String getLinkedServices(arcuscrm.ArcI_DataSignOnLinkedServices pData)
    {
        if(pData.validate()) new arcuscrm.ArcI_ConnSignOnCAPLinkedServices().invoke(pData);
        return JSON.serialize(pData);
    }

    public static String getServiceToken(arcuscrm.ArcI_DataSignOnGetServiceToken pData)
    {
        if(pData.validate()) new arcuscrm.ArcI_ConnSignOnCAPGetServiceToken().invoke(pData);
        return JSON.serialize(pData);
    }

    public static String logout(arcuscrm.ArcI_DataSignOnLogout pData)
    {
        if(pData.validate()) new arcuscrm.ArcI_ConnSignOnCAPLogout().invoke(pData);
        return JSON.serialize(pData);
    }
}