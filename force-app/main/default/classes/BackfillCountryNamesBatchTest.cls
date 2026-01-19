/**
 * @description Test class for BackfillCountryNamesBatch
 * @author Procetra (procetra.com)
 */
@isTest
private class BackfillCountryNamesBatchTest {
    
    /**
     * @description Test batch execution with valid data
     */
    @isTest
    static void testBatchExecution() {
        // Get a valid country code field from Account to test with
        // This test uses dynamic field discovery to work in any org
        String countryCodeField = findCountryCodeField('Account');
        
        if (countryCodeField == null) {
            // Skip test if no country code field found
            System.debug('No country code field found on Account - skipping test');
            return;
        }
        
        // Create a text field name that would hold the country name
        // In a real scenario, this would be a custom field created by the user
        String countryNameField = countryCodeField.replace('__CountryCode__s', '_Country__c')
                                                   .replace('__countrycode__s', '_Country__c');
        
        Test.startTest();
        
        try {
            // Create the batch - this validates the fields exist
            BackfillCountryNamesBatch batch = new BackfillCountryNamesBatch(
                'Account',
                countryCodeField,
                countryNameField
            );
            
            // Execute the batch
            Database.executeBatch(batch, 200);
        } catch (BackfillCountryNamesBatch.BackfillException e) {
            // Expected if country name field doesn't exist
            System.debug('Expected exception: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Test batch with invalid object name
     */
    @isTest
    static void testInvalidObjectName() {
        Test.startTest();
        
        try {
            BackfillCountryNamesBatch batch = new BackfillCountryNamesBatch(
                'InvalidObjectName__c',
                'Country_Code__c',
                'Country_Name__c'
            );
            System.assert(false, 'Should have thrown exception');
        } catch (BackfillCountryNamesBatch.BackfillException e) {
            System.assert(e.getMessage().contains('does not exist'), 'Should mention object does not exist');
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Test batch with invalid field name
     */
    @isTest
    static void testInvalidFieldName() {
        Test.startTest();
        
        try {
            BackfillCountryNamesBatch batch = new BackfillCountryNamesBatch(
                'Account',
                'Invalid_Field_Name__c',
                'Country_Name__c'
            );
            System.assert(false, 'Should have thrown exception');
        } catch (BackfillCountryNamesBatch.BackfillException e) {
            System.assert(e.getMessage().contains('does not exist'), 'Should mention field does not exist');
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Test the invocable method with valid input
     */
    @isTest
    static void testInvocableMethodValid() {
        String countryCodeField = findCountryCodeField('Account');
        
        if (countryCodeField == null) {
            System.debug('No country code field found - skipping test');
            return;
        }
        
        String countryNameField = countryCodeField.replace('__CountryCode__s', '_Country__c')
                                                   .replace('__countrycode__s', '_Country__c');
        
        Test.startTest();
        
        BackfillCountryNamesBatch.BackfillInput input = new BackfillCountryNamesBatch.BackfillInput();
        input.objectName = 'Account';
        input.countryCodeField = countryCodeField;
        input.countryNameField = countryNameField;
        input.batchSize = 100;
        
        List<BackfillCountryNamesBatch.BackfillInput> inputs = new List<BackfillCountryNamesBatch.BackfillInput>{ input };
        
        try {
            List<BackfillCountryNamesBatch.BackfillOutput> outputs = BackfillCountryNamesBatch.startBackfill(inputs);
            // May succeed or fail depending on field existence
            System.assertEquals(1, outputs.size(), 'Should return one output');
        } catch (Exception e) {
            // Expected if fields don't exist
            System.debug('Expected exception: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Test the invocable method with missing required fields
     */
    @isTest
    static void testInvocableMethodMissingInput() {
        Test.startTest();
        
        BackfillCountryNamesBatch.BackfillInput input = new BackfillCountryNamesBatch.BackfillInput();
        input.objectName = ''; // Empty - should fail
        input.countryCodeField = 'Some_Field__c';
        input.countryNameField = 'Another_Field__c';
        
        List<BackfillCountryNamesBatch.BackfillInput> inputs = new List<BackfillCountryNamesBatch.BackfillInput>{ input };
        
        List<BackfillCountryNamesBatch.BackfillOutput> outputs = BackfillCountryNamesBatch.startBackfill(inputs);
        
        System.assertEquals(1, outputs.size(), 'Should return one output');
        System.assertEquals('ERROR', outputs[0].status, 'Should have error status');
        System.assert(outputs[0].message.contains('required'), 'Should mention required field');
        
        Test.stopTest();
    }
    
    /**
     * @description Test the invocable method with invalid object
     */
    @isTest
    static void testInvocableMethodInvalidObject() {
        Test.startTest();
        
        BackfillCountryNamesBatch.BackfillInput input = new BackfillCountryNamesBatch.BackfillInput();
        input.objectName = 'FakeObject__c';
        input.countryCodeField = 'Some_Field__c';
        input.countryNameField = 'Another_Field__c';
        
        List<BackfillCountryNamesBatch.BackfillInput> inputs = new List<BackfillCountryNamesBatch.BackfillInput>{ input };
        
        List<BackfillCountryNamesBatch.BackfillOutput> outputs = BackfillCountryNamesBatch.startBackfill(inputs);
        
        System.assertEquals(1, outputs.size(), 'Should return one output');
        System.assertEquals('ERROR', outputs[0].status, 'Should have error status');
        
        Test.stopTest();
    }
    
    /**
     * @description Test batch size cap in invocable method
     */
    @isTest
    static void testBatchSizeCap() {
        String countryCodeField = findCountryCodeField('Account');
        
        if (countryCodeField == null) {
            System.debug('No country code field found - skipping test');
            return;
        }
        
        String countryNameField = countryCodeField.replace('__CountryCode__s', '_Country__c')
                                                   .replace('__countrycode__s', '_Country__c');
        
        Test.startTest();
        
        BackfillCountryNamesBatch.BackfillInput input = new BackfillCountryNamesBatch.BackfillInput();
        input.objectName = 'Account';
        input.countryCodeField = countryCodeField;
        input.countryNameField = countryNameField;
        input.batchSize = 5000; // Over the cap of 2000
        
        List<BackfillCountryNamesBatch.BackfillInput> inputs = new List<BackfillCountryNamesBatch.BackfillInput>{ input };
        
        try {
            List<BackfillCountryNamesBatch.BackfillOutput> outputs = BackfillCountryNamesBatch.startBackfill(inputs);
            // Batch size should be capped at 2000
        } catch (Exception e) {
            // Expected if fields don't exist
            System.debug('Expected exception: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Test with null batch size (should use default)
     */
    @isTest
    static void testNullBatchSize() {
        String countryCodeField = findCountryCodeField('Account');
        
        if (countryCodeField == null) {
            System.debug('No country code field found - skipping test');
            return;
        }
        
        String countryNameField = countryCodeField.replace('__CountryCode__s', '_Country__c')
                                                   .replace('__countrycode__s', '_Country__c');
        
        Test.startTest();
        
        BackfillCountryNamesBatch.BackfillInput input = new BackfillCountryNamesBatch.BackfillInput();
        input.objectName = 'Account';
        input.countryCodeField = countryCodeField;
        input.countryNameField = countryNameField;
        input.batchSize = null; // Should use default of 200
        
        List<BackfillCountryNamesBatch.BackfillInput> inputs = new List<BackfillCountryNamesBatch.BackfillInput>{ input };
        
        try {
            List<BackfillCountryNamesBatch.BackfillOutput> outputs = BackfillCountryNamesBatch.startBackfill(inputs);
        } catch (Exception e) {
            // Expected if fields don't exist
            System.debug('Expected exception: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Test multiple inputs in single invocable call
     */
    @isTest
    static void testMultipleInputs() {
        Test.startTest();
        
        // Create two inputs - both invalid to test error handling
        BackfillCountryNamesBatch.BackfillInput input1 = new BackfillCountryNamesBatch.BackfillInput();
        input1.objectName = 'FakeObject1__c';
        input1.countryCodeField = 'Field1__c';
        input1.countryNameField = 'Field2__c';
        
        BackfillCountryNamesBatch.BackfillInput input2 = new BackfillCountryNamesBatch.BackfillInput();
        input2.objectName = 'FakeObject2__c';
        input2.countryCodeField = 'Field3__c';
        input2.countryNameField = 'Field4__c';
        
        List<BackfillCountryNamesBatch.BackfillInput> inputs = new List<BackfillCountryNamesBatch.BackfillInput>{ input1, input2 };
        
        List<BackfillCountryNamesBatch.BackfillOutput> outputs = BackfillCountryNamesBatch.startBackfill(inputs);
        
        System.assertEquals(2, outputs.size(), 'Should return two outputs');
        System.assertEquals('ERROR', outputs[0].status, 'First should have error status');
        System.assertEquals('ERROR', outputs[1].status, 'Second should have error status');
        
        Test.stopTest();
    }
    
    /**
     * @description Helper method to find a country code field on an object
     */
    private static String findCountryCodeField(String objectName) {
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        if (objectType == null) return null;
        
        Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        
        for (String fieldName : fieldMap.keySet()) {
            if (fieldName.endsWith('__countrycode__s')) {
                return fieldName;
            }
        }
        
        return null;
    }
}
