public with sharing class PR_TestUtils {
    
    public static User guestUser() {
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
			UserName = 'orange' + DateTime.now().getTime() + 'giraffe@animal.fruit.org'
		);

		if(Test.isRunningTest()) insert guest;
		return guest;
	}

    @testVisible
    private static void createAndAssignPermissionSet(Id UserId, List<ObjectPermissions> objectPermissions, List<FieldPermissions> fieldPermissions) {
        PermissionSet permissionSet = new PermissionSet(Name = 'Test_permission_set', Label = 'Test permissions');
        insert permissionSet;

        for(ObjectPermissions objectPermission : objectPermissions) {
            objectPermission.ParentId = permissionSet.Id;
        }

        for(FieldPermissions fieldPermission : fieldPermissions) {
            fieldPermission.ParentId = permissionSet.Id;
        }

        insert objectPermissions;
        insert fieldPermissions;

        insert new PermissionSetAssignment(
			AssigneeId = userId, 
			PermissionSetId = permissionSet.Id
		);
    }
}