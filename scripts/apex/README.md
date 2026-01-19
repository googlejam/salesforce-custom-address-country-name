# Backfill Scripts for Country Names

These scripts help populate full country names for existing records after deploying the Country Name Lookup solution.

## Prerequisites

Before running these scripts, ensure:
1. ✅ `CountryPicklistUtil` class is deployed to your org
2. ✅ `PopulateCountryNameAction` class is deployed
3. ✅ `BackfillCountryNamesBatch` class is deployed
4. ✅ You know your:
   - **Object API Name** (e.g., `Account`, `Contact`, `My_Custom_Object__c`)
   - **Country Code Field** (e.g., `My_Address__CountryCode__s`)
   - **Country Name Field** (e.g., `My_Address_Country__c`)

## Scripts

### 1. diagnostic-country-names.apex

**Purpose:** Check how many records need updating before you start.

**How to run:**
1. Open the file and **update the CONFIGURATION section** with your object/field names:
   ```apex
   String objectName = 'Account';                              // Your object
   String countryCodeField = 'My_Address__CountryCode__s';    // Your country code field
   String countryNameField = 'My_Address_Country__c';          // Your target text field
   ```
2. Open Salesforce Developer Console
3. Go to **Debug** → **Open Execute Anonymous Window**
4. Copy/paste the updated script
5. Click **Execute**
6. Open the log and click **Debug Only** to see results

**Sample Output:**
```
=== STATISTICS ===
Total with Country Code: 2403
With Country Name:       0
NEEDING update:          2403

=== SUMMARY ===
Records to update: 2403
Estimated batch executions (at 200/batch): 13
```

### 2. backfill-country-names.apex

**Purpose:** Start a batch job to update all records.

**How to run:**
1. Open the file and **update the CONFIGURATION section**:
   ```apex
   String objectName = 'Account';                              // Your object
   String countryCodeField = 'My_Address__CountryCode__s';    // Your country code field
   String countryNameField = 'My_Address_Country__c';          // Your target text field
   Integer batchSize = 200;                                    // Records per batch (max 2000)
   ```
2. Open Salesforce Developer Console
3. Go to **Debug** → **Open Execute Anonymous Window**
4. Copy/paste the updated script
5. Click **Execute**
6. Monitor progress in **Setup** → **Apex Jobs**

**Sample Output:**
```
====================================
Starting Backfill Country Names
====================================
Object: Account
Country Code Field: My_Address__CountryCode__s
Country Name Field: My_Address_Country__c
Batch Size: 200
------------------------------------
SUCCESS! Batch job started.
Job ID: 707xx000000xxxx
------------------------------------
Monitor progress in Setup > Apex Jobs
====================================
```

## Alternative: Run Directly in Developer Console

Instead of using the script files, you can run the batch directly:

```apex
// Single address field
Database.executeBatch(new BackfillCountryNamesBatch(
    'Account',                        // Your object
    'My_Address__CountryCode__s',    // Your country code field
    'My_Address_Country__c'           // Your target text field
), 200);
```

### Multiple Address Fields

Run separate batch jobs for each address field you need to backfill:

```apex
// First address field
Database.executeBatch(new BackfillCountryNamesBatch(
    'Account', 
    'US_Address__CountryCode__s', 
    'US_Address_Country__c'
), 200);

// Second address field
Database.executeBatch(new BackfillCountryNamesBatch(
    'Account', 
    'Foreign_Address__CountryCode__s', 
    'Foreign_Address_Country__c'
), 200);
```

## Monitoring Progress

After starting a batch job:

1. Go to **Setup** → **Apex Jobs**
2. Find your job by the `BackfillCountryNamesBatch` class name
3. Watch the **Batches Processed** column
4. Check debug logs for detailed output

## Production Deployment Steps

1. **Deploy Apex Classes** to production:
   ```bash
   sf project deploy start -d force-app/main/default/classes -o ProductionOrg
   ```

2. **Create Custom Fields** (if not already created):
   - `Your_Address_Country__c` (Text, 255) on your object

3. **Run Diagnostic:**
   - Update and execute `diagnostic-country-names.apex`
   - Note how many records need updating

4. **Run Backfill:**
   - Update and execute `backfill-country-names.apex`
   - Monitor in Setup > Apex Jobs until complete

5. **Activate Flow:**
   - Ensure your Record-Triggered Flow is active
   - New/updated records will automatically get country names

## Notes

- **Any Object:** These scripts work with ANY standard or custom object
- **Any Field:** Just provide the correct API names for your fields
- **Batch Size:** Default is 200, max is 2000
- **Multiple Runs:** For large datasets, the batch handles everything automatically
- **Error Handling:** Failed records are logged but don't stop the batch

## Troubleshooting

### "Object does not exist" Error
- Check the spelling of your object API name
- For custom objects, include the `__c` suffix

### "Field does not exist" Error
- Verify the field API name is correct
- Country code fields from Address fields end with `__CountryCode__s`
- Make sure you've created the target text field for country names

### Batch not processing records
- Check that records actually need updating (country name field is null)
- Verify the country code field has valid values
- Check Setup > Apex Jobs for any errors
