/* REMOVE WHEN ARCSHARED GETS UPDATED AND SWITCH COMMENTS IN CRM_ConfigurationMetadataCont */
public with sharing class CustomMetadataCreator {
    public List<Metadata.CustomMetadata> customMetadataList;
    public String objectName;

    public CustomMetadataCreator(String objectName) {
        this.objectName = objectName;
        this.customMetadataList = new List<Metadata.CustomMetadata>();
    }

    public CustomMetadataCreator(String objectName, SObject record) {
        this.objectName = objectName;
        this.customMetadataList = new List<Metadata.CustomMetadata>();
        
        createSingleMetadataRecord(record);
    }

    public CustomMetadataCreator(String objectName, List<SObject> records) {
        this.objectName = objectName;
        this.customMetadataList = new List<Metadata.CustomMetadata>();

        for(SObject record : records){
            createSingleMetadataRecord(record);
        }
    }

    public void addRecord(SObject record) {
        createSingleMetadataRecord(record);
    }

    public void addRecords(List<SObject> records) {
        for(SObject record : records){
            createSingleMetadataRecord(record);
        }
    }

    private void createSingleMetadataRecord(SObject record) {
        Metadata.CustomMetadata customMetadata = initializeCustomMetadata(record);
        customMetadata.values.addAll(createCustomFields(record));
        this.customMetadataList.add(customMetadata);
    }

    private Metadata.CustomMetadata initializeCustomMetadata(SObject record) {
        Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();

        customMetadata.fullName = objectName + '.' + ((String)record.get('MasterLabel')).replaceAll(' ', '_');
        customMetadata.label = (String)record.get('MasterLabel');

        return customMetadata;
    }

    private List<Metadata.CustomMetadataValue> createCustomFields(SObject record) {
        Map<String, Object> fieldMap = record.getPopulatedFieldsAsMap();
        List<Metadata.CustomMetadataValue> fieldValues = new List<Metadata.CustomMetadataValue>();

        for(String key : fieldMap.keySet()){
            if(key.toLowerCase().endsWith('__c')){
                Metadata.CustomMetadataValue fieldValue = new Metadata.CustomMetadataValue();
                fieldValue.field = key;
                fieldValue.value = fieldMap.get(key);
                fieldValues.add(fieldValue);
            }            
        }

        return fieldValues;
    }

    public Id deploy() {
        if(customMetadataList.size() == 0) throw new CustomMetadataCreatorException('No custom metadata found for deployment');

        Metadata.DeployContainer container = new Metadata.DeployContainer();
        for(Metadata.CustomMetadata customMetadata : customMetadataList){
            container.addMetadata(customMetadata);
        }

        DeployCallback callback = new DeployCallback();
        return Metadata.Operations.enqueueDeployment(container, callback);
    }

    public static Id deploy(List<Metadata.CustomMetadata> customMetadataList) {
        Metadata.DeployContainer container = new Metadata.DeployContainer();
        for(Metadata.CustomMetadata customMetadata : customMetadataList){
            container.addMetadata(customMetadata);
        }

        DeployCallback callback = new DeployCallback();
        return Metadata.Operations.enqueueDeployment(container, callback);
    }

    public class DeployCallback implements Metadata.DeployCallback {
        public void handleResult(
            Metadata.DeployResult result, 
            Metadata.DeployCallbackContext context
        ) {
            /*if(result.status == Metadata.DeployStatus.SUCCEEDED) {
                insert new System_Log__c(
                    Log_Source__c = result.id,
                    Log_Info__c = 'SUCCESS',
                    Debug_Data__c = 'Custom metadata deployment request'
                );
            } else {                
                insert new System_Log__c(
                    Log_Source__c = result.id,
                    Log_Info__c = 'FAILURE',
                    Debug_Data__c = 'Custom metadata deployment request',
                    Debug_Data_Rich__c = JSON.serialize(result)
                );
            }*/
        }
    }

    public class CustomMetadataCreatorException extends Exception {}
}