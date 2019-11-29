public class CRM_DocumentManagement {
    
    @AuraEnabled
    public static List<ContentWorkspaceDoc> getDocsToIndex(){
        
        List<ContentWorkspaceDoc> docsToIndex = [SELECT ContentDocument.Id,ContentDocument.CreatedDate,ContentDocument.LastModifiedDate,ContentDocument.IsDeleted,ContentDocument.SystemModstamp,ContentDocument.Title,ContentWorkspace.Name 
                                                 FROM ContentWorkspaceDoc WHERE ContentWorkspace.Name != 'Asset Library' AND ContentDocument.FileType = 'PDF'  ORDER BY ContentWorkspace.Name ASC ];
        
        system.debug('docsToIndex = ' + docsToIndex);
        return docsToIndex;
    }
    
    @AuraEnabled
    public static List<ContentWorkspace> getIndexingLibrariesWithPrefix(String libraryPrefix){
        if (libraryPrefix == null) libraryPrefix= 'Unindexed';
        String libSearchStr = libraryPrefix + '%';
        List<ContentWorkspace> libraries = [SELECT Id, Name, Description, WorkspaceImageId FROM ContentWorkspace WHERE ContentWorkspace.Name LIKE :libSearchStr ORDER BY Name ASC  ];
        system.debug('libraries = ' + libraries);
        system.debug('SIZE libraries =  ' + libraries.size() );
        return libraries;
    }
    
    @AuraEnabled
    public static List<ContentWorkspaceDoc> getDocsToIndexBasedonLibraryPrefix(String libraryPrefix){
        
        if (libraryPrefix == null) libraryPrefix= 'Unindexed';
        String libSearchStr = libraryPrefix + '%';
        
        List<ContentWorkspaceDoc> docsToIndex = [SELECT ContentDocument.Id,ContentDocument.CreatedDate,ContentDocument.LastModifiedDate,ContentDocument.IsDeleted,ContentDocument.SystemModstamp,ContentDocument.Title,ContentWorkspace.Name 
                                                 FROM ContentWorkspaceDoc WHERE ContentWorkspace.Name LIKE :libSearchStr AND ContentDocument.FileType = 'PDF'   ORDER BY ContentWorkspace.Name ASC ];
        
        system.debug('docsToIndex = ' + docsToIndex);
        system.debug('SIZE back =  ' + docsToIndex.size() );
        return docsToIndex;
        
    }
    
    @AuraEnabled
    public static List<ContentVersion> findContentVersionsInLibrary(String libraryId, Boolean isLatest, Boolean showSensitveFiles, String orderBy, String sortType) {
        
        System.debug('findContentVersionsInLibrary libraryId =  '+ libraryId);
        
        List<ContentWorkspaceDoc> docsInLibrary = [SELECT ContentDocument.Id,ContentDocument.CreatedDate,ContentDocument.LastModifiedDate,ContentDocument.IsDeleted,ContentDocument.SystemModstamp,ContentDocument.Title,ContentWorkspace.Name 
                                                   FROM ContentWorkspaceDoc WHERE ContentWorkspace.Id = :libraryId AND ContentDocument.FileType = 'PDF'];
        
        System.debug('docsInLibrary =  '+ docsInLibrary);
        
        Set<Id> ContDocIdSet = new Set<Id>();
        for(ContentWorkspaceDoc cdw : docsInLibrary) ContDocIdSet.add( cdw.ContentDocument.Id );
        
        System.debug('ContDocIdSet =  '+ ContDocIdSet);
        
        String query = 'SELECT Id, ContentDocumentId, Description, FileType, ContentSize, Title,ContentDocument.Title, ContentUrl, ' + 
            'VersionNumber, TagCsv, FileExtension, FirstPublishLocationId, Origin, NetworkId, ' +  
            'IsLatest,  TextPreview,  ' +  
            'IsMajorVersion,   PublishStatus,  ReasonForChange, ContentModifiedDate, ContentModifiedById ' +
            'FROM ContentVersion ' +
            'WHERE ContentDocumentId IN :ContDocIdSet AND arcuscrm__Indexing_Completed__c = false  ';
        
        if(orderBy != '') {
            query += ' ORDER BY ' + orderBy + ' ' + sortType +' NULLS LAST';
            //query += ' ORDER BY arcuscrm__Document_Date__c DESC NULLS LAST';
        }        
        
        System.debug('query:::' + query);
        List<ContentVersion> contVerList = database.query(query);
        
        System.debug('contVerList =  '+ contVerList);  
        System.debug('contVerList.size() =  '+ contVerList.size());  
        
        return contVerList;
    }
    
    @AuraEnabled
    public static List<ContentVersion> findContentVersionsForPlanning(String recordId, Boolean isLatest, Boolean showSensitveFiles, String orderBy, String sortType) {
        
        System.debug('findContentVersionsForPlanning recordId =  '+ recordId);
        List<ContentDocumentLink> cdlList = [SELECT LinkedEntityId,LinkedEntity.Name, ContentDocumentId,ContentDocument.Title,ContentDocument.Description, ShareType, Visibility, Id
                                             FROM ContentDocumentLink 
                                             WHERE LinkedEntityId = :recordId];
        
        System.debug('cdlList =  '+ cdlList);                         
        
        Set<Id> ContDocIdSet = new Set<Id>();
        for(ContentDocumentLink cdl : cdlList) ContDocIdSet.add( cdl.ContentDocumentId );
        
        System.debug('ContDocIdSet =  '+ ContDocIdSet);   
        
        String query = 'SELECT Id, ContentDocumentId, Description, FileType, ContentSize, Title,ContentDocument.Title, ContentUrl, ' + 
            'VersionNumber, TagCsv, FileExtension, FirstPublishLocationId, Origin, NetworkId, ' +  
            'IsLatest,  TextPreview, arcuscrm__Conga_Generated__c, ' +  
            'IsMajorVersion,   PublishStatus,  ReasonForChange, ContentModifiedDate, ContentModifiedById, ' +
            'FROM ContentVersion ' +
            'WHERE ContentDocumentId IN :ContDocIdSet ';
        if(isLatest) {
            query += ' AND IsLatest = ' + isLatest;
        }
        
        if(orderBy != '') {
            query += ' ORDER BY ' + orderBy + ' ' + sortType +' NULLS LAST';
        }        
        
        System.debug('query:::' + query);
        List<ContentVersion> contVerList = database.query(query);
        
        System.debug('contVerList =  '+ contVerList);   
        
        return contVerList;
    }
    
    
    @AuraEnabled
    public static Case indexDocument( ContentVersion docToIndex) {
        
        System.debug('indexDocument');
        System.debug('docToIndex = '+ docToIndex);
        
        RecordType docRT = [ SELECT Id, Name, SobjectType, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Document_Workflow_Case' LIMIT 1 ];
        if (docRT != null){
            Case myCase = new Case( Subject = 'Document Indexing Case', RecordTypeId = docRT.Id );
            insert myCase;
            
            System.debug('myCase = ' + myCase);
            
            ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = myCase.Id, ShareType= 'V' ,Visibility = 'InternalUsers' , ContentDocumentId = docToIndex.ContentDocumentId  );
            
            insert cdl;
            System.debug('cdl = ' + cdl);
            
            System.debug('Mark doc as being indexed' );
            ContentVersion cv = [SELECT Id, ContentDocumentId, IsLatest, arcuscrm__Indexing_Completed__c  
                                 FROM ContentVersion WHERE IsLatest = true AND  ContentDocumentId = :docToIndex.ContentDocumentId  LIMIT 1  ];
            cv.arcuscrm__Indexing_Completed__c  = true;
            System.debug('cv = ' + cv);
            update cv;
            
            System.debug('Then take doc out of the library. ' );
            
            
            
            List<ContentWorkspaceDoc>  cwdocList = [SELECT ContentDocument.Id,ContentDocument.CreatedDate,ContentDocument.LastModifiedDate,ContentWorkspace.Name
                                                    FROM ContentWorkspaceDoc WHERE  ContentDocument.Id = :docToIndex.ContentDocumentId  LIMIT 100 ];
            
            System.debug('cwdocList = ' + cwdocList);
            // Nelow errors as ContentWorkspaceDoc is parent of content doc ...
            //delete cwdocList; 
            
            //ContentWorkspace.Name = 'Council Tax' AND    
            
            return myCase;
        }
        //update docToIndexBack;
        return null;
    }
    
    @AuraEnabled
    public static Map<String, Object> updateFiles(List<ContentVersion> draftValues) {
        
        System.debug('updateFiles');
        System.debug('draftValues = '+ draftValues);
        
        Map<String, Object> response = new Map<String, Object>();
        Map<String, Object> errors = validate(draftValues);
        
        if (errors.size() > 0) {
            response.put('code', 'ERROR_SAVING');
            response.put('errors', errors);
            return response;
        }
        
        System.debug('Do Update');
        update draftValues;
        
        response.put('code', 'SUCCESS');
        response.put('errors', errors);
        response.put('message', 'Your changes are saved.');
        
        return response;
    }
    
    private static Map<String, Object> validate(List<ContentVersion> draftValues) {
        Integer totalErrors = 0;
        Map<String, Object> errors = new Map<String, Object>();
        Map<String, Object> rowsError = new Map<String, Object>();
        
        for (ContentVersion cv: draftValues) {
            List<String> rowErrorMessages = new List<String>();
            List<String> rowErrorFieldNames = new List<String>();
            
            if (rowErrorMessages.size() > 0) {
                ContentVersion cvWithTitle = [SELECT Id, Title FROM ContentVersion WHERE Id = :cv.Id];
                Map<String, Object> rowErrors = new Map<String, Object>();
                
                rowErrors.put('messages', rowErrorMessages);
                rowErrors.put('fieldNames', rowErrorFieldNames);
                rowErrors.put('title', cvWithTitle.Title + ' has ' + rowErrorMessages.size() + ' errors');
                
                totalErrors += rowErrorMessages.size();
                
                rowsError.put((String) cv.Id, rowErrors);
            }
        }
        
        if (totalErrors > 0) {
            Map<String, Object> table = new Map<String, Object>();
            List<String> tableMessages = new List<String>();
            
            for (Object rowError: rowsError.values()) {
                String rowErrorTitle = (String)((Map<String, Object>)rowError).get('title');
                
                tableMessages.add(rowErrorTitle);
            }
            table.put('title', 'Some records have errors');
            table.put('messages', tableMessages);
            errors.put('rows', rowsError);
            errors.put('table', table);
        }
        
        return errors;
    }  
    
    
    
}