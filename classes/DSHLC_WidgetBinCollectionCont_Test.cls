/*
Company    :    Arcus Global
Product    :    Arcus DSHLC
Purpose    :    Test class for DSHLC_WidgetBinCollectionCont
Modified   :
*/
@isTest
private class DSHLC_WidgetBinCollectionCont_Test {

	@isTest
	private static void testGetRouteDetailWithRecordId() {
		Date today = System.today();
		List<Route__c> routes = new List<Route__c> {
			new Route__c(
				Name = 'Landfill',
				Type_of_Round__c = 'Landfill',
				Next_Execution_Date__c = today,
				Previous_Scheduled_Date__c = today,
				Second_Execution_Date__c = today,
				Schedule_Day__c = 'Monday',
				Schedule_URL__c = 'https://account.arcusglobal.com',
				Route_Description__c = 'Landfill Monday'
			),
			new Route__c(
				Name = 'Recycling',
				Type_of_Round__c = 'Recycling',
				Next_Execution_Date__c = today,
				Previous_Scheduled_Date__c = today,
				Second_Execution_Date__c = today,
				Schedule_Day__c = 'Monday',
				Schedule_URL__c = 'https://account.arcusglobal.com',
				Route_Description__c = 'Recycling Monday'
			),
			new Route__c(
				Name = 'Food',
				Type_of_Round__c = 'Food',
				Next_Execution_Date__c = today,
				Previous_Scheduled_Date__c = today,
				Second_Execution_Date__c = today,
				Schedule_Day__c = 'Monday',
				Schedule_URL__c = 'https://account.arcusglobal.com',
				Route_Description__c = 'Food Monday'
			),
			new Route__c(
				Name = 'Garden',
				Type_of_Round__c = 'Garden',
				Next_Execution_Date__c = today,
				Previous_Scheduled_Date__c = today,
				Second_Execution_Date__c = today,
				Schedule_Day__c = 'Monday',
				Schedule_URL__c = 'https://account.arcusglobal.com',
				Route_Description__c = 'Garden Monday'
			)
		};
		insert routes;

		arcusgazetteer__BLPU__c blpu = new arcusgazetteer__BLPU__c(
			Landfill_Waste_Route__c = routes[0].Id,
			Recycling_Waste_Route__c = routes[1].Id,
			Food_Waste_Route__c = routes[2].Id,
			Garden_Waste_Route__c = routes[3].Id
		);
		insert blpu;

		arcusgazetteer__Location__c location = new arcusgazetteer__Location__c(
        	Name ='test street',
			arcusgazetteer__BLPU__c = blpu.Id
        );
        insert location;

        Contact testContact = new Contact(
        	LastName = 'test',
        	Email = 'test.user@DSHLC.WidgetBinCollectionCont.Test.com',
        	arcusgazetteer__Mailing_Address__c = location.Id
        );
        insert testContact;

        Test.startTest();
        	arcusgazetteer__Location__c result = DSHLC_WidgetBinCollectionCont.getRouteDetail(testContact.Id);
        Test.stopTest();

        System.assertEquals('Landfill', result.arcusgazetteer__BLPU__r.Landfill_Waste_Route__r.Type_of_Round__c, 'Wrong round type, it should be Landfill');

        System.assertEquals(today, result.arcusgazetteer__BLPU__r.Landfill_Waste_Route__r.Next_Execution_Date__c, 'Wrong date, it should be todays date');

        System.assertEquals('Monday', result.arcusgazetteer__BLPU__r.Recycling_Waste_Route__r.Schedule_Day__c, 'Wrong scheduled day, it should be Monday');

		System.assertEquals('https://account.arcusglobal.com', result.arcusgazetteer__BLPU__r.Garden_Waste_Route__r.Schedule_URL__c, 'Incorrect schedule URL returned, it should be the one set in the route record');
	}

	@isTest
	private static void testGetRouteDetailWithLoggedInUser() {
		Date today = System.today();
		List<Route__c> routes = new List<Route__c> {
			new Route__c(
				Name = 'Landfill',
				Type_of_Round__c = 'Landfill',
				Next_Execution_Date__c = today,
				Previous_Scheduled_Date__c = today,
				Second_Execution_Date__c = today,
				Schedule_Day__c = 'Monday',
				Schedule_URL__c = 'https://account.arcusglobal.com',
				Route_Description__c = 'Landfill Monday'
			),
			new Route__c(
				Name = 'Recycling',
				Type_of_Round__c = 'Recycling',
				Next_Execution_Date__c = today,
				Previous_Scheduled_Date__c = today,
				Second_Execution_Date__c = today,
				Schedule_Day__c = 'Monday',
				Schedule_URL__c = 'https://account.arcusglobal.com',
				Route_Description__c = 'Recycling Monday'
			),
			new Route__c(
				Name = 'Food',
				Type_of_Round__c = 'Food',
				Next_Execution_Date__c = today,
				Previous_Scheduled_Date__c = today,
				Second_Execution_Date__c = today,
				Schedule_Day__c = 'Monday',
				Schedule_URL__c = 'https://account.arcusglobal.com',
				Route_Description__c = 'Food Monday'
			),
			new Route__c(
				Name = 'Garden',
				Type_of_Round__c = 'Garden',
				Next_Execution_Date__c = today,
				Previous_Scheduled_Date__c = today,
				Second_Execution_Date__c = today,
				Schedule_Day__c = 'Monday',
				Schedule_URL__c = 'https://account.arcusglobal.com',
				Route_Description__c = 'Garden Monday'
			)
		};
		insert routes;

		arcusgazetteer__BLPU__c blpu = new arcusgazetteer__BLPU__c(
			Landfill_Waste_Route__c = routes[0].Id,
			Recycling_Waste_Route__c = routes[1].Id,
			Food_Waste_Route__c = routes[2].Id,
			Garden_Waste_Route__c = routes[3].Id
		);
		insert blpu;

		arcusgazetteer__Location__c location = new arcusgazetteer__Location__c(
        	Name ='test street',
			arcusgazetteer__BLPU__c = blpu.Id
        );
        insert location;


        User loggedInUser = DSHLC_TestUtility.createCommunityUser();

        Contact loggedInUserContact = new Contact(
        	Id = loggedInUser.ContactId,
        	Email = 'test.user@DSHLC.WidgetBinCollectionCont.Test.com',
        	arcusgazetteer__Mailing_Address__c = location.Id
        );
        update loggedInUserContact;

        String testRecordId = null;

        System.runAs(loggedInUser) {
	        Test.startTest();
	        	arcusgazetteer__Location__c result = DSHLC_WidgetBinCollectionCont.getRouteDetail(testRecordId);
	        Test.stopTest();

	        System.assertEquals('Recycling', result.arcusgazetteer__BLPU__r.Recycling_Waste_Route__r.Type_of_Round__c, 'Wrong round type, it should be Recycling');

	        System.assertEquals(today, result.arcusgazetteer__BLPU__r.Food_Waste_Route__r.Next_Execution_Date__c, 'Wrong date, it should be todays date');

	        System.assertEquals('Monday', result.arcusgazetteer__BLPU__r.Garden_Waste_Route__r.Schedule_Day__c, 'Wrong scheduled day, it should be Monday');

			System.assertEquals('https://account.arcusglobal.com', result.arcusgazetteer__BLPU__r.Landfill_Waste_Route__r.Schedule_URL__c, 'Incorrect schedule URL returned, it should be the one set in the route record');
    	}
	}

}