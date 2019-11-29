public with sharing class PR_CommentsCont {

    @AuraEnabled
    public static Map<String, Object> getConsultationPeriod(String request){
        Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(request, Map<String, String>.class);
        Map<String, Object> params = new Map<String, Object>();

        if(String.IsNotBlank(requestMap.get('secureDesignerAttribute'))){
            arcshared.SecureDesignerAttributeService service = new arcshared.SecureDesignerAttributeService(requestMap.get('secureDesignerAttribute'));
            Map<String, Object> attributes = (Map<String, Object>)JSON.deserializeUntyped(service.config.arcshared__Public_JSON_Schema__c);

            params.put('attributes', service.config.arcshared__Public_JSON_Schema__c);
        }

        if(PR_ConsulteeService.isAuthenticatedConsultee() && String.isNotBlank(requestMap.get('serviceClass')) && requestMap.get('serviceClass') != 'PR_ConsulteeService'){       
            params.put('authenticated',true);     
            PR_ConsulteeService service = getServiceClass(requestMap.get('serviceClass'));
            params.put('requested', service.hasConsultationRequest(requestMap));
        }

        params.put('public', isPublicConsultationPeriod(requestMap));
        return params;
    }

    private static boolean isPublicConsultationPeriod(Map<String, String> requestMap){
        ConsultationPeriodRequest cpr = new ConsultationPeriodRequest(
            String.valueOf(requestMap.get('startField')),
            String.valueOf(requestMap.get('endField')),
            String.valueOf(requestMap.get('publicConsultField')),
            String.valueOf(requestMap.get('stringId'))
        );

        List<sObject> queryRes = arcshared.RecordCRUDUtils.soqlRecord(cpr.query);

        if(queryRes.size() == 1){
            Date today = Date.today();
            Date consultationStart = (Date)queryRes[0].get(cpr.startField);
            if(String.isBlank(cpr.endField)){
                return consultationStart <= today;
            }else{
                Date consultationEnd  = queryRes[0].get(cpr.endField) != null ? (Date)queryRes[0].get(cpr.endField) : null;
                if(consultationEnd != null)
                    return (consultationStart <= today && today <= consultationEnd);
                else
                    return consultationStart <= today;
            }
        }
        else return false;
    }

    @AuraEnabled
    public static Map<String, Object> getComments(Id recordId, String lookup, String configDevName){
        Map<String, Object> params = new Map<String, Object>{'comments' =>  new List<Sobject>(), 'attributes' => '{}'};
        if(recordId == null || String.isBlank(lookup)) return params;

        String safeLookup = arcshared.Utils.getFieldDescribe('arcshared__Web_Comment__c', lookup).getName();
        Set<String> fields = new Set<String>{
            'Id,',
            'Name,',
            'arcshared__Name__c,',
            'CreatedDate,',
            'arcshared__Text__c,',
            'arcshared__Public__c,',
            safeLookup + ','
        };

        if(String.isNotBlank(configDevName)){
            arcshared.SecureDesignerAttributeService service = new arcshared.SecureDesignerAttributeService(configDevName);
            Map<String, Object> attributes = (Map<String, Object>)JSON.deserializeUntyped(service.config.arcshared__Public_JSON_Schema__c);

            for(Object columnObject : (List<Object>)attributes.get('columns')){
                Map<String, Object> column = (Map<String, Object>)columnObject;
                fields.add((String)column.get('fieldName') + ',');
            }

            params.put('attributes', service.config.arcshared__Public_JSON_Schema__c);
        }

        String queryString = 'SELECT ' + String.join(new List<String>(fields), '').removeEnd(',') + ' FROM arcshared__Web_Comment__c WHERE ' + safeLookup + ' = \'' + recordId + '\' AND arcshared__Public__c = true ORDER BY CreatedDate DESC';
        params.put('comments', PR_QueryWithoutSharing.query(queryString));
        params.put('authenticated', PR_ConsulteeService.isAuthenticatedConsultee());

        return params;
    }

    @AuraEnabled
    public static void saveComment(arcshared__Web_Comment__c comment, List<Id> documentIds, String request){
        Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(request, Map<String, String>.class);

        if(PR_ConsulteeService.isAuthenticatedConsultee()){
            String query = 'SELECT Contact.Name, Contact.Email, Contact.arcusgazetteer__Correspondence_Print_Address__c FROM User WHERE Id = \'' + UserInfo.getUserId() + '\'';
            User user = ((List<User>)arcshared.RecordCRUDUtils.soqlRecord(query))[0];
            comment.Name = user.Contact.Name + '\'s comment';
            comment.arcshared__Name__c = user.Contact.Name;
            comment.arcshared__Address__c = user.Contact.arcusgazetteer__Correspondence_Print_Address__c;
            comment.arcshared__Email__c = user.Contact.Email;

            if(requestMap.get('type') == 'consult'){
                PR_ConsulteeService service = getServiceClass(requestMap.get('serviceClass'));
                service.saveComment(comment, documentIds, requestMap);
            }else{
                makePublicComment(comment, requestMap);
            }
        }else{
            makePublicComment(comment, requestMap);
        }
    }

    private static void makePublicComment(arcshared__Web_Comment__c comment, Map<String, String> requestMap){
        if(isPublicConsultationPeriod(requestMap)){
            comment.Name = comment.arcshared__Name__c + '\'s comment';
            arcshared.RecordCRUDUtils.insertRecord(comment);
        }else throwAuraException('Application is not in a consultation period.');
    }

    @AuraEnabled
    public static String getDisclaimerByScope(String scopeString, Id recordId, String configDevName){
        if(String.isNotBlank(scopeString)){
            Pattern p = Pattern.compile('s:[A-za-z0-9]*');
            Matcher m = p.matcher(scopeString);

            if(m.matches()){
                String fileName = scopeString.split(':')[1];
                List<StaticResource> sr = [SELECT Body FROM StaticResource WHERE Name = :fileName LIMIT 1];
                if(sr.size() != 1) throwAuraException('Resource not found.');
                scopeString = sr[0].Body.toString();
            }
        }

        if(String.isNotBlank(configDevName)){
            arcshared.SecureDesignerAttributeService service = new arcshared.SecureDesignerAttributeService(configDevName);
            Map<String, Object> attributes = (Map<String, Object>)JSON.deserializeUntyped(service.config.arcshared__Public_JSON_Schema__c);
            scopeString = JSON.serialize(attributes.get('disclaimers'));
        }

        List<DisclaimerScope> disclaimerScopeList = (List<DisclaimerScope>)JSON.deserialize(scopeString, List<DisclaimerScope>.class);
        Set<String> fieldSet = new Set<String>();

        for(DisclaimerScope scope : disclaimerScopeList){
            fieldSet.addAll(scope.key_fields);
        }

        String query = buildDisclaimerScopeQuery(new List<String>(fieldSet), recordId);
        List<SObject> values = arcshared.RecordCRUDUtils.soqlRecord(query);
        if(values.size() != 1) throwAuraException('Record not found.');

        return findMatchingDisclaimer(disclaimerScopeList, values[0]);
    }

    private static String findMatchingDisclaimer(List<DisclaimerScope> disclaimerScopeList, SObject record){

        for(DisclaimerScope scope : disclaimerScopeList){
            String recordKey = '';
            for(String field : scope.key_fields) recordKey += getValueFromRecordByField(field, record);

            String scopeKey = scope.key.replaceAll(scope.separator, '');
            if(scopeKey == recordKey) return scope.disclaimer;
        }

        return null;
    }

    private static String getValueFromRecordByField(String fullField, SObject record){
        if(fullField.contains('RecordType')){
            List<String> fieldList = fullField.split('\\.');
            String query = 'SELECT Name, DeveloperName FROM RecordType WHERE id = \'' + record.get('RecordTypeId') + '\'';
            List<SObject> results = arcshared.RecordCRUDUtils.soqlRecord(query);

            return (String)results[0].get(fieldList[1]);
        }else return (String)record.get(fullField);
    }

    private static String buildDisclaimerScopeQuery(List<String> fields, Id recordId){
        String query = 'SELECT ' + String.join(fields, ',') +
            ' FROM ' + recordId.getSObjectType().getDescribe().getName() +
            ' WHERE id = \'' + recordId + '\'';

        return query;
    }

    private static PR_ConsulteeService getServiceClass(String serviceClass){
        Type customType = Type.forName(serviceClass);
        return (PR_ConsulteeService)customType.newInstance();
    }

    private static void throwAuraException(String message){
        AuraHandledException ex = new AuraHandledException(message);
        ex.setMessage(message);
        throw ex;
    }

    public class ConsultationPeriodRequest{
        public String startField {get;set;}
        public String endField {get;set;}
        public String publicConsultField {get;set;}
        private Id recordId {get;set;}

        private DescribeSObjectResult objectDescribe {get;set;}
        private String objectName {get;set;}
        public String query {get;set;}

        public consultationPeriodRequest(String startField, String endField, String publicConsultField, String stringId){
            this.recordId = (Id)stringId;
            this.objectDescribe = this.recordId.getSObjectType().getDescribe();
            this.objectName = objectDescribe.getName();

            this.startField = this.getSafeField(startField);
            this.endfield = String.isBlank(endField) ? null : this.getSafeField(endField);
            this.publicConsultField = this.getSafeField(publicConsultField);
            
            this.constructQuery();
        }

        private void constructQuery(){
            this.query = 'SELECT Id, ' + this.startField ;
            if(this.endField != null)
                this.query += ' , ' + this.endField;
            this.query += ' FROM ' + this.objectName;
            this.query += ' WHERE Id = \'' + this.recordId + '\'';
            this.query += ' AND ' + this.publicConsultField + ' = true'; 
        }

        private String getSafeField(String unsafeField){
            return this.objectDescribe.fields.getMap().get(unsafeField).getDescribe().getName();
        }
    }

    public class DisclaimerScope{
        public String key {get;set;}
        public String separator {get;set;}
        public Set<String> key_fields {get;set;}
        public String disclaimer {get;set;}
    }
}