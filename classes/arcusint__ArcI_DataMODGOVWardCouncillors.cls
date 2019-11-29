global class ArcI_DataMODGOVWardCouncillors extends ArcI_DataMODGOVCommon 
{
    //data out
    //**none at present**

    //data in
    global List<Ward> wardsList;

    //helper classes & methods
    global class Ward
    {
        global String wardTitle;
        global List<Member> wardCouncillorsList;
    }
}