trigger CRM_UserTrigger on User (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    arcshared.TriggerDispatcher.callHandlers();
}