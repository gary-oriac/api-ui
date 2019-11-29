public virtual with sharing class indexingDocumentFetcher {
    
    public virtual List<Document> fetch() {
        List<Document> documents = getDocuments();

        documents.sort();
        return documents;
    }

    private List<Document> getDocuments() {
        List<ContentVersion> versions = [
            SELECT Id, ContentDocumentId, Title, CreatedDate, Indexing_Category__c
            FROM ContentVersion 
            WHERE Indexing_Category__c != null 
            AND Indexing_Completed__c = false
        ];

        List<Document> documents = new List<Document>();
        for(ContentVersion version : versions) {
            documents.add(new Document(
                version.Id,
                version.ContentDocumentId, 
                version.Title,
                version.Indexing_Category__c,
                Date.valueOf(version.CreatedDate)
            ));
        }

        return documents;
    }

    public class Document implements Comparable{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String contentDocumentId;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String source;
        @AuraEnabled
        public Date createdDate;
        @AuraEnabled
        public Boolean indexed;

        public Document(String id, String contentDocumentId, String title, String source, Date createdDate) {
            this.id = id;
            this.contentDocumentId = contentDocumentId;
            this.title = title;
            this.source = source;
            this.createdDate = createdDate;

            this.indexed = false;
        }

        public Integer compareTo(Object compareTo) {
            Document compareToDocument = (Document)compareTo;

            String sourceOne = this.source;
            String sourceTwo = compareToDocument.source;

            String titleOne = this.title;
            String titleTwo = compareToDocument.title;

            if(sourceOne == sourceTwo) {
                if(titleOne == titleTwo) {
                    return 0;
                } else if(titleOne > titleTwo) {
                    return 1;
                }

                return -1;
            } else if(sourceOne > sourceTwo) {
                return 1;
            }

            return -1;
        }
    }

}