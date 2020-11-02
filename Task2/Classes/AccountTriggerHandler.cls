public with sharing class AccountTriggerHandler {

    public static void handleUpdate(Map<Id, Account> newAccounts) {
        List<Id> accountIdsForPDF = new List<Id>();
        for(Id accId: newAccounts.keySet()) {
            if(isPDFchecked(newAccounts.get(accId))) {
                accountIdsForPDF.add(accId);
            }
        }
        PDFCreator.createPDFs(accountIdsForPDF);
    }

    private static Boolean isPDFchecked(Account acc) {
        if(acc.PDF__c == true) {
            return true;
        }
        return false;
    }

}
