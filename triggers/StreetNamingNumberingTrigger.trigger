trigger StreetNamingNumberingTrigger on Street_Naming_Numbering_Application__c (after insert, before insert, after update, before update, after delete, before delete, after undelete) {
    arcshared.TriggerDispatcher.CallHandlers();
}