public virtual with sharing class indexingDocumentLinker {
    
    public virtual void link(List<Id> recordIds, Id versionId) {
        Id documentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: versionId
        ].ContentDocumentId;

        List<ContentDocumentLink> links = new List<ContentDocumentLink>();        
        for(Id recordId : recordIds) {
            links.add(createContentDocumentLink(recordId, documentId));
        }

        try{
            insert links;
        } catch(System.DmlException e) {
            if(!e.getMessage().contains('is already linked with the entity')) {
                throw e;
            }
        }
    }

    private ContentDocumentLink createContentDocumentLink(Id recordId, Id documentId) {
        return new ContentDocumentLink(
            LinkedEntityId = recordId,
            ContentDocumentId = documentId,
            ShareType = 'I',
            Visibility = 'InternalUsers'
        );
    }

}