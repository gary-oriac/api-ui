global with sharing class ArcI_DataMODGOVMps extends ArcI_DataMODGOVCommon
{
	//data out
	global Boolean bIsMPs;

    //data in
    global List<Member> mpsList;


	//data validation
	public override Boolean validate()
	{
        System.debug('<ARCUS - ArcI_DataMODGOVMps> starting validation...');
		Boolean result = bIsMPs != null & bIsMPs == true ? true : false;
        System.debug('<ARCUS - ArcI_DataMODGOVMps> Is input data valid: ' + result);

        return result;
	}

}