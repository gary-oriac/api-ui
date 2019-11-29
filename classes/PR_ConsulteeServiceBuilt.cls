public with sharing class PR_ConsulteeServiceBuilt extends PR_ConsulteeService {
	Object columns;
	Parameters classParameters;
	Map<String, String> params = new Map<String, String>();
    Map<Id, arcusbuiltenv__Related_Party__c> relatedPartiesMap = new Map<Id, arcusbuiltenv__Related_Party__c>();

    /***************** Methods for getting configuration for the viewing consultations (PR_ViewConsultations) *****************/
	public override Map<String, Object> getViewConsultationsConfig(String configDevName, String filter) {
		Map<String, Object> config = new Map<String, Object>();
		Id contactId = getContactId();
		filter = String.isBlank(filter) ? 'All' : filter;

		if (isAuthenticatedConsultee() && contactId != null && String.isNotBlank(configDevName)) {
			processParametersForViewConsultationsConfig(configDevName, filter);

			Boolean filterIsOn = !filter.equalsIgnoreCase('All');
			String lookupToParentField = classParameters.consultationLookups.values().get(0);
			String openForCommentsField;

			if (filter.equalsIgnoreCase('To respond')) {
				if (String.isNotBlank(classParameters.openForCommentsCheckbox)) {
					openForCommentsField = lookupToParentField;
					if (lookupToParentField.endsWithIgnoreCase('__c')) {
						openForCommentsField = openForCommentsField.removeEndIgnoreCase('c') + 'r';
					}
					openForCommentsField += '.' + classParameters.openForCommentsCheckbox;
				}
			}

			Set<Object> queryFields = new Set<Object> {'Id', 'Consultee__r.arcusbuiltenv__Contact__c', lookupToParentField};
			if (filterIsOn) {
				queryFields.add('arcusbuiltenv__Status__c');

				if (filter.equalsIgnoreCase('To respond')) {
					queryFields.add(openForCommentsField);
				}
			}

			queryFields.addAll(getConsultationFieldsFromColumns(columns));

			String queryString = 'SELECT ' + String.join(new List<Object>(queryFields), ', ') + ' FROM arcusbuiltenv__Consultation__c ';
			queryString += 'WHERE Consultee__r.arcusbuiltenv__Contact__c = \'' + contactId + '\' AND ' + lookupToParentField + ' != null';

			if (filterIsOn) {
				if (filter.equalsIgnoreCase('To respond')) {
					queryString += ' AND ' + openForCommentsField + ' = true';
					queryString += ' AND arcusbuiltenv__Status__c != \'' + classParameters.responseStatus + '\'';
				} else if (filter.equalsIgnoreCase('Responded')) {
					queryString += ' AND arcusbuiltenv__Status__c = \'' + classParameters.responseStatus + '\'';
				}
			}

			List<Object> consultations = arcshared.RecordCRUDUtils.soqlRecord(queryString);

			config.put('columns', columns);
			config.put('consultations', consultations);
			config.put('queryFields', queryFields);
		}

		return config;
	}

	private static Set<Object> getConsultationFieldsFromColumns(Object columnsAttribute) {
		Set<Object> columnFields = new Set<Object>();

		List<Object> columns = (List<Object>)columnsAttribute;
		for (Object columnObj : columns) {
			columnFields.addAll(getFieldNamesFromColumn(columnObj));
		}

		return columnFields;
	}

	private static Set<Object> getFieldNamesFromColumn(Object colObj) {
		Set<Object> fieldNames = new Set<Object>();

		if (colObj instanceof Map<String, Object>) {
			Map<String, Object> colObjMap = (Map<String, Object>)colObj;
			for (String objKey : colObjMap.keySet()) {
				Object valueObject = colObjMap.get(objKey);
				if (valueObject instanceof Map<String, Object>) {
					fieldNames.addAll(getFieldNamesFromColumn(valueObject));
				} else if (objKey == 'fieldName') {
					fieldNames.add((Object)valueObject);
				}
			}
		}

		return fieldNames;
	}

	@TestVisible
	private void processParametersForViewConsultationsConfig(String secureDesignerAttribute, String filter) {
		arcshared.SecureDesignerAttributeService service = new arcshared.SecureDesignerAttributeService(secureDesignerAttribute);
		Map<String, Object> secureDesignerAttributes = (Map<String, Object>)JSON.deserializeUntyped(service.config.arcshared__Public_JSON_Schema__c);

		if (!secureDesignerAttributes.containsKey('columns')) {
			throwAuraException('Missing configuration for key: columns');
		}

		columns = secureDesignerAttributes.get('columns');

		if (!secureDesignerAttributes.containsKey('serviceClassParameters')) {
			throwAuraException('Missing configuration for key: serviceClassParameters');
		}

		String stringParameters  = JSON.serialize(secureDesignerAttributes.get('serviceClassParameters'));
		classParameters = (Parameters)JSON.deserialize(stringParameters, Parameters.class);

		if (classParameters.consultationLookups == null || classParameters.consultationLookups.isEmpty()) {
			throwAuraException('Missing configuration for key: consultationLookups');
		}

		if (!filter.equalsIgnoreCase('All')) {
			if (String.isBlank(classParameters.responseStatus)) {
				throwAuraException('Missing configuration for key: responseStatus');
			}

			if (filter.equalsIgnoreCase('To respond') && String.isBlank(classParameters.openForCommentsCheckbox)) {
				throwAuraException('Missing configuration for key: openForCommentsCheckbox');
			}
		}
	}

    /***************** Methods for handling commenting on a record (PR_CommentsFeed) *****************/
    public override Boolean hasConsultationRequest(Map<String, String> params){
        this.params = params;
        List<arcusbuiltenv__Consultation__c> consultations = getConsultations();
        return consultations.size() > 0 ? true : false;
    }

    public override void saveComment(arcshared__Web_Comment__c comment, List<Id> documentIds, Map<String, String> params){
        this.params = params;
        List<arcusbuiltenv__Consultation__c> consultations = getConsultations();        
        if(consultations.size() > 0){
            Id consultationId = getMostRelevantConsultationId(consultations);
            comment.arcusbuiltenv__Consultation__c = consultationId;
            comment.arcshared__Commentator_Type__c = relatedPartiesMap.get(consultations[0].Consultee__c).arcusbuiltenv__Role__c;
            arcshared.RecordCRUDUtils.insertRecord(comment);

            arcshared.RecordCRUDUtils.updateRecord(new arcusbuiltenv__Consultation__c(
                Id = consultationId, 
                arcusbuiltenv__Status__c = classParameters.responseStatus
            ));

			if(documentIds != null && documentIds.size() > 0) {
				String value = arcshared.AppConfigSupport.getSingleValue('PublicRegisterConsulteeSettings', 'FileAutoPublicBE');
				if(value != null && Boolean.valueOf(value)) {
					arcshared.RecordFilesService.shareRecordFilesWithPublicRegister(documentIds, comment.Id);
				} else {
					arcshared.RecordFilesService.shareRecordFilesWithInternalUser(documentIds, comment.Id, UserInfo.getUserId());
				}
			}
        }else{
            throwAuraException('There are no open consultation requests.');
        }
    }

    private Id getMostRelevantConsultationId(List<arcusbuiltenv__Consultation__c> consultations){
        List<Id> consultationIds = new List<Id>();
        for(arcusbuiltenv__Consultation__c consultation: consultations) consultationIds.add(consultation.Id);
        String query = 'SELECT Id, arcusbuiltenv__Consultation__c FROM arcshared__Web_Comment__c WHERE arcusbuiltenv__Consultation__c IN (\'' + String.join(consultationIds, '\',\'') + '\')';        

        Set<Id> consultationIdsWithWebComments = new Set<Id>();
        for(arcshared__Web_Comment__c webComment : (List<arcshared__Web_Comment__c>)arcshared.RecordCRUDUtils.soqlRecord(query)) consultationIdsWithWebComments.add(webComment.arcusbuiltenv__Consultation__c);
        
        for(arcusbuiltenv__Consultation__c consultation : consultations){
            if(!consultationIdsWithWebComments.contains(consultation.Id)) return consultation.Id;
        }

        return consultations[0].Id;
    }

    private List<arcusbuiltenv__Consultation__c> getConsultations(){
        Id parentId = (Id)params.get('stringId');
        processParameters(params.get('secureDesignerAttribute'));

        String parentName = parentId.getSObjectType().getDescribe().getName();
        String relatedPartyLookup = classParameters.relatedPartyLookups.get(parentName);
        String consultationLookup = classParameters.consultationLookups.get(parentName);
        String relatedPartyIds = getRelatedPartyIds(parentId, relatedPartyLookup);
        if(relatedPartyIds == null) return new List<arcusbuiltenv__Consultation__c>();

        String query = 'SELECT Id, Consultee__c FROM arcusbuiltenv__Consultation__c WHERE ' +
            consultationLookup + ' = \'' + parentId + '\' AND ' + 
            consultationLookup.removeEnd('__c') + '__r.' + params.get('publicConsultField') + ' = true AND ' + 
            'Consultee__c IN (' + relatedPartyIds + ')';
        
        return (List<arcusbuiltenv__Consultation__c>)arcshared.RecordCRUDUtils.soqlRecord(query);
    }

    private String getRelatedPartyIds(Id parentId, String relatedPartyLookup){
        String query = 'SELECT Id, arcusbuiltenv__Role__c FROM arcusbuiltenv__Related_Party__c WHERE ' +
            relatedPartyLookup + ' = \'' + parentId + '\' AND ' +
            'arcusbuiltenv__Contact__c = \'' + getContactId()  + '\'';  

        String ids = '';
        for(arcusbuiltenv__Related_Party__c relatedParty : (List<arcusbuiltenv__Related_Party__c>) arcshared.RecordCRUDUtils.soqlRecord(query)){
            ids += '\'' + relatedParty.Id + '\',';
            relatedPartiesMap.put(relatedParty.Id, relatedParty);
        }

        return String.IsNotBlank(ids) ? ids.removeEnd(',') : null;
    }

    /***************** Helper methods *****************/
    private Id getContactId(){
        return ((List<User>) arcshared.RecordCRUDUtils.soqlRecord(
            'SELECT ContactId FROM User WHERE Id = \'' + UserInfo.getUserId() + '\'')
        )[0].ContactId;
    }

    private void processParameters(String secureDesignerAttribute){
        if(String.isNotBlank(secureDesignerAttribute)){
            arcshared.SecureDesignerAttributeService service = new arcshared.SecureDesignerAttributeService(secureDesignerAttribute);
            Map<String, Object> secureDesignerAttributes = (Map<String, Object>)JSON.deserializeUntyped(service.config.arcshared__Public_JSON_Schema__c);
            String stringParameters = JSON.serialize(secureDesignerAttributes.get('serviceClassParameters'));

            classParameters = (Parameters)JSON.deserialize(stringParameters, Parameters.class);            
        }
    }

    private static void throwAuraException(String message){
        AuraHandledException ex = new AuraHandledException(message);
        ex.setMessage(message);
        throw ex;
    }

    public class Parameters{
        public Map<String, String> relatedPartyLookups {get;set;}
        public Map<String, String> consultationLookups {get;set;}
        public String openForCommentsCheckbox {get;set;}
        public String responseStatus {get;set;}
    }
}