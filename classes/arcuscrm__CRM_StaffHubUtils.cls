global class CRM_StaffHubUtils {
    public static final Set<Id> SET_OF_STAFF_PROFILEIDS = getSetOfStaffHubProfileIds();

    @TestVisible
    private static Set<Id> getSetOfStaffHubProfileIds(){
        Set<Id> profileIds = new Set<Id>();
        Set<String> staffProfileNameSet = new Set<String>();
        
        List<arcuscrm__Profile_For_Staff_Hub__mdt> staffProfilesMDT = [SELECT Label FROM arcuscrm__Profile_For_Staff_Hub__mdt];
        for(arcuscrm__Profile_For_Staff_Hub__mdt pfsh : staffProfilesMDT) staffProfileNameSet.add(pfsh.Label);
        
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN :staffProfileNameSet];
        for(Profile p : profiles) profileIds.add(p.Id);
        
        return profileIds;
    }

/* 
88888888888                888         888     888 888    d8b 888          
    888                    888         888     888 888    Y8P 888          
    888                    888         888     888 888        888          
    888   .d88b.  .d8888b  888888      888     888 888888 888 888 .d8888b  
    888  d8P  Y8b 88K      888         888     888 888    888 888 88K      
    888  88888888 "Y8888b. 888         888     888 888    888 888 "Y8888b. 
    888  Y8b.          X88 Y88b.       Y88b. .d88P Y88b.  888 888      X88 
    888   "Y8888   88888P'  "Y888       "Y88888P"   "Y888 888 888  88888P' 
  */

    @TestVisible
    private static final Id TEST_STAFF_PROFILEID = getStaffProfileId();

    @TestVisible
    private static List<User> returnNewUsersWithoutProfile(Integer numberOfUsers){
        List<User> output = new List<User>();
        for(Integer i = 0; i < numberOfUsers; i++){
            User newUser = new User(
                Alias = 'testFO', 
                Email='testuser'+ String.valueOf(i+1) +'@test.com',
                EmailEncodingKey='UTF-8', 
                LastName='Testing', 
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_GB',
                UserName = 'StaffHubUser'+ String.valueOf(i+1) +'@test.com', 
                TimeZoneSidKey='America/Los_Angeles'
        );
        output.add(newUser);
        }
        return output;
    }

    private static Id getStaffProfileId(){
        return SET_OF_STAFF_PROFILEIDS.isEmpty() ? null : new List<Id>(SET_OF_STAFF_PROFILEIDS)[0];
    }
}