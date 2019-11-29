@isTest
public with sharing class indexingDocumentIndexerCont_Test {
    
    private static Id configurationRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Document_Indexing_Area' AND sObjectType = 'arcshared__Configuration__c'].Id;

    @isTest
    private static void fileIsReturnedWithDefaultFetcher() {
        insert new ContentVersion(
            Title = 'TestOne',
            Indexing_Category__c = 'CategoryOne',
            PathOnClient = 'test.txt',
            VersionData = Blob.valueOf('a')
        );

        List<indexingDocumentFetcher.Document> documents = indexingDocumentIndexerCont.getDocuments(null);

        System.assertEquals(1, documents.size());
    }

    @isTest
    private static void fileIsReturnedWithCustomFetcherAsParameter() {
        List<indexingDocumentFetcher.Document> documents = indexingDocumentIndexerCont.getDocuments('indexingDocumentIndexerCont_Test.CustomFetcher');

        System.assertEquals(1, documents.size());
    }

    @isTest
    private static void fileIsReturnedWithCustomFetcherAsCustomSetting() {
        arcshared.AppConfigSupport.setSingleRecord(
            'DocumentIndexing', 
            new arcshared.AppConfigSupport.setting(
                'FetcherClass',
                'String',
                'indexingDocumentIndexerCont_Test.CustomFetcher',
                'indexingDocumentIndexerCont_Test.CustomFetcher',
                1,
                true,
                true
            )
        );
        arcshared.AppConfigSupport.refreshCache();

        List<indexingDocumentFetcher.Document> documents = indexingDocumentIndexerCont.getDocuments(null);

        System.assertEquals(1, documents.size());
    }

    @isTest
    private static void fileIsLinkedWithDefaultLinker() {
        ContentVersion version = new ContentVersion(
            Title = 'TestOne',
            Indexing_Category__c = 'CategoryOne',
            PathOnClient = 'test.txt',
            VersionData = Blob.valueOf('a')
        );
        insert version;

        Account account = new Account(Name = 'Blah');
        insert account;

        indexingDocumentIndexerCont.link(
            null, 
            new List<Id>{account.Id}, 
            version.Id
        );

        List<ContentDocumentLink> links = [
            SELECT Id 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId =: account.Id
        ];

        System.assertEquals(1, links.size());
    }

    @isTest
    private static void fileIsLinkedWithCustomLinkerAsParameter() {
        indexingDocumentIndexerCont.link(
            'indexingDocumentIndexerCont_Test.CustomLinker', 
            null, 
            null
        );

        List<Account> accounts = [
            SELECT Id 
            FROM Account
            WHERE Name = 'LINK'
        ];

        System.assertEquals(1, accounts.size());
    }

    @isTest
    private static void fileIsLinkedWithCustomLinkerAsCustomSetting() {
        arcshared.AppConfigSupport.setSingleRecord(
            'DocumentIndexing', 
            new arcshared.AppConfigSupport.setting(
                'LinkerClass',
                'String',
                'indexingDocumentIndexerCont_Test.CustomLinker',
                'indexingDocumentIndexerCont_Test.CustomLinker',
                1,
                true,
                true
            )
        );
        arcshared.AppConfigSupport.refreshCache();

        indexingDocumentIndexerCont.link(
            null, 
            null, 
            null
        );

        List<Account> accounts = [
            SELECT Id 
            FROM Account
            WHERE Name = 'LINK'
        ];

        System.assertEquals(1, accounts.size());
    }

    @isTest
    private static void oneConfigurationIsReturned() {
        insert new arcshared__Configuration__c(
            RecordTypeId = configurationRecordTypeId,
            arcshared__Enabled__c = true,
            arcshared__Action__c = '{"indexing_category":"Planning"}'
        );

        List<Map<String, Object>> actionData = indexingDocumentIndexerCont.getConfigurations();

        System.assertEquals('Planning', (String)actionData[0].get('indexing_category'));
    }

    @isTest
    private static void picklistValuesAreReturnedForIndexingCategoryField() {
        List<indexingDocumentIndexerCont.Option> options = indexingDocumentIndexerCont.getIndexingCategoryValues();

        System.assert(options.size() > 0);
    }

    @isTest
    private static void picklistValuesAreRetrunedForCategoryField() {
        List<indexingDocumentIndexerCont.Option> options = indexingDocumentIndexerCont.getPicklistValues('arcshared__Category__c');

        System.assert(options.size() > 0);
    }

    @isTest
    private static void searchResultsOneResultForOnAccountEntity() {
        Account account = new Account(Name = 'moo');
        insert account;

        Test.startTest();
        Test.setFixedSearchResults(new List<Id>{account.Id});
        List<SObject> result = indexingDocumentIndexerCont.search('Account', 'moo', new List<String>{'Name'});
        Test.stopTest();

        System.assertEquals(1, result.size());
    }

    public class CustomFetcher extends indexingDocumentFetcher {
        
        public override List<indexingDocumentFetcher.Document> fetch() {
            return new List<indexingDocumentFetcher.Document>{
                new indexingDocumentFetcher.Document(
                    'a',
                    'b',
                    'c',
                    'd',
                    Date.today()
                )
            };
        }
    }

    public class CustomLinker extends indexingDocumentLinker {

        public override void link(List<Id> recordIds, Id versionId) {
            insert new Account(Name = 'LINK');
        }
    }
}