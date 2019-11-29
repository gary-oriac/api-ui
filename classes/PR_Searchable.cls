public with sharing class PR_Searchable {
    public String name {get;set;}
    public String objectName {get;set;}
    public List<Field> objectFields {get;set;}

    public String objectRestrictions {get;set;}
    public String objectOrderBy {get;set;}
    public String objectLabel {get;set;}
    public String returnMessage {get;set;}
    public String recordsPerPage {get;set;}
    public String iconName {get;set;}

    public class Field {
		public String path {get;set;}
		public String label {get;set;}
		public String type {get;set;}
		public String refLabel {get;set;}
		public String prefix {get;set;}
	}

    public static List<PR_Searchable> parse(String searchableJson) {
        return (List<PR_Searchable>)JSON.deserialize(searchableJson, List<PR_Searchable>.class);
    }

    public Boolean isAccessible() {
        Schema.DescribeSObjectResult objectDescribe = arcshared.Utils.getsObjectDescribe(objectName);
		if(objectDescribe != null && !objectDescribe.isAccessible()){
			return false;
		}

        for(Field field : objectFields) {
            Schema.DescribeFieldResult fieldDescribe = PR_ConfigurationService.describeFieldByPath(objectName, field.path).fieldDescribe;
            if(!fieldDescribe.isAccessible()) return false;
        }

        return true;
    }

    public void removeInAccessibleFields() {
        for(Integer i = objectFields.size() - 1; i >= 0; i--) {
            Schema.DescribeFieldResult fieldDescribe = PR_ConfigurationService.describeFieldByPath(objectName, objectFields[i].path).fieldDescribe;
            if(!fieldDescribe.isAccessible()) objectFields.remove(i);
        }
    }

    public Set<String> queryFields() {
        Set<String> fields = new Set<String>();

        for(Field field : objectFields) {
            if(field.refLabel != null && !fields.contains(field.refLabel)) {
                fields.add(field.refLabel);
            }

            if(!fields.contains(field.path)) {
                if(field.type == 'picklist') {
                    fields.add('toLabel(' + field.path + ')');
                } else {
                    fields.add(field.path);
                }
            }
        }

        return fields;
    }
}