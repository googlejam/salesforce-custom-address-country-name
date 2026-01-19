/**
 * Backfill Country Names Script
 * 
 * Use this script to populate full country names for existing Account records
 * that have custom Address fields with CountryCode values.
 * 
 * Run this script in Developer Console: Debug > Open Execute Anonymous Window
 * Run multiple times until "Remaining accounts: 0" is shown
 * 
 * IMPORTANT: The CountryPicklistUtil class must be deployed before running this script.
 */

System.debug('*** BATCH UPDATE START ***');

// Get records that need updating - batch of 200
List<Account> accounts = [
    SELECT Id,
           mm_US_Address__CountryCode__s, mm_US_Address_Country__c,
           mm_Foreign_Address__CountryCode__s, mm_Foreign_Address_Country__c
    FROM Account 
    WHERE (mm_US_Address__CountryCode__s != null AND mm_US_Address_Country__c = null)
       OR (mm_Foreign_Address__CountryCode__s != null AND mm_Foreign_Address_Country__c = null)
    LIMIT 200
];

System.debug('Found ' + accounts.size() + ' accounts to process');

// Update the records
Integer usUpdated = 0;
Integer foreignUpdated = 0;

for (Account acc : accounts) {
    // Update US Address country name if blank
    if (acc.mm_US_Address__CountryCode__s != null && acc.mm_US_Address_Country__c == null) {
        acc.mm_US_Address_Country__c = CountryPicklistUtil.getCountryName(acc.mm_US_Address__CountryCode__s);
        if (acc.mm_US_Address_Country__c != null) {
            usUpdated++;
            System.debug('Updated Account ' + acc.Id + ': ' + acc.mm_US_Address__CountryCode__s + ' => ' + acc.mm_US_Address_Country__c);
        }
    }
    
    // Update Foreign Address country name if blank
    if (acc.mm_Foreign_Address__CountryCode__s != null && acc.mm_Foreign_Address_Country__c == null) {
        acc.mm_Foreign_Address_Country__c = CountryPicklistUtil.getCountryName(
            acc.mm_Foreign_Address__CountryCode__s, 
            'Account', 
            'mm_foreign_address__countrycode__s'
        );
        if (acc.mm_Foreign_Address_Country__c != null) {
            foreignUpdated++;
        }
    }
}

// Perform the update
if (!accounts.isEmpty()) {
    update accounts;
}

System.debug('Updated ' + usUpdated + ' US addresses and ' + foreignUpdated + ' Foreign addresses');

// Check remaining
Integer remaining = [
    SELECT COUNT() FROM Account 
    WHERE (mm_US_Address__CountryCode__s != null AND mm_US_Address_Country__c = null)
       OR (mm_Foreign_Address__CountryCode__s != null AND mm_Foreign_Address_Country__c = null)
];

System.debug('*** Remaining accounts: ' + remaining + ' ***');
if (remaining > 0) {
    System.debug('Run this script again to process the next batch');
} else {
    System.debug('ALL DONE! All records have been updated.');
}
