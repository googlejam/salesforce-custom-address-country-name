/**
 * Backfill Country Names Script
 * 
 * Use this script to populate full country names for existing records
 * that have custom Address fields with CountryCode values.
 * 
 * Run this script in Developer Console: Debug > Open Execute Anonymous Window
 * 
 * IMPORTANT: 
 * 1. The BackfillCountryNamesBatch and CountryPicklistUtil classes must be deployed first
 * 2. Update the variables below with YOUR object and field names
 * 
 * @author Glenn Goodman
 */

// ============================================================================
// CONFIGURATION - Update these values for your org
// ============================================================================

// The API name of your object (e.g., 'Account', 'Contact', 'My_Custom_Object__c')
String objectName = 'Account';

// The API name of the country code field from your custom Address field
// This is the field that stores the 2-letter ISO code (e.g., 'US', 'CA')
String countryCodeField = 'mm_US_Address__CountryCode__s';

// The API name of the text field where you want the full country name stored
String countryNameField = 'mm_US_Address_Country__c';

// Batch size (number of records to process at a time, max 2000)
Integer batchSize = 200;

// ============================================================================
// DO NOT MODIFY BELOW THIS LINE
// ============================================================================

System.debug('====================================');
System.debug('Starting Backfill Country Names');
System.debug('====================================');
System.debug('Object: ' + objectName);
System.debug('Country Code Field: ' + countryCodeField);
System.debug('Country Name Field: ' + countryNameField);
System.debug('Batch Size: ' + batchSize);
System.debug('------------------------------------');

try {
    // Create the batch job
    BackfillCountryNamesBatch batch = new BackfillCountryNamesBatch(
        objectName,
        countryCodeField,
        countryNameField
    );
    
    // Execute the batch
    Id jobId = Database.executeBatch(batch, batchSize);
    
    System.debug('SUCCESS! Batch job started.');
    System.debug('Job ID: ' + jobId);
    System.debug('------------------------------------');
    System.debug('Monitor progress in Setup > Apex Jobs');
    System.debug('====================================');
    
} catch (BackfillCountryNamesBatch.BackfillException e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Please check your object and field names.');
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
