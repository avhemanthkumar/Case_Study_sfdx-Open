public with sharing class ProductInfoController {
    
    // Wrapper class to hold the product information
    public class ProductInfoWrapper {
        @AuraEnabled public String pbeId; // Price Book Entry Id for mapping key-field in Datatable
        @AuraEnabled public String currencyCode; // Currency code for dynamic rendering Datatable
        @AuraEnabled public String productName; // Product name
        @AuraEnabled public Decimal costperCalendarMonth; // Cost per Calendar Month
        @AuraEnabled public String atmFeeOtherCurrencies; //ATM Fee in other currencies
        @AuraEnabled public Decimal cardReplacementCost; //Card Replacement Cost
        @AuraEnabled public String countryName; //Country Name for User
        
    }
    
    // Method to retrieve the product information based on the contact's product and Home country
    // Returns a list of ProductInfoWrapper objects
    @AuraEnabled
    public static List<ProductInfoWrapper> getProductInfo(Id productId, Id priceBookId) {
        try {
                     
            system.debug('productLookup--->'+productId);
            system.debug('countryLookup--->'+priceBookId);
            // Query for the matching PricebookEntry records based on the product lookup and country lookup
            List<PricebookEntry> pricebookEntries = [SELECT Product2.Name, UnitPrice,ATM_Fee_in_other_currencies__c,Card_Replacement_Cost__c,Pricebook2Id,Pricebook2.Name,CurrencyIsoCode
                                                     FROM PricebookEntry 
                                                     WHERE Product2Id = :productId AND Pricebook2Id =:priceBookId];
            
            
            if(pricebookEntries.isEmpty()){
                
                throw new AuraHandledException('No matching Pricebook Entry found for the given product and country');
                
            }
            
            system.debug('PriceBook Entry--->'+pricebookEntries);
            
            // Create an empty list to hold the ProductInfoWrapper objects
            List<ProductInfoWrapper> productInfoList = new List<ProductInfoWrapper>();
            
            // Iterate over the PricebookEntry records and build the ProductInfoWrapper objects
            if (!pricebookEntries.isEmpty()) {
                
                for (PricebookEntry entry : pricebookEntries) {
                    
                    ProductInfoWrapper productInfo = new ProductInfoWrapper();
                    productInfo.productName = entry.Product2.Name;
                    productInfo.costperCalendarMonth = entry.UnitPrice;
                    productInfo.cardReplacementCost = entry.Card_Replacement_Cost__c;
                    productInfo.atmFeeOtherCurrencies = entry.ATM_Fee_in_other_currencies__c;
                    productInfo.pbeId = entry.Id;
                    productInfo.currencyCode = entry.CurrencyIsoCode;
                    productInfo.countryName = getCountryNameFromMdt(entry.Pricebook2.Name);
                    system.debug('Country Name---->'+getCountryNameFromMdt(entry.Pricebook2.Name));
                    productInfoList.add(productInfo);
                }
            }
            
            system.debug('Product Info List----->'+productInfoList);
            // Return the list of ProductInfoWrapper objects
            return productInfoList;
        } catch(Exception ex) {
            
                system.debug('Exception--->'+ex.getMessage()); 
                AuraHandledException ae = new AuraHandledException('No matching Pricebook Entry found for the given product and country');
                ae.setMessage('No matching Pricebook Entry found for the given product and country');
                throw ae;
            
            
        }
    }
    
   //Method to fetch Customer's Country Name from Custom MetadatType records based on 2-Letter-Country Code
   public static String getCountryNameFromMdt(String twoLetterCode){
        
       CountryMapping__mdt countryMdt = CountryMapping__mdt.getInstance(twoLetterCode);
        String countryName = countryMdt.Country_Name__c;
        
        return countryName;
        
        
    }
}