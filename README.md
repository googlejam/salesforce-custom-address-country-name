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

### 1. Enable State and Country/Territory Picklists

State and Country/Territory Picklists must be enabled in your org:

1. Go to **Setup** → **Data Management** → **State and Country/Territory Picklists**
2. Click **Enable State and Country/Territory Picklists**
3. Follow the wizard to enable (this may take a few minutes)
4. After enabling, edit the picklist values to ensure desired countries are active

> ⚠️ **Note:** This is a one-way operation and cannot be undone. Review Salesforce documentation before enabling.

### 2. Create a Custom Address Field

If you don't already have a custom Address field:

1. Go to **Setup** → **Object Manager** → Select your object (e.g., Account)
2. Click **Fields & Relationships** → **New**
3. Select **Address** as the field type
4. Complete the wizard to create the field

When State/Country Picklists are enabled, your custom address field will automatically have:
- `YourAddress__CountryCode__s` - The ISO country code (e.g., "US")
- `YourAddress__StateCode__s` - The ISO state/province code
- And other address components (Street, City, PostalCode)

### 3. Create a Text Field for Country Name

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
   - `force-app/main/default/classes/CountryPicklistUtilTest.cls`
   - `force-app/main/default/classes/CountryPicklistUtilTest.cls-meta.xml`

## Configuration

### Update the Default Field Reference

By default, the utility is configured for Account with `mm_us_address__countrycode__s`. Update this in `CountryPicklistUtil.cls`:

```apex
// Default SObject and field for country code lookup
// Change these for your org
private static final String DEFAULT_SOBJECT = 'Account';
private static final String DEFAULT_COUNTRY_CODE_FIELD = 'your_address_field__countrycode__s';
```

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
| `CountryPicklistUtilTest.cls` | Test class (21 tests, 100% coverage) |

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
