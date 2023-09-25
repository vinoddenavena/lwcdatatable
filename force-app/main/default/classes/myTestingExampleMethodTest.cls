@isTest
private class myTestingExampleMethodTest {
   
    @isTest
    static void testGetSObject() {
        // Create a custom object with an Email__c field
        Banks__c bnk = new Banks__c(Name='Wissen Bank',Phone__c='6302545872',Type__c='Car Loans',Address__c='Banglore');
        insert bnk;
        Customers__c customObj = new Customers__c(Name = 'Customers', Email__c = 'test@example.com',Customer_Bank__c=bnk.Id,Phone__c='9010506758');
        insert customObj;
        
        // Call the getSObject method
        List<myTestingExampleMethod.SObjectDetails> result = myTestingExampleMethod.getSObject();
        
        // Verify that the result contains the expected object
        System.assertEquals(4, result.size(),'Size is 4');
        myTestingExampleMethod.SObjectDetails obj = result[0];
        System.assertEquals('Customers__c', obj.apiName,'api Name');
        System.assertEquals('Customers', obj.label,'label Name');
    }
    
    @isTest
    static void testGetSObjectFields() {
        // Create a custom object with a picklist field
        Banks__c bnk = new Banks__c(Name='Wissen Bank',Phone__c='6302545872',Type__c='Car Loans',Address__c='Banglore');
        insert bnk;
        Intrested_Parties__c customObj = new Intrested_Parties__c(Name = 'Test Custom Object', Email__c = 'test@example.com', Status__c = 'Open - Not Contacted',Bank__c=bnk.Id,Phone_Number__c='9010506758');
        insert customObj;
        
        // Call the getSObjectFields method
        List<myTestingExampleMethod.SObjectFieldDetails> result = myTestingExampleMethod.getSObjectFields('Intrested_Parties__c');
        
        // Verify that the result contains the expected field
        System.assertEquals(2, result.size(),'Size 2');
        myTestingExampleMethod.SObjectFieldDetails field = result[0];
        System.assertEquals('Status__c', field.apiName,'field api name');
        System.assertEquals('Status', field.label,'field label');
        System.assertEquals(4, field.picklistValues.size(),'size 4');
        myTestingExampleMethod.PicklistValueDetails picklistValue = field.picklistValues[0];
        System.assertEquals('Open - Not Contacted', picklistValue.value,'picklist value');
        System.assertEquals('Open - Not Contacted', picklistValue.label,'picklist label');
    }
    
    @isTest
    static void testGetPicklistFieldValues() {
        // Create a custom object with a picklist field
        Banks__c bnk = new Banks__c(Name='Wissen Bank',Phone__c='6302545872',Type__c='Car Loans',Address__c='Banglore');
        insert bnk;
        Intrested_Parties__c customObj = new Intrested_Parties__c(Name = 'Test Custom Object',Email__c = 'test@example.com', Status__c = 'Open - Not Contacted',Bank__c=bnk.Id,Phone_Number__c='9010506758');
        insert customObj;
        
        // Call the getPicklistFieldValues method
        List<String> result = myTestingExampleMethod.getPicklistFieldValues('Intrested_Parties__c', 'Status__c');
        
        // Verify that the result contains the expected values
        System.assertEquals(4, result.size(),'size 4');
        System.assert(result.contains('Open - Not Contacted'),'It contain value');
        System.assert(result.contains('Open - Not Contacted'),'It contain value');
    }
    
    @isTest
    static void testGetFieldData() {
        Banks__c bnk = new Banks__c(Name='Wissen Bank',Phone__c='6302545872',Type__c='Car Loans',Address__c='Banglore');
        insert bnk;
        // Create a custom object with an Email__c field
        Intrested_Parties__c customObj = new Intrested_Parties__c(Name = 'Test Custom Object', Email__c = 'test@example.com',Bank__c=bnk.Id,Phone_Number__c='9010506758',Status__c='Open - Not Contacted');
        insert customObj;
        
        // Call the getFieldData method
        
        List<SObject> result = myTestingExampleMethod.getFieldData('Intrested_Parties__c','Status__c', 'Open - Not Contacted');
        
        // Verify that the result contains the expected record
        System.assertEquals(1, result.size(),'Size 1');
        Intrested_Parties__c obj = (Intrested_Parties__c) result[0];
        System.assertEquals('Test Custom Object', obj.Name,'object data');
        System.assertEquals('test@example.com', obj.Email__c,'object data');
    }
}