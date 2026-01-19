/**
 * Diagnostic Script - Country Names
 * 
 * Use this script to check how many Account records need country name backfill
 * Run in Developer Console: Debug > Open Execute Anonymous Window
 */

System.debug('*** COUNTRY NAME DIAGNOSTIC REPORT ***');
System.debug('');

// US Address Statistics
Integer totalWithUSCode = [SELECT COUNT() FROM Account WHERE mm_US_Address__CountryCode__s != null];
Integer usHasName = [SELECT COUNT() FROM Account WHERE mm_US_Address_Country__c != null];
Integer usNeedsUpdate = [SELECT COUNT() FROM Account 
    WHERE mm_US_Address__CountryCode__s != null 
    AND mm_US_Address_Country__c = null];

System.debug('=== US ADDRESS ===');
System.debug('Total with CountryCode: ' + totalWithUSCode);
System.debug('With Country Name:      ' + usHasName);
System.debug('NEEDING update:         ' + usNeedsUpdate);
System.debug('');

// Foreign Address Statistics
Integer totalWithForeignCode = [SELECT COUNT() FROM Account WHERE mm_Foreign_Address__CountryCode__s != null];
Integer foreignHasName = [SELECT COUNT() FROM Account WHERE mm_Foreign_Address_Country__c != null];
Integer foreignNeedsUpdate = [SELECT COUNT() FROM Account 
    WHERE mm_Foreign_Address__CountryCode__s != null 
    AND mm_Foreign_Address_Country__c = null];

System.debug('=== FOREIGN ADDRESS ===');
System.debug('Total with CountryCode: ' + totalWithForeignCode);
System.debug('With Country Name:      ' + foreignHasName);
System.debug('NEEDING update:         ' + foreignNeedsUpdate);
System.debug('');

// Total needing update
Integer totalNeedsUpdate = [SELECT COUNT() FROM Account 
    WHERE (mm_US_Address__CountryCode__s != null AND mm_US_Address_Country__c = null)
       OR (mm_Foreign_Address__CountryCode__s != null AND mm_Foreign_Address_Country__c = null)];

System.debug('=== SUMMARY ===');
System.debug('Total Accounts needing update: ' + totalNeedsUpdate);
if (totalNeedsUpdate > 0) {
    Integer batchesNeeded = (Integer) Math.ceil(totalNeedsUpdate / 200.0);
    System.debug('Estimated batches needed (200 per batch): ' + batchesNeeded);
}
System.debug('');
System.debug('*** END DIAGNOSTIC ***');
