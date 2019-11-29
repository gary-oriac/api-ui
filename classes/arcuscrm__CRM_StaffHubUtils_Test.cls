@isTest
public class CRM_StaffHubUtils_Test {

    @isTest
    private static void getSetOfStaffHubProfileIds_Test(){
        List<arcuscrm__Profile_For_Staff_Hub__mdt> staffProfilesMDT = [SELECT Label FROM arcuscrm__Profile_For_Staff_Hub__mdt];

        Integer expectedOutputSize = staffProfilesMDT.size();

        Test.startTest();
            Set<Id> result = CRM_StaffHubUtils.getSetOfStaffHubProfileIds();
        Test.stopTest();

        Integer actualOutputSize = result.size();

        System.assertEquals(expectedOutputSize, actualOutputSize, 'The method should return a set of Ids corresponding to the profile specified in the Profile_For_Staff_Hub custom metadata. Each metadata should specify an actual existing profile.');
        System.assertEquals(expectedOutputSize, actualOutputSize, 'The method should return a set of Ids corresponding to the profile specified in the Profile_For_Staff_Hub custom metadata. Each metadata should specify an actual existing profile.');
    }

    @isTest
    private static void returnNewUsersWithoutProfile_Test(){
        Integer expectedNumberOfUsers = 3;

        Test.startTest();
            List<User> result = CRM_StaffHubUtils.returnNewUsersWithoutProfile(expectedNumberOfUsers);
            for(User u : result){
                u.ProfileId = CRM_StaffHubUtils.TEST_STAFF_PROFILEID;
            }
            insert result; //This checks that the method returns a valid user (plus an added profile)
        Test.stopTest();

        Integer actualNumberOfUsers = result.size();

        System.assertEquals(expectedNumberOfUsers, actualNumberOfUsers, 'The method should return the same number of valid profile-less users as requested.');
    }

    @isTest
    private static void ProfilesForStuffHubSetUpCorrectly(){
        System.assert(CRM_StaffHubUtils.TEST_STAFF_PROFILEID != null,'SETUP ISSUE - There should be at least one profile that exists in Profiles For Staff Hub custom metadata.');
    }
}