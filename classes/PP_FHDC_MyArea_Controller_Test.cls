@isTest
public with sharing class PP_FHDC_MyArea_Controller_Test
{
    static Decimal MIN_X_COORD = 80000.00;
	static Decimal MAX_X_COORD = 656100.00;

	static Decimal MIN_Y_COORD = 5000.00;
	static Decimal MAX_Y_COORD = 657700.00;

	static Decimal generateRandomValidXCoordinate(){
		return (Math.random() * (MAX_X_COORD-MIN_X_COORD) + MIN_X_COORD).setScale(2);
	}
	static Decimal generateRandomValidYCoordinate(){
		return (Math.random() * (MAX_Y_COORD-MIN_Y_COORD) + MIN_Y_COORD).setScale(2);
	}
    @TestSetup
    static void createTestData(){

        Id syncedLocationRtId = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'arcusgazetteer__Location__c' AND Name = 'Synced' LIMIT 1].Id;

        arcusgazetteer__BLPU__c blpu = new arcusgazetteer__BLPU__c(
            arcusgazetteer__UPRN__c = '1234',
            arcusgazetteer__Logical_Status__c = '1',
            arcusgazetteer__X_Coordinate__c = generateRandomValidXCoordinate(),
            arcusgazetteer__Y_Coordinate__c = generateRandomValidYCoordinate(),
            arcusgazetteer__Ward_Name__c = 'Unknown'
        );

        insert blpu;
        System.assertNotEquals(null, blpu.Id);

        arcusgazetteer__Location__c location = new arcusgazetteer__Location__c(
            arcusgazetteer__Address_Line__c = 'new address',
            arcusgazetteer__UPRN__c = '1234',
            arcusgazetteer__X_Coordinate__c = blpu.arcusgazetteer__X_Coordinate__c,
            arcusgazetteer__Y_Coordinate__c = blpu.arcusgazetteer__Y_Coordinate__c,
            arcusgazetteer__Ward__c = 'Unknown',
            RecordTypeId = syncedLocationRtId,
            arcusgazetteer__BLPU__c = blpu.Id
        );
        insert location;
        System.assertNotEquals(null, location.Id);

        Contact testContact = new Contact(FirstName = 'MyAreTestF', LastName = 'MyAreaTestL');
        insert testContact;
        System.assertNotEquals(null, testContact.Id);
        
        arcusgazetteer__Location_Link__c link = new arcusgazetteer__Location_Link__c(
			arcusgazetteer__Contact__c = testContact.Id,
			// arcusgazetteer__Correspondence_Address__c = isCorrespondence,
			arcusgazetteer__Location__c = location.Id
		);
        insert link;
        System.assertNotEquals(null, link.Id);

    }

    @isTest
    static void testRequestLatestMyAreaData_createNewRecords_success()
    {
        //
        contact c = [SELECT Id FROM Contact WHERE FirstName = 'MyAreTestF'];
        System.assertNotEquals(null, c.Id);

        arcusgazetteer__BLPU__c relatedBlpu = [
            SELECT Id, Council_Tax_Band__c, Garden_Waste_Route__c, Garden_Waste_Route__r.Next_Execution_Date__c, Landfill_Waste_Route__c, Landfill_Waste_Route__r.Next_Execution_Date__c, Recycling_Waste_Route__c, Recycling_Waste_Route__r.Next_Execution_Date__c//, Food_Waste_Route__c, Food_Waste_Route__r.Next_Execution_Date__c
            FROM arcusgazetteer__BLPU__c
            LIMIT 1
        ];
        System.assertNotEquals(null, relatedBlpu.Id);
        System.assertEquals(null, relatedBlpu.Council_Tax_Band__c);

        //set the mock for the api callout
        ArcI_ConnMyAreaMain_Mock testMock = new ArcI_ConnMyAreaMain_Mock();
        testMock.setAsTestMock();

        System.assert(null != [SELECT Id FROM Council_Tax_Band__c]);

        //Act
        System.assertEquals('success', PP_FHDC_MyArea_Controller.requestLatestMyAreaData(c.Id));
        relatedBlpu = [
            SELECT Id, Council_Tax_Band__c, Garden_Waste_Route__c, Garden_Waste_Route__r.Next_Execution_Date__c, Landfill_Waste_Route__c, Landfill_Waste_Route__r.Next_Execution_Date__c, Recycling_Waste_Route__c, Recycling_Waste_Route__r.Next_Execution_Date__c
            FROM arcusgazetteer__BLPU__c
            WHERE Id = :relatedBlpu.Id
        ];
        System.assertNotEquals(null, relatedBlpu.Council_Tax_Band__c);
        System.assertNotEquals(null, relatedBlpu.Garden_Waste_Route__c);
        System.assertNotEquals(null, relatedBlpu.Landfill_Waste_Route__c);
        System.assertNotEquals(null, relatedBlpu.Recycling_Waste_Route__c);

    }

     @isTest
    static void testRequestLatestMyAreaData_updateExistingRecords_success()
    {
        //
        contact c = [SELECT Id FROM Contact WHERE FirstName = 'MyAreTestF'];
        System.assertNotEquals(null, c.Id);

        arcusgazetteer__BLPU__c relatedBlpu = [
            SELECT Id, Council_Tax_Band__c, Garden_Waste_Route__c, Garden_Waste_Route__r.Next_Execution_Date__c, Landfill_Waste_Route__c, Landfill_Waste_Route__r.Next_Execution_Date__c, Recycling_Waste_Route__c, Recycling_Waste_Route__r.Next_Execution_Date__c//, Food_Waste_Route__c, Food_Waste_Route__r.Next_Execution_Date__c
            FROM arcusgazetteer__BLPU__c
            LIMIT 1
        ];
        System.assertNotEquals(null, relatedBlpu.Id);
        System.assertEquals(null, relatedBlpu.Council_Tax_Band__c);

        //set the mock for the api callout
        ArcI_ConnMyAreaMain_Mock testMock = new ArcI_ConnMyAreaMain_Mock();
        testMock.setAsTestMock();

        System.assert(null != [SELECT Id FROM Council_Tax_Band__c]);

        //Act
        System.assertEquals('success', PP_FHDC_MyArea_Controller.requestLatestMyAreaData(c.Id));
        relatedBlpu = [
            SELECT Id, Council_Tax_Band__c, Garden_Waste_Route__c, Garden_Waste_Route__r.Next_Execution_Date__c, Landfill_Waste_Route__c, Landfill_Waste_Route__r.Next_Execution_Date__c, Recycling_Waste_Route__c, Recycling_Waste_Route__r.Next_Execution_Date__c
            FROM arcusgazetteer__BLPU__c
            WHERE Id = :relatedBlpu.Id
        ];
        System.assertNotEquals(null, relatedBlpu.Council_Tax_Band__c);
        System.assertNotEquals(null, relatedBlpu.Garden_Waste_Route__c);
        System.assertNotEquals(null, relatedBlpu.Landfill_Waste_Route__c);
        System.assertNotEquals(null, relatedBlpu.Recycling_Waste_Route__c);

    }

    @isTest
    static void testRefreshCouncillorsData_countyCouncillorsOnly_Success()
    {
		/*arcusint.*/ArcI_ConnMODGOVCountyCouncillors_Mock testMock = new /*arcusint.*/ArcI_ConnMODGOVCountyCouncillors_Mock();
        testMock.setAsTestMock();

        List<Councillor_Details__c> testCouncillors = [SELECT Id, CreatedDate FROM Councillor_Details__c];
        System.assert(testCouncillors.size() == 0);

        //Act & Assert
        System.assertEquals('success', PP_FHDC_MyArea_Controller.refreshCouncillorsData());

        testCouncillors = [SELECT Id, CreatedDate FROM Councillor_Details__c];
        System.assert(testCouncillors.size() > 0);
    }

    
    @isTest
    static void testRefreshCouncillorsData_wardCouncillorsOnly_Success()
    {
		/*arcusint.*/ArcI_ConnMODGOVWardCouncillors_Mock testMock = new /*arcusint.*/ArcI_ConnMODGOVWardCouncillors_Mock();
        testMock.setAsTestMock();

        List<Councillor_Details__c> testCouncillors = [SELECT Id, CreatedDate FROM Councillor_Details__c];
        System.assert(testCouncillors.size() == 0);

        System.assertEquals('success', PP_FHDC_MyArea_Controller.refreshCouncillorsData());

        testCouncillors = [SELECT Id, CreatedDate FROM Councillor_Details__c];
        System.assert(testCouncillors.size() > 0);
    }

    
    @isTest
    static void testRefreshCouncillorsData_mpsOnly_Success()
    {
		/*arcusint.*/ArcI_ConnMODGOVMps_Mock testMock = new /*arcusint.*/ArcI_ConnMODGOVMps_Mock();
        testMock.setAsTestMock();

        List<Councillor_Details__c> testCouncillors = [SELECT Id, CreatedDate FROM Councillor_Details__c];
        System.assert(testCouncillors.size() == 0);

        System.assertEquals('success', PP_FHDC_MyArea_Controller.refreshCouncillorsData());

        testCouncillors = [SELECT Id, CreatedDate FROM Councillor_Details__c];
        System.assert(testCouncillors.size() > 0);
    }


    class ArcI_ConnMODGOVCountyCouncillors_Mock extends arcshared.ArcI_ConnMain_Mock
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

    class ArcI_ConnMODGOVWardCouncillors_Mock extends arcshared.ArcI_ConnMain_Mock
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

    class ArcI_ConnMODGOVMps_Mock extends arcshared.ArcI_ConnMain_Mock
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

}