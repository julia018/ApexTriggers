trigger AccountTrigger on Account (before insert, after insert, after delete, after update) {

    if(Trigger.isBefore && Trigger.isInsert) {

        //generating external Ids for new accounts
        AccountTriggerHandler.updateExternalIds(Trigger.new);
    }

    if(Trigger.isAfter) {

        if(Trigger.isInsert) {
            System.debug(Trigger.newMap);
            AccountHandlerQueue queueHandler = new AccountHandlerQueue('CREATE');
            queueHandler.setInsertedAccountIds(Trigger.newMap.keySet());
            System.enqueueJob(queueHandler);
        } else if(Trigger.isUpdate) {
            List<Id> updatedAccsByFields = AccountTriggerHandler.getUpdatedAccountIdsByFields(Trigger.new, Trigger.old);
            AccountHandlerQueue queueHandler = new AccountHandlerQueue('UPDATE');
            queueHandler.setUpdatedAccIds(updatedAccsByFields);
            System.enqueueJob(queueHandler);
        } else if(Trigger.isDelete) {
            
            List<String> deletedExternalIds = AccountTriggerHandler.getExternalIds(Trigger.old);
            AccountHandlerQueue queueHandler = new AccountHandlerQueue('DELETE');
            queueHandler.setDeletedAccountExternalIds(deletedExternalIds);
            System.enqueueJob(queueHandler);
        }

    }


}