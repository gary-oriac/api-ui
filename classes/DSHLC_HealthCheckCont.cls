/*
Company    :    Arcus Global
Product    :    Arcus DSH
Purpose    :    DSH Lightning Health Check controller
Notes      :           
*/
public with sharing class DSHLC_HealthCheckCont extends DSHLC_ConfigSettings {

    @AuraEnabled
    public static Boolean isLoggedInUser() {
        if (UserInfo.getUserType() != 'Guest') {
            return true;
        } else {
            return false;
        }
    }

    @AuraEnabled
    public static Boolean hasClearance() {
        String profileName = [SELECT Name from Profile WHERE Id = :UserInfo.getProfileId()].Name;
        if (profileName.toLowerCase().indexOf('system administrator') > -1) {
            return true;
        } else {
            return false;
        }
    }

    @AuraEnabled
    public static List<BaseAccountListWrapper> getBaseAccounts() {
        Set<String> accountSet = new Set<String> {'Business - New', 'Resident - New', 'Resident - Non LLPG'};

        List<Account> accountList = [
            SELECT 
                Id, 
                Name, 
                OwnerId, 
                Owner.Name, 
                Owner.UserRoleId,
                Owner.UserRole.Name 
            FROM 
                Account
            WHERE
                Name IN :accountSet
        ];
        List<BaseAccountListWrapper> accountListWrapper = new List<BaseAccountListWrapper>();

        Map<String,Account> accountNameToRecordMap = new Map<String,Account>();
        for(Account accountDetail:accountList) {
            accountNameToRecordMap.put(accountDetail.Name, accountDetail);
        }
        for(String accountName:accountSet) {
            BaseAccountListWrapper accountWrapper;
            if (accountNameToRecordMap.containsKey(accountName)) {
                accountWrapper = new BaseAccountListWrapper(true, accountNameToRecordMap.get(accountName));
            } else {
                accountWrapper = new BaseAccountListWrapper(false, accountName);
            }
            accountListWrapper.add(accountWrapper);
        }

        return accountListWrapper;
    }

    public class BaseAccountListWrapper {
        @AuraEnabled public Boolean Account;
        @AuraEnabled public String Name;
        @AuraEnabled public String Owner;
        @AuraEnabled public String Role;

        public BaseAccountListWrapper(Boolean account, Account accountDetail) {
            Account = true;
            Name = accountDetail.Name;
            Owner = accountDetail.Owner.Name;
            Role = accountDetail.Owner.UserRole.Name;
        }

        public BaseAccountListWrapper(Boolean account, String name) { 
            this.Account = account;
            this.Name = name;
        }
    }

    @AuraEnabled
    public static List<WardAccountListWrapper> getWardAccounts() {
        Set<String> accountSet = new Set<String> {'Business - New', 'Resident - New', 'Resident - Non LLPG'};

        List<Account> accountList = [
            SELECT 
                Id, 
                Name, 
                OwnerId, 
                Owner.Name, 
                Owner.UserRoleId,
                Owner.UserRole.Name,
                arcusgazetteer__Ward_Code__c
            FROM 
                Account
            WHERE
                Name NOT IN :accountSet
            AND 
                Name LIKE 'Resident%'
        ];
        List<WardAccountListWrapper> accountListWrapper = new List<WardAccountListWrapper>();
        
        for(Account accountDetail:accountList) {
            accountListWrapper.add(new WardAccountListWrapper(accountDetail));
        }
        return accountListWrapper;      
    }

    public class WardAccountListWrapper {
        @AuraEnabled public String Name;
        @AuraEnabled public String Owner;
        @AuraEnabled public String Role;
        @AuraEnabled public String WardCode;
        @AuraEnabled public Boolean ValidFormat;

        public WardAccountListWrapper(Account accountDetail) {
            Name = accountDetail.Name;
            Owner = accountDetail.Owner.Name;
            Role = accountDetail.Owner.UserRole.Name;
            WardCode = accountDetail.arcusgazetteer__Ward_Code__c ;
            if (accountDetail.Name != null && accountDetail.Name.contains('Resident - ')) {
                ValidFormat = true;
            } else {
                ValidFormat = false;
            }
        }
    }

}