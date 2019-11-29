@isTest
private class InsertUnpackagedRecords_Test {
	
	@isTest static void testInsertingCongaTemplateRecords() {
		Integer preCount = [SELECT count() FROM APXTConga4__Conga_Template__c];

		InsertUnpackagedRecords.insertCongaTemplates();

		System.assertEquals(InsertUnpackagedRecords.s_CongaTemplatesAmount, [SELECT count() FROM APXTConga4__Conga_Template__c]-preCount);
	}
	
	@isTest static void testInsertingCongaQueryRecords() {
		Integer preCount = [SELECT count() FROM APXTConga4__Conga_Merge_Query__c];

		InsertUnpackagedRecords.insertCongaQueries();

		System.assertEquals(InsertUnpackagedRecords.s_CongaQueriesAmount, [SELECT count() FROM APXTConga4__Conga_Merge_Query__c]-preCount);
	}	

}