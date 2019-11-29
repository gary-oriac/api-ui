/*
Company    :    Arcus Global
Product    :    Arcus DSH (Lightning DSH Core)
Purpose    :    Test class for Council Tax Homepage Widget
Notes      :           
*/
@isTest
private class DSHLC_WidgetCouncilTaxCont_Test {

  @isTest
	private static void testGetCouncilTaxBandDetailsWithRecordId() {

		List<Council_Tax_Band__c> testBandDetails = new List<Council_Tax_Band__c> {
			new Council_Tax_Band__c(
                Name = '2222/3333-Test A',
                Council_Tax_Band__c = 'A',
                Council_Tax_Year__c = '2222/3333',
                Council_Tax_Amount__c = 2000,
                County_Council_Amount__c  = 1567,
                District_Council_Amount__c  = 234,
                Fire_And_Rescue_Amount__c  = 123,
                Police_And_Crime_Amount__c = 678,
                Social_Care_Amount__c = 345, 
                Special_1_Amount__c = 20, 
                Town_Council_Amount__c = 100 
			)
		};
		insert testBandDetails;

		arcusgazetteer__BLPU__c blpu = new arcusgazetteer__BLPU__c(
			Council_Tax_Band__c = 'A'
		);
		insert blpu;

		arcusgazetteer__Location__c location = new arcusgazetteer__Location__c(
        	Name ='test street',
			arcusgazetteer__BLPU__c = blpu.Id
        );
        insert location;

        Contact testContact = new Contact(
        	LastName = 'test',
        	Email = 'test.user@DSHLCWidgetCouncilTaxCont.test.com',
        	arcusgazetteer__Mailing_Address__c = location.Id
        );
        insert testContact;


        Test.startTest();
        	List<Council_Tax_Band__c> result = DSHLC_WidgetCouncilTaxCont.getCouncilTaxBandDetails(testContact.Id);
        Test.stopTest();

        System.assertEquals('A', result[0].Council_Tax_Band__c, 'Wrong band, it should be A');
        System.assertEquals('2222/3333', result[0].Council_Tax_Year__c, 'Wrong year, it should be 2222/3333');
        System.assertEquals(2000, result[0].Council_Tax_Amount__c, 'Wrong amount for council tax, it should be 2000');
	}


	  @isTest
	private static void testGetCouncilTaxBandDetailsWithLoggedInUser() {

		List<Council_Tax_Band__c> testBandDetails = new List<Council_Tax_Band__c> {
			new Council_Tax_Band__c(
                Name = '2222/3333-Test D',
                Council_Tax_Band__c = 'D',
                Council_Tax_Year__c = '2222/3333',
                Council_Tax_Amount__c = 3000,
                County_Council_Amount__c  = 2567,
                District_Council_Amount__c  = 334,
                Fire_And_Rescue_Amount__c  = 223,
                Police_And_Crime_Amount__c = 778,
                Social_Care_Amount__c = 445, 
                Special_1_Amount__c = 30, 
                Town_Council_Amount__c = 200 
			)
		};
		insert testBandDetails;

		arcusgazetteer__BLPU__c blpu = new arcusgazetteer__BLPU__c(
			Council_Tax_Band__c = 'D'
		);
		insert blpu;

		arcusgazetteer__Location__c location = new arcusgazetteer__Location__c(
        	Name ='test2 street',
			arcusgazetteer__BLPU__c = blpu.Id
        );
        insert location;

        User loggedInUser = DSHLC_TestUtility.createCommunityUser();

        Contact loggedInUserContact = new Contact(
        	Id = loggedInUser.ContactId,
        	Email = 'test2.user@DSHLCWidgetBinCollectionCont.Test.com',
        	arcusgazetteer__Mailing_Address__c = location.Id
        );
        update loggedInUserContact;

        String testRecordId = null;

        System.runAs(loggedInUser) {
	        Test.startTest();
	        	List<Council_Tax_Band__c> result = DSHLC_WidgetCouncilTaxCont.getCouncilTaxBandDetails(testRecordId);
	        Test.stopTest();

	        System.assertEquals('D', result[0].Council_Tax_Band__c, 'Wrong band, it should be D');
	        System.assertEquals(223, result[0].Fire_And_Rescue_Amount__c, 'Wrong amount for fire and rescue, it should be 233');
		}
	}


}