trigger AccountTrigger on Account (before insert, after insert, after delete, after update) {

    if(Trigger.isAfter && Trigger.isUpdate) {

        AccountTriggerHandler.handleUpdate(Trigger.newMap);
    }

}