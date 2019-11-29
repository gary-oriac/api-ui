global class CRM_StaffHubUserTriggerHandler extends arcshared.TriggerDispatcher.TriggerHandler{

    public static final Id COUNCIL_OFFICER_RTID = [SELECT Id FROM RecordType WHERE DeveloperName = 'Council_Officer' AND SobjectType = 'Contact' LIMIT 1].Id;

    global static List<arcshared.AppConfigSupport.setting> TRIGGER_SETTINGS {
        get {
            List<arcshared.AppConfigSupport.setting> result = new List<arcshared.AppConfigSupport.setting>();
            arcshared.AppConfigSupport.setting staffHubUserTriggerSetting = new arcshared.AppConfigSupport.setting();
            staffHubUserTriggerSetting.key = 'arcuscrm.CRM_StaffHubUserTriggerHandler';
            staffHubUserTriggerSetting.editable = true;
            staffHubUserTriggerSetting.valueType = 'TriggerSetting';
            staffHubUserTriggerSetting.currentValue = 'arcuscrm.CRM_StaffHubUserTriggerHandler,User,1';
            staffHubUserTriggerSetting.defaultValue = staffHubUserTriggerSetting.currentValue;
            staffHubUserTriggerSetting.available = true;
            staffHubUserTriggerSetting.description = 'Trigger setting to allow staff hub user contact automation to function';
            result.add(staffHubUserTriggerSetting);
            return result;
        }
    }
    
    global override void MainEntry(List<SObject> newlist, Map<ID, SObject> newmap, List<SObject> oldlist, Map<ID,SObject> oldmap){
        List<User> newUserList = (List<User>)newlist;
        List<User> oldUserList = (List<User>)oldlist;

        if(Trigger.IsBefore && Trigger.IsInsert){
            List<User> usersWithEligibleProfile = filterUsersWithEligibleProfiles(newUserList);
            markUsersAsStaffHub(usersWithEligibleProfile);
        }
        if(Trigger.IsAfter && (Trigger.IsInsert || Trigger.IsUpdate )){
            List<User> usersThatNeedContactCreated = filterStaffHubUsersWithNoContact(newUserList);
            createContactsForUsersAndLinkBothDirections(usersThatNeedContactCreated);
        }
    }

/* 
888b     d888          888    888                    888          
8888b   d8888          888    888                    888          
88888b.d88888          888    888                    888          
888Y88888P888  .d88b.  888888 88888b.   .d88b.   .d88888 .d8888b  
888 Y888P 888 d8P  Y8b 888    888 "88b d88""88b d88" 888 88K      
888  Y8P  888 88888888 888    888  888 888  888 888  888 "Y8888b. 
888   "   888 Y8b.     Y88b.  888  888 Y88..88P Y88b 888      X88 
888       888  "Y8888   "Y888 888  888  "Y88P"   "Y88888  88888P' 
 */

    @TestVisible
    private static List<User> filterUsersWithEligibleProfiles(List<User> input){
        List<User> output = new List<User>();

        for(User i : input){
            if(CRM_StaffHubUtils.SET_OF_STAFF_PROFILEIDS.contains(i.profileId)){
                output.add(i);
            }
        }
        return output;
    }

    @TestVisible
    private static void markUsersAsStaffHub(List<User> input){
        for(User u : input){
            u.arcuscrm__Should_Have_Linked_Staff_Contact__c = true;
        }
    }

    @TestVisible
    private static List<User> filterStaffHubUsersWithNoContact(List<User> input){
        List<User> output = new List<User>();

        for(User u : input){
            if(u.arcuscrm__Should_Have_Linked_Staff_Contact__c && String.isBlank(u.arcuscrm__Employee_Contact_Id__c)) output.add(u);
        }

        return output;
    }

    @TestVisible
    private static void createContactsForUsersAndLinkBothDirections(List<User> input){
        List<Contact> contactsToInsert = new List<Contact>();

        for(User u : input){
            contactsToInsert.add(createContactForAParticularUser(u));
        }

        CRM_InsertContactsForStaffHubUsers createContactAndLinkJob = new CRM_InsertContactsForStaffHubUsers(contactsToInsert);
        Id jobId = System.enqueueJob(createContactAndLinkJob);
    }

    private static Contact createContactForAParticularUser(User input){
        Contact output = new Contact(
            FirstName = input.FirstName,
            LastName = input.LastName,
            Email = input.Email,
            Phone = input.Phone,
            arcuscrm__Linked_Internal_User__c = input.Id,
            RecordTypeId = COUNCIL_OFFICER_RTID
        );
        return output;
    }
}