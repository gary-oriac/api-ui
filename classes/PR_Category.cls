public with sharing class PR_Category {
    public String name {get;set;}
    public String value {get;set;}
    public String label {get;set;}
    public List<FieldSet> field_set {get;set;}

    public class FieldSet {
		public String label {get;set;}
		public String field {get;set;}
		public String type {get;set;}
		public String range_type {get;set;}
		public String required {get;set;}
		public List<Option> options {get;set;}

		public String path {get;set;}
		public String operation {get;set;}
	}

    public class Option implements Comparable{
		public String label {get;set;}
		public String value {get;set;}

		public Integer compareTo(Object compareTo){
			Option compareToOption = (Option)compareTo;
			String compareToLabel = (String)compareToOption.label;

			Integer value = 0;
			if(label > compareToLabel) value = 1;
			else if(label < compareToLabel) value = -1;

			return value;
		}
	}

    public static List<PR_Category> parse(String categoryJson) {
        List<PR_Category> categories = (List<PR_Category>)JSON.deserialize(categoryJson, List<PR_Category>.class);
        for(PR_Category category : categories) {
            category.setOptions();
        }

        return categories;
    }

    public Boolean isAccessible() {
        Schema.DescribeSObjectResult objectDescribe = arcshared.Utils.getsObjectDescribe(value);
		if(objectDescribe != null && !objectDescribe.isAccessible()){
			return false;
		}

        for(FieldSet fieldSet : field_set) {
            Schema.DescribeFieldResult fieldDescribe = PR_ConfigurationService.describeFieldByPath(value, fieldSet.path).fieldDescribe;
            if(!fieldDescribe.isAccessible()) return false;
        }

        return true;
    }

    public void removeInAccessibleFields() {
        for(Integer i = field_set.size() - 1; i >= 0; i--) {
            Schema.DescribeFieldResult fieldDescribe = PR_ConfigurationService.describeFieldByPath(value, field_set[i].path).fieldDescribe;
            if(!fieldDescribe.isAccessible()) field_set.remove(i);
        }
    }

    public void setOptions() {
        for(FieldSet fieldSet : field_set) { 
            if(fieldSet.options == null || fieldSet.options.size() == 0){
                PR_ConfigurationService.Describe describe = PR_ConfigurationService.describeFieldByPath(value, fieldSet.path);
                
                if(fieldSet.type.toLowerCase() == 'picklist' && fieldSet.field.toLowerCase() != 'recordtypeid'){
                    fieldSet.options = getPicklistOptions(describe.fieldDescribe);
                }

                if(fieldSet.type.toLowerCase() == 'picklist' && fieldSet.field.toLowerCase() == 'recordtypeid'){
                    fieldSet.options = getRecordTypeOptions(describe.objectName);
                }

                if(fieldSet.options != null) fieldSet.options.sort();
            }
        }
    }

    private static List<Option> getPicklistOptions(Schema.DescribeFieldResult fieldDescribe){
		List<Option> options = new List<Option>();

		for(Schema.PicklistEntry picklistEntry : fieldDescribe.getPicklistValues()){
			if(picklistEntry.isActive()){
				Option option = new Option();
				option.label = picklistEntry.getLabel();
				option.value = picklistEntry.getValue();
				options.add(option);
			}
		}

		return options;
	}

    private static List<Option> getRecordTypeOptions(String objectName){
		List<Option> options = new List<Option>();
		for(RecordType recordType : arcshared.Utils.getAllRecordTypeBysObject(objectName)){
			Option option = new Option();
			option.label = recordType.Name;
			option.value = recordType.Id;
			options.add(option);
		}

		return options;
	}
}