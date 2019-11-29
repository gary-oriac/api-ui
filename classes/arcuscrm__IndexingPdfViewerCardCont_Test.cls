@isTest
public with sharing class IndexingPdfViewerCardCont_Test {

    @isTest
    static void domainIsReturned() {
        System.assertEquals(
            System.Url.getSalesforceBaseUrl().toExternalForm(), 
            IndexingPdfViewerCardCont.getDomain()
        );
    }
}