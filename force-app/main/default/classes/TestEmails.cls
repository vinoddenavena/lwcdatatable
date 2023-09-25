/**
* @description this get interested parties data and it will send mails
*/
public with sharing class TestEmails {
    @AuraEnabled(cacheable=true)
    /**
* @description this get interested parties data and it will send mails
* @param Status is used to filter data based on status
*/
    
    public static List<Intrested_Parties__c> fetchOpportunityList(String status){ 
        if (Schema.sObjectType.Intrested_Parties__c.isAccessible() && Schema.sObjectType.Intrested_Parties__c.isQueryable()) {
            if(status != ''){
                return [SELECT Id, Name, Email__c, Status__c, Phone_Number__c, Bank__c, Source__c FROM Intrested_Parties__c WHERE Status__c = :status];  
            } else {
                return [SELECT Id, Name, Email__c, Status__c, Phone_Number__c, Bank__c, Source__c FROM Intrested_Parties__c];  
            }
        } else {
            return new List<Intrested_Parties__c>(); // Return an empty list if the user doesn't have access to the object.
        }
    } 
    
    @AuraEnabled
    /**
* @description this get interested parties data and it will send mails
* @param emailDetails
* @param toAddress
*/
    public static void sendEmail(Map<String,Object> emailDetails,List<String> toAddress) {
        List<String> toAddressesIds = toAddress;
        String subject= (String)emailDetails.get('subject');
        String body = (String)emailDetails.get('body');
        String fileName = (String)emailDetails.get('fileName');
        String base64Data = (String)emailDetails.get('base64Data');
        
        if (!Schema.sObjectType.EmailMessage.isCreateable()) {
            // The user doesn't have permission to create Email Messages.
            // Handle the error condition or notify the user accordingly.
            return;
        }
        
        List<Messaging.SingleEmailMessage> lstEmailsToCandidate = new List<Messaging.SingleEmailMessage>();
        for (String cnd : toAddressesIds) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toEmailIDs = new String[]{cnd};
                email.setToAddresses(toEmailIDs);
            if (fileName != null && base64Data != null) {
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName(fileName);
                attachment.setBody(EncodingUtil.base64Decode(base64Data));
                email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
            }
            
            email.setSubject(subject);
            email.setHtmlBody(body);
            email.setReplyTo('lakshman.m14744@w-477hwc5v8v17f4uzhze8uecrzec24qbjj1w394u8ch3kdfi91.2w-ri1ihead.ap16.apex.salesforce.com');
            lstEmailsToCandidate.add(email);
        }
        
        if (!lstEmailsToCandidate.isEmpty()) {
            Messaging.sendEmail(lstEmailsToCandidate);
        }
    }
}