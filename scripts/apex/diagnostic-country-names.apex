/**
 * Diagnostic Script - Country Names
 * 
 * Use this script to check how many records need country name backfill
 * Run in Developer Console: Debug > Open Execute Anonymous Window
 * 
 * IMPORTANT: Update the variables below with YOUR object and field names
 * 
 * @author Glenn Goodman
 */

// ============================================================================
// CONFIGURATION - Update these values for your org
// ============================================================================

// The API name of your object
String objectName = 'Account';

// The API name of the country code field from your custom Address field
String countryCodeField = 'mm_US_Address__CountryCode__s';

// The API name of the text field where you want the full country name stored
String countryNameField = 'mm_US_Address_Country__c';

// ============================================================================
// DO NOT MODIFY BELOW THIS LINE
// ============================================================================

System.debug('*** COUNTRY NAME DIAGNOSTIC REPORT ***');
System.debug('');
System.debug('Object: ' + objectName);
System.debug('Country Code Field: ' + countryCodeField);
System.debug('Country Name Field: ' + countryNameField);
System.debug('');

try {
    // Validate object exists
    Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
    if (objectType == null) {
        System.debug('ERROR: Object "' + objectName + '" does not exist.');
        return;
    }
    
    Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
    
    // Validate fields exist
    if (!fieldMap.containsKey(countryCodeField.toLowerCase())) {
        System.debug('ERROR: Field "' + countryCodeField + '" does not exist on ' + objectName);
        return;
    }
    
    if (!fieldMap.containsKey(countryNameField.toLowerCase())) {
        System.debug('ERROR: Field "' + countryNameField + '" does not exist on ' + objectName);
        return;
    }
    
    // Build and run queries
    String totalWithCodeQuery = 'SELECT COUNT() FROM ' + objectName + 
                                 ' WHERE ' + countryCodeField + ' != null';
    Integer totalWithCode = Database.countQuery(totalWithCodeQuery);
    
    String hasNameQuery = 'SELECT COUNT() FROM ' + objectName + 
                          ' WHERE ' + countryNameField + ' != null';
    Integer hasName = Database.countQuery(hasNameQuery);
    
    String needsUpdateQuery = 'SELECT COUNT() FROM ' + objectName + 
                              ' WHERE ' + countryCodeField + ' != null' +
                              ' AND ' + countryNameField + ' = null';
    Integer needsUpdate = Database.countQuery(needsUpdateQuery);
    
    System.debug('=== STATISTICS ===');
    System.debug('Total with Country Code: ' + totalWithCode);
    System.debug('With Country Name:       ' + hasName);
    System.debug('NEEDING update:          ' + needsUpdate);
    System.debug('');
    
    System.debug('=== SUMMARY ===');
    if (needsUpdate > 0) {
        Integer batchesNeeded = (Integer) Math.ceil(needsUpdate / 200.0);
        System.debug('Records to update: ' + needsUpdate);
        System.debug('Estimated batch executions (at 200/batch): ' + batchesNeeded);
        System.debug('');
        System.debug('To backfill, run the backfill-country-names.apex script');
        System.debug('Or use: Database.executeBatch(new BackfillCountryNamesBatch(\'' + 
                     objectName + '\', \'' + countryCodeField + '\', \'' + countryNameField + '\'), 200);');
    } else {
        System.debug('All records are up to date! No backfill needed.');
    }
    
    System.debug('');
    System.debug('*** END DIAGNOSTIC ***');
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
