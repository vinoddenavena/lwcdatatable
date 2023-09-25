@isTest
private class MyEmailServiceTest {
    @isTest
    static  void testHandleInboundEmail() {
        Banks__c bnk = new Banks__c(Name='Wissen Bank',Phone__c='6302545872',Type__c='Car Loans',Address__c='Banglore');
        insert bnk;
        // Create test data
        Intrested_Parties__c party = new Intrested_Parties__c(Name='Test Party', Email__c='test@example.com',Phone_Number__c = '5201506758',Bank__c = bnk.Id);
        insert party;
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Test Subject';
        email.plainTextBody = 'Test Body';
        email.fromAddress = 'test@example.com';
        
        // Add binary attachment
        Messaging.Inboundemail.BinaryAttachment binaryAttachment = new Messaging.Inboundemail.BinaryAttachment();
        binaryAttachment.fileName = 'Test Attachment';
        binaryAttachment.body = Blob.valueOf('Test Attachment Body');
        email.binaryAttachments = new Messaging.Inboundemail.BinaryAttachment[] { binaryAttachment };
            
            // Add text attachment
            Messaging.Inboundemail.TextAttachment textAttachment = new Messaging.Inboundemail.TextAttachment();
        textAttachment.fileName = 'Test Text Attachment';
        textAttachment.body = 'Test Text Attachment Body';
        email.textAttachments = new Messaging.Inboundemail.TextAttachment[] { textAttachment };
            
            // Call the handleInboundEmail method
            MyEmailService emailService = new MyEmailService();
        Messaging.InboundEmailResult result = emailService.handleInboundEmail(email, null);
        
        // Verify the results
        List<Email_Responce__c> responses = [SELECT Interested_Parties__c, Subject__c, Body__c FROM Email_Responce__c];
        System.assertEquals(1, responses.size(),'Size is one');
        System.assertEquals(party.Id, responses[0].Interested_Parties__c,'Party Id');
        System.assertEquals(email.subject, responses[0].Subject__c,'Email Subject');
        System.assertEquals(email.plainTextBody, responses[0].Body__c,'Plain Body');
        
        // Verify attachments
        List<Attachment> attachments = [SELECT Id, Name, Body, ParentId FROM Attachment];
        System.assertEquals(2, attachments.size());
        System.assertEquals(binaryAttachment.fileName, attachments[0].Name,'binaryAttachment fileName');
        System.assertEquals(binaryAttachment.body, attachments[0].Body,'binaryAttachment body');
        System.assertEquals(responses[0].Id, attachments[0].ParentId,'response Id');
        System.assertEquals(textAttachment.fileName, attachments[1].Name,'textAttachment fileName');
        System.assertEquals(Blob.valueOf(textAttachment.body), attachments[1].Body,'Blod value of attachment');
        System.assertEquals(responses[0].Id, attachments[1].ParentId,'response Id');
        
        // Clean up the test data
        delete attachments;
        delete responses;
        delete party;
        
    }
}