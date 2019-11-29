public with sharing class ArcI_ConnMODGOVMps_Mock extends arcshared.ArcI_ConnMain_Mock
{
    public override String getResponseBody(ResponseType pResponseType)
    {
        return 
            '<?xml version="1.0" encoding="utf-8"?>'+
            '<mpswards membertype="MP">'+
                '<mps count=" 1">'+
                    '<mp>'+
                        '<mpid>111</mpid>'+
                        '<fullusername>Stewie Griffin</fullusername>'+
                        '<photosmallurl>http://www.folkestone-hythe.gov.uk/moderngov/UserData/4/9/2/Info00000111/smallpic.jpg</photosmallurl>'+
                        '<photobigurl>http://www.folkestone-hythe.gov.uk/moderngov/UserData/4/9/2/Info00000111/bigpic.jpg</photobigurl>'+
                        '<politicalpartytitle>Conservative</politicalpartytitle>'+
                        '<districttitle>'+
                        '</districttitle>'+
                        '<representing>'+
                        '</representing>'+
                        '<keyposts>'+
                        '</keyposts>'+
                        '<workaddress>'+
                            '<line1>House of Commons</line1>'+
                            '<line2>Drummer Street</line2>'+
                            '<line3>The Drummers Yard</line3>'+
                            '<line4>London</line4>'+
                            '<postcode>SW1A 0AA</postcode>'+
                            '<phone>03333 333333</phone>'+
                            '<mobile>077777777777</mobile>'+
                            '<email>stewie.griffin.mp@parliament-test.uk</email>'+
                        '</workaddress>'+
                        '<homeaddress>'+
                            '<line1>Stewie And Co. Conservative Association</line1>'+
                            '<line2>4 West Griffin Gardens</line2>'+
                            '<line3>Folkestone</line3>'+
                            '<postcode>CT20 1SP</postcode>'+
                            '<phone>04444 4444444</phone>'+
                        '</homeaddress>'+
                        '<wards>'+
                        '</wards>'+
                    '</mp>'+
                '</mps>'+
            '</mpswards>';
    }
}