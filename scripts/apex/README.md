# Backfill Scripts for Country Names

These scripts help populate full country names for existing Account records after deploying the Country Name Lookup solution.

## Prerequisites

Before running these scripts, ensure:
1. ✅ `CountryPicklistUtil` class is deployed to your org
2. ✅ `PopulateCountryNameAction` class is deployed
3. ✅ Custom fields exist on Account:
   - `mm_US_Address__CountryCode__s` (from custom Address field)
   - `mm_US_Address_Country__c` (Text field for full name)
   - `mm_Foreign_Address__CountryCode__s` (from custom Address field)
   - `mm_Foreign_Address_Country__c` (Text field for full name)

## Scripts

### 1. diagnostic-country-names.apex

**Purpose:** Check how many records need updating before you start.

**How to run:**
1. Open Salesforce Developer Console
2. Go to **Debug** → **Open Execute Anonymous Window**
3. Copy/paste the contents of `diagnostic-country-names.apex`
4. Click **Execute**
5. Open the log and click **Debug Only** to see results

**Sample Output:**
```
=== US ADDRESS ===
Total with CountryCode: 2403
With Country Name:      0
NEEDING update:         2403

=== SUMMARY ===
Total Accounts needing update: 2403
Estimated batches needed (200 per batch): 13
```

### 2. backfill-country-names.apex

**Purpose:** Update records in batches of 200.

**How to run:**
1. Open Salesforce Developer Console
2. Go to **Debug** → **Open Execute Anonymous Window**
3. Copy/paste the contents of `backfill-country-names.apex`
4. Click **Execute**
5. **Repeat** until you see `Remaining accounts: 0`

**Sample Output:**
```
*** BATCH UPDATE START ***
Found 200 accounts to process
Updated Account 001xxx: US => United States
Updated Account 001xxx: CA => Canada
...
Updated 200 US addresses and 0 Foreign addresses
*** Remaining accounts: 216 ***
Run this script again to process the next batch
```

## Production Deployment Steps

1. **Deploy Apex Classes:**
   ```bash
   sf project deploy start -d force-app/main/default/classes -o ProductionOrg
   ```

2. **Create Custom Fields** (if not already created):
   - `mm_US_Address_Country__c` (Text, 255)
   - `mm_Foreign_Address_Country__c` (Text, 255)

3. **Run Diagnostic:**
   - Execute `diagnostic-country-names.apex`
   - Note how many records need updating

4. **Run Backfill:**
   - Execute `backfill-country-names.apex` repeatedly
   - Each run processes 200 records
   - Continue until "Remaining accounts: 0"

5. **Activate Flow:**
   - Ensure your Record-Triggered Flow is active
   - New/updated records will automatically get country names

## Notes

- **Batch Size:** The scripts process 200 records at a time to stay within Salesforce governor limits
- **Account Name Field:** These scripts intentionally don't query the Account Name field (which may be read-only in your org)
- **Error Handling:** If you encounter errors, check that the field API names match your org's configuration

## Customizing for Other Fields

To adapt these scripts for different field names, update the following in both scripts:
- `mm_US_Address__CountryCode__s` → Your country code field
- `mm_US_Address_Country__c` → Your country name field
- `mm_Foreign_Address__CountryCode__s` → Your foreign address country code field
- `mm_Foreign_Address_Country__c` → Your foreign address country name field

Also update the `CountryPicklistUtil.getCountryName()` call to reference the correct field.
