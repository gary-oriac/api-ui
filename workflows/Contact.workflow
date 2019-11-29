<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>DSHLC_Business_Profile_Update</fullName>
        <description>Notification of Business profile update</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>customer.services@folkestone-hythe.gov.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Communities_Templates/FHDC_Business_Profile_Update</template>
    </alerts>
    <alerts>
        <fullName>DSHLC_Resident_Profile_Update</fullName>
        <description>Notification of Resident profile update</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>customer.services@folkestone-hythe.gov.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Communities_Templates/FHDC_Resident_Profile_Update</template>
    </alerts>
    <fieldUpdates>
        <fullName>arcuscrm__Remove_email_address_based_on_check</fullName>
        <description>This update will add .deceased to an email when the contact is flagged as deceased</description>
        <field>Email</field>
        <formula>IF(  ISBLANK(Email)  , '' ,  Email +".deceased" )</formula>
        <name>Obfuscate email address based on check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>arcuscrm__Update_surname_based_on_check</fullName>
        <description>If deceased, update surname</description>
        <field>LastName</field>
        <formula>LastName &amp;" "&amp; "(DECEASED)"</formula>
        <name>Update surname based on check.</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>arcuscrm__dead_do_not_call</fullName>
        <field>DoNotCall</field>
        <literalValue>1</literalValue>
        <name>dead do not call</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>arcuscrm__dead_do_not_contact</fullName>
        <field>arcuscrm__Do_Not_Contact__c</field>
        <literalValue>1</literalValue>
        <name>dead do not contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>arcuscrm__Contact is flagged as deceased</fullName>
        <actions>
            <name>arcuscrm__Remove_email_address_based_on_check</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>arcuscrm__Update_surname_based_on_check</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>arcuscrm__dead_do_not_call</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>arcuscrm__dead_do_not_contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.arcuscrm__Contact_is_Deceased__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>If contact is marked as deceased, then change the last name and email and flag as do not contact.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
