public with sharing class ArcI_ServiceMyArea
{
   public static String getMyAreaBinsAndCtaxData(ArcI_DataMyArea pData)
    {
        if(pData.validate())
        {
            new ArcI_ConnMyAreaMain().invoke(pData);
        }

        System.debug('<ArcI_ServiceMyArea.getMyAreaBinsAndCtaxData()> pData: ' + JSON.serialize(pData));

   		return JSON.serialize(pData);
    }
}