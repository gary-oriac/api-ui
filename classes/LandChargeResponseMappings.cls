public class LandChargeResponseMappings {

    public static String getDataTypeFromSObjectType(Schema.SObjectType inputType){
        return SOBJECT_TO_DATA_TYPE.get(inputType);
    }
    public static Schema.SObjectField getSFUniqueKeyFieldFromSObjectType(Schema.SObjectType inputType){
        return SOBJECT_TO_SF_UNIQUE_KEY_FIELD.get(inputType);
    }
    public static String getArbitraryFieldFromSFField(Schema.SObjectField inputField){
        return SF_FIELD_TO_ARBITRARY_FIELD.get(inputField);
    }

    public static String getDataTypeFromLayerName(String layerDeveloperName){
        if(!LAYER_TO_DATA_TYPE.containsKey(layerDeveloperName)) return layerDeveloperName;
        return LAYER_TO_DATA_TYPE.get(layerDeveloperName);
    }
    public static String getGISUniqueKeyFieldFromLayerName(String layerDeveloperName){
        if(!LAYER_TO_GIS_UNIQUE_KEY.containsKey(layerDeveloperName)) return layerDeveloperName;
        return LAYER_TO_GIS_UNIQUE_KEY.get(layerDeveloperName);
    }
    public static String getArbitraryFieldFromLayerNameAndGISField(String layerDeveloperName, String gisFieldName){
        Map<String, String> fieldMap = LAYER_TO_GIS_FIELD_TO_ARBITRARY_FIELD.get(layerDeveloperName);
        if(fieldMap == null || !fieldMap.containsKey(gisFieldName)) return gisFieldName;
        return fieldMap.get(gisFieldName);
    }

    public static Boolean isDateField(String layerDeveloperName, String gisFieldName){
        if(!LAYER_TO_DATE_FIELDS.containsKey(layerDeveloperName)) return false;
        return LAYER_TO_DATE_FIELDS.get(layerDeveloperName).contains(gisFieldName);
    }

    public static Set<String> getCON29FieldNames(){
        return CON29_FIELD_NAMES;
    }

    public static Set<Schema.SObjectField> getCON29SearchFields(){
        Set<Schema.SObjectField> fields = new Set<Schema.SObjectField>();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.arcuslandcharge__LCApplication__c.fields.getMap();
        for(String fieldName : CON29_FIELD_NAMES) fields.add(fieldMap.get(fieldName));
        return fields;
    }

    public static Set<Schema.SObjectField> getLLC1SearchFields(){
        return LLC1_FIELD_TO_PICKLIST_VALUE.keySet();
    }

    public static String getRegisterPartValueFromSearchField(Schema.SObjectField field){
        return LLC1_FIELD_TO_PICKLIST_VALUE.get(field);
    }

    public static LandChargeResponseGenerator.QuestionConfig getConfigForQuestion(String fieldName){
        return QUESTION_TO_CONFIG.get(fieldName);
    }

    public static LandChargeResponseGenerator.LLC1Config getConfigForDataType(String dataType){
        return LLC1_CONFIG.get(dataType);
    }

    public static Set<String> getLLC1DataTypes(){
        return new Set<String>{
            'Land Charge By Reference',
            'Enforcement Action',
            'Article 4',
            'Compulsory Purchase Order'
        };
    }

    private static final Map<Schema.SObjectType, String> SOBJECT_TO_DATA_TYPE = new Map<Schema.SObjectType, String>{
        arcusbuiltenv__Planning_Application__c.SObjectType => 'Planning Application',
        arcusbuiltenv__Building_Control_Application__c.SObjectType => 'Building Control Application',
        arcusbuiltenv__Enforcement__c.SObjectType => 'Enforcement',
        arcuslandcharge__LC_Register__c.SObjectType => 'Land Charge',
        arcusbuiltenv__Tree_Preservation_Order__c.SObjectType => 'Tree Preservation Order',
        arcusbuiltenv__Planning_Obligation__c.SObjectType => 'Planning Obligation',
        arcusbuiltenv__Appeal__c.SObjectType => 'Appeal',
        Asset.SObjectType => 'Heritage Asset',
        arcusbuiltenv__Action__c.SObjectType => 'Enforcement Action'
    };
    private static final Map<Schema.SObjectType, Schema.SObjectField> SOBJECT_TO_SF_UNIQUE_KEY_FIELD = new Map<Schema.SObjectType, Schema.SObjectField>{
        arcusbuiltenv__Planning_Application__c.SObjectType => arcusbuiltenv__Planning_Application__c.Name,
        arcusbuiltenv__Building_Control_Application__c.SObjectType => arcusbuiltenv__Building_Control_Application__c.Name,
        arcusbuiltenv__Enforcement__c.SObjectType => arcusbuiltenv__Enforcement__c.Name,
        arcuslandcharge__LC_Register__c.SObjectType => arcuslandcharge__LC_Register__c.Id,
        arcusbuiltenv__Tree_Preservation_Order__c.SObjectType => arcusbuiltenv__Tree_Preservation_Order__c.Id,
        arcusbuiltenv__Planning_Obligation__c.SObjectType => arcusbuiltenv__Planning_Obligation__c.Name,
        arcusbuiltenv__Appeal__c.SObjectType => arcusbuiltenv__Appeal__c.Name,
        Asset.SObjectType => Asset.Name,
        arcusbuiltenv__Action__c.SObjectType => arcusbuiltenv__Action__c.Name
    };
    private static final Map<Schema.SObjectField, String> SF_FIELD_TO_ARBITRARY_FIELD;
    static{
        // for now, we will name all fields in the arbitrary data types in exactly the same way as the Salesforce
        // fields are named.  We could probably have done the same with the SObject names too...
        // (actually, this puts them in lower case)
        SF_FIELD_TO_ARBITRARY_FIELD = new Map<Schema.SObjectField, String>();
        Map<String, Schema.SObjectField> planningFields = arcshared.Utils.getFieldTokens('arcusbuiltenv__Planning_Application__c');
        Map<String, Schema.SObjectField> buildingControlFields = arcshared.Utils.getFieldTokens('arcusbuiltenv__Building_Control_Application__c');
        Map<String, Schema.SObjectField> enforcementFields = arcshared.Utils.getFieldTokens('arcusbuiltenv__Enforcement__c');
        Map<String, Schema.SObjectField> tpoFields = arcshared.Utils.getFieldTokens('arcusbuiltenv__Tree_Preservation_Order__c');
        Map<String, Schema.SObjectField> landChargeFields = arcshared.Utils.getFieldTokens('arcuslandcharge__LC_Register__c');
        Map<String, Schema.SObjectField> planningObligationFields = arcshared.Utils.getFieldTokens('arcusbuiltenv__Planning_Obligation__c');
        Map<String, Schema.SObjectField> appealFields = arcshared.Utils.getFieldTokens('arcusbuiltenv__Appeal__c');
        Map<String, Schema.SObjectField> assetFields = arcshared.Utils.getFieldTokens('Asset');
        Map<String, Schema.SObjectField> enforcementActionFields = arcshared.Utils.getFieldTokens('arcusbuiltenv__Action__c');

        for(String fieldName : planningFields.keySet()){
            SF_FIELD_TO_ARBITRARY_FIELD.put(planningFields.get(fieldName), fieldName);
        }
        for(String fieldName : buildingControlFields.keySet()){
            SF_FIELD_TO_ARBITRARY_FIELD.put(buildingControlFields.get(fieldName), fieldName);
        }
        for(String fieldName : enforcementFields.keySet()){
            SF_FIELD_TO_ARBITRARY_FIELD.put(enforcementFields.get(fieldName), fieldName);
        }
        for(String fieldName : tpoFields.keySet()){
            SF_FIELD_TO_ARBITRARY_FIELD.put(tpoFields.get(fieldName), fieldName);
        }
        for(String fieldName : landChargeFields.keySet()){
            SF_FIELD_TO_ARBITRARY_FIELD.put(landChargeFields.get(fieldName), fieldName);
        }
        for(String fieldName : planningObligationFields.keySet()){
            SF_FIELD_TO_ARBITRARY_FIELD.put(planningObligationFields.get(fieldName), fieldName);
        }
        for(String fieldName : appealFields.keySet()){
            SF_FIELD_TO_ARBITRARY_FIELD.put(appealFields.get(fieldName), fieldName);
        }
        for(String fieldName : assetFields.keySet()){
            SF_FIELD_TO_ARBITRARY_FIELD.put(assetFields.get(fieldName), fieldName);
        }
        for(String fieldName : enforcementActionFields.keySet()){
            SF_FIELD_TO_ARBITRARY_FIELD.put(enforcementActionFields.get(fieldName), fieldName);
        }
    }
    private static final Map<String, String> LAYER_TO_DATA_TYPE;
    private static final Map<String, String> LAYER_TO_GIS_UNIQUE_KEY;
    private static final Map<String, Map<String, String>> LAYER_TO_GIS_FIELD_TO_ARBITRARY_FIELD;
    private static final Map<String, Set<String>> LAYER_TO_DATE_FIELDS;
    public class GISMapping{ // TODO: make private
        public Map<String, String> LAYER_TO_DATA_TYPE;
        public Map<String, String> LAYER_TO_GIS_UNIQUE_KEY;
        public Map<String, Map<String, String>> LAYER_TO_GIS_FIELD_TO_ARBITRARY_FIELD;
        public Map<String, Set<String>> LAYER_TO_DATE_FIELDS;
    }
    static{
        List<StaticResource> mappingFile = [SELECT Body
                                            FROM StaticResource
                                            WHERE Name = 'LandChargesGISMapping'];
        if(!Test.isRunningTest() && mappingFile.size() == 1){
            GISMapping staticResourceData = (GISMapping) JSON.deserialize(mappingFile[0].Body.toString(), GISMapping.class);
            LAYER_TO_DATA_TYPE = staticResourceData.LAYER_TO_DATA_TYPE;
            LAYER_TO_GIS_UNIQUE_KEY = staticResourceData.LAYER_TO_GIS_UNIQUE_KEY;
            LAYER_TO_GIS_FIELD_TO_ARBITRARY_FIELD = staticResourceData.LAYER_TO_GIS_FIELD_TO_ARBITRARY_FIELD;
            LAYER_TO_DATE_FIELDS = staticResourceData.LAYER_TO_DATE_FIELDS;
        } else {
            LAYER_TO_DATA_TYPE = new Map<String, String>{
                'SF_Planning_Test_Layer' => 'Planning Application',
                'Land_Charge_Layer' => 'Land Charges', // TODO: get actual layers from AVDC sandbox
                'Advert_control' => 'Advert Control' // used in tests
            };

            LAYER_TO_GIS_UNIQUE_KEY = new Map<String, String>{
                'SF_Planning_Test_Layer' => 'REFVAL',
                'Land_Charge_Layer' => '???', // TODO: get actual layers and fields from AVDC sandbox
                'Advert_control' => 'GlobalID' // used in tests
            };

            LAYER_TO_GIS_FIELD_TO_ARBITRARY_FIELD = new Map<String, Map<String, String>>{
                'SF_Planning_Test_Layer' => new Map<String, String>{
                    'REFVAL' => 'name'
                },
                'Land_Charge_Layer' => new Map<String, String>{
                    '???' => 'name'
                },
                'Advert_control' => new Map<String, String>{
                    'GlobalID' => 'GIS Id'
                }
            };

            LAYER_TO_DATE_FIELDS = new Map<String, Set<String>>();
        }
    }

    private static final Set<String> CON29_FIELD_NAMES = new Set<String>{
        'arcuslandcharge__CON29O10_1__c',
        'arcuslandcharge__CON29O10_2__c',
        'arcuslandcharge__CON29O10_3__c',
        'arcuslandcharge__CON29O11_1__c',
        'arcuslandcharge__CON29O11_2__c',
        'arcuslandcharge__CON29O12_1__c',
        'arcuslandcharge__CON29O12_2__c',
        'arcuslandcharge__CON29O12_3__c',
        'arcuslandcharge__CON29O13__c',
        'arcuslandcharge__CON29O14_1__c',
        'arcuslandcharge__CON29O14_2__c',
        // 'arcuslandcharge__CON29O15_2__c', // missing from CON29 Response
        'arcuslandcharge__CON29O15__c',
        'arcuslandcharge__CON29O16__c',
        'arcuslandcharge__CON29O17_1__c',
        'arcuslandcharge__CON29O17_2a__c',
        'arcuslandcharge__CON29O17_2b__c',
        'arcuslandcharge__CON29O18__c',
        'arcuslandcharge__CON29O19__c',
        'arcuslandcharge__CON29O20_1__c',
        'arcuslandcharge__CON29O20_2a__c',
        'arcuslandcharge__CON29O20_2b__c',
        'arcuslandcharge__CON29O21__c',
        'arcuslandcharge__CON29O22_1__c',
        'arcuslandcharge__CON29O22_2__c',
        'arcuslandcharge__CON29O22_3__c',
        'arcuslandcharge__CON29O4a__c',
        'arcuslandcharge__CON29O4b__c',
        'arcuslandcharge__CON29O5_1__c',
        'arcuslandcharge__CON29O5_2__c',
        'arcuslandcharge__CON29O5_3a__c',
        'arcuslandcharge__CON29O5_3b__c',
        'arcuslandcharge__CON29O5_3c__c',
        'arcuslandcharge__CON29O5_3d__c',
        'arcuslandcharge__CON29O5_3e__c',
        // 'arcuslandcharge__CON29O6_3a__c',
        // 'arcuslandcharge__CON29O6_3b__c',
        // 'arcuslandcharge__CON29O6_3c__c',
        // 'arcuslandcharge__CON29O6_3d__c',
        // 'arcuslandcharge__CON29O6_3e__c',
        'arcuslandcharge__CON29O6__c',
        'arcuslandcharge__CON29O7_1__c',
        'arcuslandcharge__CON29O7_2__c',
        'arcuslandcharge__CON29O8__c',
        'arcuslandcharge__CON29O9__c',
        'arcuslandcharge__CON29R1_1a__c',
        'arcuslandcharge__CON29R1_1b__c',
        'arcuslandcharge__CON29R1_1c__c',
        'arcuslandcharge__CON29R1_1d__c',
        'arcuslandcharge__CON29R1_1e__c',
        'arcuslandcharge__CON29R1_1f__c',
        'arcuslandcharge__CON29R1_1g__c',
        'arcuslandcharge__CON29R1_1h__c',
        'arcuslandcharge__CON29R1_1i__c',
        'arcuslandcharge__CON29R1_1j__c',
        'arcuslandcharge__CON29R1_1k__c',
        'arcuslandcharge__CON29R1_1l__c',
        'arcuslandcharge__CON29R1_2__c',
        'arcuslandcharge__CON29R2_1a__c',
        'arcuslandcharge__CON29R2_1b__c',
        'arcuslandcharge__CON29R2_1c__c',
        'arcuslandcharge__CON29R2_1d__c',
        'arcuslandcharge__CON29R2_2__c',
        'arcuslandcharge__CON29R2_3__c',
        'arcuslandcharge__CON29R2_4__c',
        'arcuslandcharge__CON29R2_5__c',
        'arcuslandcharge__CON29R3_10a__c',
        'arcuslandcharge__CON29R3_10b__c',
        'arcuslandcharge__CON29R3_10c__c',
        'arcuslandcharge__CON29R3_10d__c',
        'arcuslandcharge__CON29R3_10e__c',
        'arcuslandcharge__CON29R3_10f__c',
        'arcuslandcharge__CON29R3_10g__c',
        'arcuslandcharge__CON29R3_10h__c',
        'arcuslandcharge__CON29R3_11a__c',
        'arcuslandcharge__CON29R3_11b__c',
        'arcuslandcharge__CON29R3_12__c',
        'arcuslandcharge__CON29R3_13a__c',
        'arcuslandcharge__CON29R3_13b__c',
        'arcuslandcharge__CON29R3_13c__c',
        'arcuslandcharge__CON29R3_14__c',
        'arcuslandcharge__CON29R3_15a__c',
        'arcuslandcharge__CON29R3_15b__c',
        'arcuslandcharge__CON29R3_1__c',
        'arcuslandcharge__CON29R3_2__c',
        'arcuslandcharge__CON29R3_3a__c',
        'arcuslandcharge__CON29R3_3b__c',
        'arcuslandcharge__CON29R3_3c__c',
        'arcuslandcharge__CON29R3_4a__c',
        'arcuslandcharge__CON29R3_4b__c',
        'arcuslandcharge__CON29R3_4c__c',
        'arcuslandcharge__CON29R3_4d__c',
        'arcuslandcharge__CON29R3_4e__c',
        'arcuslandcharge__CON29R3_4f__c',
        'arcuslandcharge__CON29R3_5a__c',
        'arcuslandcharge__CON29R3_5b__c',
        'arcuslandcharge__CON29R3_6a__c',
        'arcuslandcharge__CON29R3_6b__c',
        'arcuslandcharge__CON29R3_6c__c',
        'arcuslandcharge__CON29R3_6d__c',
        'arcuslandcharge__CON29R3_6e__c',
        'arcuslandcharge__CON29R3_6f__c',
        'arcuslandcharge__CON29R3_6g__c',
        'arcuslandcharge__CON29R3_6h__c',
        'arcuslandcharge__CON29R3_6i__c',
        'arcuslandcharge__CON29R3_6j__c',
        'arcuslandcharge__CON29R3_6k__c',
        'arcuslandcharge__CON29R3_6l__c',
        'arcuslandcharge__CON29R3_7a__c',
        'arcuslandcharge__CON29R3_7b__c',
        'arcuslandcharge__CON29R3_7c__c',
        'arcuslandcharge__CON29R3_7d__c',
        'arcuslandcharge__CON29R3_7e__c',
        'arcuslandcharge__CON29R3_7f__c',
        'arcuslandcharge__CON29R3_7g__c',
        'arcuslandcharge__CON29R3_8__c',
        'arcuslandcharge__CON29R3_9a__c',
        'arcuslandcharge__CON29R3_9b__c',
        'arcuslandcharge__CON29R3_9c__c',
        'arcuslandcharge__CON29R3_9d__c',
        'arcuslandcharge__CON29R3_9e__c',
        'arcuslandcharge__CON29R3_9f__c',
        'arcuslandcharge__CON29R3_9g__c',
        'arcuslandcharge__CON29R3_9h__c',
        'arcuslandcharge__CON29R3_9i__c',
        'arcuslandcharge__CON29R3_9j__c',
        'arcuslandcharge__CON29R3_9k__c',
        'arcuslandcharge__CON29R3_9l__c',
        'arcuslandcharge__CON29R3_9m__c',
        'arcuslandcharge__CON29R3_9n__c'
    };

    private static final Map<Schema.SObjectField, String> LLC1_FIELD_TO_PICKLIST_VALUE = new Map<Schema.SObjectField, String>{
            arcuslandcharge__LCApplication__c.arcuslandcharge__LLC1_1__c => 'Part 1: General Financial Charges',
            arcuslandcharge__LCApplication__c.arcuslandcharge__LLC1_2__c => 'Part 2: Specific Financial Charges',
            arcuslandcharge__LCApplication__c.arcuslandcharge__LLC1_3__c => 'Part 3: Planning Charges',
            arcuslandcharge__LCApplication__c.arcuslandcharge__LLC1_4__c => 'Part 4: Miscellaneous Charges',
            arcuslandcharge__LCApplication__c.arcuslandcharge__LLC1_5__c => 'Part 5: Fenland Ways Maintenance Charges',
            arcuslandcharge__LCApplication__c.arcuslandcharge__LLC1_6__c => 'Part 6: Land Compensation Charges',
            arcuslandcharge__LCApplication__c.arcuslandcharge__LLC1_7__c => 'Part 7: New Towns Charges',
            arcuslandcharge__LCApplication__c.arcuslandcharge__LLC1_8__c => 'Part 8: Civil Aviation Charges',
            arcuslandcharge__LCApplication__c.arcuslandcharge__LLC1_9__c => 'Part 9: Opencast Coal Charges',
            arcuslandcharge__LCApplication__c.arcuslandcharge__LLC1_10__c => 'Part 10: Listed Buildings Charges',
            arcuslandcharge__LCApplication__c.arcuslandcharge__LLC1_11__c => 'Part 11: Light Obstruction Notices',
            arcuslandcharge__LCApplication__c.arcuslandcharge__LLC1_12__c => 'Part 12: Drainage Scheme Charges'
        };

    private static final Map<String, LandChargeResponseGenerator.QuestionConfig> QUESTION_TO_CONFIG;
    static{
        List<StaticResource> mappingFile = [SELECT Body
                                            FROM StaticResource
                                            WHERE Name = 'UnamangedLandChargeMapping'];
        if(!Test.isRunningTest() && mappingFile.size() == 1){
            QUESTION_TO_CONFIG = (Map<String, LandChargeResponseGenerator.QuestionConfig>) JSON.deserialize(mappingFile[0].Body.toString(), Map<String, LandChargeResponseGenerator.QuestionConfig>.class);
        } else {
            QUESTION_TO_CONFIG = new Map<String, LandChargeResponseGenerator.QuestionConfig>();
            LandChargeResponseGenerator.QuestionConfig emptyConfig = new LandChargeResponseGenerator.QuestionConfig();
            emptyConfig.dataTypes = new Map<String, LandChargeResponseGenerator.DataTypeConfig>{
                'Planning Application' => new LandChargeResponseGenerator.DataTypeConfig(),
                'Advert Control' => new LandChargeResponseGenerator.DataTypeConfig()
            };
            for(String field : CON29_FIELD_NAMES){
                QUESTION_TO_CONFIG.put(field, emptyConfig);
            }
            LandChargeResponseGenerator.QuestionConfig ethelConfig = new LandChargeResponseGenerator.QuestionConfig();
            LandChargeResponseGenerator.DataTypeConfig ethelDataTypeConfig = new LandChargeResponseGenerator.DataTypeConfig();
            CriteriaMatcherClone.Rule ethelRule = new CriteriaMatcherClone.Rule();
            ethelRule.field = 'potato';
            ethelRule.firstValue = 'Ethel';
            ethelRule.type = 'string';
            ethelRule.comparator = 'equals';
            ethelDataTypeConfig.criteria.add(ethelRule);
            ethelConfig.dataTypes = new Map<String, LandChargeResponseGenerator.DataTypeConfig>{
                'Planning Application' => ethelDataTypeConfig,
                'Advert Control' => ethelDataTypeConfig
            };
            QUESTION_TO_CONFIG.put('arcuslandcharge__CON29R3_9n__c', ethelConfig);
        }
    }

    private static final Map<String, LandChargeResponseGenerator.LLC1Config> LLC1_CONFIG;
    static{
            List<StaticResource> mappingFile = [SELECT Body
                                        FROM StaticResource
                                        WHERE Name = 'UnamangedLLC1Templates'];
        if(!Test.isRunningTest() && mappingFile.size() == 1){
            LLC1_CONFIG = (Map<String, LandChargeResponseGenerator.LLC1Config>) JSON.deserialize(mappingFile[0].Body.toString(), Map<String, LandChargeResponseGenerator.LLC1Config>.class);
        } else {
            LandChargeResponseGenerator.LLC1Config basicConfig = new LandChargeResponseGenerator.LLC1Config();
            basicConfig.fieldTemplates = new Map<String, String>();

            LLC1_CONFIG = new Map<String, LandChargeResponseGenerator.LLC1Config>{
                'Planning Application' => basicConfig
            };
        }
    }
}