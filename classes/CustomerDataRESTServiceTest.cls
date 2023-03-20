@isTest
private class CustomerDataRESTServiceTest {
    
    // Set up test data
    @testSetup
    static void setup() {
        // Create test account
        Account acc = TestDataFactory.createAccount('Test Account',true);
        
        // Create custom price book
        Pricebook2 customPricebook = TestDataFactory.createPricebook2(true);
        
        // Create test product
        Product2 product = TestDataFactory.createProduct2(true);
        
        // Create price book entry for product
        PricebookEntry pricebookEntry = TestDataFactory.createPricebookEntry(customPricebook, product, true);
        
        // Create test contact for the account and product
        Contact newcontact = TestDataFactory.createContact(product.Id, customPricebook.Id, acc.Id, false);
        newcontact.UUId__c = '7265456';
        Insert newcontact;
    }
    
    // Test a successful call to the REST service
    @isTest
    static void testCustomerDataRESTServiceSuccess() {
        // Get UUID of a contact created in test setup
        string externalContactId = [SELECT Id,UUId__c FROM contact LIMIT 1]?.UUId__c;
        system.debug('externalContactId----->'+externalContactId);
        
        // Set up a test request
        system.debug('DOMAIN URL --> '+JSON.serialize(URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/CustomerDataRESTService/'+ externalContactId));
        RestRequest request = new RestRequest();
        request.httpMethod = 'GET';
        request.requestUri =URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/CustomerDataRESTService/'+ externalContactId;
        RestContext.request = request;   
        
        // Call the REST service and retrieve the result
        List<CustomerDataRESTService.ProductInfoWrapper> result = CustomerDataRESTService.getContactByUUId();
       
        // Assert that the list is not empty and contains the expected values
        Assert.areNotEqual(0, result.size());
        Assert.areEqual('Test Product', result[0].productName);
        Assert.areEqual(1250.00, result[0].costperCalendarMonth);
        Assert.areEqual(50.00, result[0].cardReplacementCost);
        Assert.areEqual('Free', result[0].atmFeeOtherCurrencies);
    }
    
    // Test a failed call to the REST service
    @isTest
    static void testCustomerDataRESTServiceFailure() {
       
        // Set up a test request with an invalid UUID
        system.debug('DOMAIN URL --> '+JSON.serialize(URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/CustomerDataRESTService/'+123544));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        req.requestUri =URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/CustomerDataRESTService/'+123544;
        RestContext.request = req;
        RestContext.response = res;
        
        try{
            // Call the REST service and catch the exception
            List<CustomerDataRESTService.ProductInfoWrapper> result = CustomerDataRESTService.getContactByUUId();
    
        }catch(Exception e){
            // Assert that the exception message matches the expected message
            Assert.areEqual('Error in retrieving Product Information: List has no rows for assignment to SObject', e.getMessage());
        }
    }
    
    //Test buildProductInfoWrapper method without data in Product and Home Country fields 
    @istest
    static void testBuildingProductInfoWrapperMethod(){
        
         
        Id accountId = [SELECT Id FROM Account LIMIT 1]?.Id;
        Contact exceptionContact = TestDataFactory.getContact(accountId,'Test', 'Contact', false);
        exceptionContact.UUId__c = '8956214';
        Insert exceptionContact;
      
        try{
                 List<CustomerDataRESTService.ProductInfoWrapper> wrapperResult = CustomerDataRESTService.buildProductInfoWrapper(exceptionContact);
        }catch(Exception e){
            
            Assert.areEqual('Error building product info', e.getMessage());
        }
        
    }
}