public with sharing class AccountHandlerQueue implements Queueable, Database.AllowsCallouts{
    
    private List<String> deletedAccountExternalIds;
    private Set<Id> insertedAccountIds;
    private List<Id> updatedAccIds;
    private String action;

    public AccountHandlerQueue(String action) {
        this.action = action;
    }


    public void execute(QueueableContext context) {
        switch on this.action {
            when 'CREATE' {
                addAccounts();
            }
            when 'UPDATE' {
                updateAccounts();
            }
            when 'DELETE' {
                deleteAccounts();
            }
        }
    }

    private void addAccounts() {
        List<Account> accList = [SELECT Id, Name, Phone, AccountNumber, BillingCountry, BillingCity, BillingStreet, ShippingCountry, ShippingCity, ShippingStreet, externalId__c 
                                FROM Account 
                                WHERE Id IN :insertedAccountIds];
        String serializedAccountList = JSON.serialize(accList);
        AccountRestService.addAccounts(serializedAccountList);
    }

    private void updateAccounts() {

        if(updatedAccIds.size() == 0) {
            return;
        }

        List<Account> updatedAccs = getAccountListById(updatedAccIds);
        String serializedAccountList = JSON.serialize(updatedAccs);
        AccountRestService.updateAccounts(serializedAccountList);
    }

    private void deleteAccounts() {
        AccountRestService.deleteAccounts(deletedAccountExternalIds);
    }

    private static List<Account> getAccountListById(List<Id> accIdList) {

        List<Account> accList = [SELECT Name, AccountNumber, Phone, BillingCountry, externalId__c
                                FROM Account
                                WHERE Id IN :accIdList];
        return accList;        
    }

    public void setDeletedAccountExternalIds(List<String> accIds) {
        this.deletedAccountExternalIds = accIds;
    }

    public void setInsertedAccountIds(Set<Id> accIds) {
        this.insertedAccountIds = accIds;
    }

    public void setUpdatedAccIds(List<Id> accIds) {
        this.updatedAccIds = accIds;
    }

}
