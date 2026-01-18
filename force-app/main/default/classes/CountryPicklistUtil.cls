/**
 * @description Utility class for accessing Country Name from State/Country Picklists.
 *              Uses Salesforce's built-in State/Country Picklist feature via Schema API.
 *              No custom metadata required - works with any org that has State/Country Picklists enabled.
 *              
 *              Prerequisites:
 *              - State and Country/Territory Picklists must be enabled in Salesforce Setup
 *              - Custom Address field must exist on the object
 * 
 * @author Generated via Cline
 * @date 2026-01-17
 */
public with sharing class CountryPicklistUtil {
    
    // Default SObject and field for country code lookup
    // Uses Account's custom address field - change this for your org
    private static final String DEFAULT_SOBJECT = 'Account';
    private static final String DEFAULT_COUNTRY_CODE_FIELD = 'mm_us_address__countrycode__s';
    
    // Static cache for country code to name mapping
    private static Map<String, String> countryCodeToNameMap;
    
    /**
     * @description Gets the cached map of country codes to country names
     *              Uses the State/Country Picklist values from the configured address field
     * @return Map<String, String> - Map of country code (e.g., 'US') to name (e.g., 'United States')
     */
    public static Map<String, String> getCountryCodeToNameMap() {
        if (countryCodeToNameMap == null) {
            countryCodeToNameMap = buildCountryMapFromPicklist(DEFAULT_SOBJECT, DEFAULT_COUNTRY_CODE_FIELD);
        }
        return countryCodeToNameMap;
    }
    
    /**
     * @description Gets a map of country codes to names from a specific field
     * @param sObjectName The API name of the SObject (e.g., 'Account', 'Contact')
     * @param countryCodeFieldName The API name of the CountryCode field (e.g., 'mm_us_address__countrycode__s')
     * @return Map<String, String> - Map of country code to name
     */
    public static Map<String, String> getCountryCodeToNameMap(String sObjectName, String countryCodeFieldName) {
        return buildCountryMapFromPicklist(sObjectName, countryCodeFieldName);
    }
    
    /**
     * @description Builds a map of country codes to names from picklist values
     * @param sObjectName The API name of the SObject
     * @param countryCodeFieldName The API name of the CountryCode field
     * @return Map<String, String> - Map of country code to name
     */
    private static Map<String, String> buildCountryMapFromPicklist(String sObjectName, String countryCodeFieldName) {
        Map<String, String> codeToNameMap = new Map<String, String>();
        
        try {
            // Get the SObject type
            Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(sObjectName);
            if (sObjType == null) {
                System.debug(LoggingLevel.WARN, 'SObject not found: ' + sObjectName);
                return codeToNameMap;
            }
            
            // Get the field
            Schema.SObjectField field = sObjType.getDescribe().fields.getMap().get(countryCodeFieldName.toLowerCase());
            if (field == null) {
                System.debug(LoggingLevel.WARN, 'Field not found: ' + countryCodeFieldName + ' on ' + sObjectName);
                return codeToNameMap;
            }
            
            // Get picklist values
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if (fieldDescribe.getType() != Schema.DisplayType.PICKLIST) {
                System.debug(LoggingLevel.WARN, 'Field is not a picklist: ' + countryCodeFieldName);
                return codeToNameMap;
            }
            
            // Build the map from picklist entries
            for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                if (entry.isActive()) {
                    codeToNameMap.put(entry.getValue().toUpperCase(), entry.getLabel());
                }
            }
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error building country map: ' + e.getMessage());
        }
        
        return codeToNameMap;
    }
    
    /**
     * @description Gets the country name for a given country code
     * @param countryCode The ISO country code (e.g., 'US', 'CA', 'GB')
     * @return String - The full country name, or null if not found
     */
    public static String getCountryName(String countryCode) {
        if (String.isBlank(countryCode)) {
            return null;
        }
        return getCountryCodeToNameMap().get(countryCode.toUpperCase());
    }
    
    /**
     * @description Gets the country name for a given country code using a specific object/field
     * @param countryCode The ISO country code
     * @param sObjectName The API name of the SObject
     * @param countryCodeFieldName The API name of the CountryCode field
     * @return String - The full country name, or null if not found
     */
    public static String getCountryName(String countryCode, String sObjectName, String countryCodeFieldName) {
        if (String.isBlank(countryCode)) {
            return null;
        }
        Map<String, String> codeMap = getCountryCodeToNameMap(sObjectName, countryCodeFieldName);
        return codeMap.get(countryCode.toUpperCase());
    }
    
    /**
     * @description Gets country names for a set of country codes
     *              Useful for bulk operations to avoid multiple calls
     * @param countryCodes Set of country codes to look up
     * @return Map<String, String> - Map of country code to country name
     */
    public static Map<String, String> getCountryNames(Set<String> countryCodes) {
        Map<String, String> results = new Map<String, String>();
        if (countryCodes == null || countryCodes.isEmpty()) {
            return results;
        }
        
        Map<String, String> allCountries = getCountryCodeToNameMap();
        for (String code : countryCodes) {
            if (String.isNotBlank(code)) {
                String upperCode = code.toUpperCase();
                if (allCountries.containsKey(upperCode)) {
                    results.put(code, allCountries.get(upperCode));
                }
            }
        }
        return results;
    }
    
    /**
     * @description Checks if a country code exists in the picklist
     * @param countryCode The ISO country code to check
     * @return Boolean - True if the country code exists, false otherwise
     */
    public static Boolean isValidCountryCode(String countryCode) {
        if (String.isBlank(countryCode)) {
            return false;
        }
        return getCountryCodeToNameMap().containsKey(countryCode.toUpperCase());
    }
    
    /**
     * @description Gets all available country codes
     * @return Set<String> - Set of all country codes
     */
    public static Set<String> getAllCountryCodes() {
        return getCountryCodeToNameMap().keySet();
    }
    
    /**
     * @description Gets the total number of countries available
     * @return Integer - Number of countries
     */
    public static Integer getCountryCount() {
        return getCountryCodeToNameMap().size();
    }
    
    /**
     * @description Clears the cached values - useful for testing or if picklist values change
     */
    @TestVisible
    private static void clearCache() {
        countryCodeToNameMap = null;
    }
}
