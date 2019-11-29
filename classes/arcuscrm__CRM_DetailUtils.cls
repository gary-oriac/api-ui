public class CRM_DetailUtils {

    
    @AuraEnabled
    public static List<ContentVersion> getRecordFiles(Id caseId){
    	
        List<ContentDocumentLink> cdls = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.LatestPublishedVersionId , ShareType, Visibility  
                                          FROM ContentDocumentLink 
                                          WHERE LinkedEntityId =:caseId];
        
        System.debug('cdls = ' + cdls);
        System.debug('cdls.size() = ' + cdls.size());
        
        Set<Id> cvIds = new Set<Id>();
        
        for(ContentDocumentLink cdl : cdls) cvIds.add(cdl.ContentDocument.LatestPublishedVersionId );
        
        System.debug('cvIds = ' + cvIds);
        System.debug('cvIds.size() = ' + cvIds.size());
        
        List<ContentVersion> cvList = [SELECT Id, ContentDocumentId, ContentBodyId, VersionData 
                                       FROM ContentVersion
                                       WHERE  ID IN :cvIds ];
        
        return cvList;
        
    }
    
}