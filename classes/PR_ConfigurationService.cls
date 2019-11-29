public with sharing class PR_ConfigurationService {
    static List<PR_Searchable> searchables = new List<PR_Searchable>();
    static List<PR_Category> categories = new List<PR_Category>();
    static List<PR_WeeklyList> weeklyLists = new List<PR_WeeklyList>();

    @AuraEnabled(cacheable=true)
    public static String fetchSecureDesignerAttribute(String developerName){
        arcshared.SecureDesignerAttributeService secureDesignerAttributeService = new arcshared.SecureDesignerAttributeService(developerName);
        return secureDesignerAttributeService.getPublicConfig();
    }

    public static PR_Searchable fetchSearchable(List<String> resourceNames, String name) {
        fetchSearchables(resourceNames);

        // Should inaccessible field be removed before fetch?
        // There is additional security checks when queried
        for(PR_Searchable searchable : searchables) {
            if(searchable.name == name) return searchable;
        }

        return null;
    }

    public static List<PR_Searchable> fetchSearchables(List<String> resourceNames) {
        if(searchables.size() > 0) return searchables;

        Resource resource = new Resource(resourceNames);

        for(arcshared__Configuration__c configuration : resource.configurations) {
            searchables.addAll(PR_Searchable.parse(configuration.arcshared__Public_JSON_Schema__c));
        }

        for(StaticResource staticResource : resource.staticResources) {
            searchables.addAll(PR_Searchable.parse(staticResource.Body.toString()));
        }
                
        return searchables;
    }

    public static PR_Category fetchCategory(List<String> resourceNames, String name) {
        fetchCategories(resourceNames);

        // Should inaccessible field be removed before fetch?
        // There is additional security checks when queried
        for(PR_Category category : categories) {
            if(category.name == name) return category;
        }

        return null;
    }

    public static List<PR_Category> fetchCategories(List<String> resourceNames) {
        if(categories.size() > 0) return categories;

        Resource resource = new Resource(resourceNames);

        for(arcshared__Configuration__c configuration : resource.configurations) {
            categories.addAll(PR_Category.parse(configuration.arcshared__Public_JSON_Schema__c));
        }

        for(StaticResource staticResource : resource.staticResources) {
            categories.addAll(PR_Category.parse(staticResource.Body.toString()));
        }
                
        return categories;
    }

    public static PR_WeeklyList fetchWeeklyList(List<String> resourceNames, String name) {
        fetchWeeklyLists(resourceNames);

        for(PR_WeeklyList weeklyList : weeklyLists) {
            if(weeklyList.name == name) return weeklyList;
        }

        return null;
    }

    public static List<PR_WeeklyList> fetchWeeklyLists(List<String> resourceNames) {
        if(weeklyLists.size() > 0) return weeklyLists;

        Resource resource = new Resource(resourceNames);

        for(arcshared__Configuration__c configuration : resource.configurations) {
            weeklyLists.addAll(PR_WeeklyList.parse(configuration.arcshared__Public_JSON_Schema__c));
        }

        for(StaticResource staticResource : resource.staticResources) {
            weeklyLists.addAll(PR_WeeklyList.parse(staticResource.Body.toString()));
        }
                
        return weeklyLists;
    }
    
    public static Describe describeFieldByPath(String objectName, String path) {
        List<String> fields = path.split('\\.');

        Schema.DescribeFieldResult currentFieldDescribe;
        String currentObjectName = objectName;

        while (fields.size() > 0) {
            currentFieldDescribe = getFieldDescribe(currentObjectName, fields[0]);

            if(currentFieldDescribe == null) return null;
            if(currentFieldDescribe.isNamePointing()) return null;            
            if(currentFieldDescribe.getReferenceTo().size() > 0 && fields.size() > 1) {
                currentObjectName = currentFieldDescribe.getReferenceTo()[0].getDescribe().getName();
            }
            
            fields.remove(0);
        }

        return new Describe(currentFieldDescribe, currentObjectName);
    }

    private static Schema.DescribeFieldResult getFieldDescribe(String objectName, String field) {
        field = field.replace('__r', '__c');

        Schema.DescribeFieldResult fieldDescribe = arcshared.Utils.getFieldDescribe(objectName, field);

        if(fieldDescribe == null){
            fieldDescribe = arcshared.Utils.getFieldDescribe(objectName, field+'id');

            if(fieldDescribe == null) return null;
        }

        return fieldDescribe;
    }

    public class Resource {
        List<StaticResource> staticResources = new List<StaticResource>();
        List<arcshared__Configuration__c> configurations = new List<arcshared__Configuration__c>();

        public Resource(List<String> names) {
            List<StaticResource> staticResources = [SELECT id, Name, Body FROM StaticResource WHERE Name IN :names AND (ContentType = 'application/javascript' OR ContentType = 'text/javascript')];
            List<arcshared__Configuration__c> configurations = [SELECT arcshared__Public_JSON_Schema__c FROM arcshared__Configuration__c WHERE arcshared__DeveloperName__c IN :names];

            if(staticResources != null) this.staticResources = staticResources;
            if(configurations != null) this.configurations = configurations;
        }
    }

    public class Describe {
        public Schema.DescribeFieldResult fieldDescribe;
        public String objectName;

        public Describe(Schema.DescribeFieldResult fieldDescribe, String objectName) {
            this.fieldDescribe = fieldDescribe;
            this.objectName = objectName;
        }
    }
}