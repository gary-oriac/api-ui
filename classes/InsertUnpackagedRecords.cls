public with sharing class InsertUnpackagedRecords {

	public static Integer s_CongaTemplatesAmount;
	public static Integer s_CongaQueriesAmount;
	public static Integer s_CustomSettingsAmount;

	public static final String APP_CONFIG_CATEGORY_FIELD_VALUE_FOR_TRIGGER_DEFINITIONS = 'TriggerHandlers';
    public static final String APP_CONFIG_TYPE_FIELD_VALUE_FOR_TRIGGER_DEFINITIONS = 'TriggerSetting';
    public static final Integer DEFAULT_TRIGGER_ORDER = 1;
    public static final Integer DEFAULT_APPCONFIG_ORDER_FIELD_VALUE = 1;
	public static final Boolean DEFAULT_APPCONFIG_AVAILABLE_FIELD_VALUE = true;
	public static final Boolean DEFAULT_APPCONFIG_EDITABLE_FIELD_VALUE = false;
    public static final List<String> OPTION_ALL_RECORD_TYPES = new List<String>();
    public static final Integer NUMBER_TRIGGER_CUSTOM_SETTINGS_INSERTED = 1;

	
	public static void insertCongaTemplates(){
		List<APXTConga4__Conga_Template__c> congaTemplates = new List<APXTConga4__Conga_Template__c>();
		congaTemplates.add(new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Tenant Service Request',
															APXTConga4__Template_Type__c = 'Document',
															APXTConga4__Template_Group__c = 'Regserv',
															APXTConga4__Description__c = 'Tenant Service Request Form'
		));
		congaTemplates.add(new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Statement Of Reasons',
															APXTConga4__Template_Type__c = 'Document',
															APXTConga4__Template_Group__c = 'Regserv',
															APXTConga4__Description__c = 'Statement Of Reasons For Housing Inspection'
		));
		
		insert congaTemplates;

		s_CongaTemplatesAmount = congaTemplates.size();
	}

	public static void insertCongaQueries(){
        List<APXTConga4__Conga_Merge_Query__c> congaQueries = new List<APXTConga4__Conga_Merge_Query__c>();
        congaQueries.add(new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'SOR Hazards Query',
                                                            APXTConga4__Description__c = 'Query all hazards related to the housing inspection',
                                                            APXTConga4__Query__c = 'SELECT arcenforcements__Category_formula__c, arcenforcements__Hazard_Classification_Name__c, arcenforcements__Hazard_Description__c, arcenforcements__Likelihood_Justification__c, arcenforcements__Rating_formula__c, arcenforcements__Spread_Of_Health_Outcomes_Justification__c, (SELECT ContentDocument.Latestpublishedversion.arcenforcements__File_Field_Image_URL__c FROM AttachedContentDocuments WHERE ContentDocument.FileType LIKE \'%jpg%\' OR ContentDocument.FileType LIKE \'%jpeg%\' OR ContentDocument.FileType LIKE \'%gif%\' OR ContentDocument.FileType LIKE \'%png%\') FROM arcenforcements__Hazard__c WHERE Id IN (Select arcenforcements__Hazard__c FROM arcenforcements__Related_Hazard__c WHERE arcenforcements__Process__c =\'{pv4}\') ORDER BY arcenforcements__Hazard_Score__c DESC'));
        congaQueries.add(new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'SOR Housing Enforcements Query',
                                                            APXTConga4__Description__c = 'Query all housing enforcements related to the housing inspection',
                                                            APXTConga4__Query__c = 'SELECT arcenforcements__Action_Justification__c, arcusregserv__Parent_Process__c, arcusregserv__Subtype__c, arcusregserv__Subsubtype__c, arcenforcements__Enforcement_action_name__c, (SELECT Id, arcenforcements__Hazard__r.arcenforcements__Hazard_Classification_Name__c, arcenforcements__Hazard__r.arcenforcements__Rating_formula__c, arcenforcements__Hazard__r.arcenforcements__Category_formula__c FROM arcenforcements__Related_Hazards__r ORDER BY arcenforcements__Hazard__r.arcenforcements__Hazard_Score__c DESC) FROM arcusregserv__RS_Activity__c WHERE arcusregserv__Parent_Process__c = \'{pv4}\' AND RecordType.Name != \'Statement Of Reasons\' ORDER BY arcusregserv__Subsubtype__c ASC NULLS LAST'));
        congaQueries.add(new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'SOR Parent Process Query',
                                                            APXTConga4__Description__c = 'Query the parent process (house inpection)',
                                                            APXTConga4__Query__c = 'SELECT arcusregserv__Location__c, (SELECT Name, arcusregserv__User__r.Name FROM arcusregserv__Assigned_Officers__r WHERE arcusregserv__Role__c=\'Enforcement Officer\'), arcusregserv__Start_Date__c, arcusregserv__Location__r.arcusgazetteer__Address__c, (SELECT ContentDocument.Latestpublishedversion.arcenforcements__File_Field_Image_URL__c FROM AttachedContentDocuments WHERE ContentDocument.Title LIKE \'%SOR_%\' AND (ContentDocument.FileType LIKE \'%jpg%\' OR ContentDocument.FileType LIKE \'%jpeg%\' OR ContentDocument.FileType LIKE \'%gif%\' OR ContentDocument.FileType LIKE \'%png%\')) FROM arcusregserv__RS_Activity__c WHERE Id = \'{pv4}\''));
        congaQueries.add(new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'SOR Deficiencies Query',
                                                            APXTConga4__Description__c = 'Query all the deficiencies related to hazard',
                                                            APXTConga4__Query__c = 'SELECT arcenforcements__Hazard_Classification_Name__c, (SELECT arcenforcements__Deficiency__r.arcenforcements__Description__c, arcenforcements__Deficiency__r.arcenforcements__Assessment_room_information__c  FROM arcenforcements__Deficiency_Links__r) FROM arcenforcements__Hazard__c WHERE Id IN (Select arcenforcements__Hazard__c FROM arcenforcements__Related_Hazard__c WHERE arcenforcements__Process__c =\'{pv4}\') ORDER BY arcenforcements__Hazard_Classification_Name__c ASC'));
        insert congaQueries;
        s_CongaQueriesAmount = congaQueries.size();
    }

}