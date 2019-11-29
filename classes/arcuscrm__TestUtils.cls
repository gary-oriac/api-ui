public with sharing class TestUtils {

    public static String randomString(Integer length) {
        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
		String randomString = '';

		while(randomString.length() < length){
			Integer index = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
			randomString += chars.substring(index, index + 1);
		}

		return randomString;
    }

    public static User createUser() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

		User user = new User(
			Alias = 'tUser',
			Email = 'tester@test.com',
			EmailEncodingKey = 'UTF-8',
			LastName = 'Testing',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'Europe/London',
			Username = randomString(50) + UserInfo.getOrganizationId() + '@arc.shared',
			ProfileId = profile.Id
		);

		insert user;

		return user;
    }

}