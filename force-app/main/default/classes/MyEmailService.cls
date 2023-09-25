/**
 * This class implements the Messaging.InboundEmailHandler interface
 * to handle inbound emails and create Email_Response__c records.
 */
public with sharing class MyEmailService implements Messaging.InboundEmailHandler {
    
    /**
     * Handles incoming emails and creates Email_Response__c records.
     * 
     * @param email The incoming email message.
     * @param envelope The inbound email envelope.
     * @return The result of processing the inbound email.
     */
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        try {
            // Extract relevant data from the email
            String sender = email.fromAddress;
            String subject = email.subject;
            String body = email.plainTextBody;

            // Query for the interested parties with the given email address
            if (Schema.sObjectType.Intrested_Parties__c.isAccessible() && Schema.sObjectType.Intrested_Parties__c.isQueryable()) {
                List<Intrested_Parties__c> parties = [
                    SELECT Id, Name, Email__c 
                    FROM Intrested_Parties__c 
                    WHERE Email__c = :sender 
                    LIMIT 1
                ];

                if (parties != null && !parties.isEmpty()) {
                    // If there is a matching party, create email response records for them
                    List<Email_Responce__c> responses = new List<Email_Responce__c>();
                    List<Attachment> attList = new List<Attachment>();
                    
                    // Create a new Email Response record
                    Email_Responce__c response = new Email_Responce__c(
                        Interested_Parties__c = parties[0].Id,
                        Subject__c = subject,
                        Body__c = body  
                    );

                    if (Schema.sObjectType.Email_Responce__c.isCreateable()) {
                        // Insert the Email Response record
                        insert response;

                        if (email.binaryAttachments != null) {
                            for (Messaging.Inboundemail.BinaryAttachment file : email.binaryAttachments) {
                                // Create an Attachment for binary attachments
                                Attachment attachment = new Attachment();
                                attachment.Name = file.fileName;
                                attachment.Body = file.body;
                                attachment.ParentId = response.Id;
                                attList.add(attachment);
                            }
                            if (attList.size() > 0 && Schema.sObjectType.Attachment.isCreateable()) {
                                // Insert binary attachments
                                insert attList;
                            }
                        }

                        List<Attachment> attList3 = new List<Attachment>();
                        if (email.textAttachments != null) {
                            // Save text attachments, if any
                            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                                // Create an Attachment for text attachments
                                Attachment attachment = new Attachment();
                                attachment.Name = tAttachment.fileName;
                                attachment.Body = Blob.valueOf(tAttachment.body);
                                attachment.ParentId = response.Id;
                                attList3.add(attachment);
                            }
                            if (attList3.size() > 0 && Schema.sObjectType.Attachment.isCreateable()) {
                                // Insert text attachments
                                insert attList3;
                            }
                        }

                        // Set the success message in the email result
                        result.message = 'Email received successfully.';
                    } else {
                        // Set the error message in the email result
                        result.message = 'User does not have permission to create Email Response records.';
                    }
                } else {
                    // Set the error message in the email result
                    result.message = 'Sorry, you are not an existing customer. Please contact the admin.';
                }
            } else {
                // Set the error message in the email result
                result.message = 'User does not have permission to query Intrested_Parties__c object.';
            }
        } catch (Exception ex) {
            // Set the error message in the email result and log the exception
            result.message = 'An error occurred while processing the email. Please contact the admin.';
            System.debug(LoggingLevel.ERROR, ex.getMessage());
        }
        return result;
    }
}