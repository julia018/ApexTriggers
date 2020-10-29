public with sharing class AccountTriggerHandler {

    private static List<Schema.SObjectField> accountTrackedFields = generateAccountTrackedFields();

    @future(callout=true)
    public static void onDelete(List<String> deletedAccountExternalIds) {

        AccountRestService.deleteAccounts(deletedAccountExternalIds);
    }

    @future(callout=true)
    public static void onInsert(Set<Id> insertedAccountIds) {

        List<Account> accList = [SELECT Id, Name, Phone, AccountNumber, BillingCountry, BillingCity, BillingStreet, ShippingCountry, ShippingCity, ShippingStreet, externalId__c 
                                FROM Account 
                                WHERE Id IN :insertedAccountIds];
        String serializedAccountList = JSON.serialize(accList);
        AccountRestService.addAccounts(serializedAccountList);
    }

    @future(callout=true)
    public static void onUpdate(List<Id> updatedAccIds) {

        if(updatedAccIds.size() == 0) {
            return;
        }

        List<Account> updatedAccs = getAccountListById(updatedAccIds);
        String serializedAccountList = JSON.serialize(updatedAccs);
        AccountRestService.updateAccounts(serializedAccountList);
    }

    private static List<Schema.SObjectField> generateAccountTrackedFields() {

        List<Schema.SObjectField> fields = new List<Schema.SObjectField>();
        fields.add(Schema.Account.Name);
        fields.add(Schema.Account.AccountNumber);
        fields.add(Schema.Account.Phone);
        fields.add(Schema.Account.BillingAddress);
        fields.add(Schema.Account.ShippingAddress);

        return fields;
    }

    public static List<Id> getUpdatedAccountIdsByFields(List<Account> newAccs, List<Account> oldAccs) {

        List<Id> updatedAccountIds = new List<Id>();

        for(Integer i = 0; i < newAccs.size(); i++) {
            for(Schema.SObjectField field: accountTrackedFields) {
                if(newAccs.get(i).get(field) != oldAccs.get(i).get(field)) {
                    updatedAccountIds.add(newAccs.get(i).Id);
                    break;
                }
            }
        }

        return updatedAccountIds;
    } 

    private static Account getAccountById(Id accId) {

        List<Account> accList = [SELECT Id, Name, AccountNumber, Phone, BillingCountry, externalId__c
                                FROM Account
                                WHERE Id =: accId];
        return accList[0];        
    }

    private static List<Account> getAccountListById(List<Id> accIdList) {

        List<Account> accList = [SELECT Name, AccountNumber, Phone, BillingCountry, externalId__c
                                FROM Account
                                WHERE Id IN :accIdList];
        return accList;        
    }

    public static void updateExternalIds(List<Account> insertedAccounts) {

        for(Account acc: insertedAccounts) {
            acc.externalId__c = getUUID();
        }
    }

    public static List<String> getExternalIds(List<Account> oldAccounts) {

        List<String> oldExternalIds = new List<String>();

        for(Account deletedAcc: oldAccounts) {
            oldExternalIds.add(deletedAcc.externalId__c);
        }

        return oldExternalIds;
    }

    private static String getUUID() {

        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,30);
        system.debug(guid);
        return guid;
    }

}
