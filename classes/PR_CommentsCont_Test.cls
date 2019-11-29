@isTest
private class PR_CommentsCont_Test {
    //Work around for an AVDC failing process builder
    private static Id AssetRecordTypeId;

	@TestSetup
	static void setup(){
		List<RecordType> recordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset' LIMIT 1];
		if(recordType != null && !recordType.isEmpty()) AssetRecordTypeId = recordType[0].Id;
	}

	@isTest
	static void shouldReturnDisclaimerText(){
		String config = '[{"key":"test_account","separator":"","key_fields":["Name"],"disclaimer":"testotest"}]';

		Account acc = new Account(Name = 'test_account');
		insert acc;

		String disclaimer = PR_CommentsCont.getDisclaimerByScope(config, acc.Id, null);

		System.assertEquals('testotest', disclaimer);
	}

	@isTest
	static void shouldNotReturnDisclaimerText(){
		String config = '[{"key":"test_account","separator":"","key_fields":["Name"],"disclaimer":"testotest"}]';

		Account acc = new Account(Name = 'not_test_account');
		insert acc;

		String disclaimer = PR_CommentsCont.getDisclaimerByScope(config, acc.Id, null);

		System.assertEquals(null, disclaimer);
	}

	@isTest
	private static void contactIsInPublicConsultation(){

		Map<String, Object> consultationPeriods = new Map<String, Object>();
		System.runAs(guestUser()){
			Account account = new Account(Name = 'Stabby horse ranch');
			insert account;
			Asset asset = new Asset(
				AccountId = account.Id,
				Name = 'Horn polish',
				PurchaseDate = Date.today(),
				InstallDate = Date.today(),
				IsCompetitorProduct = true
			);
            if(AssetRecordTypeId != null) asset.put('RecordTypeId', AssetRecordTypeId);
			insert asset;

			Map<String, String> requestMap = new Map<String, String>{
				'startField' => 'PurchaseDate',
				'endField' => 'InstallDate',
				'publicConsultField' => 'IsCompetitorProduct',
				'stringId' => asset.Id
			};

			consultationPeriods = PR_CommentsCont.getConsultationPeriod(JSON.serialize(requestMap));
		}

		System.assertEquals(true, Boolean.valueOf(consultationPeriods.get('public')));
	}

	@isTest
	private static void contactIsNotInPublicConsultation(){
		Map<String, Object> consultationPeriods = new Map<String, Object>();
		System.runAs(guestUser()){
			Account account = new Account(Name = 'Stabby horse ranch');
			insert account;
			Asset asset = new Asset(
				AccountId = account.Id,
				Name = 'Horn polish',
				PurchaseDate = Date.today(),
				InstallDate = Date.today().addDays(-10),
				IsCompetitorProduct = true
			);
            if(AssetRecordTypeId != null) asset.put('RecordTypeId', AssetRecordTypeId);
			insert asset;

			Map<String, String> requestMap = new Map<String, String>{
				'startField' => 'PurchaseDate',
				'endField' => 'InstallDate',
				'publicConsultField' => 'IsCompetitorProduct',
				'stringId' => asset.Id
			};

			consultationPeriods = PR_CommentsCont.getConsultationPeriod(JSON.serialize(requestMap));
		}

		System.assertEquals(false, Boolean.valueOf(consultationPeriods.get('public')));
	}

	@isTest
	private static void consultationRequestReturnsSecureDesignerAttributes(){
		Map<String, Object> consultationPeriods = new Map<String, Object>();
		System.runAs(guestUser()){
			arcshared__Configuration__c configuration = new arcshared__Configuration__c(
				RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Secure_Design_Attribute' AND SobjectType = 'arcshared__Configuration__c' AND NamespacePrefix = 'arcshared' LIMIT 1].Id,
				arcshared__Public_JSON_Schema__c = '{"thisShouldReturn":"I should return"}',
				arcshared__DeveloperName__c = 'Test'
			);
			insert configuration;

			Account account = new Account(Name = 'Stabby horse ranch');
			insert account;
			Asset asset = new Asset(
				AccountId = account.Id,
				Name = 'Horn polish',
				PurchaseDate = Date.today(),
				InstallDate = Date.today(),
				IsCompetitorProduct = true
			);
            if(AssetRecordTypeId != null) asset.put('RecordTypeId', AssetRecordTypeId);
			insert asset;

			Map<String, String> requestMap = new Map<String, String>{
				'startField' => 'PurchaseDate',
				'endField' => 'InstallDate',
				'publicConsultField' => 'IsCompetitorProduct',
				'stringId' => asset.Id,
				'secureDesignerAttribute' => 'Test'
			};

			consultationPeriods = PR_CommentsCont.getConsultationPeriod(JSON.serialize(requestMap));
		}

		System.assertEquals('{"thisShouldReturn":"I should return"}', consultationPeriods.get('attributes'));
	}

	@isTest
	private static void exceptionThrownWithInvalidServiceClassProvided(){
		System.NullPointerException ae;		

		try{
			PR_CommentsCont.getConsultationPeriod(JSON.serialize(new Map<String, String>{'serviceClass' => 'Bibble'}));
		}catch(System.NullPointerException e){
			ae = e;
		}
		System.assertEquals('Attempt to de-reference a null object', ae.getMessage());
	}

	@isTest
	private static void aPublicCommentIsReturned(){
		Account account = new Account(Name = 'Moo');
		insert account;

		arcshared__Web_Comment__c comment = new arcshared__Web_Comment__c(
			Name = account.Id,
			arcshared__Public__c = true,
			arcshared__Text__c = 'I am comment!'
		);
		insert comment;

		Map<String, Object> commentsMap = PR_CommentsCont.getComments(account.Id, 'Name', null);
		List<arcshared__Web_Comment__c> comments = (List<arcshared__Web_Comment__c>)commentsMap.get('comments');

		System.assertEquals('I am comment!', comments[0].arcshared__Text__c);
	}

	@isTest
	private static void aPublicCommentIsReturnedUsingSecureDesignerAttribute(){
		arcshared__Configuration__c configuration = new arcshared__Configuration__c(
			RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Secure_Design_Attribute' AND SobjectType = 'arcshared__Configuration__c' AND NamespacePrefix = 'arcshared' LIMIT 1].Id,
			arcshared__Public_JSON_Schema__c = '{"columns":[{"fieldName": "CreatedById"}]}',
			arcshared__DeveloperName__c = 'Test'
		);
		insert configuration;

		Account account = new Account(Name = 'Moo');
		insert account;

		arcshared__Web_Comment__c comment = new arcshared__Web_Comment__c(
			Name = account.Id,
			arcshared__Public__c = true,
			arcshared__Text__c = 'I am comment!'
		);
		insert comment;

		Map<String, Object> commentsMap = PR_CommentsCont.getComments(account.Id, 'Name', 'Test');
		List<arcshared__Web_Comment__c> comments = (List<arcshared__Web_Comment__c>)commentsMap.get('comments');

		System.assertEquals(UserInfo.getUserId(), comments[0].CreatedById);
	}

	@isTest
	private static void aNonPublicCommentIsNotReturned(){
		Account account = new Account(Name = 'Moo');
		insert account;

		arcshared__Web_Comment__c comment = new arcshared__Web_Comment__c(
			Name = account.Id,
			arcshared__Public__c = false,
			arcshared__Text__c = 'I am comment!'
		);
		insert comment;

		Map<String, Object> commentsMap = PR_CommentsCont.getComments(account.Id, 'Name', null);
		List<arcshared__Web_Comment__c> comments = (List<arcshared__Web_Comment__c>)commentsMap.get('comments');

		System.assertEquals(0, comments.size());
	}

	@isTest
	private static void publicCommentIsSaved(){		
		System.runAs(guestUser()){
			Account account = new Account(Name = 'Stabby horse ranch');
			insert account;
			Asset asset = new Asset(
				AccountId = account.Id,
				Name = 'Horn polish',
				PurchaseDate = Date.today(),
				InstallDate = Date.today(),
				IsCompetitorProduct = true
			);
            if(AssetRecordTypeId != null) asset.put('RecordTypeId', AssetRecordTypeId);
			insert asset;

			Map<String, String> requestMap = new Map<String, String>{
				'startField' => 'PurchaseDate',
				'endField' => 'InstallDate',
				'publicConsultField' => 'IsCompetitorProduct',
				'stringId' => asset.Id
			};

			PR_CommentsCont.saveComment(new arcshared__Web_Comment__c(arcshared__Text__c = 'I am comment!'), null, JSON.serialize(requestMap));
		}

		System.assertEquals('I am comment!', [SELECT arcshared__Text__c FROM arcshared__Web_Comment__c].arcshared__Text__c);
	}

	@isTest
	private static void publicCommentIsSavedAsAuthenticatedUser(){		
		Account account = new Account(Name = 'Stabby horse ranch');
		insert account;
		Asset asset = new Asset(
			AccountId = account.Id,
			Name = 'Horn polish',
			PurchaseDate = Date.today(),
			InstallDate = Date.today(),
			IsCompetitorProduct = true
		);
        if(AssetRecordTypeId != null) asset.put('RecordTypeId', AssetRecordTypeId);
		insert asset;

		Map<String, String> requestMap = new Map<String, String>{
			'startField' => 'PurchaseDate',
			'endField' => 'InstallDate',
			'publicConsultField' => 'IsCompetitorProduct',
			'stringId' => asset.Id,
			'type' => 'public'
		};

		PR_CommentsCont.saveComment(new arcshared__Web_Comment__c(arcshared__Text__c = 'I am comment!'), null, JSON.serialize(requestMap));

		System.assertEquals('I am comment!', [SELECT arcshared__Text__c FROM arcshared__Web_Comment__c].arcshared__Text__c);
	}

	@isTest
	private static void exceptionThrownWhenCommentingOustideOfConsultationPeroid(){
		AuraHandledException ae;

		System.runAs(guestUser()){
			Account account = new Account(Name = 'Stabby horse ranch');
			insert account;
			Asset asset = new Asset(
				AccountId = account.Id,
				Name = 'Horn polish',
				PurchaseDate = Date.today().addDays(-10),
				InstallDate = Date.today().addDays(-9),
				IsCompetitorProduct = true
			);
            if(AssetRecordTypeId != null) asset.put('RecordTypeId', AssetRecordTypeId);
			insert asset;

			Map<String, String> requestMap = new Map<String, String>{
				'startField' => 'PurchaseDate',
				'endField' => 'InstallDate',
				'publicConsultField' => 'IsCompetitorProduct',
				'stringId' => asset.Id
			};

			try{
				PR_CommentsCont.saveComment(new arcshared__Web_Comment__c(arcshared__Text__c = 'I am comment!'), null, JSON.serialize(requestMap));
			}catch(AuraHandledException e){
				ae = e;
			}			
		}

		System.assertEquals('Application is not in a consultation period.', ae.getMessage());
	}

	private static User guestUser(){
		Profile p = [SELECT id FROM Profile WHERE Name = 'Guest License User'];

		User guest = new User(
			Alias = 'ogiraffe',
			Email = 'orange.giraffe@animal.fruit',
			EmailEncodingKey = 'UTF-8',
			FirstName = 'orange',
			LastName = 'giraffe',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_GB',
			ProfileId = p.Id,
			TimeZoneSidKey = 'Europe/London',
			UserName = 'orange' + DateTime.now().getTime() + 'giraffe@animal.furit.org'
		);

		insert guest;
		addPermissions(guest.Id);
		return guest;
	}

	private static void addPermissions(Id userId){
		PermissionSet permissionSet = new PermissionSet(Name = 'Test_permission_set', Label = 'Test permissions');
		insert permissionSet;

		insert new List<ObjectPermissions>{
			new ObjectPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'Account',
				PermissionsRead = true, 
				PermissionsCreate = true
			),
			new ObjectPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'Asset',
				PermissionsRead = true, 
				PermissionsCreate = true
			),
			new ObjectPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'arcshared__Web_Comment__c',
				PermissionsRead = true, 
				PermissionsCreate = true
			)
		};

		insert new List<FieldPermissions>{
			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'Asset', 
				Field = 'Asset.PurchaseDate',
				PermissionsRead = true, 
				PermissionsEdit = true
			),
			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'Asset', 
				Field = 'Asset.InstallDate',
				PermissionsRead = true, 
				PermissionsEdit = true
			),
			new FieldPermissions(
				ParentId = permissionSet.Id, 
				SobjectType = 'Asset', 
				Field = 'Asset.IsCompetitorProduct',
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
			)
		};

		insert new PermissionSetAssignment(
			AssigneeId = userId, 
			PermissionSetId = permissionSet.Id
		);
	}
}