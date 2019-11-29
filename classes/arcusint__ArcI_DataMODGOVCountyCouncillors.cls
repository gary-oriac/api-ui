global with sharing class ArcI_DataMODGOVCountyCouncillors extends ArcI_DataMODGOVCommon
{
	//data out
	global String sShortName;
	global String sOrder;

    //data in
    global List<Member> countyCouncillorsList;


	//data validation
	public override Boolean validate()
	{
        System.debug('<ARCUS - ArcI_DataCountyCouncillors> starting validation...');
		Boolean result = (String.isNotBlank(sShortName) && String.isNotBlank(sOrder)) ? true : false;
        System.debug('<ARCUS - ArcI_DataCountyCouncillors> Is input data valid: ' + result);

        return result;
	}

}