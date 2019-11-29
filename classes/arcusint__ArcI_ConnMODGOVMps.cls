public with sharing class ArcI_ConnMODGOVMps extends ArcI_ConnMODGOVMain
{
    public override String getWebserviceName()
    {
        return '/GetMpOrMepsAndWards?bIsMPs=' + getMpsData().bIsMPs;
    }

    public override void parseResponseBody(Dom.Document responseBodyDocument)
    {
        System.debug('<ArcI_ConnMODGOVMps.parseResponseBody()> start...');

        Dom.XmlNode mpsNode = responseBodyDocument.getRootElement().getChildElement('mps', null);

        // Loop over the mps
        List<ArcI_DataMODGOVCommon.Member> mpsList = new List<ArcI_DataMODGOVCommon.Member>();

        if(mpsNode != null)
        {
            for(Dom.XmlNode currentMpNode: mpsNode.getChildElements())
            {
                //instantiate & add the member to list
                mpsList.add(instantiateNewMember(currentMpNode));
                //move to the next MP...
            }
        }
        // System.debug('<ArcI_ConnMODGOVMps.parseResponseBody()> mpsList.size: ' + mpsList.size());
        getMpsData().mpsList = mpsList;
    }
}