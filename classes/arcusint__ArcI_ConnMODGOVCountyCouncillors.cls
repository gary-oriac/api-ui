public with sharing class ArcI_ConnMODGOVCountyCouncillors extends ArcI_ConnMODGOVMain
{
    public override String getWebserviceName()
    {
        return '/GetMemberGroup?sShortName='+getCountyCouncillorsData().sShortName+'&sOrder='+getCountyCouncillorsData().sOrder;
    }

    public override void parseResponseBody(Dom.Document responseBodyDocument)
    {
        System.debug('<ArcI_ConnMODGOVCountyCouncillors.parseResponseBody()> start...');

        Dom.XmlNode membersNode = responseBodyDocument.getRootElement().getChildElement('members', null);
        // membersNode.removeChild('membercount');

        List<ArcI_DataMODGOVCommon.Member> newMembersList = new List<ArcI_DataMODGOVCommon.Member>();

        if(membersNode != null)
        {
            for(Dom.XmlNode currentMemberNode: membersNode.getChildElements())
            {
                if(currentMemberNode.getName() == 'member')
                {
                    //instantiate & add the member to list
                    newMembersList.add(instantiateNewMember(currentMemberNode));
                }
            }
        }
        // System.debug('<ArcI_ConnMODGOVCountyCouncillors.parseResponseBody()> newMembersList.size: ' + newMembersList.size());
        getCountyCouncillorsData().countyCouncillorsList = newMembersList;
    }

}