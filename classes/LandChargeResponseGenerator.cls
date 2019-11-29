global with sharing class LandChargeResponseGenerator implements arcusgazetteer.GISQuerySetInterface {

    //TODO: consider moving these two inline classes to be their own top-level classes
    public class GISQueryResult {
        public String typeOfQuery; // TODO: comment out properties that are not used
        public String queryName;
        public Id queryConfigurationID;
        public String layerName;
        public String layerDevName;
        public String bufferValue; // should be Double, but appears to actually be String...
        public String mapName;
        public Map<String, Map<String, Object>> data; // GIS feature Id to (field name to value) // this is not exactly the same as the gazetteer returned version

        // TODO: consider making a wrapper for this that encapsulates a list of them,
        //       and add a `getNormalisedData()` method to it.
        //       the actual data returned by the Gazetteer might have an additional
        //       outer level object, so
    }

    public class SFDataWrapper { // TODO: pick better name
        public List<arcusbuiltenv__Planning_Application__c> planningApps;
        public List<arcusbuiltenv__Building_Control_Application__c> buildingControlApps;
        public List<arcuslandcharge__LC_Register__c> landChargeRegistryEntries;
        public List<arcusbuiltenv__Tree_Preservation_Order__c> treePreservationOrders;
        public List<arcusbuiltenv__Enforcement__c> enforcements;
        public List<arcusbuiltenv__Planning_Obligation__c> planningObligations;
        public List<arcusbuiltenv__Appeal__c> appeals;
        public List<Asset> assets;
        public List<arcusbuiltenv__Action__c> enforcementActions;

        public List<arcusbuiltenv__Appeal__c> planningApplicationAppeals;

        public SFDataWrapper(){
            planningApps = new List<arcusbuiltenv__Planning_Application__c>();
            buildingControlApps = new List<arcusbuiltenv__Building_Control_Application__c>();
            landChargeRegistryEntries = new List<arcuslandcharge__LC_Register__c>();
            treePreservationOrders = new List<arcusbuiltenv__Tree_Preservation_Order__c>();
            enforcements = new List<arcusbuiltenv__Enforcement__c>();
            planningObligations = new List<arcusbuiltenv__Planning_Obligation__c>();
            appeals = new List<arcusbuiltenv__Appeal__c>();
            assets = new List<Asset>();
            enforcementActions = new List<arcusbuiltenv__Action__c>();

            planningApplicationAppeals = new List<arcusbuiltenv__Appeal__c>();
        }

        public Map<String, Map<String, Map<String, Object>>> getNormalisedData(){
            // uses static method addToNormalisedData from top-leve class
            Map<String, Map<String, Map<String, Object>>> normalisedData = new Map<String, Map<String, Map<String, Object>>>();
            addToNormalisedData(normalisedData, planningApps);
            addAppealToPlanningNormalisedData(normalisedData, planningApplicationAppeals);
            addToNormalisedData(normalisedData, buildingControlApps);
            addToNormalisedData(normalisedData, landChargeRegistryEntries);
            addToNormalisedData(normalisedData, treePreservationOrders);
            addToNormalisedData(normalisedData, enforcements);
            addToNormalisedData(normalisedData, planningObligations);
            addToNormalisedData(normalisedData, appeals);
            addToNormalisedData(normalisedData, assets);
            addToNormalisedData(normalisedData, enforcementActions);

            return normalisedData;
        }
    }

    private static void addAppealToPlanningNormalisedData(Map<String, Map<String, Map<String, Object>>> normalisedData, List<arcusbuiltenv__Appeal__c> appealList) {
        String referenceMergeFieldName = 'Appeal|arcusbuiltenv__Reference__c';
        String dateLodgedMergeFieldName = 'Appeal|arcusbuiltenv__Lodged_Date__c';
        
        Map<String, Map<String, Object>> normalisedPlanningData = normalisedData.get('Planning Application');

        for (arcusbuiltenv__Appeal__c appeal : appealList) {
            String planningName = appeal.arcusbuiltenv__Planning_Application__r.Name;
            Map<String, Object> planningData = normalisedPlanningData.get(planningName);
            if(appeal.arcusbuiltenv__Lodged_Date__c != null) planningData.put(dateLodgedMergeFieldName, appeal.arcusbuiltenv__Lodged_Date__c);
            if(appeal.arcusbuiltenv__Reference__c != null) planningData.put(referenceMergeFieldName, appeal.arcusbuiltenv__Reference__c);
        }
    }


    // addToNormalisedData should really be inside SFDataWrapper, but static methods are only permitted in top-level classes
    private static void addToNormalisedData(Map<String, Map<String, Map<String, Object>>> normalisedData, List<SObject> records){
        Schema.SObjectType typeOfRecords = records.getSObjectType();
        String dataType = LandChargeResponseMappings.getDataTypeFromSObjectType(typeOfRecords);
        Schema.SObjectField uniqueKeyField = LandChargeResponseMappings.getSFUniqueKeyFieldFromSObjectType(typeOfRecords);
        Map<String, Map<String, Object>> normalisedRecords = new Map<String, Map<String, Object>>();
        for(SObject record : records){
            Map<String, Object> populatedFields = record.getPopulatedFieldsAsMap(); // this is in the correct format already, but we expect to allow the arbitrary names to change
            Map<String, Object> normalisedFields = new Map<String, Object>();
            for(String fieldName : populatedFields.keySet()){
                Schema.SObjectField fieldToken = arcshared.Utils.getFieldToken(typeOfRecords.getDescribe().getName(), fieldName);
                normalisedFields.put(LandChargeResponseMappings.getArbitraryFieldFromSFField(fieldToken), populatedFields.get(fieldName));
            }
            normalisedRecords.put(String.valueOf(record.get(uniqueKeyField)), normalisedFields);
        }
        normalisedData.put(dataType, normalisedRecords);
    }

    global void process (arcusgazetteer.GISQuerySetContext context){
        // TODO: design error-handling.  Maybe needs to throw AuraHandled exceptions, but that might be
        //       done by Gazetteer when it calls this method.
        //
        try{
            final List<GISQueryResult> rawGISData = deserialiseGISDataString(context.getData());
            final arcuslandcharge__LCApplication__c landChargeSearchRecord = getLandChargeSearchRecord(context.getId());
            Map<String, Map<String, Map<String, Object>>> normalisedGISData = normaliseGISData(rawGISData); // this map is modified by side-effects later, so perhaps a different name would be clearer
            Map<String, Map<String, Map<String, Object>>> normalisedSFDataFromGISData = checkForSFDataMatchingGISData(normalisedGISData, landChargeSearchRecord).getNormalisedData();
            Map<String, Map<String, Map<String, Object>>> normalisedTextualData = runTextualSearch(landChargeSearchRecord).getNormalisedData();
            addTextualDataToSpatialData(normalisedGISData, normalisedSFDataFromGISData); // this has a side-effect.  Is the method name clear enough?
            addTextualDataToSpatialData(normalisedGISData, normalisedTextualData);
            List<SObject> responses = new List<SObject>();
            Boolean shouldSetResponseLookup = false;
            if(isCON29(landChargeSearchRecord) && !hasRunCON29(landChargeSearchRecord)){
                responses.add(buildCON29Response(normalisedGISData, landChargeSearchRecord)); // TODO: save DML in response trigger by updating lookup on search record here
                shouldSetResponseLookup = true;
            }
            if(isLLC1(landChargeSearchRecord)){
                responses.addAll(buildLLC1Responses(normalisedGISData, landChargeSearchRecord));
            }
            insertResponses(responses);
            if (shouldSetResponseLookup) landChargeSearchRecord.arcuslandcharge__Con29_Response__c = responses[0].Id;
            landChargeSearchRecord.arcuslandcharge__Search_DateTime__c = DateTime.now();
            update landChargeSearchRecord;
        } catch (Exception ex){
            System.debug(ex.getTypeName());
            System.debug(ex.getMessage());
            System.debug(ex.getLineNumber() );
            System.debug(ex.getStackTraceString());
            throw new AuraHandledException('Error running search');
        }
    }

    public Map<String, Map<String, Map<String, Object>>> getPlanningRadiusData(arcusgazetteer.GISQuerySetContext context){
        // This is an AVDC specific method.
        // In a better-designed solution, this would be in some extension of this class,
        // but right now this isn't an option.
        final List<GISQueryResult> rawGISData = deserialiseGISDataString(context.getData());
        final arcuslandcharge__LCApplication__c landChargeSearchRecord = getLandChargeSearchRecord(context.getId());
        Map<String, Map<String, Map<String, Object>>> normalisedGISData = normaliseGISData(rawGISData);
        Map<String, Map<String, Map<String, Object>>> normalisedSFDataFromGISData = checkForSFDataMatchingGISData(normalisedGISData, landChargeSearchRecord).getNormalisedData();
        addTextualDataToSpatialData(normalisedGISData, normalisedSFDataFromGISData);
        return normalisedGISData;
    }
    
    @testVisible
    private static List<GISQueryResult> deserialiseGISDataString(String data){
        // The gazetteer package currently passes a map with one key - the name of the query set
        // we don't know the name of the query set, however.
        // The unknown data types of the GIS data also prevent automatic deserialisation
        List<GISQueryResult> rawGISData = new List<GISQueryResult>();

        Object stepOne = ((Map<String, Object>) JSON.deserializeUntyped(data)).values()[0];
        List<Object> stepTwo = (List<Object>) JSON.deserializeUntyped(JSON.serialize(stepOne));
        for(Object thisObject : stepTwo){
            Map<String, Object> stepThree = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(thisObject));

            GISQueryResult thisResult = new GISQueryResult();
            thisResult.typeOfQuery = String.valueOf(stepThree.get('typeOfQuery'));
            thisResult.queryName = String.valueOf(stepThree.get('queryName'));
            thisResult.queryConfigurationID = Id.valueOf(String.valueOf(stepThree.get('queryConfigurationID')));
            thisResult.layerName = String.valueOf(stepThree.get('layerName'));
            thisResult.layerDevName = String.valueOf(stepThree.get('layerDevName'));
            thisResult.bufferValue = String.valueOf(stepThree.get('bufferValue'));
            thisResult.mapName = String.valueOf(stepThree.get('mapName'));

            thisResult.data = new Map<String, Map<String, Object>>();
            Object stepFour = ((List<Object>) JSON.deserializeUntyped(JSON.serialize(stepThree.get('data'))))[0];
            Map<String, Object> stepFive = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(stepFour));
            for(String featureId : stepFive.keySet()){
                Map<String, Object> featureAttributes = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(stepFive.get(featureId)));
                thisResult.data.put(featureId, featureAttributes);
            }

            rawGISData.add(thisResult);
        }

        return rawGISData;
    }

    @testVisible
    private static arcuslandcharge__LCApplication__c getLandChargeSearchRecord(Id recordId){
        return [SELECT Id, arcuslandcharge__Type__c,
                    arcuslandcharge__CON29O10_1__c, arcuslandcharge__CON29O10_2__c, arcuslandcharge__CON29O10_3__c,
                    arcuslandcharge__CON29O11_1__c, arcuslandcharge__CON29O11_2__c, arcuslandcharge__CON29O12_1__c,
                    arcuslandcharge__CON29O12_2__c, arcuslandcharge__CON29O12_3__c, arcuslandcharge__CON29O13__c,
                    arcuslandcharge__CON29O14_1__c, arcuslandcharge__CON29O14_2__c, arcuslandcharge__CON29O15_2__c,
                    arcuslandcharge__CON29O15__c, arcuslandcharge__CON29O16__c, arcuslandcharge__CON29O17_1__c,
                    arcuslandcharge__CON29O17_2a__c, arcuslandcharge__CON29O17_2b__c, arcuslandcharge__CON29O18__c,
                    arcuslandcharge__CON29O19__c, arcuslandcharge__CON29O20_1__c, arcuslandcharge__CON29O20_2a__c,
                    arcuslandcharge__CON29O20_2b__c, arcuslandcharge__CON29O21__c, arcuslandcharge__CON29O22_1__c,
                    arcuslandcharge__CON29O22_2__c, arcuslandcharge__CON29O22_3__c, arcuslandcharge__CON29O4a__c,
                    arcuslandcharge__CON29O4b__c, arcuslandcharge__CON29O5_1__c, arcuslandcharge__CON29O5_2__c,
                    arcuslandcharge__CON29O5_3a__c, arcuslandcharge__CON29O5_3b__c, arcuslandcharge__CON29O5_3c__c,
                    arcuslandcharge__CON29O5_3d__c, arcuslandcharge__CON29O5_3e__c, arcuslandcharge__CON29O6_3a__c,
                    arcuslandcharge__CON29O6_3b__c, arcuslandcharge__CON29O6_3c__c, arcuslandcharge__CON29O6_3d__c,
                    arcuslandcharge__CON29O6_3e__c, arcuslandcharge__CON29O6__c, arcuslandcharge__CON29O7_1__c,
                    arcuslandcharge__CON29O7_2__c, arcuslandcharge__CON29O8__c, arcuslandcharge__CON29O9__c,
                    arcuslandcharge__CON29R1_1a__c, arcuslandcharge__CON29R1_1b__c, arcuslandcharge__CON29R1_1c__c,
                    arcuslandcharge__CON29R1_1d__c, arcuslandcharge__CON29R1_1e__c, arcuslandcharge__CON29R1_1f__c,
                    arcuslandcharge__CON29R1_1g__c, arcuslandcharge__CON29R1_1h__c, arcuslandcharge__CON29R1_1i__c,
                    arcuslandcharge__CON29R1_1j__c, arcuslandcharge__CON29R1_1k__c, arcuslandcharge__CON29R1_1l__c,
                    arcuslandcharge__CON29R1_2__c, arcuslandcharge__CON29R2_1a__c, arcuslandcharge__CON29R2_1b__c,
                    arcuslandcharge__CON29R2_1c__c, arcuslandcharge__CON29R2_1d__c, arcuslandcharge__CON29R2_2__c,
                    arcuslandcharge__CON29R2_3__c, arcuslandcharge__CON29R2_4__c, arcuslandcharge__CON29R2_5__c,
                    arcuslandcharge__CON29R3_10a__c, arcuslandcharge__CON29R3_10b__c, arcuslandcharge__CON29R3_10c__c,
                    arcuslandcharge__CON29R3_10d__c, arcuslandcharge__CON29R3_10e__c, arcuslandcharge__CON29R3_10f__c,
                    arcuslandcharge__CON29R3_10g__c, arcuslandcharge__CON29R3_10h__c, arcuslandcharge__CON29R3_11a__c,
                    arcuslandcharge__CON29R3_11b__c, arcuslandcharge__CON29R3_12__c, arcuslandcharge__CON29R3_13a__c,
                    arcuslandcharge__CON29R3_13b__c, arcuslandcharge__CON29R3_13c__c, arcuslandcharge__CON29R3_14__c,
                    arcuslandcharge__CON29R3_15a__c, arcuslandcharge__CON29R3_15b__c, arcuslandcharge__CON29R3_1__c,
                    arcuslandcharge__CON29R3_2__c, arcuslandcharge__CON29R3_3a__c, arcuslandcharge__CON29R3_3b__c,
                    arcuslandcharge__CON29R3_3c__c, arcuslandcharge__CON29R3_4a__c, arcuslandcharge__CON29R3_4b__c,
                    arcuslandcharge__CON29R3_4c__c, arcuslandcharge__CON29R3_4d__c, arcuslandcharge__CON29R3_4e__c,
                    arcuslandcharge__CON29R3_4f__c, arcuslandcharge__CON29R3_5a__c, arcuslandcharge__CON29R3_5b__c,
                    arcuslandcharge__CON29R3_6a__c, arcuslandcharge__CON29R3_6b__c, arcuslandcharge__CON29R3_6c__c,
                    arcuslandcharge__CON29R3_6d__c, arcuslandcharge__CON29R3_6e__c, arcuslandcharge__CON29R3_6f__c,
                    arcuslandcharge__CON29R3_6g__c, arcuslandcharge__CON29R3_6h__c, arcuslandcharge__CON29R3_6i__c,
                    arcuslandcharge__CON29R3_6j__c, arcuslandcharge__CON29R3_6k__c, arcuslandcharge__CON29R3_6l__c,
                    arcuslandcharge__CON29R3_7a__c, arcuslandcharge__CON29R3_7b__c, arcuslandcharge__CON29R3_7c__c,
                    arcuslandcharge__CON29R3_7d__c, arcuslandcharge__CON29R3_7e__c, arcuslandcharge__CON29R3_7f__c,
                    arcuslandcharge__CON29R3_7g__c, arcuslandcharge__CON29R3_8__c, arcuslandcharge__CON29R3_9a__c,
                    arcuslandcharge__CON29R3_9b__c, arcuslandcharge__CON29R3_9c__c, arcuslandcharge__CON29R3_9d__c,
                    arcuslandcharge__CON29R3_9e__c, arcuslandcharge__CON29R3_9f__c, arcuslandcharge__CON29R3_9g__c,
                    arcuslandcharge__CON29R3_9h__c, arcuslandcharge__CON29R3_9i__c, arcuslandcharge__CON29R3_9j__c,
                    arcuslandcharge__CON29R3_9k__c, arcuslandcharge__CON29R3_9l__c, arcuslandcharge__CON29R3_9m__c,
                    arcuslandcharge__CON29R3_9n__c, arcuslandcharge__LLC1_11__c, arcuslandcharge__LLC1_12__c,
                    arcuslandcharge__LLC1_1__c, arcuslandcharge__LLC1_2__c, arcuslandcharge__LLC1_3__c,
                    arcuslandcharge__LLC1_4__c, arcuslandcharge__LLC1_5__c, arcuslandcharge__LLC1_6__c,
                    arcuslandcharge__LLC1_7__c, arcuslandcharge__LLC1_8__c, arcuslandcharge__LLC1_9__c,
                    arcuslandcharge__LLC1_10__c
                FROM arcuslandcharge__LCApplication__c
                WHERE Id = :recordId]; // TODO: use arcshared.RecordCRUDUtils
    }

    @testVisible
    private static Map<String, Map<String, Map<String, Object>>> normaliseGISData(List<GISQueryResult> rawGISData){
        Map<String, Map<String, Map<String, Object>>> normalisedData = new Map<String, Map<String, Map<String, Object>>>();
        for(GISQueryResult queryResult : rawGISData){
            String dataType = LandChargeResponseMappings.getDataTypeFromLayerName(queryResult.layerDevName);
            Map<String, Map<String, Object>> normalisedQueryResult; //
            if(normalisedData.containsKey(dataType)){
                normalisedQueryResult = normalisedData.get(dataType);
            } else {
                normalisedQueryResult = new Map<String, Map<String, Object>>();
                normalisedData.put(dataType, normalisedQueryResult);
            }

            for(String gisId : queryResult.data.keySet()){
                Map<String, Object> gisRecord = queryResult.data.get(gisId);
                Map<String, Object> normalisedRecord = new Map<String, Object>();
                String gisUniqueKeyField = LandChargeResponseMappings.getGISUniqueKeyFieldFromLayerName(queryResult.layerDevName);
                normalisedQueryResult.put(String.valueOf(gisRecord.get(gisUniqueKeyField)), normalisedRecord);
                for(String gisFieldName : gisRecord.keySet()){
                    Object fieldValue = gisRecord.get(gisFieldName);
                    if(fieldValue != null && LandChargeResponseMappings.isDateField(queryResult.layerDevName, gisFieldName)){
                        fieldValue = DateTime.newInstance(Long.valueOf((String) fieldValue));
                    }
                    normalisedRecord.put(LandChargeResponseMappings.getArbitraryFieldFromLayerNameAndGISField(queryResult.layerDevName, gisFieldName), fieldValue);
                }
            }
        }
        return normalisedData;
    }

    @testVisible
    private static SFDataWrapper checkForSFDataMatchingGISData(Map<String, Map<String, Map<String, Object>>> normalisedGISData, arcuslandcharge__LCApplication__c searchRecord){
        SFDataWrapper matchingData = new SFDataWrapper();
        String planningAppDataType = LandChargeResponseMappings.getDataTypeFromSObjectType(arcusbuiltenv__Planning_Application__c.SObjectType);
        String buildingControlAppDataType = LandChargeResponseMappings.getDataTypeFromSObjectType(arcusbuiltenv__Building_Control_Application__c.SObjectType);
        String enforcementDataType = LandChargeResponseMappings.getDataTypeFromSObjectType(arcusbuiltenv__Enforcement__c.SObjectType);
        String landChargeDataType = LandChargeResponseMappings.getDataTypeFromSObjectType(arcuslandcharge__LC_Register__c.SObjectType);
        String tpoDataType = LandChargeResponseMappings.getDataTypeFromSObjectType(arcusbuiltenv__Tree_Preservation_Order__c.SObjectType);
        String planningObligationDataType = LandChargeResponseMappings.getDataTypeFromSObjectType(arcusbuiltenv__Planning_Obligation__c.SObjectType);
        String appealDataType = LandChargeResponseMappings.getDataTypeFromSObjectType(arcusbuiltenv__Appeal__c.SObjectType);
        String assetDataType = LandChargeResponseMappings.getDataTypeFromSObjectType(Asset.SObjectType);
        String enforcementActionDataType = LandChargeResponseMappings.getDataTypeFromSObjectType(arcusbuiltenv__Action__c.SObjectType);

        Set<String> partsSelected = getLCRegisterPartsForQuery(searchRecord);

        //Get SObjects that match normalisedGISData
        if(normalisedGISData.containsKey(planningAppDataType)){
            matchingData.planningApps = [
                SELECT Id, Name, arcusbuiltenv__Proposal__c, arcusbuiltenv__Decision_Notice_Sent_Date__c, arcusbuiltenv__Site_Address__c, arcusbuiltenv__Type__c // TODO: read unique key field from mappings, and add other fields
                FROM arcusbuiltenv__Planning_Application__c
                WHERE Name IN :normalisedGISData.get(planningAppDataType).keySet()];
        }

        if(normalisedGISData.containsKey(buildingControlAppDataType)){
            matchingData.buildingControlApps = [
                SELECT Id, Name // TODO: read unique key field from mappings, and add other fields
                FROM arcusbuiltenv__Building_Control_Application__c
                WHERE Name IN :normalisedGISData.get(buildingControlAppDataType).keySet()];
        }
        if(normalisedGISData.containsKey(enforcementDataType)){
            List<arcusbuiltenv__Enforcement__c> enfs = [
                SELECT Id, Name, // TODO: read unique key field from mappings, and add other fields
                        (SELECT Id, Name, arcusbuiltenv__Type__c, arcusbuiltenv__Action_Date__c, 
                                arcusbuiltenv__Effective_Operational_Date__c, notice_reference__c, arcusbuiltenv__served_date__c, period_of_time_for_compliance_days__c,
                                arcusbuiltenv__compliance_date__c, arcusbuiltenv__withdrawn_date__c
                        FROM arcusbuiltenv__Actions__r)
                FROM arcusbuiltenv__Enforcement__c
                WHERE Name IN :normalisedGISData.get(enforcementDataType).keySet()];
            matchingData.enforcements = enfs;
            for(arcusbuiltenv__Enforcement__c enf: enfs)
            {
                matchingData.enforcementActions.addAll(enf.arcusbuiltenv__Actions__r);
            }
        }
        if(normalisedGISData.containsKey(tpoDataType)){
            matchingData.treePreservationOrders = [
                SELECT Id, Name // TODO: read unique key field from mappings, and add other fields
                FROM arcusbuiltenv__Tree_Preservation_Order__c
                WHERE Id IN :normalisedGISData.get(tpoDataType).keySet()];
        }
        if(normalisedGISData.containsKey(planningObligationDataType)){
            matchingData.planningObligations = [
                SELECT Id, Name // TODO: read unique key field from mappings, and add other fields
                FROM arcusbuiltenv__Planning_Obligation__c
                WHERE Name IN :normalisedGISData.get(planningObligationDataType).keySet()];
        }
        // if(normalisedGISData.containsKey(appealDataType)){
        //     System.debug(appealDataType);
        //     matchingData.appeals = [
        //         SELECT Id, Name // TODO: read unique key field from mappings, and add other fields
        //         FROM arcusbuiltenv__Appeal__c
        //         WHERE Name IN :normalisedGISData.get(appealDataType).keySet()];
        // }
        if(normalisedGISData.containsKey(assetDataType)){
            matchingData.assets = [
                SELECT Id, Name // TODO: read unique key field from mappings, and add other fields
                FROM Asset
                WHERE Name IN :normalisedGISData.get(assetDataType).keySet() 
                    AND RecordType.DeveloperName IN ('Locally_Listed_Heritage_Asset','Nationally_Listed_Heritage_Asset')];
        }
        // if(normalisedGISData.containsKey(enforcementActionDataType)){
        //     System.debug(enforcementActionDataType);
        //     matchingData.enforcementActions = [
        //         SELECT Id, Name // TODO: read unique key field from mappings, and add other fields
        //         FROM arcusbuiltenv__Action__c
        //         WHERE Name IN :normalisedGISData.get(enforcementActionDataType).keySet()];
        // }
        if(normalisedGISData.containsKey(landChargeDataType)){
            if(matchingData.landChargeRegistryEntries == null) matchingData.landChargeRegistryEntries = new List<arcuslandcharge__LC_Register__c>();
            matchingData.landChargeRegistryEntries.addAll([
                SELECT Id, arcuslandcharge__Register_Part__c // TODO: read unique key field from mappings, and add other fields
                FROM arcuslandcharge__LC_Register__c
                WHERE Id IN :normalisedGISData.get(landChargeDataType).keySet()
                AND arcuslandcharge__Status__c = 'Active'
                AND arcuslandcharge__Register_Part__c IN :partsSelected]);
        }

        //Gather ids of records found in above query to use in further queries
        Set<Id> treePreservationOrdersIds = new Map<Id, arcusbuiltenv__Tree_Preservation_Order__c>(matchingData.treePreservationOrders).keySet();
        Set<Id> planningObligationsIds = new Map<Id, arcusbuiltenv__Planning_Obligation__c>(matchingData.planningObligations).keySet();
        Set<Id> planningAppsIds = new Map<Id, arcusbuiltenv__Planning_Application__c>(matchingData.planningApps).keySet();
        Set<Id> assetsIds = new Map<Id, Asset>(matchingData.assets).keySet();
        Set<Id> actionIds = new Map<Id, arcusbuiltenv__Action__c>(matchingData.enforcementActions).keySet();


        if (planningAppsIds.size() > 0) matchingData.planningApplicationAppeals = getPlanningApplicationAppeals(planningAppsIds); 

        //Get Land Charge Register entries that lookup to records already found above
        matchingData.landChargeRegistryEntries.addAll([
            SELECT Id, Name, arcuslandcharge__Register_Part__c
            FROM arcuslandcharge__LC_Register__c
            WHERE arcuslandcharge__Status__c = 'Active'
            AND arcuslandcharge__Register_Part__c IN :partsSelected
            AND (
                    arcuslandcharge__Tree_Preservation_Order__c IN :treePreservationOrdersIds OR 
                    arcuslandcharge__Planning_Obligation__c IN :planningObligationsIds OR
                    arcuslandcharge__Planning_Application__c IN :planningAppsIds OR 
                    arcuslandcharge__Asset__c IN :assetsIds OR
                    Action__c IN :actionIds
            )
        ]);

        //Get Land Charge Register entries based on registerReferenceNumbers
        Set<String> registerReferenceNumbers = new Set<String>();
        if(normalisedGISData.containsKey(planningAppDataType)){
            registerReferenceNumbers.addAll(normalisedGISData.get(planningAppDataType).keyset());
        }
        if(normalisedGISData.containsKey(tpoDataType)){
            registerReferenceNumbers.addAll(normalisedGISData.get(tpoDataType).keyset());
        }

        for(String dataType : LandChargeResponseMappings.getLLC1DataTypes()){
            if(normalisedGISData.containsKey(dataType)){
                registerReferenceNumbers.addAll(normalisedGISData.get(dataType).keyset());
            }
        }

        if(!registerReferenceNumbers.isEmpty()){
            if(matchingData.landChargeRegistryEntries == null) matchingData.landChargeRegistryEntries = new List<arcuslandcharge__LC_Register__c>();
            matchingData.landChargeRegistryEntries.addAll([
                SELECT Id, Name, arcuslandcharge__Register_Part__c
                FROM arcuslandcharge__LC_Register__c
                WHERE arcuslandcharge__Related_Id__c IN :registerReferenceNumbers
                AND arcuslandcharge__Status__c = 'Active'
                AND arcuslandcharge__Register_Part__c IN :partsSelected]);
        }
        
        return matchingData;
    }

    private static List<arcusbuiltenv__Appeal__c> getPlanningApplicationAppeals(Set<Id> planningApplicationsIdSet) {
        return [SELECT Id, Name, arcusbuiltenv__Reference__c, arcusbuiltenv__Lodged_Date__c, arcusbuiltenv__Planning_Application__r.Name 
                FROM arcusbuiltenv__Appeal__c 
                WHERE arcusbuiltenv__Planning_Application__c IN :planningApplicationsIdSet];
    }

    @testVisible
    private static SFDataWrapper runTextualSearch(arcuslandcharge__LCApplication__c landChargeSearchRecord){
        //TODO read unique key field from mappings, and add other fields
        List<arcusgazetteer__BLPU__c> allBLPUs = [
            SELECT Id,
                    (SELECT Id, arcusbuiltenv__Planning_Application__c, arcusbuiltenv__Planning_Application__r.Name, arcusbuiltenv__Planning_Application__r.arcusbuiltenv__Proposal__c, arcusbuiltenv__Planning_Application__r.arcusbuiltenv__Decision_Notice_Sent_Date__c, arcusbuiltenv__Planning_Application__r.arcusbuiltenv__Site_Address__c, arcusbuiltenv__Planning_Application__r.arcusbuiltenv__Type__c,
                        arcusbuiltenv__Building_Control_Application__c, arcusbuiltenv__Building_Control_Application__r.Name,
                        arcuslandcharge__Land_Charge_Register__c, arcuslandcharge__Land_Charge_Register__r.Name, arcuslandcharge__Land_Charge_Register__r.arcuslandcharge__Register_Part__c,
                        arcusbuiltenv__Tree_Preservation_Order__c, arcusbuiltenv__Tree_Preservation_Order__r.Name,
                        arcusbuiltenv__Enforcement__c, arcusbuiltenv__Enforcement__r.Name,
                        arcusbuiltenv__Appeal__c, arcusbuiltenv__Appeal__r.Name,
                        arcusbuiltenv__Asset__c, arcusbuiltenv__Asset__r.Name
                    FROM arcusbuiltenv__BE_Location_Links__r)
                FROM arcusgazetteer__BLPU__c
                WHERE Id IN
                    (SELECT arcusbuiltenv__BLPU__c
                    FROM arcusbuiltenv__Related_Location__c
                    WHERE arcuslandcharge__LCApplication__c = :landChargeSearchRecord.Id)];

        Set<Id> relatedPlanningApplications = new Set<Id>();
        Set<Id> relatedEnforcements = new Set<Id>();
        SFDataWrapper sfData = new SFDataWrapper();
        Set<String> selectedParts = getLCRegisterPartsForQuery(landChargeSearchRecord);
        for(arcusgazetteer__BLPU__c thisBLPU : allBLPUs){
            for(arcusbuiltenv__Related_Location__c thisRelatedLocation : thisBLPU.arcusbuiltenv__BE_Location_Links__r){
                if(thisRelatedLocation.arcusbuiltenv__Planning_Application__r != null) {
                    sfData.planningApps.add(thisRelatedLocation.arcusbuiltenv__Planning_Application__r);
                    relatedPlanningApplications.add(thisRelatedLocation.arcusbuiltenv__Planning_Application__c);
                }
                if(thisRelatedLocation.arcusbuiltenv__Building_Control_Application__r != null) sfData.buildingControlApps.add(thisRelatedLocation.arcusbuiltenv__Building_Control_Application__r);
                if(thisRelatedLocation.arcuslandcharge__Land_Charge_Register__r != null && selectedParts.contains(thisRelatedLocation.arcuslandcharge__Land_Charge_Register__r.arcuslandcharge__Register_Part__c)) sfData.landChargeRegistryEntries.add(thisRelatedLocation.arcuslandcharge__Land_Charge_Register__r);
                if(thisRelatedLocation.arcusbuiltenv__Tree_Preservation_Order__r != null) sfData.treePreservationOrders.add(thisRelatedLocation.arcusbuiltenv__Tree_Preservation_Order__r);
                if(thisRelatedLocation.arcusbuiltenv__Enforcement__r != null) {
                    sfData.enforcements.add(thisRelatedLocation.arcusbuiltenv__Enforcement__r);
                    relatedEnforcements.add(thisRelatedLocation.arcusbuiltenv__Enforcement__c);
                }
                if(thisRelatedLocation.arcusbuiltenv__Appeal__r != null) sfData.appeals.add(thisRelatedLocation.arcusbuiltenv__Appeal__r);
                if(thisRelatedLocation.arcusbuiltenv__Asset__r != null) sfData.assets.add(thisRelatedLocation.arcusbuiltenv__Asset__r);
            }
        }

        if(relatedPlanningApplications.size() > 0){
            List<arcusbuiltenv__Planning_Obligation__c> planningObligations = [
                SELECT Id, Name
                FROM arcusbuiltenv__Planning_Obligation__c
                WHERE arcusbuiltenv__Planning_Application__c IN :relatedPlanningApplications];
            if(planningObligations.size() > 0) sfData.planningObligations.addAll(planningObligations);
        }

        if(relatedEnforcements.size() > 0){
            List<arcusbuiltenv__Action__c> enforcementActions = [
                SELECT  Id, Name, arcusbuiltenv__Type__c, arcusbuiltenv__Action_Date__c,
                        arcusbuiltenv__Effective_Operational_Date__c, notice_reference__c, arcusbuiltenv__served_date__c, period_of_time_for_compliance_days__c,
                        arcusbuiltenv__compliance_date__c, arcusbuiltenv__withdrawn_date__c
                FROM arcusbuiltenv__Action__c
                WHERE arcusbuiltenv__Enforcement__c IN :relatedEnforcements];
            if(enforcementActions.size() > 0) sfData.enforcementActions.addAll(enforcementActions);
        }

        Set<Id> treePreservationOrdersIds = new Map<Id, arcusbuiltenv__Tree_Preservation_Order__c>(sfData.treePreservationOrders).keySet();
        Set<Id> planningObligationsIds = new Map<Id, arcusbuiltenv__Planning_Obligation__c>(sfData.planningObligations).keySet();
        Set<Id> planningAppsIds = new Map<Id, arcusbuiltenv__Planning_Application__c>(sfData.planningApps).keySet();
        Set<Id> assetsIds = new Map<Id, Asset>(sfData.assets).keySet();
        Set<Id> actionsIds = new Map<Id, arcusbuiltenv__Action__c>(sfData.enforcementActions).keySet();

        sfData.landChargeRegistryEntries.addAll([
            SELECT  Id, Name, arcuslandcharge__Register_Part__c, arcuslandcharge__Status__c,
                    arcuslandcharge__Tree_Preservation_Order__c, arcuslandcharge__Planning_Obligation__c,
                    arcuslandcharge__Planning_Application__c,  arcuslandcharge__Asset__c
            FROM arcuslandcharge__LC_Register__c
            WHERE arcuslandcharge__Status__c = 'Active'
            AND arcuslandcharge__Register_Part__c IN :selectedParts
            AND (
                    arcuslandcharge__Tree_Preservation_Order__c IN :treePreservationOrdersIds OR 
                    arcuslandcharge__Planning_Obligation__c IN :planningObligationsIds OR
                    arcuslandcharge__Planning_Application__c IN :planningAppsIds OR 
                    arcuslandcharge__Asset__c IN :assetsIds OR
                    Action__c IN :actionsIds
            )
        ]);
        
        return sfData;
    }

    @testVisible
    private static void addTextualDataToSpatialData(Map<String, Map<String, Map<String, Object>>> spatialData, Map<String, Map<String, Map<String, Object>>> textualData){
        for(String textualDataType : textualData.keySet()){
            if(spatialData.containsKey(textualDataType)){ // TODO: this is where we would put config for SF vs GIS priority
                spatialData.get(textualDataType).putAll(textualData.get(textualDataType));
            } else {
                spatialData.put(textualDataType, textualData.get(textualDataType));
            }
        }
    }

    @testVisible
    private static Boolean isCON29(arcuslandcharge__LCApplication__c searchRecord){
        return areAnyFieldsTicked(searchRecord, LandChargeResponseMappings.getCON29SearchFields());
    }

    @testVisible
    private static Boolean hasRunCON29(arcuslandcharge__LCApplication__c searchRecord) {
        List<arcuslandcharge__CON29_Response__c> currentResponses = [SELECT Id FROM arcuslandcharge__CON29_Response__c WHERE arcuslandcharge__LCApplication__c =: searchRecord.Id];
        if(currentResponses != null && currentResponses.size() == 1) {
            return true;
        }

        return false;
    }

    @testVisible
    private static Boolean isLLC1(arcuslandcharge__LCApplication__c searchRecord){
        return areAnyFieldsTicked(searchRecord, LandChargeResponseMappings.getLLC1SearchFields());
    }

    @testVisible
    private static Boolean areAnyFieldsTicked(arcuslandcharge__LCApplication__c searchRecord, Set<Schema.SObjectField> fields){
        for(Schema.SObjectField field : fields){
            if((Boolean) searchRecord.get(field)) return true;
        }
        return false;
    }

    @testVisible
    private static Set<String> getLCRegisterPartsForQuery(arcuslandcharge__LCApplication__c searchRecord){
        Set<String> partsSelected = new Set<String>();
        for(Schema.SObjectField field : LandChargeResponseMappings.getLLC1SearchFields()){
            if((Boolean) searchRecord.get(field)) partsSelected.add(LandChargeResponseMappings.getRegisterPartValueFromSearchField(field));
        }
        return partsSelected;
    }

    public class QuestionConfig{ // having this here creates an odd dependency loop with mappings class...
        String answerForNoData = 'None.';
        String answerTemplate = 'Name: {!Planning Application.name}';
        Boolean answerUnique = false;
        public Map<String, DataTypeConfig> dataTypes;

        public String getAnswer(Map<String, Map<String, Map<String, Object>>> normalisedData, Map<String, Set<String>> mergeTokens){
            Map<String, Map<String, Map<String, Object>>> filteredData = new Map<String, Map<String, Map<String, Object>>>();
            for(String dataType : dataTypes.keySet()){
                if(!normalisedData.containsKey(dataType)) continue;
                DataTypeConfig thisConfig = dataTypes.get(dataType);
                Map<String, Map<String, Object>> filteredRecords = thisConfig.applyFilter(normalisedData.get(dataType));
                if(filteredRecords != null){
                    filteredData.put(dataType, filteredRecords);
                }
            }
            if(filteredData.isEmpty()) return answerForNoData;
            return runTemplateMerge(filteredData, mergeTokens);
        }
        @testVisible
        private String runTemplateMerge(Map<String, Map<String, Map<String, Object>>> filteredData, Map<String, Set<String>> mergeTokens){
            List<String> answerBuilder = new List<String>();
            for(String dataType : mergeTokens.keySet()){
                if(!filteredData.containsKey(dataType)) continue;
                List<Map<String, Object>> records = filteredData.get(dataType).values();
                Set<String> fieldNames = mergeTokens.get(dataType);
                for(Map<String, Object> record : records){
                    String answer = answerTemplate;
                    for(String fieldName : fieldNames){
                        String token = '{!' + dataType + '.' + fieldName + '}';
                        String value = record.containsKey(fieldName) ? getFormattedString(record.get(fieldName)): '';
                        answer = answer.replace(token, value);
                    }
                    answerBuilder.add(answer);
                    if(answerUnique != null && answerUnique) break;
                }
            }
            String dataTypeAndFieldNameTokenRegex = '\\{![A-Za-z0-9\\s]+\\.[A-Za-z0-9\\|\\_]+\\}';
            String cleanedAnswer = String.join(answerBuilder,'\r\n').replaceAll(dataTypeAndFieldNameTokenRegex, '');
            return cleanedAnswer;
        }

        private String getFormattedString(Object fieldValue){
            if(fieldValue instanceof Date) return ((Date) fieldValue).format();
            if(fieldValue instanceof DateTime) return ((DateTime) fieldValue).format('dd/MM/yyyy');
            return String.valueOf(fieldValue);
        }
    }

    private static final CriteriaMatcherClone criteriaMatcher = new CriteriaMatcherClone();
    public class DataTypeConfig{
        public List<CriteriaMatcherClone.Rule> criteria = new List<CriteriaMatcherClone.Rule>();
        public Map<String, Map<String, Object>> applyFilter(Map<String, Map<String, Object>> records){
            Map<String, Map<String, Object>> filteredRecords = new Map<String, Map<String, Object>>();
            for(String key : records.keySet()){
                Map<String, Object> record = records.get(key);
                if(criteriaMatcher.match(record, criteria)){
                    filteredRecords.put(key, record.clone());
                }
            }
            if(filteredRecords.isEmpty()) return null;
            return filteredRecords;
        }
    }

    public class LLC1Config{
        public List<CriteriaMatcherClone.Rule> criteria = new List<CriteriaMatcherClone.Rule>();
        public Map<String, String> fieldTemplates;

        public Map<String, Map<String, Object>> applyFilter(Map<String, Map<String, Object>> records){
            Map<String, Map<String, Object>> filteredRecords = new Map<String, Map<String, Object>>();
            for(String key : records.keySet()){
                Map<String, Object> record = records.get(key);
                if(criteriaMatcher.match(record, criteria)){
                    filteredRecords.put(key, record.clone());
                }
            }
            if(filteredRecords.isEmpty()) return null;
            return filteredRecords;
        }

        public List<arcuslandcharge__LLC1_Response__c> getRecords(Map<String, Map<String, Object>> records, Id searchId){
            Map<String, Map<String, Object>> filteredRecords = applyFilter(records);
            if(filteredRecords == null) return new List<arcuslandcharge__LLC1_Response__c>();
            List<arcuslandcharge__LLC1_Response__c> responses = new List<arcuslandcharge__LLC1_Response__c>();
            for(Map<String, Object> record : filteredRecords.values()){
                arcuslandcharge__LLC1_Response__c response = new arcuslandcharge__LLC1_Response__c(arcuslandcharge__LC_Application__c = searchId);
                for(String responseField : fieldTemplates.keySet()){
                    String value = fieldTemplates.get(responseField);
                    for(String dataField : record.keySet()){
                        value = value.replace('{!' + dataField + '}', String.valueOf(record.get(dataField)));
                    }
                    response.put(responseField, value);
                }
                responses.add(response);
            }
            return responses;
        }
    }

    public static Map<String, Set<String>> extractMergeTokens(Map<String, Map<String, Map<String, Object>>> normalisedData){
        Map<String, Set<String>> tokens = new Map<String, Set<String>>();
        for(String dataType : normalisedData.keySet()){
            Set<String> allFieldNames = new Set<String>();
            tokens.put(dataType, allFieldNames);
            for(Map<String, Object> record : normalisedData.get(dataType).values()){
                allFieldNames.addAll(record.keySet());
            }
        }
        return tokens;
    }

    @testVisible
    private static arcuslandcharge__CON29_Response__c buildCON29Response(Map<String, Map<String, Map<String, Object>>> normalisedData, arcuslandcharge__LCApplication__c searchRecord){
        final Map<String, Set<String>> mergeTokens = extractMergeTokens(normalisedData); // TODO: find a more elegant way to cache this data...
        arcuslandcharge__CON29_Response__c response = new arcuslandcharge__CON29_Response__c(arcuslandcharge__LCApplication__c = searchRecord.Id);
        for(String fieldName : LandChargeResponseMappings.getCON29FieldNames()){
            if(Boolean.valueOf(searchRecord.get(fieldName))){ // TODO: see if 'search all' Boolean is actually useful
                response.put(fieldName, LandChargeResponseMappings.getConfigForQuestion(fieldName).getAnswer(normalisedData, mergeTokens));
            } else {
                response.put(fieldName, 'This question was not asked.');
            }
        }
        return response;
    }

    @testVisible
    private static List<arcuslandcharge__LLC1_Response__c> buildLLC1Responses(Map<String, Map<String, Map<String, Object>>> normalisedData, arcuslandcharge__LCApplication__c searchRecord){
        List<arcuslandcharge__LLC1_Response__c> responses = new List<arcuslandcharge__LLC1_Response__c>();

        List<arcuslandcharge__LLC1_Response__c> currentResponses = [SELECT Id FROM arcuslandcharge__LLC1_Response__c WHERE arcuslandcharge__LC_Application__c =: searchRecord.Id];
        if(currentResponses != null && currentResponses.size() > 0) {
            delete currentResponses;
        }

        for(String dataType : normalisedData.keySet()){
            LLC1Config config = LandChargeResponseMappings.getConfigForDataType(dataType);
            if(config == null) continue;
            Map<String, Map<String, Object>> records = normalisedData.get(dataType);
            responses.addAll(config.getRecords(records, searchRecord.Id));
        }
        return responses;
    }

    @testVisible
    private static void insertResponses(List<SObject> responses){
        if(!responses.isEmpty()){
            Database.DMLOptions truncateSetting = new Database.DMLOptions();
            truncateSetting.allowFieldTruncation = true;

            Database.insert(responses, truncateSetting);
        }
    }
}