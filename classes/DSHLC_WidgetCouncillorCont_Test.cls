/*
Company    :    Arcus Global
Product    :    Arcus DSH (Lightning DSH Core)
Purpose    :    Test class for Councillor Homepage Widget
Notes      :
*/
@isTest
private class DSHLC_WidgetCouncillorCont_Test {
    @isTest
    private static void testGetContextWardCodeForLoggedInUser() {
        User communityUser = DSHLC_TestUtility.createCommunityUser();

        arcusgazetteer__Location__c location = new arcusgazetteer__Location__c(
			Name ='test street',
			arcusgazetteer__Ward_Name__c = 'TestWard1'
        );
        insert location;

        Contact communityContact = new Contact(
            Id = communityUser.ContactId,
            arcusgazetteer__Mailing_Address__c = location.Id
        );
        update communityContact;

        String result;
        System.runAs(communityUser) {
            Test.startTest();
            result = DSHLC_WidgetCouncillorCont.getContextWardCode(null);
            Test.stopTest();
        }

        System.assertEquals('TestWard1', result, 'Should return the ward as "TestWard1" as set on the address. Instead we have: ' + result);
    }

    @isTest
    private static void testGetContextWardCodeForContactRecord() {
        arcusgazetteer__Location__c location = new arcusgazetteer__Location__c(
			Name ='test street',
			arcusgazetteer__Ward_Name__c = 'TestWard2'
        );
        insert location;

        Contact testContact = new Contact(
            LastName = 'Tester1',
            arcusgazetteer__Mailing_Address__c = location.Id
        );
        insert testContact;

        Test.startTest();
        String result = DSHLC_WidgetCouncillorCont.getContextWardCode(testContact.Id);
        Test.stopTest();

        System.assertEquals('TestWard2', result, 'Should return the ward as "TestWard2" as set on the address. Instead we have: ' + result);
    }

    @isTest
    private static void testGetWardCodeToLabelMap() {
        Test.startTest();
        Map<String, String> result = DSHLC_WidgetCouncillorCont.getWardCodeToLabelMap();
        Test.stopTest();

        System.assertEquals(true, result != null, 'Should not get a null value returned');
        System.assertEquals(true, !result.isEmpty(), 'Should get a none empty mapping between ward code and label, instead we have an empty map');
    }

	@isTest
	private static void testGetCouncillorsDetails() {
		List<Councillor_Details__c> councillors = new List<Councillor_Details__c> {
			new Councillor_Details__c(
                Name = 'Cllr Test',
                Councillor_Email__c = 'Cllr.Test@test.test',
                Councillor_Image_URL__c = 'https://CllrTest.jpg',
                Councillor_Info_URL__c = 'https://www.test-info.com/CllrTest',
                Councillor_Phone__c  = '01234567890',
                Councillor_Type__c  = 'Test',
                Political_Party__c  = 'Test Party',
                Ward_Code__c = 'TestWard1'
			),
			new Councillor_Details__c(
                Name = 'Cllr Test 2',
                Councillor_Email__c = 'Cllr.Test2@test.test',
                Councillor_Image_URL__c = 'https://CllrTest2.jpg',
                Councillor_Info_URL__c = 'https://www.test-info.com/CllrTest2',
                Councillor_Phone__c  = '012345678922',
                Councillor_Type__c  = 'Test',
                Political_Party__c  = 'Anti-Test Party',
                Ward_Code__c = 'TestWard1'
			),
			new Councillor_Details__c(
                Name = 'Cllr Test 3',
                Councillor_Email__c = 'Cllr.Test3@test.test',
                Councillor_Image_URL__c = 'https://CllrTest3.jpg',
                Councillor_Info_URL__c = 'https://www.test-info.com/CllrTest3',
                Councillor_Phone__c  = '012345678933',
                Councillor_Type__c  = 'Test',
                Political_Party__c  = 'Conservatest Party',
                Ward_Code__c = ''
			),
			new Councillor_Details__c(
                Name = 'Cllr Test 4',
                Councillor_Email__c = 'Cllr.Test4@test.test',
                Councillor_Image_URL__c = 'https://CllrTest4.jpg',
                Councillor_Info_URL__c = 'https://www.test-info.com/CllrTest4',
                Councillor_Phone__c  = '012345678944',
                Councillor_Type__c  = 'MP',
                Political_Party__c  = 'UKTest Party',
                Ward_Code__c = ''
			)
		};
		insert councillors;

        Test.startTest();
        List<Councillor_Details__c> result = DSHLC_WidgetCouncillorCont.getCouncillorsDetails('TestWard1');
        Test.stopTest();

        System.assertEquals('TestWard1', result[0].Ward_Code__c, 'Wrong ward code, it should be TestWard1. Instead we have: ' + result[0].Ward_Code__c);
        System.assertEquals(3, result.size(), 'Incorrect number of records are returned, it should return 3 records which 2 have the same ward code and 1 is an MP. Instead we have: ' + result.size());
	}

    @isTest
    private static void testGetData() {
        Test.startTest();
        Map<String, Object> result = DSHLC_WidgetCouncillorCont.getData(null);
        Test.stopTest();

        System.assertEquals(true, result != null, 'Should not get a null value returned.');
        System.assertEquals(true, result.containsKey('wardCode'), 'Missing entry for ward code');
        System.assertEquals(true, result.containsKey('councillors'), 'Missing entry for councillors');
        System.assertEquals(true, result.containsKey('wardCodeToLabelMap'), 'Missing entry for the mapping between ward code and label');
    }
}