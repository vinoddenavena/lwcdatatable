/**
 * @description This class is used to get object details,picklist fields and values
 */
public with sharing class myTestingExampleMethod {
    
    @AuraEnabled(cacheable=true)
    /**
 * @description This Method is used to get all custom Objects having Email filed 
 * @return customObjectsWithEmail 
 */
    public static List<SObjectDetails> getSObject(){
        List<SObjectDetails> customObjectsWithEmail = new List<SObjectDetails>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        for (Schema.SObjectType schemaType : schemaMap.values()) {
            if (schemaType.getDescribe().isCustom()) {
                // Check if the object has an email field
                if (schemaType.getDescribe().fields.getMap().containsKey('Email__c')) {
                    SObjectDetails obj = new SObjectDetails();
                    obj.apiName = schemaType.getDescribe().getName();
                    obj.label = schemaType.getDescribe().getLabel();
                    customObjectsWithEmail.add(obj);
                }
            }
        }

        return customObjectsWithEmail;
    }
    
        /**
 * @description This is warpper Method is used to set object label and api name  
 */
    public class SObjectDetails {
        @AuraEnabled
                            /**
 * @description This is apiName is used to set object api name  
 */
        public String apiName {get; set;}
        @AuraEnabled
                           /**
 * @description This is label is used to set object label 
 */
        public String label {get; set;}
    }
    
    @AuraEnabled(cacheable=true)
        /**
 * @description This Method is used to get all picklist fields when object name is given
 * @param  objectName the selected object is getting from lwc
 * @return fields returns  picklist fields
 */
    public static List<SObjectFieldDetails> getSObjectFields(String objectName){
        System.debug('the object name was '+objectName);
        List<SObjectFieldDetails> fields = new List<SObjectFieldDetails>();
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
        for(Schema.SObjectField field : fieldMap.values()){
            Schema.DescribeFieldResult fieldDescribeResult = field.getDescribe();
            if(fieldDescribeResult.getType() == Schema.DisplayType.Picklist){
                SObjectFieldDetails fieldDetails = new SObjectFieldDetails();
                fieldDetails.apiName = fieldDescribeResult.getName();
                fieldDetails.label = fieldDescribeResult.getLabel();
                List<Schema.PicklistEntry> picklistValues = fieldDescribeResult.getPicklistValues();
                List<PicklistValueDetails> picklistValueDetails = new List<PicklistValueDetails>();
                for(Schema.PicklistEntry picklistValue : picklistValues){
                    PicklistValueDetails picklistValueDetail = new PicklistValueDetails();
                    picklistValueDetail.value = picklistValue.getValue();
                    picklistValueDetail.label = picklistValue.getLabel();
                    picklistValueDetails.add(picklistValueDetail);
                }
                fieldDetails.picklistValues = picklistValueDetails;
                fields.add(fieldDetails);
            }
        }
        return fields;
    }
            /**
 * @description This is warpper class is used to set field label and api name  
 */
    public class SObjectFieldDetails {
        @AuraEnabled
                    /**
 * @description This is apiName is used to set field api name  
 */
        public String apiName {get; set;}
        @AuraEnabled
                    /**
 * @description This is label is used to set field label 
 */
        public String label {get; set;}
        @AuraEnabled
                    /**
 * @description This is picklistValues is used to set value label and api name  
 */
        public List<PicklistValueDetails> picklistValues {get; set;}
    }

                /**
 * @description This is warpper class is used to set PicklistValueDetails 
 */
    public class PicklistValueDetails {
        @AuraEnabled
                           /**
 * @description This is picklistValues is used to set value label and api name  of pick list
 */
        public String value {get; set;}
        @AuraEnabled
                           /**
 * @description This is picklistValues is used to set value label and api name   of pick list
 */
        public String label {get; set;}
    }
    
    @AuraEnabled(cacheable=true)
            /**
 * @description This Method is used to get all picklist fields when object name is given
 * @param  objectName the selected object is getting from lwc
 * @param fieldName the selected field is getting from lwc
 * @return picklistValues returns  picklist fields
 */
    public static List<String> getPicklistFieldValues(String objectName, String fieldName){
        List<String> picklistValues = new List<String>();
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
        Schema.SObjectField field = fieldMap.get(fieldName);
        if(field != null && field.getDescribe().getType() == Schema.DisplayType.Picklist){
            Schema.DescribeFieldResult fieldDescribeResult = field.getDescribe();
            List<Schema.PicklistEntry> picklistEntries = fieldDescribeResult.getPicklistValues();
            for(Schema.PicklistEntry entry : picklistEntries){
                picklistValues.add(entry.getValue());
            }
        }
        return picklistValues;
    }
    
    @AuraEnabled(cacheable=true)
    /**
    *  @description This Method is used to get all picklist fields when object name is given
    * @param  objectName the selected object is getting from lwc
    * @param fieldName the selected field is getting from lwc
   * @param value the selected value is getting from lwc
    * @return sObjectResultList returns  data
    */
    public static List<SObject> getFieldData(String objectName, String fieldName, String value) {
        
        List<SObject> sObjectResultList = new List<SObject>();
        if (!String.isBlank(objectName) && !String.isBlank(fieldName) && value != null) {
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
			
            if (objType != null) {
                Schema.SObjectField field = objType.getDescribe().fields.getMap().get(fieldName);
				
                if (field != null && field.getDescribe().getType() == Schema.DisplayType.Picklist) {
                    
                   
                    String safeFieldName = String.escapeSingleQuotes(fieldName);
                    String queryy = 'SELECT Id, Name, Email__c, ' + safeFieldName + ' FROM ' + String.escapeSingleQuotes(objectName) + ' WHERE ' + safeFieldName + ' = :value AND Email__c != null';

                    sObjectResultList = Database.query(queryy);
                    
                }
            }
        } 
        else 
        {
           
            String query = 'SELECT Id, Name, Email__c FROM ' + String.escapeSingleQuotes(objectName) + ' WHERE Email__c != null';
            sObjectResultList = Database.query(query);
            
        }
       
        return sObjectResultList;
    }
}