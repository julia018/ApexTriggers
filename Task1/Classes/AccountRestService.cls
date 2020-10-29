public with sharing class AccountRestService {
 
    public static Http http = new Http();
    public static HTTPResponse response;
    public static HttpRequest request;

    public static void addAccounts(String serializedAccounts) {
        System.debug(serializedAccounts);
        request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint('callout:SFAccount/services/apexrest/Account');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(serializedAccounts); 
        response = http.send(request);  
        System.debug(response.getBody());
    }

    public static void updateAccounts(String serializedAccounts) {
        
        request = new HttpRequest();
        request.setMethod('PATCH');
        request.setEndpoint('callout:SFAccount/services/apexrest/Account');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(serializedAccounts); 
        response = http.send(request);  
        System.debug(response.getBody());

    }
 
    public static void deleteAccounts(List<String> deletedAccounts) {
         
        request = new HttpRequest();
        request.setMethod('DELETE');
        request.setEndpoint('callout:SFAccount/services/apexrest/Account');
        System.debug('Dlete');
        String serializedAccountList = JSON.serialize(deletedAccounts);
        request.setBody(serializedAccountList);
        System.debug(request.getBody());
        response = http.send(request); 
        System.debug(response.getBody());
    }
    
}