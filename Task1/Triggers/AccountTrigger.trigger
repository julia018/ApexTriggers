trigger AccountTrigger on Account (before insert, after insert, after delete, after update) {

    if(Trigger.isBefore && Trigger.isInsert) {

        AccountTriggerHandler.updateExternalIds(Trigger.new);
    }

    if(Trigger.isAfter) {

        if(Trigger.isInsert) {
            System.debug(Trigger.newMap);
            
            AccountTriggerHandler.onInsert(Trigger.newMap.keySet());
        } else if(Trigger.isUpdate) {
            List<Id> updatedAccsByFields = AccountTriggerHandler.getUpdatedAccountIdsByFields(Trigger.new, Trigger.old);
            AccountTriggerHandler.onUpdate(updatedAccsByFields);
        } else if(Trigger.isDelete) {
            
            List<String> deletedExternalIds = AccountTriggerHandler.getExternalIds(Trigger.old);
            System.debug(Trigger.old);
            System.debug('old ext ids');
            System.debug(deletedExternalIds);
            AccountTriggerHandler.onDelete(deletedExternalIds);
        }

    }
}