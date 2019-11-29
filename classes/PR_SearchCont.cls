public class PR_SearchCont {      
    private static Map<String, PR_Searchable> objectNameToSearchable = new Map<String, PR_Searchable>();

    @AuraEnabled
    public static String search(String searchable_resources, String searchable_name, String keywords) {        
        List<String> searchWords = keywords.split('\\W*+');        
        if(searchWords.size() == 0) return 'invalid_search';

        String findClause = constructSOSLFindClause(keywords);
        String objectClause = constructSOSLObjectClause(searchable_resources, searchable_name);

        List<List<sObject>> aggregateRecords = arcshared.RecordCRUDUtils.soslRecord(findClause + objectClause);

        if(aggregateRecords != null && aggregateRecords.size() > 0){
            List<Result> results = new List<Result>();
            for(List<SObject> records : aggregateRecords){
                if(records.size() > 0){
                    String objectName = String.valueOf(records[0].getSObjectType());
                    results.add(
                        new Result (records, objectNameToSearchable.get(objectName))
                    );
                }
            }

            if(results.size() > 0) return JSON.serialize(results);
            else return 'invalid_search';
        }else return 'invalid_search';
    }

    private static String constructSOSLFindClause(String keywords) {
        List<String> stringBuilder = new List<String>();
        stringBuilder.add('FIND {');
        for(String word : keywords.split('\\W\\+*|\\W')){
            stringBuilder.add('*');
            stringBuilder.add(arcshared.Utils.escapeSOSLReservedCharacters(word));
            stringBuilder.add('* ');
        }
        stringBuilder.add('} IN ALL FIELDS RETURNING '); // this will search in fields the user cannot see... https://help.salesforce.com/articleView?id=admin_fls.htm&type=0

        return String.join(stringBuilder, '');
    }

    private static String constructSOSLObjectClause(String searchableResources, String searchableName) {      
        List<String> resourceNames = getResourcesNameList(searchableResources);  
        List<String> searchableNames = getResourcesNameList(searchableName);        

        List<String> objectClauses = new List<String>();
        String objectClauseTemplate = '{0} ({1} {2})';

        for(String name : searchableNames) {
            PR_Searchable searchable = PR_ConfigurationService.fetchSearchable(resourceNames, name);
            List<String> templateOptions = new List<String>();
            templateOptions.add(searchable.objectName);
            templateOptions.add(String.join(new List<String>(searchable.queryFields()), ','));
            templateOptions.add(
                String.IsNotBlank(searchable.objectRestrictions) ? ' WHERE ' + searchable.objectRestrictions : ''
            );

            objectClauses.add(String.format(objectClauseTemplate, templateOptions));
            objectNameToSearchable.put(searchable.objectName, searchable);
        }

        return String.join(objectClauses, ',');
    }

    @AuraEnabled
    public static String getAvailableWeeklyLists(String resource_names){
        List<PR_WeeklyList> weeklyLists = PR_ConfigurationService.fetchWeeklyLists(getResourcesNameList(resource_names));

        List<Map<String, String>> options = new List<Map<String, String>>();
        for(PR_WeeklyList weeklyList : weeklyLists){
            Map<String, String> option = new Map<String, String>();
            option.put('value', weeklyList.name);
            option.put('label', weeklyList.label);
            options.add(option);
        }

        return JSON.serialize(options);
    }

    @AuraEnabled
    public static String getCategoryData(String resource_name){
        return JSON.serialize(
            PR_ConfigurationService.fetchCategories(getResourcesNameList(resource_name))
        );
    }

    @AuraEnabled
    public static String weeklyQuery(String searchable_resources, String resource_name, String category_name, String start_date){
        Date startDate = Date.valueOf(start_date);
        PR_WeeklyList weeklyList = PR_ConfigurationService.fetchWeeklyList(getResourcesNameList(resource_name), category_name);
        PR_Searchable searchable = PR_ConfigurationService.fetchSearchable(getResourcesNameList(searchable_resources), category_name);

        if(searchable == null || weeklyList == null) return 'invalid_search';

        List<Object> templateOptions = new List<Object>();
        templateOptions.add(weeklyList.restriction_field);
        templateOptions.add(String.valueOf(startDate));
        templateOptions.add(String.valueOf(startDate.addDays(7)));

        String additionalRestrictions = String.format('{0} >= {1} AND {0} <= {2}', templateOptions);
        String query = constructSOQLQuery(searchable, additionalRestrictions);        
        List<Sobject> results = arcshared.RecordCRUDUtils.soqlRecord(query);

        if(results == null || results.size() == 0) return 'invalid_search';

        return JSON.serialize(new Result(results, searchable));
    }

    @AuraEnabled
    public static String baseQuery(String searchable_resources, String category_name) {
        PR_Searchable searchable = PR_ConfigurationService.fetchSearchable(getResourcesNameList(searchable_resources), category_name);

        if(searchable == null) return 'invalid_search';

        String query = constructSOQLQuery(searchable, null);
        List<Sobject> results = arcshared.RecordCRUDUtils.soqlRecord(query);

        if(results == null || results.size() == 0) return 'invalid_search';

        return JSON.serialize(new Result(results, searchable));
    }

    @AuraEnabled
    public static String query(String searchable_resources, String resource_name, String category_name, Map<String, String> search_criteria) {
        PR_Category category = PR_ConfigurationService.fetchCategory(getResourcesNameList(resource_name), category_name);
        PR_Searchable searchable = PR_ConfigurationService.fetchSearchable(getResourcesNameList(searchable_resources), category_name);

        if(searchable == null || category == null) return 'invalid_search';

        String additionalRestrictions = constructSOQLRestrictions(category, search_criteria);
        String query = constructSOQLQuery(searchable, additionalRestrictions);
        List<Sobject> results = arcshared.RecordCRUDUtils.soqlRecord(query);

        if(results == null || results.size() == 0) return 'invalid_search';

        return JSON.serialize(new Result(results, searchable));
    }

    private static String constructSOQLRestrictions(PR_Category category, Map<String, String> criteria) {
        List<String> filterCriteria = new List<String>();
        String whereTemplate = '{0} {1} {2}';

        for(PR_Category.FieldSet fieldSet : category.field_set) {
            String key = fieldSet.path + (String.isNotBlank(fieldSet.range_type) ? ':' + fieldSet.range_type : '');
            if(criteria.get(key) == null) continue;

            String value = String.escapeSingleQuotes(criteria.get(key));
            List<String> templateOptions = new List<String>();
            templateOptions.add(fieldSet.path);

            if(fieldSet.type.toLowerCase() == 'date' || fieldSet.type.toLowerCase() == 'datetext') {
                templateOptions.add(fieldSet.operation);
                templateOptions.add(value);
            } else if(fieldSet.type.toLowerCase() == 'string') {
                templateOptions.add('LIKE');
                templateOptions.add('\'%' + value + '%\'');
            } else {
                templateOptions.add('=');
                templateOptions.add('\'' + value + '\'');
            }

            filterCriteria.add(String.format('{0} {1} {2}', templateOptions));
        }

        return String.join(filterCriteria, ' AND ');
    }

    private static String constructSOQLQuery(PR_Searchable searchable, String additionalRestrictions) {
        String restrictions = (
            String.IsBlank(searchable.objectRestrictions) && 
            String.IsBlank(additionalRestrictions)
        ) ? '' : 'WHERE ';

        if(String.isNotBlank(searchable.objectRestrictions)) {
            restrictions += searchable.objectRestrictions;
            restrictions += String.IsNotBlank(additionalRestrictions) ? ' AND ' + additionalRestrictions : '';
        } else {
            restrictions += String.IsNotBlank(additionalRestrictions) ? additionalRestrictions : '';
        }

        String templateQuery = 'SELECT {0} FROM {1} {2} {3}';
        List<String> templateOptions = new List<String>();
        
        templateOptions.add(String.join(new List<String>(searchable.queryFields()), ','));
        templateOptions.add(searchable.objectName);
        templateOptions.add(restrictions);
        templateOptions.add(
            String.IsNotBlank(searchable.objectOrderBy) ? ' ORDER BY ' + searchable.objectOrderBy : ''
        );

        return String.format(templateQuery, templateOptions);
    }

    private static List<String> getResourcesNameList(String resource_name){
        List<String> resource_names = new List<String>();

        resource_name = resource_name.replace(' ', '');
        if(resource_name.contains(',')) resource_names.addAll(resource_name.split(','));
        else resource_names.add(resource_name);

        return resource_names;
    }

    public class PublicRegisterException extends Exception {}

    public class Result {
        public List<SObject> records;
        public PR_Searchable definition;

        public Result(List<SObject> records, PR_Searchable definition) {
            this.records = records;
            this.definition = definition;
        }
    }
}