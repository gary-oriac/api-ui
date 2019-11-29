public with sharing class ArcI_ConnMODGOVWardCouncillors extends ArcI_ConnMODGOVMain
{
    public override String getWebserviceName()
    {
        return '/GetCouncillorsByWard';
    }

    public override void parseResponseBody(Dom.Document responseBodyDocument)
    {
        System.debug('<ArcI_ConnMODGOVWardCouncillors.parseResponseBody()> start...');

        Dom.XmlNode wardsNode = responseBodyDocument.getRootElement().getChildElement('wards', null);

        // Loop over the wards
        List<ArcI_DataMODGOVWardCouncillors.Ward> wardsList = new List<ArcI_DataMODGOVWardCouncillors.Ward>();
        if(wardsNode != null)
        {            
            for(Dom.XmlNode currentWardNode: wardsNode.getChildElements())
            {
                ArcI_DataMODGOVWardCouncillors.Ward newWard = new ArcI_DataMODGOVWardCouncillors.Ward();
                List<ArcI_DataMODGOVCommon.Member> wardCouncillorsList = new List<ArcI_DataMODGOVCommon.Member>();

                for(Dom.XmlNode currentWardElementNode: currentWardNode.getChildElements())
                {
                    if(currentWardElementNode.getName() == 'wardtitle')
                    {
                        newWard.wardTitle = currentWardElementNode.getText();
                    }
                    else
                    {//we are dealing with councillors node
                        for(Dom.XmlNode currentCouncillorNode: currentWardElementNode.getChildElements())
                        {
                            if(currentCouncillorNode.getName() == 'councillor')
                            {
                                //instantiate & add the member to list
                                wardCouncillorsList.add(instantiateNewMember(currentCouncillorNode));
                            }
                        }
                        //populate the current ward councillors list
                        if(wardCouncillorsList.size() > 0) {newWard.wardCouncillorsList = wardCouncillorsList;}
                        //move to the next ward...
                    }    
                }
                //add the current ward to the list
                wardsList.add(newWard);
            }
        }
        // System.debug('ward councillors list size: ' + newWard.wardCouncillorsList.size());
        //populate the global data
        getCouncillorsByWardData().wardsList = wardsList;
    }
}