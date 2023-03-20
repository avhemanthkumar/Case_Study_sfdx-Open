@isTest
private class ProductInfoControllerTest {
    @testSetup
    static void setup() {
        
        Account acc = TestDataFactory.createAccount('Test Account',true);
        
        Pricebook2 customPricebook = TestDataFactory.createPricebook2(true);
        
        Product2 product = TestDataFactory.createProduct2(true);
        
        PricebookEntry pricebookEntry = TestDataFactory.createPricebookEntry(customPricebook, product, true);
        
        Contact contact = TestDataFactory.createContact(product.Id, customPricebook.Id, acc.Id, true);
        
        Case caseRecord = TestDataFactory.createCase(contact.Id, true);
        
    }
    
    @isTest
    static void testGetProductInfo() {
        // Get the test case record
        Case caseRecord = [SELECT Id,Contact.Product__r.Name,Contact.Home_Country__r.CurrencyIsoCode FROM Case LIMIT 1];
        
        // Call the getProductInfo method
        List<ProductInfoController.ProductInfoWrapper> productInfoList = ProductInfoController.getProductInfo(caseRecord.Contact.Product__c, caseRecord.Contact.Home_Country__c);
        
        // Assert that the list is not empty and contains the expected values
        Assert.areNotEqual(0, productInfoList.size());
        Assert.areEqual('Test Product', productInfoList[0].productName);
        Assert.areEqual(1250.00, productInfoList[0].costperCalendarMonth);
        Assert.areEqual(50.00, productInfoList[0].cardReplacementCost);
        Assert.areEqual('Free', productInfoList[0].atmFeeOtherCurrencies);
        Assert.areEqual(caseRecord.Contact.Home_Country__r.CurrencyIsoCode, productInfoList[0].currencyCode);
    }
    
    @isTest
    static void testGetProductInfoNoMatch() {
        // Create a test case record with a contact having a product and country that don't have a matching pricebook entry
        Account account = TestDataFactory.createAccount('Test Account', true);
        Product2 product = TestDataFactory.getProduct2('Test Product', 'Description', true);
        Pricebook2 pricebook = TestDataFactory.getPricebook2('DE', true);
        Contact contact = TestDataFactory.getContact(account.Id, 'Test', 'Contact', true);
        Case caseRecord = TestDataFactory.getCase(contact.Id, true);
        
        // Create a new pricebook entry with a different product
        Product2 otherProduct = TestDataFactory.getProduct2( 'Other Product', 'Description', true);
        PricebookEntry otherPricebookEntry = TestDataFactory.createPricebookEntry(pricebook, otherProduct, true);
        
        // Call the getProductInfo method and expect an exception
        try {
            List<ProductInfoController.ProductInfoWrapper> productInfoList = ProductInfoController.getProductInfo(otherProduct.Id,otherPricebookEntry.Id);
        } catch(AuraHandledException ex) {
            // Assert that the expected exception message is thrown
            Assert.areEqual('No matching Pricebook Entry found for the given product and country', ex.getMessage());
        }
    }
}