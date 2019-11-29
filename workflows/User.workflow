<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>DSHLC_Business_Email_Update</fullName>
        <description>Notification of Business Email Update</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>customer.services@folkestone-hythe.gov.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Communities_Templates/FHDC_Business_Email_Update</template>
    </alerts>
    <alerts>
        <fullName>DSHLC_Business_Register</fullName>
        <description>Notification of Business Registration</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>customer.services@folkestone-hythe.gov.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Communities_Templates/FHDC_Business_Register</template>
    </alerts>
    <alerts>
        <fullName>DSHLC_Deactivate_User_Email</fullName>
        <description>Notification of user deactivation</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>customer.services@folkestone-hythe.gov.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Communities_Templates/FHDC_Deactivate_User</template>
    </alerts>
    <alerts>
        <fullName>DSHLC_Resident_Email_Update</fullName>
        <description>Notification of Resident Email Update</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>customer.services@folkestone-hythe.gov.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Communities_Templates/FHDC_Resident_Email_Update</template>
    </alerts>
    <alerts>
        <fullName>DSHLC_Resident_Register</fullName>
        <description>Notification of Resident Registration</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>customer.services@folkestone-hythe.gov.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Communities_Templates/FHDC_Resident_Register</template>
    </alerts>
</Workflow>
