trigger AccountTrigger on Account (after update) {

    AccountTriggerHelper.generateUpdateEvents(Trigger.oldMap, Trigger.newMap);

}