@isTest
private class PR_ConsulteeServiceBuilt_Test {

	@TestSetup
	static void setup() {
		String recordTypeId = arcshared.Utils.getRecordTypeIdByNamespacedsObjectAndDeveloperNameAndNamespacePrefix('arcshared__Configuration__c', 'Secure_Design_Attribute', 'arcshared');
		insert new List<arcshared__Configuration__c> {
			new arcshared__Configuration__c(
	            RecordTypeId = recordTypeId,
	            arcshared__Public_JSON_Schema__c = '{"serviceClassParameters":{"relatedPartyLookups": { "arcusbuiltenv__Planning_Application__c": "arcusbuiltenv__Planning_Application__c"}, "consultationLookups": {"arcusbuiltenv__Planning_Application__c": "arcusbuiltenv__Planning_Application__c"}, "consultationRoles":["Consultee","Consultee (Statutory)","Consultee (Non Statutory)"], "inConsultationStatuses": ["In Progress"],"responseStatus":"Responded"}}',
	            arcshared__DeveloperName__c = 'Test'
        	),
			new arcshared__Configuration__c(
				RecordTypeId = recordTypeId,
				arcshared__Public_JSON_Schema__c = '{"columns":[{"fieldName":"arcusbuiltenv__Planning_Application__r.Id","label":"Planning Application Name","sortable":true,"type":"url","typeAttributes":{"label":{"fieldName":"arcusbuiltenv__Planning_Application__r.Name"},"target":"_top","value":{"fieldName":"arcusbuiltenv__Planning_Application__r.Id"}}},{"fieldName":"arcusbuiltenv__Planning_Application__r.arcusbuiltenv__Status__c","filterable":true,"label":"Application Status","sortable":true,"type":"text"},{"fieldName":"arcusbuiltenv__Status__c","filterable":true,"label":"Consultation Status","sortable":true,"type":"text"}],"serviceClassParameters":{"consultationLookups":{"arcusbuiltenv__Planning_Application__c":"arcusbuiltenv__Planning_Application__c"},"openForCommentsCheckbox":"is_Named__c","responseStatus":"Responded"}}',
				arcshared__DeveloperName__c = 'ViewConsultationsTestConfig'
			)
		};
	}

	@isTest
	private static void testGetViewConsultationsConfig() {
		User consultee = consulteeUser();
		System.runAs(consultee) {
			List<arcusbuiltenv__Planning_Application__c> applications = new List<arcusbuiltenv__Planning_Application__c> {
				new arcusbuiltenv__Planning_Application__c (
					arcusbuiltenv__Status__c = 'New Application',
					is_Named__c = true
				),
				new arcusbuiltenv__Planning_Application__c (
					arcusbuiltenv__Status__c = 'New Application',
					is_Named__c = false
				)
			};
			insert applications;

			List<arcusbuiltenv__Related_Party__c> relatedParties = new List<arcusbuiltenv__Related_Party__c> {
				new arcusbuiltenv__Related_Party__c(
					arcusbuiltenv__Contact__c = consultee.ContactId,
					arcusbuiltenv__Role__c = 'Consultee (Non Statutory)',
					arcusbuiltenv__Planning_Application__c = applications[0].Id
				),
				new arcusbuiltenv__Related_Party__c(
					arcusbuiltenv__Contact__c = consultee.ContactId,
					arcusbuiltenv__Role__c = 'Consultee (Non Statutory)',
					arcusbuiltenv__Planning_Application__c = applications[1].Id
				)
			};
			insert relatedParties;

			List<arcusbuiltenv__Consultation__c> consultations = new List<arcusbuiltenv__Consultation__c> {
				new arcusbuiltenv__Consultation__c(
					arcusbuiltenv__Planning_Application__c = applications[0].Id,
					Consultee__c = relatedParties[0].Id,
					arcusbuiltenv__Status__c = 'In Progress'
				),
				new arcusbuiltenv__Consultation__c(
					arcusbuiltenv__Planning_Application__c = applications[1].Id,
					Consultee__c = relatedParties[1].Id,
					arcusbuiltenv__Status__c = 'Responded'
				)
			};
			insert consultations;

			String configDevName = 'ViewConsultationsTestConfig';
			String filter = 'All';
			PR_ConsulteeServiceBuilt serviceClass = new PR_ConsulteeServiceBuilt();

			Test.startTest();
			Map<String, Object> result = serviceClass.getViewConsultationsConfig(configDevName, filter);
			Test.stopTest();

			System.assertEquals(true, result != null, 'Should not get null values returned');
			System.assertEquals(true, result.get('columns') != null, 'The columns definition is not returned');
			System.assertEquals(true, result.get('consultations') != null, 'The consultation records are not returned');
			System.assertEquals(true, result.get('queryFields') != null, 'The consultation fields used in the query are not returned');
			
			System.assertEquals(true, result.get('consultations') instanceof List<arcusbuiltenv__Consultation__c>, 'The returned value for consultations is of incorrect datatype');
			List<arcusbuiltenv__Consultation__c> returnedConsultations = (List<arcusbuiltenv__Consultation__c>)result.get('consultations');
			System.assertEquals(2, returnedConsultations.size(), 'Wrong number of consultations returned, expect all the consultations returned as filter is set to show All');
			
			Set<Object> expectedQueryFields = new Set<Object> {'Id', 'Consultee__r.arcusbuiltenv__Contact__c', 'arcusbuiltenv__Planning_Application__c', 'arcusbuiltenv__Status__c'};
			expectedQueryFields.addAll(new Set<Object> {'arcusbuiltenv__Planning_Application__r.Id', 'arcusbuiltenv__Planning_Application__r.Name', 'arcusbuiltenv__Planning_Application__r.arcusbuiltenv__Status__c'});

			Set<Object> returnedQueryFields = (Set<Object>)result.get('queryFields');
			System.assertEquals(expectedQueryFields.size(), returnedQueryFields.size(), 'Incorrect number of queried fields returned, fields returned are: ' + returnedQueryFields);
			System.assertEquals(true, returnedQueryFields.containsAll(expectedQueryFields), 'Not all the expected fields that should be queried are returned, fields returned are: ' + returnedQueryFields);
		}
	}

	@isTest
	private static void testGetViewConsultationsConfigWithFilterToRespond() {
		User consultee = consulteeUser();
		System.runAs(consultee) {
			List<arcusbuiltenv__Planning_Application__c> applications = new List<arcusbuiltenv__Planning_Application__c> {
				new arcusbuiltenv__Planning_Application__c (
					arcusbuiltenv__Status__c = 'New Application',
					is_Named__c = true
				),
				new arcusbuiltenv__Planning_Application__c (
					arcusbuiltenv__Status__c = 'New Application',
					is_Named__c = false
				)
			};
			insert applications;

			List<arcusbuiltenv__Related_Party__c> relatedParties = new List<arcusbuiltenv__Related_Party__c> {
				new arcusbuiltenv__Related_Party__c(
					arcusbuiltenv__Contact__c = consultee.ContactId,
					arcusbuiltenv__Role__c = 'Consultee (Non Statutory)',
					arcusbuiltenv__Planning_Application__c = applications[0].Id
				),
				new arcusbuiltenv__Related_Party__c(
					arcusbuiltenv__Contact__c = consultee.ContactId,
					arcusbuiltenv__Role__c = 'Consultee (Non Statutory)',
					arcusbuiltenv__Planning_Application__c = applications[1].Id
				)
			};
			insert relatedParties;

			List<arcusbuiltenv__Consultation__c> consultations = new List<arcusbuiltenv__Consultation__c> {
				new arcusbuiltenv__Consultation__c(
					arcusbuiltenv__Planning_Application__c = applications[0].Id,
					Consultee__c = relatedParties[0].Id,
					arcusbuiltenv__Status__c = 'In Progress'
				),
				new arcusbuiltenv__Consultation__c(
					arcusbuiltenv__Planning_Application__c = applications[1].Id,
					Consultee__c = relatedParties[1].Id,
					arcusbuiltenv__Status__c = 'Responded'
				)
			};
			insert consultations;

			String configDevName = 'ViewConsultationsTestConfig';
			String filter = 'To respond';
			PR_ConsulteeServiceBuilt serviceClass = new PR_ConsulteeServiceBuilt();

			Test.startTest();
			Map<String, Object> result = serviceClass.getViewConsultationsConfig(configDevName, filter);
			Test.stopTest();

			System.assertEquals(true, result != null, 'Should not get null values returned');
			System.assertEquals(true, result.get('consultations') != null, 'The consultation records are not returned');
			
			System.assertEquals(true, result.get('consultations') instanceof List<arcusbuiltenv__Consultation__c>, 'The returned value for consultations is of incorrect datatype');
			List<arcusbuiltenv__Consultation__c> returnedConsultations = (List<arcusbuiltenv__Consultation__c>)result.get('consultations');
			System.assertEquals(1, returnedConsultations.size(), 'Wrong number of consultations returned, expect only one consultation record as filter is set to To respond and should only return those with status not as Responded and consulation open for comments checkbox is true');
			System.assertEquals(consultations[0].Id, returnedConsultations[0].Id, 'Incorrect consultation record returned, should be the one with status In Progress, instead returns: ' + returnedConsultations[0]);
		}
	}

	@isTest
	private static void testGetViewConsultationsConfigWithFilterResponded() {
		User consultee = consulteeUser();
		System.runAs(consultee) {
			List<arcusbuiltenv__Planning_Application__c> applications = new List<arcusbuiltenv__Planning_Application__c> {
				new arcusbuiltenv__Planning_Application__c (
					arcusbuiltenv__Status__c = 'New Application',
					is_Named__c = true
				),
				new arcusbuiltenv__Planning_Application__c (
					arcusbuiltenv__Status__c = 'New Application',
					is_Named__c = false
				)
			};
			insert applications;

			List<arcusbuiltenv__Related_Party__c> relatedParties = new List<arcusbuiltenv__Related_Party__c> {
				new arcusbuiltenv__Related_Party__c(
					arcusbuiltenv__Contact__c = consultee.ContactId,
					arcusbuiltenv__Role__c = 'Consultee (Non Statutory)',
					arcusbuiltenv__Planning_Application__c = applications[0].Id
				),
				new arcusbuiltenv__Related_Party__c(
					arcusbuiltenv__Contact__c = consultee.ContactId,
					arcusbuiltenv__Role__c = 'Consultee (Non Statutory)',
					arcusbuiltenv__Planning_Application__c = applications[1].Id
				)
			};
			insert relatedParties;

			List<arcusbuiltenv__Consultation__c> consultations = new List<arcusbuiltenv__Consultation__c> {
				new arcusbuiltenv__Consultation__c(
					arcusbuiltenv__Planning_Application__c = applications[0].Id,
					Consultee__c = relatedParties[0].Id,
					arcusbuiltenv__Status__c = 'In Progress'
				),
				new arcusbuiltenv__Consultation__c(
					arcusbuiltenv__Planning_Application__c = applications[1].Id,
					Consultee__c = relatedParties[1].Id,
					arcusbuiltenv__Status__c = 'Responded'
				)
			};
			insert consultations;

			String configDevName = 'ViewConsultationsTestConfig';
			String filter = 'Responded';
			PR_ConsulteeServiceBuilt serviceClass = new PR_ConsulteeServiceBuilt();

			Test.startTest();
			Map<String, Object> result = serviceClass.getViewConsultationsConfig(configDevName, filter);
			Test.stopTest();

			System.assertEquals(true, result != null, 'Should not get null values returned');
			System.assertEquals(true, result.get('consultations') != null, 'The consultation records are not returned');
			
			System.assertEquals(true, result.get('consultations') instanceof List<arcusbuiltenv__Consultation__c>, 'The returned value for consultations is of incorrect datatype');
			List<arcusbuiltenv__Consultation__c> returnedConsultations = (List<arcusbuiltenv__Consultation__c>)result.get('consultations');
			System.assertEquals(1, returnedConsultations.size(), 'Wrong number of consultations returned, expect only one consultation record as filter is set to Responded and should only return those with consultation status as Responded');
			System.assertEquals(consultations[1].Id, returnedConsultations[0].Id, 'Incorrect consultation record returned, should be the one with consultation status Responded, instead returns: ' + returnedConsultations[0]);
		}
	}

	@isTest
	private static void testGetProcessParametersForViewConsultationsConfigWithNoColumns() {
		String recordTypeId = arcshared.Utils.getRecordTypeIdByNamespacedsObjectAndDeveloperNameAndNamespacePrefix('arcshared__Configuration__c', 'Secure_Design_Attribute', 'arcshared');
		insert new arcshared__Configuration__c(
			RecordTypeId = recordTypeId,
			arcshared__Public_JSON_Schema__c = '{"serviceClassParameters":{"consultationLookups":{"arcusbuiltenv__Planning_Application__c":"arcusbuiltenv__Planning_Application__c"},"openForCommentsCheckbox":"is_Named__c","responseStatus":"Responded"}}',
			arcshared__DeveloperName__c = 'ViewConsultationsTestNoColumns'
		);

		PR_ConsulteeServiceBuilt serviceClass = new PR_ConsulteeServiceBuilt();

		AuraHandledException thrownException;

		Test.startTest();
		try {
			serviceClass.processParametersForViewConsultationsConfig('ViewConsultationsTestNoColumns', 'All');
		} catch (AuraHandledException ex) {
			thrownException = ex;
		}
		Test.stopTest();

		System.assertEquals(true, thrownException != null, 'AuraHandledException should be thrown as a config is missing');
		System.assertEquals('Missing configuration for key: columns', thrownException.getMessage(), 'Error message should state the config is missing for columns');
	}

	@isTest
	private static void testGetProcessParametersForViewConsultationsConfigWithNoClassParams() {
		String recordTypeId = arcshared.Utils.getRecordTypeIdByNamespacedsObjectAndDeveloperNameAndNamespacePrefix('arcshared__Configuration__c', 'Secure_Design_Attribute', 'arcshared');
		insert new arcshared__Configuration__c(
			RecordTypeId = recordTypeId,
			arcshared__Public_JSON_Schema__c = '{"columns":[{"fieldName":"arcusbuiltenv__Planning_Application__r.arcusbuiltenv__Status__c","label":"Application Status","type":"text"},{"fieldName":"arcusbuiltenv__Status__c","label":"Consultation Status","type":"text"}]}',
			arcshared__DeveloperName__c = 'ViewConsultationsTestNoClassParams'
		);

		PR_ConsulteeServiceBuilt serviceClass = new PR_ConsulteeServiceBuilt();

		AuraHandledException thrownException;

		Test.startTest();
		try {
			serviceClass.processParametersForViewConsultationsConfig('ViewConsultationsTestNoClassParams', 'All');
		} catch (AuraHandledException ex) {
			thrownException = ex;
		}
		Test.stopTest();

		System.assertEquals(true, thrownException != null, 'AuraHandledException should be thrown as a config is missing');
		System.assertEquals('Missing configuration for key: serviceClassParameters', thrownException.getMessage(), 'Error message should state the config is missing for the service class paramters');
	}

	@isTest
	private static void testGetProcessParametersForViewConsultationsConfigWithNoConsultationsLookup() {
		String recordTypeId = arcshared.Utils.getRecordTypeIdByNamespacedsObjectAndDeveloperNameAndNamespacePrefix('arcshared__Configuration__c', 'Secure_Design_Attribute', 'arcshared');
		insert new arcshared__Configuration__c(
			RecordTypeId = recordTypeId,
			arcshared__Public_JSON_Schema__c = '{"columns":[{"fieldName":"arcusbuiltenv__Planning_Application__r.arcusbuiltenv__Status__c","label":"Application Status","type":"text"},{"fieldName":"arcusbuiltenv__Status__c","label":"Consultation Status","type":"text"}],"serviceClassParameters":{"openForCommentsCheckbox":"is_Named__c","responseStatus":"Responded"}}',
			arcshared__DeveloperName__c = 'ViewConsultationsTestNoConsultationsLookup'
		);

		PR_ConsulteeServiceBuilt serviceClass = new PR_ConsulteeServiceBuilt();

		AuraHandledException thrownException;

		Test.startTest();
		try {
			serviceClass.processParametersForViewConsultationsConfig('ViewConsultationsTestNoConsultationsLookup', 'All');
		} catch (AuraHandledException ex) {
			thrownException = ex;
		}
		Test.stopTest();

		System.assertEquals(true, thrownException != null, 'AuraHandledException should be thrown as a config is missing');
		System.assertEquals('Missing configuration for key: consultationLookups', thrownException.getMessage(), 'Error message should state the config is missing for the consultation lookup field to the parent');
	}

	@isTest
	private static void testGetProcessParametersForViewConsultationsConfigWithNoResponseStatus() {
		String recordTypeId = arcshared.Utils.getRecordTypeIdByNamespacedsObjectAndDeveloperNameAndNamespacePrefix('arcshared__Configuration__c', 'Secure_Design_Attribute', 'arcshared');
		insert new arcshared__Configuration__c(
			RecordTypeId = recordTypeId,
			arcshared__Public_JSON_Schema__c = '{"columns":[{"fieldName":"arcusbuiltenv__Planning_Application__r.arcusbuiltenv__Status__c","label":"Application Status","type":"text"},{"fieldName":"arcusbuiltenv__Status__c","label":"Consultation Status","type":"text"}],"serviceClassParameters":{"consultationLookups":{"arcusbuiltenv__Planning_Application__c":"arcusbuiltenv__Planning_Application__c"},"openForCommentsCheckbox":"is_Named__c"}}',
			arcshared__DeveloperName__c = 'ViewConsultationsTestNoResponseStatus'
		);

		PR_ConsulteeServiceBuilt serviceClass = new PR_ConsulteeServiceBuilt();

		AuraHandledException thrownException;

		Test.startTest();
		try {
			serviceClass.processParametersForViewConsultationsConfig('ViewConsultationsTestNoResponseStatus', 'To respond');
		} catch (AuraHandledException ex) {
			thrownException = ex;
		}
		Test.stopTest();

		System.assertEquals(true, thrownException != null, 'AuraHandledException should be thrown as a config is missing');
		System.assertEquals('Missing configuration for key: responseStatus', thrownException.getMessage(), 'Error message should state the config is missing for the response status');
	}

	@isTest
	private static void testGetProcessParametersForViewConsultationsConfigWithNoOpenForComments() {
		String recordTypeId = arcshared.Utils.getRecordTypeIdByNamespacedsObjectAndDeveloperNameAndNamespacePrefix('arcshared__Configuration__c', 'Secure_Design_Attribute', 'arcshared');
		insert new arcshared__Configuration__c(
			RecordTypeId = recordTypeId,
			arcshared__Public_JSON_Schema__c = '{"columns":[{"fieldName":"arcusbuiltenv__Planning_Application__r.arcusbuiltenv__Status__c","label":"Application Status","type":"text"},{"fieldName":"arcusbuiltenv__Status__c","label":"Consultation Status","type":"text"}],"serviceClassParameters":{"consultationLookups":{"arcusbuiltenv__Planning_Application__c":"arcusbuiltenv__Planning_Application__c"},"responseStatus":"Responded"}}',
			arcshared__DeveloperName__c = 'ViewConsultationsTestNoOpenForComments'
		);

		PR_ConsulteeServiceBuilt serviceClass = new PR_ConsulteeServiceBuilt();

		AuraHandledException thrownException;

		Test.startTest();
		try {
			serviceClass.processParametersForViewConsultationsConfig('ViewConsultationsTestNoOpenForComments', 'To respond');
		} catch (AuraHandledException ex) {
			thrownException = ex;
		}
		Test.stopTest();

		System.assertEquals(true, thrownException != null, 'AuraHandledException should be thrown as a config is missing');
		System.assertEquals('Missing configuration for key: openForCommentsCheckbox', thrownException.getMessage(), 'Error message should state the config is missing for the open for comments checkbox field on the parent object');
	}

    @isTest
    private static void userHasARequestedConsultation(){

        Map<String, Object> consultationPeriods = new Map<String, Object>();

        System.runAs(consulteeUser()){
            Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;

            arcusbuiltenv__Planning_Application__c application = new arcusbuiltenv__Planning_Application__c(
                Consultation_Start_Date__c = Date.today(),
                arcusbuiltenv__Consultation_Deadline__c = Date.today(),
                arcusbuiltenv__Open_For_Comments__c = true
            );
            insert application;

            arcusbuiltenv__Related_Party__c relatedParty = new arcusbuiltenv__Related_Party__c(
                arcusbuiltenv__Contact__c = contactId,
                arcusbuiltenv__Role__c = 'Consultee',
                arcusbuiltenv__Planning_Application__c = application.Id
            );
            insert relatedParty;

            arcusbuiltenv__Consultation__c consultation = new arcusbuiltenv__Consultation__c(
                arcusbuiltenv__Planning_Application__c = application.Id,
                Consultee__c = relatedParty.Id
            ); 
            insert consultation;

            Map<String, String> requestMap = new Map<String, String>{
                'startField' => 'Consultation_Start_Date__c',
                'endField' => 'arcusbuiltenv__Consultation_Deadline__c',
                'publicConsultField' => 'arcusbuiltenv__Open_For_Comments__c',
                'stringId' => application.Id,
                'serviceClass' => 'PR_ConsulteeServiceBuilt',
                'secureDesignerAttribute' => 'Test'
            };

            consultationPeriods = PR_CommentsCont.getConsultationPeriod(JSON.serialize(requestMap));
        }
        
        System.assertEquals(true, Boolean.valueOf(consultationPeriods.get('requested')));
    }

    @isTest
    private static void userDoesNotHaveARequestedConsultation(){
        Map<String, Object> consultationPeriods = new Map<String, Object>();

        System.runAs(consulteeUser()){
            Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;

            arcusbuiltenv__Planning_Application__c application = new arcusbuiltenv__Planning_Application__c(
                Consultation_Start_Date__c = Date.today().addDays(-10),
                arcusbuiltenv__Consultation_Deadline__c = Date.today().addDays(-9),
                arcusbuiltenv__Open_For_Comments__c = true
            );
            insert application;

            arcusbuiltenv__Related_Party__c relatedParty = new arcusbuiltenv__Related_Party__c(
                arcusbuiltenv__Contact__c = contactId,
                arcusbuiltenv__Role__c = 'Consultee',
                arcusbuiltenv__Planning_Application__c = application.Id
            );
            insert relatedParty;

            Map<String, String> requestMap = new Map<String, String>{
                'startField' => 'Consultation_Start_Date__c',
                'endField' => 'arcusbuiltenv__Consultation_Deadline__c',
                'publicConsultField' => 'arcusbuiltenv__Open_For_Comments__c',
                'stringId' => application.Id,
                'serviceClass' => 'PR_ConsulteeServiceBuilt',
                'secureDesignerAttribute' => 'Test'
            };

            consultationPeriods = PR_CommentsCont.getConsultationPeriod(JSON.serialize(requestMap));
        }
        
        System.assertEquals(false, Boolean.valueOf(consultationPeriods.get('requested')));
    }

    @isTest
    private static void commentIsSaved(){
        Id consultationId;
        System.runAs(consulteeUser()){
            Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;

            arcusbuiltenv__Planning_Application__c application = new arcusbuiltenv__Planning_Application__c(
                Consultation_Start_Date__c = Date.today(),
                arcusbuiltenv__Consultation_Deadline__c = Date.today(),
                arcusbuiltenv__Open_For_Comments__c = true
            );
            insert application;

            arcusbuiltenv__Related_Party__c relatedParty = new arcusbuiltenv__Related_Party__c(
                arcusbuiltenv__Contact__c = contactId,
                arcusbuiltenv__Role__c = 'Consultee',
                arcusbuiltenv__Planning_Application__c = application.Id
            );
            insert relatedParty;

            arcusbuiltenv__Consultation__c consultation = new arcusbuiltenv__Consultation__c(
                arcusbuiltenv__Planning_Application__c = application.Id,
                Consultee__c = relatedParty.Id
            ); 
            insert consultation;
            consultationId = consultation.Id;

            Map<String, String> requestMap = new Map<String, String>{
                'startField' => 'Consultation_Start_Date__c',
                'endField' => 'arcusbuiltenv__Consultation_Deadline__c',
                'publicConsultField' => 'arcusbuiltenv__Open_For_Comments__c',
                'stringId' => application.Id,
                'serviceClass' => 'PR_ConsulteeServiceBuilt',
                'secureDesignerAttribute' => 'Test',
                'type' => 'consult'
            };

            PR_CommentsCont.saveComment(new arcshared__Web_Comment__c(arcshared__Text__c = 'I am comment!'), null, JSON.serialize(requestMap));            
        }

		System.assertEquals(consultationId, [SELECT arcusbuiltenv__Consultation__c FROM arcshared__Web_Comment__c].arcusbuiltenv__Consultation__c);
    }

    @isTest
    private static void commentIsSavedAgainstOpenRequest(){
        Id consultationTwoId;
        System.runAs(consulteeUser()){
            Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;

            arcusbuiltenv__Planning_Application__c application = new arcusbuiltenv__Planning_Application__c(
                Consultation_Start_Date__c = Date.today(),
                arcusbuiltenv__Consultation_Deadline__c = Date.today(),
                arcusbuiltenv__Open_For_Comments__c = true
            );
            insert application;

            arcusbuiltenv__Related_Party__c relatedParty = new arcusbuiltenv__Related_Party__c(
                arcusbuiltenv__Contact__c = contactId,
                arcusbuiltenv__Role__c = 'Consultee',
                arcusbuiltenv__Planning_Application__c = application.Id
            );
            insert relatedParty;

            arcusbuiltenv__Consultation__c consultation = new arcusbuiltenv__Consultation__c(
                arcusbuiltenv__Planning_Application__c = application.Id,
                Consultee__c = relatedParty.Id
            ); 
            insert consultation;

            arcshared__Web_Comment__c webComment = new arcshared__web_comment__c(
                arcusbuiltenv__Consultation__c = consultation.Id
            );
            insert webComment;

            arcusbuiltenv__Consultation__c consultationTwo = new arcusbuiltenv__Consultation__c(
                arcusbuiltenv__Planning_Application__c = application.Id,
                Consultee__c = relatedParty.Id
            ); 
            insert consultationTwo;
            consultationTwoId = consultationTwo.Id;

            Map<String, String> requestMap = new Map<String, String>{
                'startField' => 'Consultation_Start_Date__c',
                'endField' => 'arcusbuiltenv__Consultation_Deadline__c',
                'publicConsultField' => 'arcusbuiltenv__Open_For_Comments__c',
                'stringId' => application.Id,
                'serviceClass' => 'PR_ConsulteeServiceBuilt',
                'secureDesignerAttribute' => 'Test',
                'type' => 'consult'
            };

            PR_CommentsCont.saveComment(new arcshared__Web_Comment__c(arcshared__Text__c = 'I am comment!'), null, JSON.serialize(requestMap));            
        }

		System.assertEquals(1, [SELECT arcusbuiltenv__Consultation__c FROM arcshared__Web_Comment__c WHERE arcusbuiltenv__Consultation__c =: consultationTwoId].size());
    }

	@isTest
    private static void commentIsSavedWithStatutoryType(){        
        System.runAs(consulteeUser()){
            Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;

            arcusbuiltenv__Planning_Application__c application = new arcusbuiltenv__Planning_Application__c(
                Consultation_Start_Date__c = Date.today(),
                arcusbuiltenv__Consultation_Deadline__c = Date.today(),
                arcusbuiltenv__Open_For_Comments__c = true
            );
            insert application;

            arcusbuiltenv__Related_Party__c relatedParty = new arcusbuiltenv__Related_Party__c(
                arcusbuiltenv__Contact__c = contactId,
                arcusbuiltenv__Role__c = 'Consultee (Statutory)',
                arcusbuiltenv__Planning_Application__c = application.Id
            );
            insert relatedParty;

            arcusbuiltenv__Consultation__c consultation = new arcusbuiltenv__Consultation__c(
                arcusbuiltenv__Planning_Application__c = application.Id,
                Consultee__c = relatedParty.Id
            ); 
            insert consultation;

            Map<String, String> requestMap = new Map<String, String>{
                'startField' => 'Consultation_Start_Date__c',
                'endField' => 'arcusbuiltenv__Consultation_Deadline__c',
                'publicConsultField' => 'arcusbuiltenv__Open_For_Comments__c',
                'stringId' => application.Id,
                'serviceClass' => 'PR_ConsulteeServiceBuilt',
                'secureDesignerAttribute' => 'Test',
                'type' => 'consult'
            };

            PR_CommentsCont.saveComment(new arcshared__Web_Comment__c(arcshared__Text__c = 'I am comment!'), null, JSON.serialize(requestMap));
        }

		System.assertEquals('Consultee (Statutory)', [SELECT arcshared__Commentator_Type__c FROM arcshared__Web_Comment__c].arcshared__Commentator_Type__c);
    }

    @isTest
    private static void commentIsNotSaved(){
        AuraHandledException ae;

        System.runAs(consulteeUser()){
            Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;

            arcusbuiltenv__Planning_Application__c application = new arcusbuiltenv__Planning_Application__c(
                Consultation_Start_Date__c = Date.today().addDays(-10),
                arcusbuiltenv__Consultation_Deadline__c = Date.today().addDays(-9),
                arcusbuiltenv__Open_For_Comments__c = false
            );
            insert application;

            arcusbuiltenv__Related_Party__c relatedParty = new arcusbuiltenv__Related_Party__c(
                arcusbuiltenv__Contact__c = contactId,
                arcusbuiltenv__Role__c = 'Consultee',
                arcusbuiltenv__Planning_Application__c = application.Id
            );
            insert relatedParty;

            arcusbuiltenv__Consultation__c consultation = new arcusbuiltenv__Consultation__c(
                arcusbuiltenv__Planning_Application__c = application.Id,
                Consultee__c = relatedParty.Id
            ); 
            insert consultation;

            Map<String, String> requestMap = new Map<String, String>{
                'startField' => 'Consultation_Start_Date__c',
                'endField' => 'arcusbuiltenv__Consultation_Deadline__c',
                'publicConsultField' => 'arcusbuiltenv__Open_For_Comments__c',
                'stringId' => application.Id,
                'serviceClass' => 'PR_ConsulteeServiceBuilt',
                'secureDesignerAttribute' => 'Test',
                'type' => 'consult'
            };

            try{
				PR_CommentsCont.saveComment(new arcshared__Web_Comment__c(arcshared__Text__c = 'I am comment!'), null, JSON.serialize(requestMap));
			}catch(AuraHandledException e){
				ae = e;
			}
        }

		System.assertEquals('There are no open consultation requests.', ae.getMessage());
    }

    private static User consulteeUser(){
		Profile p = [SELECT id FROM Profile WHERE Name = 'Customer Community Login User'];
        User consultee;

        System.runAs(adminUser()){
            Account testAccount = new Account(Name = 'Portal Account');
			insert testAccount;

			Contact testContact = new Contact();
			testContact.Email = 'something@example.com';
			testContact.LastName = 'Test Last Name';
			testContact.AccountId = testAccount.Id;
			insert testContact;

			consultee = new User(
				Alias = 'ogiraffe',
				Email = 'orange.giraffe@animal.fruit',
				EmailEncodingKey = 'UTF-8',
				FirstName = 'orange',
				LastName = 'giraffe',
				LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_GB',
				ProfileId = p.Id,
				TimeZoneSidKey = 'Europe/London',
				UserName = 'orange' + DateTime.now().getTime() + 'giraffe@animal.furit.org',
				ContactId = testContact.Id
			);

			insert consultee;
		}

		addPermissions(consultee.Id);
		return consultee;
	}

	private static User adminUser(){
		Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

		UserRole testRole = new UserRole(DeveloperName = 'TestRole', Name = 'TestRole');
		insert testRole;

		User adminUser = new User(
			Alias = 'tUser',
			Email = 'test@example.com',
			EmailEncodingKey = 'UTF-8',
			LastName = 'Testing',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'Europe/London',
			Username = 'kerflufel' + UserInfo.getOrganizationId() + '@arc.shared',
			ProfileId = adminProfile.Id,
			UserRoleId = testRole.Id
		);

		return adminUser;
	}

	private static void addPermissions(Id userId){
		PermissionSet permissionSet = new PermissionSet(Name = 'Test_permission_set', Label = 'Test permissions');
		insert permissionSet;

		insert new List<ObjectPermissions>{
			new ObjectPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'Contact',
				PermissionsRead = true, 
				PermissionsCreate = true
			),
			new ObjectPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcusbuiltenv__Planning_Application__c',
				PermissionsRead = true, 
				PermissionsCreate = true
			),
			new ObjectPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcusbuiltenv__Related_Party__c',
				PermissionsRead = true, 
				PermissionsCreate = true
			),
			new ObjectPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcusbuiltenv__Consultation__c',
				PermissionsRead = true, 
				PermissionsCreate = true,
                PermissionsEdit = true
			),
            new ObjectPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcshared__web_comment__c',
				PermissionsRead = true, 
				PermissionsCreate = true
			)
		};

		insert new List<FieldPermissions>{
			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'Contact', 
				Field = 'Contact.arcusgazetteer__correspondence_print_address__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			),

			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcusbuiltenv__Planning_Application__c', 
				Field = 'arcusbuiltenv__Planning_Application__c.Consultation_Start_Date__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			),
			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcusbuiltenv__Planning_Application__c', 
				Field = 'arcusbuiltenv__Planning_Application__c.arcusbuiltenv__Consultation_Deadline__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			),
			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcusbuiltenv__Planning_Application__c', 
				Field = 'arcusbuiltenv__Planning_Application__c.arcusbuiltenv__Status__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			),
			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcusbuiltenv__Planning_Application__c', 
				Field = 'arcusbuiltenv__Planning_Application__c.is_Named__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			),
			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcusbuiltenv__Planning_Application__c', 
				Field = 'arcusbuiltenv__Planning_Application__c.arcusbuiltenv__Open_For_Comments__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			),
            new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcusbuiltenv__Planning_Application__c', 
				Field = 'arcusbuiltenv__Planning_Application__c.arcusbuiltenv__Officer__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			),

            new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcusbuiltenv__Related_Party__c', 
				Field = 'arcusbuiltenv__Related_Party__c.arcusbuiltenv__Contact__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			),
			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcusbuiltenv__Related_Party__c', 
				Field = 'arcusbuiltenv__Related_Party__c.arcusbuiltenv__Role__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			),
			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcusbuiltenv__Related_Party__c', 
				Field = 'arcusbuiltenv__Related_Party__c.arcusbuiltenv__Planning_Application__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			),

			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcusbuiltenv__Consultation__c', 
				Field = 'arcusbuiltenv__Consultation__c.arcusbuiltenv__Planning_Application__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			),
			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcusbuiltenv__Consultation__c', 
				Field = 'arcusbuiltenv__Consultation__c.Consultee__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			),
			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcusbuiltenv__Consultation__c', 
				Field = 'arcusbuiltenv__Consultation__c.arcusbuiltenv__Consultation_Deadline__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			),
			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcusbuiltenv__Consultation__c', 
				Field = 'arcusbuiltenv__Consultation__c.arcusbuiltenv__Completion_Date__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			),
			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcusbuiltenv__Consultation__c', 
				Field = 'arcusbuiltenv__Consultation__c.arcusbuiltenv__Status__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			),

			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcshared__Web_Comment__c', 
				Field = 'arcshared__Web_Comment__c.arcshared__Name__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			),
			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcshared__Web_Comment__c', 
				Field = 'arcshared__Web_Comment__c.arcshared__Text__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			),
			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcshared__Web_Comment__c', 
				Field = 'arcshared__Web_Comment__c.arcusbuiltenv__Consultation__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			),
			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcshared__Web_Comment__c', 
				Field = 'arcshared__Web_Comment__c.Planning_Application__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			),
			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcshared__Web_Comment__c', 
				Field = 'arcshared__Web_Comment__c.arcshared__Address__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			),
			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcshared__Web_Comment__c', 
				Field = 'arcshared__Web_Comment__c.arcshared__Email__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			),
			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcshared__Web_Comment__c', 
				Field = 'arcshared__Web_Comment__c.arcshared__Commentator_Type__c',
				PermissionsRead = true, 
				PermissionsEdit = true
			)
		};

		insert new PermissionSetAssignment(
			AssigneeId = userId, 
			PermissionSetId = permissionSet.Id
		);
	}
}