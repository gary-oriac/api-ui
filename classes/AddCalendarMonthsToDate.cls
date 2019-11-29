public class AddCalendarMonthsToDate {
	@InvocableMethod
    public static void  addCalendarMonths(List<Param> params){
        Param param = params[0];
        String currentRecordAPIName = (param.currentRecordId).getSObjectType().getDescribe().getName();
        
        Id idtouse = param.currentRecordId;
        
        String query = 'SELECT Id, ' + param.baseDateFieldApiName + ' FROM ' + currentRecordAPIName + ' WHERE Id = \'' + idtouse + '\' LIMIT 1';
        List<SObject> objs = arcshared.RecordCRUDUtils.soqlRecord( query );
        if (objs.size() > 0){
            date myDate = (Date) objs[0].get(param.baseDateFieldApiName);
            date newDate = myDate.addMonths(param.numOfMonths);
            objs[0].put(param.targetDateFieldApiName, newDate);
            arcshared.RecordCRUDUtils.updateRecord( objs[0] );
        }
    }
        
    public class Param{
        @InvocableVariable(required=true)
        public Id currentRecordId; 
        @InvocableVariable(required=true)
        public String baseDateFieldApiName;
        @InvocableVariable(required=true)
        public String targetDateFieldApiName;
        @InvocableVariable(required=true)
        public Integer numOfMonths;
    }
}