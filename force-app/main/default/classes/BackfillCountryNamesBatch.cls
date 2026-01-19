/**
 * @description Batch Apex class to backfill country names from country codes
 *              on custom Address fields. Works with any object that has
 *              State/Country Picklist enabled custom Address fields.
 * 
 * @example
 * // Run from Developer Console:
 * BackfillCountryNamesBatch batch = new BackfillCountryNamesBatch(
 *     'Account',
 *     'mm_US_Address__CountryCode__s',
 *     'mm_US_Address_Country__c'
 * );
 * Database.executeBatch(batch, 200);
 * 
 * // Or use the static invocable method from Flow:
 * BackfillCountryNamesBatch.startBackfill(inputList);
 * 
 * @author Procetra (procetra.com)
 */
public class BackfillCountryNamesBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    private String objectName;
    private String countryCodeField;
    private String countryNameField;
    private Integer totalProcessed = 0;
    private Integer totalUpdated = 0;
    private Integer totalErrors = 0;
    private List<String> errorMessages = new List<String>();
    
    /**
     * @description Constructor for the batch class
     * @param objectName The API name of the SObject (e.g., 'Account', 'Contact')
     * @param countryCodeField The API name of the country code field (e.g., 'My_Address__CountryCode__s')
     * @param countryNameField The API name of the text field to populate with full country name
     */
    public BackfillCountryNamesBatch(String objectName, String countryCodeField, String countryNameField) {
        this.objectName = objectName;
        this.countryCodeField = countryCodeField;
        this.countryNameField = countryNameField;
        
        // Validate inputs
        validateInputs();
    }
    
    /**
     * @description Validates that the provided field names exist on the object
     */
    private void validateInputs() {
        // Check object exists
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        if (objectType == null) {
            throw new BackfillException('Object "' + objectName + '" does not exist.');
        }
        
        Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        
        // Check country code field exists
        if (!fieldMap.containsKey(countryCodeField.toLowerCase())) {
            throw new BackfillException('Field "' + countryCodeField + '" does not exist on ' + objectName);
        }
        
        // Check country name field exists
        if (!fieldMap.containsKey(countryNameField.toLowerCase())) {
            throw new BackfillException('Field "' + countryNameField + '" does not exist on ' + objectName);
        }
    }
    
    /**
     * @description Start method - builds the query for records needing update
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, ' + countryCodeField + ', ' + countryNameField + 
                       ' FROM ' + objectName + 
                       ' WHERE ' + countryCodeField + ' != null' +
                       ' AND ' + countryNameField + ' = null';
        
        System.debug('BackfillCountryNamesBatch Query: ' + query);
        return Database.getQueryLocator(query);
    }
    
    /**
     * @description Execute method - processes each batch of records
     */
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<SObject> recordsToUpdate = new List<SObject>();
        
        for (SObject record : scope) {
            totalProcessed++;
            
            String countryCode = (String) record.get(countryCodeField);
            
            if (String.isNotBlank(countryCode)) {
                // Get the full country name using the utility
                String countryName = CountryPicklistUtil.getCountryName(
                    countryCode, 
                    objectName, 
                    countryCodeField
                );
                
                if (String.isNotBlank(countryName)) {
                    record.put(countryNameField, countryName);
                    recordsToUpdate.add(record);
                }
            }
        }
        
        // Update records
        if (!recordsToUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(recordsToUpdate, false);
            
            for (Integer i = 0; i < results.size(); i++) {
                if (results[i].isSuccess()) {
                    totalUpdated++;
                } else {
                    totalErrors++;
                    for (Database.Error err : results[i].getErrors()) {
                        String errorMsg = 'Error on record ' + recordsToUpdate[i].Id + ': ' + err.getMessage();
                        errorMessages.add(errorMsg);
                        System.debug(LoggingLevel.ERROR, errorMsg);
                    }
                }
            }
        }
    }
    
    /**
     * @description Finish method - logs summary of the batch job
     */
    public void finish(Database.BatchableContext bc) {
        System.debug('====================================');
        System.debug('BackfillCountryNamesBatch COMPLETE');
        System.debug('====================================');
        System.debug('Object: ' + objectName);
        System.debug('Source Field: ' + countryCodeField);
        System.debug('Target Field: ' + countryNameField);
        System.debug('------------------------------------');
        System.debug('Total Processed: ' + totalProcessed);
        System.debug('Total Updated:   ' + totalUpdated);
        System.debug('Total Errors:    ' + totalErrors);
        System.debug('====================================');
        
        if (!errorMessages.isEmpty()) {
            System.debug('ERRORS:');
            for (String error : errorMessages) {
                System.debug('  - ' + error);
            }
        }
    }
    
    // =========================================================================
    // INVOCABLE METHOD - For calling from Flow
    // =========================================================================
    
    /**
     * @description Input class for the invocable method
     */
    public class BackfillInput {
        @InvocableVariable(label='Object API Name' description='e.g., Account, Contact' required=true)
        public String objectName;
        
        @InvocableVariable(label='Country Code Field' description='e.g., My_Address__CountryCode__s' required=true)
        public String countryCodeField;
        
        @InvocableVariable(label='Country Name Field' description='e.g., My_Address_Country__c' required=true)
        public String countryNameField;
        
        @InvocableVariable(label='Batch Size' description='Records per batch (default 200)')
        public Integer batchSize;
    }
    
    /**
     * @description Output class for the invocable method
     */
    public class BackfillOutput {
        @InvocableVariable(label='Job ID')
        public String jobId;
        
        @InvocableVariable(label='Status')
        public String status;
        
        @InvocableVariable(label='Message')
        public String message;
    }
    
    /**
     * @description Invocable method to start the backfill batch from Flow
     * @param inputs List of BackfillInput containing the configuration
     * @return List of BackfillOutput with job ID and status
     */
    @InvocableMethod(
        label='Backfill Country Names' 
        description='Starts a batch job to populate country names from country codes on custom Address fields'
        category='Country Name Lookup'
    )
    public static List<BackfillOutput> startBackfill(List<BackfillInput> inputs) {
        List<BackfillOutput> outputs = new List<BackfillOutput>();
        
        for (BackfillInput input : inputs) {
            BackfillOutput output = new BackfillOutput();
            
            try {
                // Validate required fields
                if (String.isBlank(input.objectName)) {
                    throw new BackfillException('Object Name is required');
                }
                if (String.isBlank(input.countryCodeField)) {
                    throw new BackfillException('Country Code Field is required');
                }
                if (String.isBlank(input.countryNameField)) {
                    throw new BackfillException('Country Name Field is required');
                }
                
                // Set default batch size
                Integer batchSize = (input.batchSize != null && input.batchSize > 0) ? input.batchSize : 200;
                batchSize = Math.min(batchSize, 2000); // Cap at 2000
                
                // Create and execute the batch
                BackfillCountryNamesBatch batch = new BackfillCountryNamesBatch(
                    input.objectName,
                    input.countryCodeField,
                    input.countryNameField
                );
                
                Id jobId = Database.executeBatch(batch, batchSize);
                
                output.jobId = jobId;
                output.status = 'SUCCESS';
                output.message = 'Batch job started successfully. Job ID: ' + jobId;
                
            } catch (Exception e) {
                output.status = 'ERROR';
                output.message = e.getMessage();
                System.debug(LoggingLevel.ERROR, 'BackfillCountryNamesBatch Error: ' + e.getMessage());
            }
            
            outputs.add(output);
        }
        
        return outputs;
    }
    
    /**
     * @description Custom exception class for backfill errors
     */
    public class BackfillException extends Exception {}
}
