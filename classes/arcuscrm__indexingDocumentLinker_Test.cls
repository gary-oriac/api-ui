@isTest
private with sharing class indexingDocumentLinker_Test {
    
    private static Blob versionData = Blob.valueOf('a');

    @isTest
    private static void documentIsLinkedToOneAccount() {
        
        ContentVersion version = new ContentVersion(
            Title = 'TestOne',
            PathOnClient = 'test.txt',
            VersionData = versionData
        );
        insert version;

        Account account = new Account(Name = 'Blah');
        insert account;

        indexingDocumentLinker linker = new indexingDocumentLinker();
        linker.link(new List<Id>{account.Id}, version.Id);

        List<ContentDocumentLink> links = [
            SELECT Id 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId =: account.Id
        ];

        System.assertEquals(1, links.size());
    }

    @isTest
    private static void documentIsLinkedToTwoAccounts() {
        ContentVersion version = new ContentVersion(
            Title = 'TestOne',
            PathOnClient = 'test.txt',
            VersionData = versionData
        );
        insert version;

        Account accountOne = new Account(Name = 'Blah');
        insert accountOne;
        Account accountTwo = new Account(Name = 'Blah');
        insert accountTwo;

        List<Id> accountIds = new List<Id>{
            accountOne.Id,
            accountTwo.Id
        };

        indexingDocumentLinker linker = new indexingDocumentLinker();
        linker.link(accountIds, version.Id);

        List<ContentDocumentLink> links = [
            SELECT Id 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :accountIds
        ];

        System.assertEquals(2, links.size());
    }
}