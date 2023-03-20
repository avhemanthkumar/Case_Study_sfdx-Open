@RestResource(urlMapping='/CustomerDataRESTService/*')
global class CustomerDataRESTService {
    
    // Wrapper class to hold the product information
    global class ProductInfoWrapper {
        public String productName { get; set; } // Product name
        public Decimal costperCalendarMonth { get; set; } // Cost per Calendar Month
        public String atmFeeOtherCurrencies { get; set; } //ATM Fee in other currencies
        public Decimal cardReplacementCost { get; set; } //Card Replacement Cost
    }
    
    /*
     * Returns a list of product information for a contact with a given UUID
     * 
     * @param uuid - the UUID of the contact to retrieve product information for
     * @return a list of ProductInfoWrapper objects representing the product information for the contact
     */
    @HttpGet
    global static List<ProductInfoWrapper> getContactByUUId() {
        
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String uuid = request.requestURI.substringAfterLast('/');
        List<ProductInfoWrapper> productInfoList = new List<ProductInfoWrapper>();
        try {
            Contact con = [SELECT Id, UUId__c, Product__c, Home_Country__c FROM Contact WHERE UUId__c = :uuid LIMIT 1];
            productInfoList = buildProductInfoWrapper(con);
        } catch (Exception e) {
            // Log the error and return an error response
            System.debug('Error in retrieving Product Information: ' + e.getMessage());
            response.statusCode = 500;
            response.responseBody = Blob.valueOf('Error: ' + e.getMessage());
            
            throw new CustomException('Error in retrieving Product Information: ' + e.getMessage());
        }
        
        return productInfoList;
    }
    
    /*
     * Builds a list of product information wrapper objects for a given contact
     * 
     * @param con - the Contact to retrieve product information for
     * @return a list of ProductInfoWrapper objects representing the product information for the contact
     */
    public static List<ProductInfoWrapper> buildProductInfoWrapper(Contact con){
        List<ProductInfoWrapper> productInfoList = new List<ProductInfoWrapper>();
        
        try {
            List<PricebookEntry> pricebookEntries = [SELECT Product2.Name, UnitPrice, ATM_Fee_in_other_currencies__c, Card_Replacement_Cost__c, Pricebook2Id, CurrencyIsoCode
                                                     FROM PricebookEntry 
                                                     WHERE Product2Id = :con.Product__c AND Pricebook2Id = :con.Home_Country__c];
            
            if(pricebookEntries.isEmpty()){
                
                throw new CustomException('Error building product info');
            }

            for (PricebookEntry entry : pricebookEntries) {
                ProductInfoWrapper productInfo = new ProductInfoWrapper();
                productInfo.productName = entry.Product2.Name;
                productInfo.costperCalendarMonth = entry.UnitPrice;
                productInfo.cardReplacementCost = entry.Card_Replacement_Cost__c;
                productInfo.atmFeeOtherCurrencies = entry.ATM_Fee_in_other_currencies__c;
                productInfoList.add(productInfo);
            }
        } catch (Exception e) {
            // Log the error and throw a custom exception
            System.debug('Error in buildProductInfoWrapper: ' + e.getMessage());
            throw new CustomException('Error building product info');
        }
        
        return productInfoList;
    }
    
    /*
     * Custom exception class
     */
    public class CustomException extends Exception {}
}