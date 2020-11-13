@isTest
public with sharing class AccountAccessTest {

    private static User u1;
    private static User u2;
    private static Account testAccount;
    
    @testSetup static void setup() {
        u1 = new User();
        u1.LastName = 'Test Code 1';
        u1.Email = 'test@test.com';
        u1.Alias = 'Tcode';
        u1.Username = 'test1234444567@test.com';
        u1.CommunityNickname = 'test123';
        u1.LocaleSidKey = 'en_US';
        u1.TimeZoneSidKey = 'GMT';
        u1.ProfileID = getStandardUserId();
        u1.LanguageLocaleKey = 'en_US';
        u1.EmailEncodingKey = 'UTF-8';
        insert u1;

        u2 = new User();
        u2.LastName = 'Test Code 2';
        u2.Email = 'test@test.com';
        u2.Alias = 'Tcode';
        u2.Username = 'test1234555567@test.com';
        u2.CommunityNickname = 'test1234';
        u2.LocaleSidKey = 'en_US';
        u2.TimeZoneSidKey = 'GMT';
        u2.ProfileID = getMarketingProfileId();
        u2.LanguageLocaleKey = 'en_US';
        u2.EmailEncodingKey = 'UTF-8';
        u2.UserRoleId = [select Id from UserRole where Name='Marketing Team'].Id;
        insert u2;

        Test.startTest();
        //create test account
        System.runAs(u1) {        
            Account acc = new Account(Name = 'Hallie1', OwnerId = u1.Id);
            try{
                insert acc;
                Account newAcc = [SELECT Id, Name, OwnerId, CreatedById from Account where name = 'Hallie1'];
                System.debug('OwnerId in runas '+newAcc.OwnerId);
                System.debug('crby in runas '+newAcc.CreatedById);
                System.debug(' NOT EXCEPTION!');
            } catch(DmlException e) {
                System.debug('EXCEPTION!');
                System.debug(e);
            }
        }
            
        
        Test.stopTest();
    }

    @isTest private static void userTest() {

        List<User> userList = [SELECT Id, Name
                               FROM User];
        System.assertEquals(11, userList.size());
    }

    private static Id getStandardUserId() {

        Profile standardProfile = [SELECT Id
                                   FROM Profile
                                   WHERE Name = 'Standard User'];

        return standardProfile.Id;
    }

    private static Id getMarketingProfileId() {

        Profile standardProfile = [SELECT Id
                                   FROM Profile
                                   WHERE Name = 'Marketing User'];

        return standardProfile.Id;
    }

    @isTest private static void accountAccessTest() {
        //List<Account> listAcc = getAccountListByName();
        //System.assertEquals(10, listAcc.size());  
        User u1 = [select Id from user where Username = 'test1234444567@test.com'];
        User u2 = [select Id from user where Username = 'test1234555567@test.com'];
        User u3 = [select Id from user where name = 'test testy'];

        System.debug(u1);      
        System.runAs(u1) {  
                List<Account> accList = getAccountList();
                System.assertNotEquals(null, accList);  
                Account accc = accList.get(0);
                accc.Team__c = 'Team 1';
                update accc;
        }

            
        GroupMember gm= new GroupMember(); 
        gm.GroupId=getGroupIdByName('Team 3');
        gm.UserOrGroupId = u2.id;
        insert gm; 

        System.runAs(u2) {
            List<Account> accList = getAccountList();
            System.assertEquals(0, accList.size());  
        }

        System.runAs(u3) {
            List<Account> accList = getAccountList();
            System.assertEquals(0, accList.size());  
        }             
        
    }

    private static List<Account> getAccountList() {
        List<Account> accs = [SELECT Id, Name
                              FROM Account
                              WITH SECURITY_ENFORCED];
        
        return accs;
    }

    private static Id getGroupIdByName(String groupName) {
        Group grp = [SELECT Id 
                    FROM Group 
                    WHERE Name =: groupName];
        return grp.Id; 
    }

}
