/**
 * @description Invocable Apex action to populate country name from country code
 *              Can be called from any Flow to look up full country names from
 *              Salesforce's State and Country/Territory Picklists
 * 
 *              This action is designed to be reusable across any object with
 *              custom Address fields, allowing admins to configure new
 *              implementations without code changes.
 * 
 * @author Generated via Cline
 * @date 2026-01-17
 */
public with sharing class PopulateCountryNameAction {
    
    /**
     * @description Main invocable method that processes country code lookups
     *              Accepts a list of requests and returns country names
     * @param requests List of Request objects containing country codes to look up
     * @return List<Result> - Results containing country names
     */
    @InvocableMethod(
        label='Get Country Name from Code' 
        description='Looks up the full country name from a country code using Salesforce State/Country Picklists. Returns the country name for use in Flow assignments.'
        category='Address Utilities'
    )
    public static List<Result> getCountryName(List<Request> requests) {
        List<Result> results = new List<Result>();
        
        if (requests == null || requests.isEmpty()) {
            return results;
        }
        
        // Collect all unique country codes for bulk lookup
        Set<String> countryCodes = new Set<String>();
        for (Request req : requests) {
            if (String.isNotBlank(req.countryCode)) {
                countryCodes.add(req.countryCode);
            }
        }
        
        // Get all country names in one call (uses cached values)
        Map<String, String> countryCodeToName = CountryPicklistUtil.getCountryNames(countryCodes);
        
        // Process each request and build results
        for (Request req : requests) {
            Result res = new Result();
            
            if (String.isBlank(req.countryCode)) {
                res.countryName = null;
                res.success = true;
                res.message = 'Country code was blank or null';
            } else {
                String countryName = countryCodeToName.get(req.countryCode);
                
                if (countryName != null) {
                    res.countryName = countryName;
                    res.success = true;
                    res.message = 'Country name found';
                } else {
                    // Try with uppercase if not found
                    countryName = countryCodeToName.get(req.countryCode.toUpperCase());
                    if (countryName != null) {
                        res.countryName = countryName;
                        res.success = true;
                        res.message = 'Country name found';
                    } else {
                        res.countryName = null;
                        res.success = false;
                        res.message = 'Country code not found: ' + req.countryCode;
                    }
                }
            }
            
            results.add(res);
        }
        
        return results;
    }
    
    /**
     * @description Request class for the invocable action
     *              Contains the country code to look up
     */
    public class Request {
        @InvocableVariable(
            label='Country Code' 
            description='The 2-letter ISO country code (e.g., US, CA, GB, MX)'
            required=true
        )
        public String countryCode;
    }
    
    /**
     * @description Result class for the invocable action
     *              Contains the looked-up country name and status
     */
    public class Result {
        @InvocableVariable(
            label='Country Name' 
            description='The full country name (e.g., United States, Canada, United Kingdom)'
        )
        public String countryName;
        
        @InvocableVariable(
            label='Success' 
            description='Whether the lookup was successful'
        )
        public Boolean success;
        
        @InvocableVariable(
            label='Message' 
            description='Status message providing details about the lookup result'
        )
        public String message;
    }
}
