@isTest
public class TestEmailsTestClass {
    @isTest
    static void testFetchOpportunityList() {
     
        Banks__c bnk = new Banks__c(Name='Wissen Bank',Phone__c='6302545872',Type__c='Car Loans',Address__c='Banglore');
        insert bnk;
        Intrested_Parties__c ip1 = new Intrested_Parties__c();
        ip1.Name = 'Test IP 1';
        ip1.Email__c = 'test1@test.com';
        ip1.Status__c = 'Open - Not Contacted';
        ip1.Phone_Number__c = '9909090101';
        ip1.Bank__c = bnk.Id;
        insert ip1;

        Intrested_Parties__c ip2 = new Intrested_Parties__c();
        ip2.Name = 'Test IP 2';
        ip2.Email__c = 'test2@test.com';
        ip2.Status__c = 'Open - Not Contacted';
        ip2.Phone_Number__c = '9909090101';
        ip2.Bank__c =  bnk.Id;
        insert ip2;

        Test.startTest();
        // Test with Status parameter
        List<Intrested_Parties__c> ipList = TestEmails.fetchOpportunityList('Open - Not Contacted');
        System.assertEquals(2, ipList.size(),'2');

        // Test without Status parameter
        ipList = TestEmails.fetchOpportunityList('');
        System.assertEquals(2, ipList.size(),'2');

        Test.stopTest();
    }

    @isTest
    static void testSendEmail() {
       
       	Banks__c bnk = new Banks__c(Name='Wissen Bank',Phone__c='6302545872',Type__c='Car Loans',Address__c='Banglore');
        insert bnk;
        Intrested_Parties__c ip1 = new Intrested_Parties__c();
        ip1.Name = 'Test IP 1';
        ip1.Email__c = 'test1@test.com';
        ip1.Status__c = 'Open - Not Contacted';
        ip1.Phone_Number__c = '9909090101';
        ip1.Bank__c = bnk.Id;
        insert ip1;

        Intrested_Parties__c ip2 = new Intrested_Parties__c();
        ip2.Name = 'Test IP 2';
        ip2.Email__c = 'test2@test.com';
        ip2.Status__c = 'Open - Not Contacted';
        ip2.Phone_Number__c = '9909090101';
        ip2.Bank__c = bnk.Id;
        insert ip2;

        // Prepare test email data
        List<Intrested_Parties__c> emails = new List<Intrested_Parties__c>{ip1, ip2};
            List<String> toAddressesIds = new  List<String>();
        for(Intrested_Parties__c o:emails){
            String email = o.Email__c;
            toAddressesIds.add(email);
        }
        Map<String,String> testMap = new Map<String,String>();
        testMap.put('subject' , 'Test Email Subject');
         testMap.put('body' , 'Test Email Body');
        testMap.put('fileName' , 'Test Attachment');
         testMap.put('base64Data', EncodingUtil.base64Encode(Blob.valueOf('Test Attachment Body')));
		
        Test.startTest();
        TestEmails.sendEmail(testMap,toAddressesIds);
        Test.stopTest();

        // Assert that the emails were sent
        List<EmailMessage> sentEmails = [SELECT Id, ToAddress FROM EmailMessage];

        System.assertEquals(2, sentEmails.size(),'Size 2');
        System.assertEquals(ip1.Email__c, sentEmails[0].ToAddress,'Get Emails');
    }
}