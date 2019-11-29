global class ContentIndexingTriggerHandler extends arcshared.TriggerDispatcher.TriggerHandler{
    global override void MainEntry(List<SObject> newlist, Map<ID, SObject> newmap, List<SObject> oldlist, Map<ID,SObject> oldmap){
        List<ContentVersion> filesToShareWithIndexers;
		if(Trigger.isInsert && Trigger.isAfter) {
            filesToShareWithIndexers = new List<ContentVersion>();
            for(ContentVersion file: (List<ContentVersion>)newlist){
                if(file.Indexing_Category__c != null){
                    filesToShareWithIndexers.add(file);
                }
            }

            if(filesToShareWithIndexers.size() > 0) createLinksToIndexers(filesToShareWithIndexers);
		}

        if(Trigger.isUpdate && Trigger.isAfter) {
            filesToShareWithIndexers = new List<ContentVersion>();
            for(ContentVersion file: (List<ContentVersion>)newlist){
                if(file.Indexing_Category__c != null && file.Indexing_Category__c != ((ContentVersion)oldmap.get(file.Id)).Indexing_Category__c){
                    filesToShareWithIndexers.add(file);
                }
            }

            if(filesToShareWithIndexers.size() > 0) createLinksToIndexers(filesToShareWithIndexers);
        }
    }

	private void createLinksToIndexers(List<ContentVersion> filesToShare) {
        List<arcshared__Configuration__c> configs = [SELECT Id, arcshared__Action__c FROM arcshared__Configuration__c WHERE RecordType.DeveloperName = 'Document_Indexing_Area' AND arcshared__Enabled__c = true];

        List<Id> contentDocumentIds = new List<Id>();
        for(ContentVersion fileToShare: filesToShare){
            contentDocumentIds.add(fileToShare.ContentDocumentId);
        }

        Map<Id, Set<Id>> entityIdsByDocumentId = new Map<Id, Set<Id>>();

        if(contentDocumentIds.size() > 0) {
            List<ContentDocumentLink> links = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocumentIds];
            for(ContentDocumentLink link: links){
                Set<Id> relatedEntities = new Set<Id>();
                if(entityIdsByDocumentId.containsKey(link.ContentDocumentId)){
                    relatedEntities = entityIdsByDocumentId.get(link.ContentDocumentId);
                }
                relatedEntities.add(link.LinkedEntityId);
                entityIdsByDocumentId.put(link.ContentDocumentId, relatedEntities);
            }
        }

        Map<String, List<String>> usersByCategory = new Map<String, List<String>>();
        for(arcshared__Configuration__c config: configs){
            Map<String,Object> indexingConfigMap = (Map<String, Object>)JSON.deserializeUntyped(config.arcshared__Action__c);
            if(indexingConfigMap.containsKey('indexing_officers') && indexingConfigMap.containsKey('indexing_category')){
                List<Object> officersList = (List<Object>)indexingConfigMap.get('indexing_officers');
                String category = (String)indexingConfigMap.get('indexing_category');
                for(Object officerObj: officersList){
                    Map<String, Object> officerDetails = (Map<String,Object>) officerObj;

                    List<String> officersForCategory = new List<String>();
                    if(usersByCategory.containsKey((String)indexingConfigMap.get('indexing_category'))){
                        officersForCategory = usersByCategory.get((String)indexingConfigMap.get('indexing_category'));
                    }
                    officersForCategory.add((String)officerDetails.get('value'));
                    usersByCategory.put(category, officersForCategory);
                }
            }
        }

        List<ContentDocumentLink> newLinks = new List<ContentDocumentLink>();
        for(ContentVersion file: filesToShare){
            List<String> indexingOfficers = usersByCategory.get(file.Indexing_Category__c);
            Set<Id> existingLinkedEntityIds = (entityIdsByDocumentId.containsKey(file.ContentDocumentId) ? entityIdsByDocumentId.get(file.ContentDocumentId) : new Set<Id>());
            if(indexingOfficers != null){
                for(String indexingOfficer: indexingOfficers){
                    if(file.OwnerId != Id.valueOf(indexingOfficer) && !existingLinkedEntityIds.contains(indexingOfficer)){
                        newLinks.add(new ContentDocumentLink(ShareType = 'C', ContentDocumentId = file.ContentDocumentId, LinkedEntityId = indexingOfficer));
                    }
                }
            }
        }

        if(newLinks.size() > 0){
            insert newLinks;
        }
	}
}