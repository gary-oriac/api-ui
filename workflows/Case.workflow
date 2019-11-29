<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Case_closed_response</fullName>
        <description>Case closed response</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>customer.services@folkestone-hythe.gov.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Autoresponder_Templates/Generic_Case_Closed_Autoresponder</template>
    </alerts>
    <alerts>
        <fullName>Generic_Autoresponder</fullName>
        <description>Generic Autoresponder</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>customer.services@folkestone-hythe.gov.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Autoresponder_Templates/Generic_Autoresponder</template>
    </alerts>
    <rules>
        <fullName>Generic Case Closed Autoresponder</fullName>
        <actions>
            <name>Case_closed_response</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>Case closed autoresponder to customer</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
