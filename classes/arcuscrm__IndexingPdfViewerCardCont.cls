public with sharing class IndexingPdfViewerCardCont {

	@AuraEnabled(cacheable=true)
	public static String getDomain() {
		return System.Url.getSalesforceBaseUrl().toExternalForm();
	}

}