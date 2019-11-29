/*  
Company    :    Arcus Global
Product    :    Arcus DSH   
Purpose    :    An apex page controller that supports self registration of users in communities that allow self registration
Notes      :    
*/
public without sharing class DSHLC_RegisterCont extends DSHLC_ConfigSettings {
    public static final String RESIDENT_NEW_ACCOUNT = 'Resident - New';
    public static final String BUSINESS_NEW_ACCOUNT = 'Business - New';
    public static final Map<String, String> ACCOUNT_NAME_MAP = new Map<String, String> {'resident' => RESIDENT_NEW_ACCOUNT, 'business' => BUSINESS_NEW_ACCOUNT};

    public class RegisterContException extends Exception {}

    @AuraEnabled
    public static String getCommunityName() {
        return DSHLC_CommunityInfo.getCommunity().LC.removeEnd('2');
    }

    @AuraEnabled
    public static String getCommunityNameSC() {
        return DSHLC_CommunityInfo.getCommunity().SC.removeEnd('2');
    }

    @AuraEnabled
    public static String getCouncilPrivacyPolicyURL() {
        String privacyPolicyURL = DSHLC_ConfigSettings.getCouncilPrivacyPolicyURL();
        return privacyPolicyURL;
    }
     @AuraEnabled
    public static String getCouncilTermsAndConditionsURL() {
        String termsAndConditionsURL = DSHLC_ConfigSettings.getCouncilTermsAndConditionsURL();
        return termsAndConditionsURL;
    }

    @testVisible
    private static String selectAccountId(String MailingAddressId) {
        List<String> errors = new List<String>();
        String communityNameLC = getCommunityName();
        String accountId; 
        if (communityNameLC.equals('resident')) {
            // If a resident, assign to new resident 
            accountId = getAccountByName(RESIDENT_NEW_ACCOUNT);
            // unless there is an account for this mailing address id
            String accountIdFromMailingAddressId = getAccountIdByMailingAddressId(MailingAddressId);
            if (accountIdFromMailingAddressId != null) {
                accountId = accountIdFromMailingAddressId;
            }
        } else if (communityNameLC.equals('business')) {
            accountId = getAccountByName(BUSINESS_NEW_ACCOUNT);
        } else {
            throw new RegisterContException('Sorry, you are not able to create an account. Please contact us for more details. REG002');
        }
        return accountId;
    }

    private static String getAccountByName(String name) {
        String nameForQuery = Test.isRunningTest() ? name + ' - DSHLC_RegisterCont_Test' : name;
        List<Account> accounts = [SELECT Id FROM Account WHERE Name = :nameForQuery LIMIT 1];
        if (accounts.size() == 0) {
            throw new RegisterContException('Sorry, you are not able to create an account. Please contact us for more details. REG001');
        }
        return accounts.get(0).Id;
    }

    @TestVisible
    private static String getAccountIdByMailingAddressId(String MailingAddressId) {
        arcusgazetteer__Location__c location;
        if (MailingAddressId != '' && MailingAddressId != '#' && MailingAddressId != null) {
            List<arcusgazetteer__Location__c> locations = [
                SELECT 
                    Id, 
                    arcusgazetteer__Street__c,
                    arcusgazetteer__Post_Town__c,
                    arcusgazetteer__Postcode__c,
                    arcusgazetteer__Ward_Name__c
                FROM 
                    arcusgazetteer__Location__c 
                WHERE 
                    arcusgazetteer__Valid_Postal_Address__c = true 
                AND
                    Id = :MailingAddressId
            ];
            if (!locations.isEmpty()) {
                location = locations.get(0);
            }
        }

        if(location != null && location.arcusgazetteer__Ward_Name__c != null){
                List<Account> accounts = [ 
                    SELECT 
                        Id 
                    FROM 
                        Account
                    WHERE 
                        arcusgazetteer__Ward_Code__c = :location.arcusgazetteer__Ward_Name__c
                    LIMIT 1];
                    if (accounts.size() > 0){
                        String accountId = accounts.get(0).Id;
                        return accountId;
                    }
        }   
        return null;
    }

    public static Boolean validateEmail(String email) {
        Boolean res = true;

        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})'; 

        //////This is the regex used in the email input component. It doesn't work in apex (the complier is differnt in js). The above seems to work in the same way. It is here for reference //////
         // String emailRegex = '/^$|^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/';

        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);

        if (!MyMatcher.matches()) 
            res = false;
        return res; 
    }

    private static void validatePassword(User u, String password, String confirmPassword) {
        if(!Test.isRunningTest()) {
            Site.validatePassword(u, password, confirmPassword);
        }
    }

    @testVisible
    private static List<String> validateUserDetails(String communityNameLC, String firstname, String lastname, String email, String password, String passwordRetype, Boolean isRetypePasswordShown, String mailingAddressText, Boolean termsAndConditions, Boolean privacyPolicy, String companyName) {
        List<String> errors = new List<String>();

        if (communityNameLC == 'business' && String.isBlank(companyName)) {
            errors.add('Please enter your business name');
        }
        
        if (String.isBlank(firstname)) {
            errors.add('Please enter your first name');
        }
        
        if (String.isBlank(lastname)) {
            errors.add('Please enter your last name');
        }
        
        if (String.isBlank(email)) {
            errors.add('Please enter your email');
        } else if (!validateEmail(email)) {
            errors.add('Please enter an email address in the correct format, like name@example.com');
        } else if (email.length() > 80) {
            errors.add('Please enter a shorter email');
        }
        
        if (String.isBlank(mailingAddressText)) {
            errors.add('Please enter your postcode');
        }

        Boolean checkPasswordPolicy = true;
        if (String.isBlank(password)) {
            errors.add('Please enter a valid password');
            checkPasswordPolicy = false;
        } else if (isRetypePasswordShown) {
            if (String.isBlank(passwordRetype)) {
                errors.add('Please retype your password');
                checkPasswordPolicy = false;
            } else if (!passwordRetype.equals(password)) {
                errors.add('Please make sure the passwords match');
                checkPasswordPolicy = false;
            }
        }

        if (checkPasswordPolicy) {
            User u = new User();
            u.Username = 'registration@dsh.com'; // not actual user to be inserted, just used for validating the password
            if (!isRetypePasswordShown) {
                passwordRetype = password;
            }

            try {
                validatePassword(u, password, passwordRetype);
            } catch (SecurityException ex) {
                System.debug('<ARCUS> error in validate password with exception type: ' + ex.getTypeName() + ', error message: ' + ex.getMessage());
                errors.add('Please enter a valid password');
            }
        }
        
        if (privacyPolicy == false) {
            errors.add('Please ensure you have read the privacy policy');
        }
        
        if (termsAndConditions == false) {
            errors.add('Please agree to the terms and conditions');
        }

        return errors;
    }

    @AuraEnabled
    public static List<String> selfRegister(String firstname, String lastname, String email, String password, String passwordRetype, Boolean isRetypePasswordShown, String MailingAddressText, String MailingAddressId, Boolean termsAndConditions, Boolean privacyPolicy, String regConfirmUrl, String startUrl, String companyName) {
        List<String> errors = new List<String>();

        String communityNameSC = getCommunityNameSC();
        String communityNameLC = getCommunityName();

        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();
            errors = validateUserDetails(communityNameLC, firstname, lastname, email, password, passwordRetype, isRetypePasswordShown, MailingAddressText, termsAndConditions, privacyPolicy, companyName);
            if (!errors.isEmpty()) {
                return errors;
            }
            // Check whether Username exists in Salesforce already 
            List<User> users = [SELECT Username FROM User WHERE isActive = true AND Username = :email LIMIT 1];                 
            if (users.size() > 0) {
                // If Username is taken, show error
                errors.add('Sorry, you are not able to create an account. Please contact us for more details. REG007');
                return errors;
            }

            String accountId;
            try {
                accountId = selectAccountId(MailingAddressId);        
            } catch (RegisterContException ex) {
                errors.add(ex.getMessage());
                return errors;
            }
           
            String userId = null;
            Boolean SFLinks = false;
            User u = assembleUserObject(email, firstname, lastname, termsAndConditions, privacyPolicy);

            try {
                System.debug('<ARCUS> the account id = ' + accountId);
                // Check for existing Contacts that SF may link up to User
                List<Contact> matchingContacts = queryMatchingContacts(email, accountId);
                SFLinks = !matchingContacts.isEmpty();

                if (SFLinks == true) {
                    // If LastName of Contact does not match Last name of registration, stop registration
                    for (Contact matchingContact : matchingContacts) {
                        if (String.isNotBlank(matchingContact.LastName) && !matchingContact.LastName.equalsIgnoreCase(lastname)) {
                            errors.add('Sorry, you are not able to create an account. Please contact us for more details. REG010');
                            return errors;
                        }
                    }
                }

                // Setting 4th variable true will send a welcome email
                userId = Test.isRunningTest() ? UserInfo.getUserId() : Site.createExternalUser(u, accountId, password, false);

            } catch (Exception ex) {   
                throw ex;
                System.debug('<ARCUS> error in registration ' + ex.getMessage());
                errors.add('Sorry, you are not able to create an account. Please contact us for more details. REG003');
                return errors;
            } 
            
            if (userId != null) {
                updateContact(userId, firstname, companyName, MailingAddressId);
                if (SFLinks == true) {
                    sendConfirmationEmailForLinkingContacts(firstname, lastname, email);
                }
            } else {
                if (SFLinks == true) {
                    errors.add('Sorry, you are not able to create an account. Please contact us for more details. REG004');
                    return errors;
                }
                if (SFLinks == false) {
                    errors.add('Sorry, you are not able to create an account. Please contact us for more details. REG005');
                    return errors;
                }
            }

            if (password != null && password.length() > 1) {   
                // userId = Test.isRunningTest() ? UserInfo.getUserId() : Site.createExternalUser(u, accountId, password, false);    
                ApexPages.PageReference lgn = Site.login(email, password, startUrl);
                if(!Test.isRunningTest()) {
                    aura.redirect(lgn);
                }
            }  
        } catch (Exception ex) {
            Database.rollback(sp);
            System.debug('<ARCUS> error in registration ' + ex.getMessage());
            errors.add('Sorry, you are not able to create an account. Please contact us for more details. REG009');
            return errors;
        }
        return null;
    }

    @TestVisible
    private static User assembleUserObject(String email, String firstname, String lastname, Boolean termsAndConditions, Boolean privacyPolicy) {
        String communityNameSC = getCommunityNameSC();
        String communityNameLC = getCommunityName();
        String profileName = 'Custom: Customer Community User - ' + communityNameSC;
        String profileId = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1].Id;
        Date dateStamp = Date.today();
        Long timestamp = datetime.now().getTime();
        User u = new User();
        u.Username = email;
        u.Email = email;
        u.FirstName = firstname;
        u.LastName = lastname;    
        u.ProfileId = profileId;
        u.CommunityNickname = 'DSH_' + timestamp; 
        u.arcshared__Registration_Type__c = 'Self Registration';
        u.arcshared__DSH_Accepted_Terms_And_Conditions__c = true;
        u.arcshared__DSH_Accepted_Terms_And_Conditions_Date__c = dateStamp;
        u.arcshared__DSH_Accepted_Privacy_Policy__c = true;
        u.arcshared__DSH_Accepted_Privacy_Policy_Date__c = dateStamp;
        return u;
    }

    @TestVisible
    private static List<Contact> queryMatchingContacts(String email, String accountId) {
        String communityNameSC = getCommunityNameSC();
        List<Contact> contacts = [
            SELECT 
                Id, 
                FirstName, 
                LastName
            FROM 
                Contact
            WHERE 
                Email = :email 
                AND AccountId = :accountId
            LIMIT 100
        ];
        return contacts;
    }

    @TestVisible
    private static String updateContact(String userId, String firstname, String companyName, String MailingAddressId) {
        Id contactId = [SELECT ContactId FROM User WHERE Id = :userId LIMIT 1].ContactId;

        Contact c = new Contact(Id = contactId);
        c.FirstName = firstname;

        if (String.isNotBlank(companyName)){ 
            c.arcshared__Company_Name__c = companyName;
        }

        c.arcshared__Community__c = getCommunityNameSC();

        if (String.isNotBlank(MailingAddressId)) {
            c.arcusgazetteer__Mailing_Address__c = MailingAddressId; 
        }

        try {
            update c;
        } catch (Exception ex) {
            System.debug('<ARCUS> error in contact update ' + ex.getMessage());
            throw ex;
            // throw new RegisterContException(ex.getMessage()+'Sorry, you are not able to create an account. Please contact us for more details. REG008');
        } 
        return null;
    }

    @TestVisible
    private static String sendConfirmationEmailForLinkingContacts(String firstname, String lastname, String email) {
        String communityName = getCommunityName();
        String councilLongName = DSHLC_ConfigSettings.getCouncilLongName();
        String councilShortName = DSHLC_ConfigSettings.getCouncilShortName();
        String possessiveDeterminer = DSHLC_ConfigSettings.getPossessiveDeterminer();
        String entryForEmail ='';
        String accountType= '';
        
        if (communityName.equals('resident')) {
            accountType = possessiveDeterminer + ' Account';
            entryForEmail = councilShortName + ' ' + accountType;
        } else {
            entryForEmail = 'online Business Account';
            accountType = 'account';
        }
        String emailBody = 'Dear '+ FirstName +' '+ LastName +',';
        emailBody += '<br/><br/>Thank you for completing the registration for your ' + entryForEmail + '.';
        emailBody += '<br/><br/>As you previously had an online account with ' + councilLongName + ', your details ';
        emailBody += '<br/>have been transferred to your new ' + entryForEmail + '. Please review the "' + possessiveDeterminer + ' ';
        emailBody += 'Details" section of your ' + accountType + ' to ensure these are up to date.';
        String subject = councilLongName + ' – review your details';

        sendEmail(Email, subject, emailBody);

        return emailBody;
    }

    @TestVisible
    private static boolean sendEmail(String toAddress,String subject, String emailBody ){
        List<String> toAddressesInput = new List<String> {toAddress};
        // First, reserve email capacity for the current Apex transaction to ensure
        // that we won't exceed our daily email limits when sending email after
        // the current transaction is committed.
        if(!Test.isRunningTest()){
            Messaging.reserveSingleEmailCapacity(1);
        }
        // Processes and actions involved in the Apex transaction occur next,
        // which conclude with sending a single email.
        
        // Now create a new single email message object
        // that will send out a single email to the addresses in the To, CC & BCC list.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(toAddressesInput);

        // Specify the name used as the display name.
        List<OrgWideEmailAddress> owa = [SELECT Id, DisplayName FROM OrgWideEmailAddress];
        if (owa.size() > 0) {
            mail.setOrgWideEmailAddressId(owa.get(0).Id);
        } 
        
        // Specify the subject line for your email address.
        mail.setSubject(subject);
        
        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);
        
        // Specify the text content of the email.
        mail.setPlainTextBody(emailBody);
        
        mail.setHtmlBody(emailBody);
        
        // Send the email you have created.
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            return true;
        }catch(Exception ex){
            System.debug('<ARCUS> error in sending email' + ex.getMessage() );
        }    
        //*/
        return false;
    }

}