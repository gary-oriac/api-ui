@RestResource(urlMapping='/record_processor/*')
global with sharing class RecordProcessorAPI {

    @HttpPost
    global static String process_records(String records, String relations, String returnKey){
        arcshared.RecordProcessor processor = new arcshared.RecordProcessor(records, relations);
        List<arcshared.RecordProcessor.RecordGroup> recordGroups = processor.process();

        String returnId;
        for(arcshared.RecordProcessor.RecordGroup gr: recordGroups){
            if(gr.id == returnKey && gr.record != null) {
                returnId = (String) gr.record.get('Id');
                break;
            }
        }
        return returnId;
    }
}