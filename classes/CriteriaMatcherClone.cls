/*
This is a clone of the DefaultCriteriaMatcher in arcus shared
I have swapped the SObject `record` for a Map<String, Object>, and added the arcshared namespace where needed to compile,
and I have also added the Rule as an inline class here,
as JSON.serialize throws System.JSONException: Cannot serialize type from package: Rule
*/
public class CriteriaMatcherClone {

    public class Rule{
        public String field {get;set;}
        public String firstValue {get;set;}
        public String secondValue {get;set;}
        public String type {get;set;}
        public String comparator {get;set;}
    }

    private Map<String, Object> record;

    final private Set<String> numericType = new Set<String>{
        'currency',
        'double',
        'percent',
        'integer'
    };

    public Boolean match(Map<String, Object> record, List<Rule> rules){
        this.record = record;

        for(Rule rule : rules){
            Boolean ruleMatch = checkRule(rule);

            if(ruleMatch == null){
                throw new arcshared.Criteria.MalformedCriteriaException('Criteria contained an invalid Comparator');
            } else if(!ruleMatch) return false;
        }

        return true;
    }

    private Boolean checkRule(Rule rule){
        String recordValue = record.get(rule.field) != null ? String.valueOf(record.get(rule.field)) : '';
        String matchingValue = String.valueOf(rule.firstValue);
        String secondMatchingValue = String.valueOf(rule.secondValue);

        if(rule.type.toLowerCase() == 'multipicklist'){
            return checkMultiPicklist(rule.comparator.toLowerCase(), recordValue, matchingValue);
        }else if(numericType.contains(rule.type.toLowerCase())){
            return checkNumericType(rule.comparator.toLowerCase(), recordValue, matchingValue, secondMatchingValue);
        }else if(rule.type.toLowerCase() == 'date'){
            return checkDateType(rule.comparator, recordValue, matchingValue);
        }else if(rule.type.toLowerCase() == 'datetime'){
            return checkDateTimeType(rule.comparator, recordValue, matchingValue);
        }else{
            return checkSimpleType(rule.comparator.toLowerCase(), recordValue, matchingValue);
        }
    }

    @TestVisible
    private Boolean checkMultiPicklist(String comparator, String recordValue, String matchingValue){
        Set<String> recordOptions = new Set<String>(recordValue.split(';'));

        if(comparator == 'equals'){
            Integer startingSize = recordOptions.size();

            for(String matchingOption : matchingValue.split(';')){
                if(!recordOptions.contains(matchingOption)) return false;

                recordOptions.add(matchingOption);
            }

            return startingSize == recordOptions.size();
        }else{
            if(comparator != 'contains' && comparator != 'doesnotcontain') return null;

            for(String matchingOption : matchingValue.split(';')){
                if(comparator == 'contains' && !recordOptions.contains(matchingOption)) return false;
                if(comparator == 'doesnotcontain' && recordOptions.contains(matchingOption)) return false;
            }

            return true;
        }
    }

    @TestVisible
    private Boolean checkNumericType(String comparator, String recordValue, String matchingValue, String secondMatchingValue){
        if(String.isBlank(recordValue)) recordValue = '0';

        if(comparator == 'greater' || comparator == 'greaterthan'){
            return Double.valueOf(recordValue) > Double.valueOf(matchingValue);
        }else if (comparator == 'lesser'){
            return Double.valueOf(recordValue) < Double.valueOf(matchingValue);
        }else if(comparator == 'between'){
            return Double.valueOf(recordValue) >= Double.valueOf(matchingValue) &&
                Double.valueOf(recordValue) <= Double.valueOf(secondMatchingValue);
        }else if(comparator == 'notbetween'){
            return !(Double.valueOf(recordValue) >= Double.valueOf(matchingValue) &&
                Double.valueOf(recordValue) <= Double.valueOf(secondMatchingValue));
        }else if(comparator == 'equals'){
            return Double.valueOf(recordValue) == Double.valueOf(matchingValue);
        }
        else if(comparator == 'notequals'){
            return Double.valueOf(recordValue) != Double.valueOf(matchingValue);
        }
        return null;
    }

    @TestVisible
    private Boolean checkDateType(String comparator, String recordValue, String matchingValue){
        Date recordDate = String.isBlank(recordValue) ? null : Date.valueOf(recordValue);
        Date matchingDate = Date.valueOf(matchingValue);

        if(comparator == 'equals'){
            return recordDate == matchingDate;
        }else if(comparator == 'notequals'){
            return recordDate != matchingDate;
        }else if(comparator == 'greaterthan' || comparator == 'greater'){
            return recordDate > matchingDate;
        }else if(comparator == 'lesser'){
            return recordDate < matchingDate;
        }

        return null;
    }

    @TestVisible
    private Boolean checkDateTimeType(String comparator, String recordValue, String matchingValue){
        DateTime recordDateTime = DateTime.valueOf(recordValue);
        DateTime matchingDateTime = (DateTime)JSON.deserialize('"' + matchingValue + '"', DateTime.class);

        if(comparator == 'equals'){
            return recordDateTime == matchingDateTime;
        }else if(comparator == 'notequals'){
            return recordDateTime != matchingDateTime;
        }else if(comparator == 'greaterthan' || comparator == 'greater'){
            return recordDateTime.date() >= matchingDateTime.date() &&
                recordDateTime.time() > matchingDateTime.time();
        }else if(comparator == 'lesser'){
            return recordDateTime.date() <= matchingDateTime.date() &&
                recordDateTime.time() < matchingDateTime.time();
        }

        return null;
    }

    @TestVisible
    private Boolean checkSimpleType(String comparator, String recordValue, String matchingValue){
        if(comparator == 'equals'){
            return recordValue == matchingValue;
        }else if(comparator == 'notequals'){
            return recordValue != matchingValue;
        }else if(comparator == 'contains'){
            return recordValue.contains(matchingValue);
        }else if(comparator == 'doesnotcontain'){
            return !recordValue.contains(matchingValue);
        }else if(comparator == 'greaterthan' || comparator == 'greater'){
            return recordValue > matchingValue;
        }else if(comparator == 'lesser'){
            return recordValue < matchingValue;
        } else if (comparator == 'regex'){
            return Pattern.matches(matchingValue, recordValue); // inefficient if there are lots of records to be checked
        }

        return null;
    }
}