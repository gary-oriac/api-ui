@isTest
public with sharing class PR_ViewConsultationsCont_Test {
	@isTest
	static void testGetConfigurations() {
		Test.startTest();
		Map<String, Object> result = PR_ViewConsultationsCont.getConfigurations('PR_ConsulteeService_Mock', 'testConfig', 'testFilter');
		Test.stopTest();

		System.assertEquals(true, result != null, 'Should return none null values as we expect no exception to happen and return mock values');
	}

	@isTest
	static void testMockedImplementations() {
		PR_ConsulteeService_Mock mockClass = new PR_ConsulteeService_Mock();
		Test.startTest();
		mockClass.saveComment(null, null, null);
		Boolean result = mockClass.hasConsultationRequest(null);
		Test.stopTest();
		System.assertEquals(true, result);
	}
}