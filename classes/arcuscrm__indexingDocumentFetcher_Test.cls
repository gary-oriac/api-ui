@isTest
private with sharing class indexingDocumentFetcher_Test {

    private static Id configurationRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Document_Indexing_Area' AND sObjectType = 'arcshared__Configuration__c'].Id;
    private static Blob versionData = Blob.valueOf('a');

    @isTest
    private static void oneFileIsReturnedForOneCategory() {

        insert new List<ContentVersion> {
            new ContentVersion(
                Title = 'Test',
                Indexing_Category__c = 'CategoryOne',
                PathOnClient = 'test.txt',
                VersionData = versionData
            )
        };
        

        indexingDocumentFetcher fetcher = new indexingDocumentFetcher();
        List<indexingDocumentFetcher.Document> documents = fetcher.fetch();

        System.assertEquals(1, documents.size());
    }

    @isTest
    private static void twoFilesAreReturnedForTwoCategories() {
        insert new List<ContentVersion> {
            new ContentVersion(
                Title = 'TestOne',
                Indexing_Category__c = 'CategoryOne',
                PathOnClient = 'test.txt',
                VersionData = versionData
            ),
            new ContentVersion(
                Title = 'TestTwo',
                Indexing_Category__c = 'CategoryTwo',
                PathOnClient = 'test.txt',
                VersionData = versionData
            )
        };

        indexingDocumentFetcher fetcher = new indexingDocumentFetcher();
        List<indexingDocumentFetcher.Document> documents = fetcher.fetch();

        Set<String> categories = new Set<String>();
        for(indexingDocumentFetcher.Document document : documents) {
            categories.add(document.source);
        }

        System.assertEquals(2, categories.size());
    }

    @isTest
    private static void threeFilesAreReturnedForTwoCategories() {
        insert new List<ContentVersion> {
            new ContentVersion(
                Title = 'TestOne',
                Indexing_Category__c = 'CategoryOne',
                PathOnClient = 'test.txt',
                VersionData = versionData
            ),
            new ContentVersion(
                Title = 'TestTwo',
                Indexing_Category__c = 'CategoryTwo',
                PathOnClient = 'test.txt',
                VersionData = versionData
            ),
            new ContentVersion(
                Title = 'TestThree',
                Indexing_Category__c = 'CategoryTwo',
                PathOnClient = 'test.txt',
                VersionData = versionData
            )
        };

        indexingDocumentFetcher fetcher = new indexingDocumentFetcher();
        List<indexingDocumentFetcher.Document> documents = fetcher.fetch();

        Set<String> categories = new Set<String>();
        for(indexingDocumentFetcher.Document document : documents) {
            categories.add(document.source);
        }

        System.assertEquals(2, categories.size());
        System.assertEquals(3, documents.size());
    }

    @isTest
    private static void noFilesAreReturnedWhenMissingCategories() {
        insert new List<ContentVersion> {
            new ContentVersion(
                Title = 'TestOne',
                PathOnClient = 'test.txt',
                VersionData = versionData
            ),
            new ContentVersion(
                Title = 'TestTwo',
                PathOnClient = 'test.txt',
                VersionData = versionData
            )
        };

        indexingDocumentFetcher fetcher = new indexingDocumentFetcher();
        List<indexingDocumentFetcher.Document> documents = fetcher.fetch();

        System.assertEquals(0, documents.size());
    }

}