# Salesforce Custom Address Country Name Lookup

Automatically populate full country names from country codes on **custom address fields** in Salesforce.

## The Problem

When using Salesforce's **custom Address fields** (not standard BillingAddress/ShippingAddress), the country code is stored but the full country name is not automatically available. For example:

- Standard Address: `BillingCountryCode = "US"` → `BillingCountry = "United States"` ✅
- Custom Address: `My_Address__CountryCode__s = "US"` → **No automatic full name** ❌

This solution provides an invocable Apex action that can be called from a Flow to automatically populate the full country name when a custom address is updated.

## Features

- ✅ **No custom metadata required** - Uses Salesforce's built-in State/Country Picklist values
- ✅ **Works with any custom Address field** on any object
- ✅ **Invocable from Flow** - Easy to configure, no code changes needed
- ✅ **Cached for performance** - Country lookups are cached in memory
- ✅ **100% test coverage** - Production ready

## Prerequisites

### 1. Enable Custom Address Fields (User Interface Setting)

Before you can create custom Address fields on your objects, you must enable this feature:

1. Go to **Setup** → **User Interface** (search "User Interface" in Quick Find)
2. Scroll down to find **Enable Custom Address Fields**
3. Check the box and click **Save**

> 💡 **Tip:** This setting is often overlooked! Without it, you won't see "Address" as an available field type when creating new custom fields.

### 2. Enable State and Country/Territory Picklists

State and Country/Territory Picklists must be enabled in your org:

1. Go to **Setup** → **Data Management** → **State and Country/Territory Picklists**
2. Click **Enable State and Country/Territory Picklists**
3. Follow the wizard to enable (this may take a few minutes)
4. After enabling, edit the picklist values to ensure desired countries are active

> ⚠️ **Note:** This is a one-way operation and cannot be undone. Review Salesforce documentation before enabling.

### 3. Create a Custom Address Field

If you don't already have a custom Address field:

1. Go to **Setup** → **Object Manager** → Select your object (e.g., Account)
2. Click **Fields & Relationships** → **New**
3. Select **Address** as the field type
4. Complete the wizard to create the field

When State/Country Picklists are enabled, your custom address field will automatically have:
- `YourAddress__CountryCode__s` - The ISO country code (e.g., "US")
- `YourAddress__StateCode__s` - The ISO state/province code
- And other address components (Street, City, PostalCode)

### 4. Create a Text Field for Country Name

Create a text field to store the full country name:

1. On the same object, create a new **Text** field (recommended length: 255)
2. Name it appropriately (e.g., `My_Address_Country__c`)

## Installation

### Deploy Using Salesforce CLI

```bash
# Clone the repository
git clone https://github.com/googlejam/salesforce-custom-address-country-name.git
cd salesforce-custom-address-country-name

# Authenticate to your org
sf org login web -a MyOrg

# Deploy the Apex classes
sf project deploy start -d force-app/main/default/classes -o MyOrg

# Verify tests pass
sf apex run test -n CountryPicklistUtilTest -o MyOrg -r human
```

### Manual Installation

1. Copy the contents of these files to your org:
   - `force-app/main/default/classes/CountryPicklistUtil.cls`
   - `force-app/main/default/classes/CountryPicklistUtil.cls-meta.xml`
   - `force-app/main/default/classes/PopulateCountryNameAction.cls`
   - `force-app/main/default/classes/PopulateCountryNameAction.cls-meta.xml`
   - `force-app/main/default/classes/BackfillCountryNamesBatch.cls`
   - `force-app/main/default/classes/BackfillCountryNamesBatch.cls-meta.xml`
   - `force-app/main/default/classes/CountryPicklistUtilTest.cls`
   - `force-app/main/default/classes/CountryPicklistUtilTest.cls-meta.xml`
   - `force-app/main/default/classes/BackfillCountryNamesBatchTest.cls`
   - `force-app/main/default/classes/BackfillCountryNamesBatchTest.cls-meta.xml`

## Configuration

### Important: No Code Changes Required for Most Users! 

**Good news:** Since Salesforce's State/Country Picklists are **org-wide** (the same country codes and names exist on all objects), the Flow action and utility work with **any object** and **any custom Address field** without modifying the Apex code.

The default object/field settings in the code are only used for:
1. Reading the picklist values (which are identical across all Address fields)
2. Test class validation

**You only need to update the defaults if:**
- Your org doesn't have the default object/field (causes test failures)
- You want the code to reflect your specific implementation

### Optional: Update the Default Field Reference

If needed, update the defaults in `CountryPicklistUtil.cls`:

```apex
// Default SObject and field for country code lookup
// These are only used for initial picklist loading and tests
// The actual lookup works with ANY object's country code field
private static final String DEFAULT_SOBJECT = 'Account';
private static final String DEFAULT_COUNTRY_CODE_FIELD = 'your_address_field__countrycode__s';
```

### Summary: What's Configurable Where

| Component | Configuration | Where to Configure |
|-----------|---------------|-------------------|
| **Flow Action** | Any object, any country code | In Flow Builder - pass the country code from any field |
| **Backfill Batch** | Fully parameterized | Pass object, source field, target field as parameters |
| **Utility Class** | Defaults only | Edit `CountryPicklistUtil.cls` (optional) |

## Creating the Flow

### Record-Triggered Flow for Account (Example)

1. **Go to Setup** → **Flows** → **New Flow**
2. Select **Record-Triggered Flow**
3. Configure the trigger:
   - **Object:** Account
   - **Trigger:** A record is created or updated
   - **Entry Conditions:** 
     - `YourAddress__CountryCode__s` Is Changed = True
     - AND `YourAddress__CountryCode__s` Is Null = False
   - **Optimize for:** Actions and Related Records
   - **When to Run:** After the record is saved

4. **Add an Action Element:**
   - Search for "Get Country Name from Code" (the Apex Action)
   - Set Input: `countryCode` = `{!$Record.YourAddress__CountryCode__s}`
   - Store the output in a variable or directly assign to field

5. **Add an Update Records Element:**
   - Records to Update: Use the record that triggered the flow
   - Set Field Values: `Your_Address_Country__c` = `{!outputFromAction.countryName}`

6. **Activate the Flow**

### Alternative: Direct Output Assignment

You can also assign the Apex action output directly to the record field:
- Output Parameter: `countryName` → `$Record.Your_Address_Country__c`

## Usage in Apex

The utility can also be called directly from Apex:

```apex
// Get a single country name
String countryName = CountryPicklistUtil.getCountryName('US');
// Returns: "United States"

// Get multiple country names
Set<String> codes = new Set<String>{'US', 'CA', 'GB'};
Map<String, String> names = CountryPicklistUtil.getCountryNames(codes);
// Returns: {US=United States, CA=Canada, GB=United Kingdom}

// Check if a country code is valid
Boolean isValid = CountryPicklistUtil.isValidCountryCode('XX');
// Returns: false

// Get all available country codes
Set<String> allCodes = CountryPicklistUtil.getAllCountryCodes();

// Use with a different object/field
String name = CountryPicklistUtil.getCountryName('DE', 'Contact', 'other_address__countrycode__s');
```

## Extending to Other Objects

To use with a different object (e.g., Contact, custom object):

1. Create a custom Address field on that object
2. Create a text field for the country name
3. Create a new Record-Triggered Flow on that object
4. Use the same Apex Action - it works with any object!

## Files Included

| File | Description |
|------|-------------|
| `CountryPicklistUtil.cls` | Utility class for country code to name lookup |
| `PopulateCountryNameAction.cls` | Invocable Apex action for Flow |
| `BackfillCountryNamesBatch.cls` | Batch class to backfill existing records |
| `CountryPicklistUtilTest.cls` | Test class for utility (21 tests) |
| `BackfillCountryNamesBatchTest.cls` | Test class for batch (10 tests) |

## Backfilling Existing Records

After deploying the solution, your Flows will handle new/updated records automatically. But what about existing records? Use the included **Batch Apex class** to backfill country names for all existing records.

### Option 1: Run from Developer Console

```apex
// Backfill country names for Account records
BackfillCountryNamesBatch batch = new BackfillCountryNamesBatch(
    'Account',                           // Object API name
    'My_Address__CountryCode__s',    // Source: Country code field
    'My_Address_Country__c'           // Target: Country name text field
);
Database.executeBatch(batch, 200);
```

**Monitor the job:**
- Go to **Setup** → **Apex Jobs** to see progress
- Check debug logs for detailed results

### Option 2: Run from Flow (Admin-Friendly)

The batch class includes an **Invocable Method** that can be called from Flow:

1. Create a **Screen Flow** or **Autolaunched Flow**
2. Add an **Action** element
3. Search for **"Backfill Country Names"**
4. Provide inputs:
   - **Object API Name:** e.g., `Account`
   - **Country Code Field:** e.g., `My_Address__CountryCode__s`
   - **Country Name Field:** e.g., `My_Address_Country__c`
   - **Batch Size:** (optional, default 200)
5. The action returns a Job ID you can use to monitor progress

### Option 3: Schedule the Batch

```apex
// Schedule to run at midnight on the first of each month
String cronExpression = '0 0 0 1 * ?';
System.schedule('Backfill Country Names', cronExpression, 
    new BackfillCountryNamesBatch('Account', 'My_Address__CountryCode__s', 'My_Address_Country__c'));
```

### Backfill Multiple Address Fields

Run separate batch jobs for each address field:

```apex
// US Address
Database.executeBatch(new BackfillCountryNamesBatch(
    'Account', 
    'My_Address__CountryCode__s', 
    'My_Address_Country__c'
), 200);

// Foreign Address  
Database.executeBatch(new BackfillCountryNamesBatch(
    'Account', 
    'Other_Address__CountryCode__s', 
    'Other_Address_Country__c'
), 200);
```

### Batch Class Features

- ✅ **Validates inputs** - Checks object/field existence before running
- ✅ **Detailed logging** - Shows progress and errors in debug log
- ✅ **Error handling** - Continues processing even if individual records fail
- ✅ **Stateful** - Tracks totals across all batches
- ✅ **Flow-compatible** - Invocable method for admin use

## How It Works

1. The utility uses Salesforce's Schema API to access picklist values
2. It reads the country code picklist from your custom address field
3. Picklist entries contain both the code (value) and full name (label)
4. Results are cached for performance
5. No SOQL queries are required!

## Troubleshooting

### "Field not found" Error
- Ensure State/Country Picklists are enabled
- Verify the field API name is correct (including `__countrycode__s` suffix)

### Country name not populating
- Check that the Flow is active
- Verify entry conditions are correct
- Test the Apex action directly in Developer Console

### Tests failing
- Ensure State/Country Picklists are enabled in your org
- Verify there's at least one custom Address field

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Salesforce State and Country/Territory Picklists documentation
- Salesforce Schema API documentation
