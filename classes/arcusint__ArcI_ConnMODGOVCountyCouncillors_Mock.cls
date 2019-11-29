public with sharing class ArcI_ConnMODGOVCountyCouncillors_Mock extends arcshared.ArcI_ConnMain_Mock
{
    public override String getResponseBody(ResponseType pResponseType)
    {
        return 
            '<?xml version="1.0" encoding="utf-8"?>'+
            '<memberlistby0>'+
                '<members>'+
                    '<membercount> 2</membercount>'+
                    '<member>'+
                        '<memberid>123</memberid>'+
                        '<fullusername>Miss Piggy</fullusername>'+
                        '<photosmallurl>http://www.test.gov.uk/moderngov/UserData/5/5/3/Info00000123/smallpic.jpg</photosmallurl>'+
                        '<photobigurl>http://www.test.gov.uk/moderngov/UserData/5/5/3/Info00000123/bigpic.jpg</photobigurl>'+
                        '<politicalpartytitle>Conservative</politicalpartytitle>'+
                        '<districttitle>'+
                        '</districttitle>'+
                        '<representing>Elham Valley</representing>'+
                        '<keyposts>Regional representative</keyposts>'+
                        '<workaddress>'+
                            '<phone>01622 694434</phone>'+
                            '<email>miss.piggy@test.gov.uk</email>'+
                        '</workaddress>'+
                        '<homeaddress>'+
                        '</homeaddress>'+
                    '</member>'+
                    '<member>'+
                        '<memberid>321</memberid>'+
                        '<fullusername>Mr Kermitt De Frog</fullusername>'+
                        '<photosmallurl>http://www.test.gov.uk/moderngov/UserData/7/6/9/Info0000321/smallpic.png</photosmallurl>'+
                        '<photobigurl>http://www.test.gov.uk/moderngov/UserData/7/6/9/Info0000321/bigpic.png</photobigurl>'+
                        '<politicalpartytitle>Conservative</politicalpartytitle>'+
                        '<districttitle>'+
                        '</districttitle>'+
                        '<representing>Romney Marsh</representing>'+
                        '<keyposts>'+
                        '</keyposts>'+
                        '<workaddress>'+
                            '<email>mr.kermitt@test.gov.uk</email>'+
                        '</workaddress>'+
                        '<homeaddress>'+
                        '</homeaddress>'+
                    '</member>'+
                '</members>'+
            '</memberlistby0>';
    }   
}