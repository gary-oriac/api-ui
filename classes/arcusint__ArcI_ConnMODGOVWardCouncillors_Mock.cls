public with sharing class ArcI_ConnMODGOVWardCouncillors_Mock extends arcshared.ArcI_ConnMain_Mock
{
    public override String getResponseBody(ResponseType pResponseType)
    {
        return
            '<?xml version="1.0" encoding="utf-8"?>'+
            '<councillorsbyward>'+
                '<wards>'+
                    '<ward>'+
                        '<wardtitle>Broadmead Ward</wardtitle>'+
                        '<councillors>'+
                            '<councillorcount> 1</councillorcount>'+
                            '<councillor>'+
                                '<councillorid>123</councillorid>'+
                                '<fullusername>Councillor Mrs Blue Berry</fullusername>'+
                                '<photosmallurl>http://www.test.gov.uk/moderngov/UserData/3/8/3/Info00000123/smallpic.jpg</photosmallurl>'+
                                '<photobigurl>http://www.test.gov.uk/moderngov/UserData/3/8/3/Info00000123/bigpic.jpg</photobigurl>'+
                                '<politicalpartytitle>Conservative</politicalpartytitle>'+
                                '<districttitle>'+
                                '</districttitle>'+
                                '<representing>'+
                                '</representing>'+
                                '<keyposts>'+
                                '</keyposts>'+
                                '<workaddress>'+
                                    '<email>BlueCllr.Berry@test.gov.uk</email>'+
                                '</workaddress>'+
                                '<homeaddress>'+
                                    '<line1>123 Birkdale Drive</line1>'+
                                    '<line2>Folkestone, Kent</line2>'+
                                    '<line4>CT19 5LP</line4>'+
                                    '<phone>01234 567890</phone>'+
                                '</homeaddress>'+
                            '</councillor>'+
                        '</councillors>'+
                    '</ward>'+
                    '<ward>'+
                        '<wardtitle>Cheriton Ward</wardtitle>'+
                        '<councillors>'+
                            '<councillorcount> 2</councillorcount>'+
                            '<councillor>'+
                                '<councillorid>789</councillorid>'+
                                '<fullusername>Councillor John Doe</fullusername>'+
                                '<photosmallurl>http://www.test.gov.uk/moderngov/UserData/9/8/3/Info00000789/smallpic.jpg</photosmallurl>'+
                                '<photobigurl>http://www.test.gov.uk/moderngov/UserData/9/8/3/Info00000789/bigpic.jpg</photobigurl>'+
                                '<politicalpartytitle>Conservative</politicalpartytitle>'+
                                '<districttitle>'+
                                '</districttitle>'+
                                '<representing>'+
                                '</representing>'+
                                '<keyposts>'+
                                '</keyposts>'+
                                '<workaddress>'+
                                    '<mobile>07000 123456</mobile>'+
                                    '<email>john.doe@test.gov.uk</email>'+
                                '</workaddress>'+
                                '<homeaddress>'+
                                    '<line1>777 Blenheim Place</line1>'+
                                    '<line2>Coolinge Lane</line2>'+
                                    '<line3>Folkestone, Kent</line3>'+
                                    '<postcode>CT20 3RJ</postcode>'+
                                    '<phone>01111 111111</phone>'+
                                    '<mobile>07000 654321</mobile>'+
                                '</homeaddress>'+
                            '</councillor>'+
                            '<councillor>'+
                                '<councillorid>987</councillorid>'+
                                '<fullusername>Councillor Peter Griffin</fullusername>'+
                                '<photosmallurl>http://www.test.gov.uk/moderngov/UserData/4/4/1/Info00000987/smallpic.jpg</photosmallurl>'+
                                '<photobigurl>http://www.test.gov.uk/moderngov/UserData/4/4/1/Info00000987/bigpic.jpg</photobigurl>'+
                                '<politicalpartytitle>Conservative</politicalpartytitle>'+
                                '<districttitle>'+
                                '</districttitle>'+
                                '<representing>'+
                                '</representing>'+
                                '<keyposts>'+
                                '</keyposts>'+
                                '<workaddress>'+
                                    '<email>peter.griffin@test.gov.uk</email>'+
                                '</workaddress>'+
                                '<homeaddress>'+
                                    '<line1>999 Shaftesbury Avenue</line1>'+
                                    '<line2>Cheriton</line2>'+
                                    '<line3>Folkestone, Kent</line3>'+
                                    '<postcode>CT19 4LX</postcode>'+
                                    '<phone>02222 222222</phone>'+
                                '</homeaddress>'+
                                '<termsofoffice>'+
                                    '<termofoffice>'+
                                        '<startdate>unspecified</startdate>'+
                                        '<enddate>11/05/2015</enddate>'+
                                    '</termofoffice>'+
                                    '<termofoffice>'+
                                        '<startdate>08/05/2019</startdate>'+
                                        '<enddate>unspecified</enddate>'+
                                    '</termofoffice>'+
                                '</termsofoffice>'+
                            '</councillor>'+
                        '</councillors>'+
                    '</ward>'+
                '</wards>'+
            '</councillorsbyward>';
    }
}