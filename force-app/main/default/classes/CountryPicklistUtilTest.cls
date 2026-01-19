/**
 * @description Test class for CountryPicklistUtil and PopulateCountryNameAction
 *              Tests the Country Mapping custom metadata lookup functionality
 * 
 * @author Glenn Goodman
 * @date 2026-01-17
 */
@IsTest
private class CountryPicklistUtilTest {
    
    /**
     * @description Test getting country code to name map
     */
    @IsTest
    static void testGetCountryCodeToNameMap() {
        Test.startTest();
        Map<String, String> countryMap = CountryPicklistUtil.getCountryCodeToNameMap();
        Test.stopTest();
        
        // Map should not be null and should have entries
        System.assertNotEquals(null, countryMap, 'Country map should not be null');
        System.assert(countryMap.size() > 0, 'Country map should have entries');
        
        // US should be present (we know it was created)
        System.assert(countryMap.containsKey('US'), 'US should be in country map');
    }
    
    /**
     * @description Test getting a single country name
     */
    @IsTest
    static void testGetCountryName() {
        Test.startTest();
        String countryName = CountryPicklistUtil.getCountryName('US');
        Test.stopTest();
        
        System.assertNotEquals(null, countryName, 'US country name should not be null');
        System.assertEquals('United States', countryName, 'US should return United States');
    }
    
    /**
     * @description Test getting country name with lowercase code
     */
    @IsTest
    static void testGetCountryNameLowercase() {
        Test.startTest();
        String countryName = CountryPicklistUtil.getCountryName('us');
        Test.stopTest();
        
        System.assertNotEquals(null, countryName, 'Country name should not be null for lowercase code');
        System.assertEquals('United States', countryName, 'Lowercase us should return United States');
    }
    
    /**
     * @description Test getting country name with null code
     */
    @IsTest
    static void testGetCountryNameNull() {
        Test.startTest();
        String countryName = CountryPicklistUtil.getCountryName(null);
        Test.stopTest();
        
        System.assertEquals(null, countryName, 'Null country code should return null');
    }
    
    /**
     * @description Test getting country name with blank code
     */
    @IsTest
    static void testGetCountryNameBlank() {
        Test.startTest();
        String countryName = CountryPicklistUtil.getCountryName('');
        Test.stopTest();
        
        System.assertEquals(null, countryName, 'Blank country code should return null');
    }
    
    /**
     * @description Test getting country name with invalid code
     */
    @IsTest
    static void testGetCountryNameInvalid() {
        Test.startTest();
        String countryName = CountryPicklistUtil.getCountryName('ZZ');
        Test.stopTest();
        
        System.assertEquals(null, countryName, 'Invalid country code should return null');
    }
    
    /**
     * @description Test getting multiple country names
     */
    @IsTest
    static void testGetCountryNames() {
        Set<String> codes = new Set<String>{'US', 'CA', 'MX', 'GB'};
        
        Test.startTest();
        Map<String, String> results = CountryPicklistUtil.getCountryNames(codes);
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.containsKey('US'), 'Results should contain US');
    }
    
    /**
     * @description Test getting country names with null set
     */
    @IsTest
    static void testGetCountryNamesNull() {
        Test.startTest();
        Map<String, String> results = CountryPicklistUtil.getCountryNames(null);
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(0, results.size(), 'Results should be empty for null input');
    }
    
    /**
     * @description Test getting country names with empty set
     */
    @IsTest
    static void testGetCountryNamesEmpty() {
        Test.startTest();
        Map<String, String> results = CountryPicklistUtil.getCountryNames(new Set<String>());
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(0, results.size(), 'Results should be empty for empty input');
    }
    
    /**
     * @description Test isValidCountryCode method
     */
    @IsTest
    static void testIsValidCountryCode() {
        Test.startTest();
        Boolean isValidUS = CountryPicklistUtil.isValidCountryCode('US');
        Boolean isValidLower = CountryPicklistUtil.isValidCountryCode('us');
        Boolean isInvalid = CountryPicklistUtil.isValidCountryCode('ZZ');
        Boolean isNull = CountryPicklistUtil.isValidCountryCode(null);
        Boolean isBlank = CountryPicklistUtil.isValidCountryCode('');
        Test.stopTest();
        
        System.assertEquals(true, isValidUS, 'US should be valid');
        System.assertEquals(true, isValidLower, 'Lowercase us should be valid');
        System.assertEquals(false, isInvalid, 'ZZ should be invalid');
        System.assertEquals(false, isNull, 'Null should be invalid');
        System.assertEquals(false, isBlank, 'Blank should be invalid');
    }
    
    /**
     * @description Test getAllCountryCodes method
     */
    @IsTest
    static void testGetAllCountryCodes() {
        Test.startTest();
        Set<String> countryCodes = CountryPicklistUtil.getAllCountryCodes();
        Test.stopTest();
        
        System.assertNotEquals(null, countryCodes, 'Country codes set should not be null');
        System.assert(countryCodes.size() > 0, 'Country codes set should have entries');
        System.assert(countryCodes.contains('US'), 'Country codes should contain US');
    }
    
    /**
     * @description Test getCountryCount method
     */
    @IsTest
    static void testGetCountryCount() {
        Test.startTest();
        Integer count = CountryPicklistUtil.getCountryCount();
        Test.stopTest();
        
        System.assert(count > 0, 'Country count should be greater than 0');
    }
    
    /**
     * @description Test cache clearing
     */
    @IsTest
    static void testClearCache() {
        // First, populate the cache
        CountryPicklistUtil.getCountryCodeToNameMap();
        
        Test.startTest();
        CountryPicklistUtil.clearCache();
        // Get values again to verify cache rebuild works
        Map<String, String> countryMap = CountryPicklistUtil.getCountryCodeToNameMap();
        Test.stopTest();
        
        System.assertNotEquals(null, countryMap, 'Cache should be rebuilt after clear');
        System.assert(countryMap.size() > 0, 'Cache should have values after rebuild');
    }
    
    // ==========================================
    // Tests for PopulateCountryNameAction
    // ==========================================
    
    /**
     * @description Test invocable action with valid country code
     */
    @IsTest
    static void testInvocableActionValidCode() {
        PopulateCountryNameAction.Request req = new PopulateCountryNameAction.Request();
        req.countryCode = 'US';
        
        Test.startTest();
        List<PopulateCountryNameAction.Result> results = 
            PopulateCountryNameAction.getCountryName(new List<PopulateCountryNameAction.Request>{req});
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals('United States', results[0].countryName, 'Should return United States');
        System.assertEquals(true, results[0].success, 'Should be successful');
    }
    
    /**
     * @description Test invocable action with multiple country codes
     */
    @IsTest
    static void testInvocableActionMultipleCodes() {
        List<PopulateCountryNameAction.Request> requests = new List<PopulateCountryNameAction.Request>();
        
        PopulateCountryNameAction.Request req1 = new PopulateCountryNameAction.Request();
        req1.countryCode = 'US';
        requests.add(req1);
        
        PopulateCountryNameAction.Request req2 = new PopulateCountryNameAction.Request();
        req2.countryCode = 'CA';
        requests.add(req2);
        
        PopulateCountryNameAction.Request req3 = new PopulateCountryNameAction.Request();
        req3.countryCode = 'MX';
        requests.add(req3);
        
        Test.startTest();
        List<PopulateCountryNameAction.Result> results = 
            PopulateCountryNameAction.getCountryName(requests);
        Test.stopTest();
        
        System.assertEquals(3, results.size(), 'Should return three results');
        System.assertEquals(true, results[0].success, 'First result should be successful');
        System.assertEquals(true, results[1].success, 'Second result should be successful');
        System.assertEquals(true, results[2].success, 'Third result should be successful');
    }
    
    /**
     * @description Test invocable action with null country code
     */
    @IsTest
    static void testInvocableActionNullCode() {
        PopulateCountryNameAction.Request req = new PopulateCountryNameAction.Request();
        req.countryCode = null;
        
        Test.startTest();
        List<PopulateCountryNameAction.Result> results = 
            PopulateCountryNameAction.getCountryName(new List<PopulateCountryNameAction.Request>{req});
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(null, results[0].countryName, 'Country name should be null');
        System.assertEquals(true, results[0].success, 'Should still be successful (graceful handling)');
    }
    
    /**
     * @description Test invocable action with blank country code
     */
    @IsTest
    static void testInvocableActionBlankCode() {
        PopulateCountryNameAction.Request req = new PopulateCountryNameAction.Request();
        req.countryCode = '';
        
        Test.startTest();
        List<PopulateCountryNameAction.Result> results = 
            PopulateCountryNameAction.getCountryName(new List<PopulateCountryNameAction.Request>{req});
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(null, results[0].countryName, 'Country name should be null');
    }
    
    /**
     * @description Test invocable action with invalid country code
     */
    @IsTest
    static void testInvocableActionInvalidCode() {
        PopulateCountryNameAction.Request req = new PopulateCountryNameAction.Request();
        req.countryCode = 'ZZ';
        
        Test.startTest();
        List<PopulateCountryNameAction.Result> results = 
            PopulateCountryNameAction.getCountryName(new List<PopulateCountryNameAction.Request>{req});
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(null, results[0].countryName, 'Country name should be null for invalid code');
        System.assertEquals(false, results[0].success, 'Should not be successful');
        System.assert(results[0].message.contains('not found'), 'Message should indicate not found');
    }
    
    /**
     * @description Test invocable action with lowercase country code
     */
    @IsTest
    static void testInvocableActionLowercaseCode() {
        PopulateCountryNameAction.Request req = new PopulateCountryNameAction.Request();
        req.countryCode = 'us';
        
        Test.startTest();
        List<PopulateCountryNameAction.Result> results = 
            PopulateCountryNameAction.getCountryName(new List<PopulateCountryNameAction.Request>{req});
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertNotEquals(null, results[0].countryName, 'Should find country for lowercase code');
    }
    
    /**
     * @description Test invocable action with null request list
     */
    @IsTest
    static void testInvocableActionNullList() {
        Test.startTest();
        List<PopulateCountryNameAction.Result> results = 
            PopulateCountryNameAction.getCountryName(null);
        Test.stopTest();
        
        System.assertEquals(0, results.size(), 'Should return empty list for null input');
    }
    
    /**
     * @description Test invocable action with empty request list
     */
    @IsTest
    static void testInvocableActionEmptyList() {
        Test.startTest();
        List<PopulateCountryNameAction.Result> results = 
            PopulateCountryNameAction.getCountryName(new List<PopulateCountryNameAction.Request>());
        Test.stopTest();
        
        System.assertEquals(0, results.size(), 'Should return empty list for empty input');
    }
}
