public with sharing class AccountTriggerHelper {
    
    public static void generateUpdateEvents(Map<Id, Account> oldMap, Map<Id, Account> newMap) {

        SObjectType accountType = Schema.getGlobalDescribe().get('Account');
        Map<String,Schema.SObjectField> schemaFieldMap = accountType.getDescribe().fields.getMap();
        String oldTeam = '';
        String newTeam = '';
        Boolean isTeamChanged = false;

        for (Account newAccount: newMap.values()) {

            String eventMessage = '';

            Account oldAccount = oldMap.get(newAccount.ID);

            for(String fieldName : schemaFieldMap.keySet()) {
                if(newAccount.get(fieldName) != oldAccount.get(fieldName)) {
                    if(schemaFieldMap.get(fieldName).getDescribe().isUpdateable()) {
                    
                        String fieldLabel = schemaFieldMap.get(fieldName).getDescribe().getLabel();
                        eventMessage += fieldLabel + ': ' + oldAccount.get(fieldName) + ' -> ' + newAccount.get(fieldName) + '; ';
                
                    }
                    if(fieldName == 'Team__c') {
                        isTeamChanged = true;
                        oldTeam = oldAccount.get(fieldName) + '';
                        newTeam = newAccount.get(fieldName) + '';
                    }
                }                        
            }
        
            generatePlatformEvent(eventMessage, newAccount.Id);
            
            // handle account team change
            if(isTeamChanged) {
                deleteRecordAccessForGroup(newAccount.Id, oldTeam);
                giveRecordAccessToGroup(newAccount.Id, newTeam);
            }
        }
    }

    private static void generatePlatformEvent(String message, Id accId) {
        Account_Change__e accChangeEvent = new Account_Change__e(
            Message__c = message,
            Account_Id__c = accId + ''
        );

        Database.SaveResult sr = Eventbus.publish(accChangeEvent);
        if(sr.isSuccess()) {
            System.debug('Success in publishing event!');
            System.debug(message);

        } else {
            for(Database.Error err : sr.getErrors()) {
                System.debug('Error returned: ' +
                             err.getStatusCode() +
                             ' - ' +
                             err.getMessage());
            }
        }
    }    

    private static void deleteRecordAccessForGroup(Id accountId, String oldTeamName) {
        System.debug('old t name'+oldTeamName);
        if(oldTeamName != 'null') {
            AccountShare accShare = getAccountShareByIds(accountId, oldTeamName);
            System.debug('Old acc share' + accShare);        
            if(accShare != null) {
                delete accShare;
            }
        }        
    }

    private static void giveRecordAccessToGroup(Id accountId, String newTeamName) {
        // Create new sharing object for the custom Stuff object
        AccountShare accShare  = new AccountShare();
        //Define object’s ID
        accShare.AccountId = accountId;
        // Define ID of a user/group
        Id groupId = getGroupIdByName(newTeamName);
        System.debug(groupId);
        accShare.UserOrGroupId = groupId;
        // Define access level
        accShare.AccountAccessLevel = 'Edit';
        accShare.OpportunityAccessLevel = 'Edit';
        // Define rowCause as 'manual' for manual sharing.
        // This line can be ommitted, as ‘manual’ is the default value. 
        accShare.RowCause = Schema.AccountShare.RowCause.Manual;
        // Insert the created object 
        insert accShare;
        System.debug(accShare);
    }

    private static Id getGroupIdByName(String groupName) {
        Group grp = [SELECT Id 
                    FROM Group 
                    WHERE Name =: groupName];
        return grp.Id; 
    }

    private static AccountShare getAccountShareByIds(Id accId, String groupName) {
        Id groupId = getGroupIdByName(groupName);
        AccountShare accShare = [SELECT Id 
                                FROM AccountShare 
                                WHERE AccountId =: accId and UserOrGroupId =: groupId];
        return accShare; 
    }
 
}
