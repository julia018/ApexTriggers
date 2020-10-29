@RestResource(urlMapping='/Account/*')
global with sharing class AccountAPI {

    private static List<Schema.SObjectField> accountTrackedFields = generateAccountTrackedFields();

    @HttpDelete
    global static void doDelete() {
        
        RestRequest req = RestContext.request;
        System.debug(req);
        List<String> deletedAccsExternalIds = (List<String>)JSON.deserialize(req.requestbody.toString(), List<String>.class);
        
        List<Account> accountsToDelete = new List<Account>();
        for(String externalId: deletedAccsExternalIds) {
            checkIsAccountToDelete(externalId, accountsToDelete);
        } 
        
        delete accountsToDelete;
    }

    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        System.debug(RestContext.request);
        List<Account> accList = (List<Account>)JSON.deserialize(req.requestbody.toString(), List<Account>.class);
        System.debug(accList.size());
        System.debug(accList[0]);
        List<Account> newAccounts = new List<Account>();
        for(Account acc: accList) {
            if(!isAccountPresent(acc.externalId__c)) {
                acc.Id = null;
                newAccounts.add(acc);
            }
        } 
        System.debug(newAccounts.size());       
        insert newAccounts;
    }

    @HttpPatch
    global static void doUpdate() {        

        RestRequest request = RestContext.request;
        List<Account> receivedAccList = (List<Account>)JSON.deserialize(request.requestbody.toString(), List<Account>.class);
        List<Account> accountsToUpdate = getAccountsToUpdate(receivedAccList);
        update accountsToUpdate;        
    }

    private static List<Account> getAccountsToUpdate(List<Account> receivedAccs) {

        List<Account> updatedAccs = new List<Account>();

        for(Account acc: receivedAccs) {
            Account currAcc = getAccountByExternalId(acc.externalId__c);
            for(Schema.SObjectField field: accountTrackedFields) {
                if(currAcc.get(field) != acc.get(field)) {
                    Account copy = acc.clone(false, true, true, true);
                    copy.Id = currAcc.Id;
                    updatedAccs.add(copy);
                    break;
                }
            }
        }

        return updatedAccs;
    }

    private static Boolean isAccountPresent(String externalId) {
        List<Account> accList = [SELECT Id
                                FROM Account
                                WHERE externalId__c =: externalId];
        if(accList.size() == 0) {
            return false;
        }
        return true;
    }

    private static Account getAccountByExternalId(String externalId) {
        List<Account> accList = [SELECT Id, Name, AccountNumber, Phone, BillingCountry, BillingCity, BillingStreet, ShippingCountry, ShippingCity, ShippingStreet
                                FROM Account
                                WHERE externalId__c =: externalId];
        return accList[0];
    }

    private static Boolean areAccountsEqual(Account firstAcc, Account secondAcc) {
        Account firstAccCopy = firstAcc.clone(false, true, true, true);
        firstAcc.Id = null;
        Account secondAccCopy = secondAcc.clone(false, true, true, true);
        secondAcc.Id = null;
        if(firstAcc == secondAcc) {
            return true;
        } else {
            return false;
        }       
    }

    private static void checkIsAccountToDelete(String externalId, List<Account> accountListToDelete) {
        if(isAccountPresent(externalId)) {
            Account acc = getAccountByExternalId(externalId);
            accountListToDelete.add(acc);
        }
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
