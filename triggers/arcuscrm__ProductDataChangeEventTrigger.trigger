trigger ProductDataChangeEventTrigger on arcshared__Product_Data_Change__e (after insert) {

        List<arcshared__Product_Data_Change__e> productDataChangeList = (List<arcshared__Product_Data_Change__e>) System.Trigger.new; 
        processProductDataChangeEvents(productDataChangeList);

        private static void processProductDataChangeEvents(List<arcshared__Product_Data_Change__e> productDataChangeList) {
            List<arcshared__Product_Data_Change__e> eventBatch = new List<arcshared__Product_Data_Change__e>();
            Integer batchSize = 49;
            Integer counter = 0;
            String replayId;
            for (arcshared__Product_Data_Change__e productDataChangeEvent : productDataChangeList) {
                counter++;
                replayId = productDataChangeEvent.replayId;
                eventBatch.add(productDataChangeEvent);

                // this will process in batches of 50 at once, due to Process Builders/things that might
                // fire on a case creation. It might be okay higher, or it might need to be lower!
                if (counter > batchSize) {
                    break;
                }
            }

            List<arcshared__Product_Data_Change__e> validEvents = checkValidity(eventBatch);

            CRM_ShadowCaseUtils.processProductDataChangeEventList(validEvents);
            if (counter > batchSize) EventBus.TriggerContext.currentContext().setResumeCheckpoint(replayId); 
        }

        private static List<arcshared__Product_Data_Change__e> checkValidity(List<arcshared__Product_Data_Change__e> productDataChangeList) {
            List<arcshared.ProductDataChangeUtils.EventValidity> results = arcshared.ProductDataChangeUtils.validateEvents(productDataChangeList);

            List<arcshared__Product_Data_Change__e> validEvents = new List<arcshared__Product_Data_Change__e>();
            String errorString = '';
            for (arcshared.ProductDataChangeUtils.EventValidity result : results) {
                if (result.isValid) {
                    validEvents.add(result.event);
                } else {
                    errorString += '\nType: ' + result.event.arcshared__Type__c + 
                                   ' with Parent record Ids: ' + result.event.arcshared__Record_Id__c + '.\n';
                    for (arcshared.ProductDataChangeUtils.RuleValidity rule : result.ruleValidities) {
                        if (!rule.isValid) {
                            errorString += '\t' + rule.message + '\n';
                        }
                    }                                            
                }
            }
            if (String.isNotBlank(errorString)) addInvalidEventsErrorToSystemLog(errorString);

            return validEvents;
        }  

        private static void addInvalidEventsErrorToSystemLog(String errorString) {
            errorString = 'The following errors happened when validating the Product Data Change Events in the Trigger:\n' + 
                           '--------------------------------------------------------------------------------------------\n' + 
                           errorString;
            CRM_ShadowCaseUtils.addErrorToSystemLog(errorString, 'ProductDataChangeEventTrigger failed.');
        }
}