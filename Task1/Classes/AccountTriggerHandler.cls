public with sharing class AccountTriggerHandler {

    private static List<Schema.SObjectField> accountTrackedFields = generateAccountTrackedFields();

    public static void updateExternalIds(List<Account> insertedAccounts) {

        for(Account acc: insertedAccounts) {
            acc.externalId__c = getUUID();
        }
    }

    private static String getUUID() {

        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,30);
        system.debug(guid);
        return guid;
    }

    public static List<String> getExternalIds(List<Account> oldAccounts) {

        List<String> oldExternalIds = new List<String>();

        for(Account deletedAcc: oldAccounts) {
            oldExternalIds.add(deletedAcc.externalId__c);
        }

        return oldExternalIds;
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

    private static List<Schema.SObjectField> generateAccountTrackedFields() {

        List<Schema.SObjectField> fields = new List<Schema.SObjectField>();
        fields.add(Schema.Account.Name);
        fields.add(Schema.Account.AccountNumber);
        fields.add(Schema.Account.Phone);
        fields.add(Schema.Account.BillingAddress);
        fields.add(Schema.Account.ShippingAddress);

        return fields;
    }
}
