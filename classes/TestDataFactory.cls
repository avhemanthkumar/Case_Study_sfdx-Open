@isTest
public class TestDataFactory {
    public static Pricebook2 createPricebook2(Boolean doInsert) {
        
        Pricebook2 testPriceBook = new Pricebook2(Name = 'DE', IsActive = true,CurrencyIsoCode='EUR');
        
        if(doInsert) INSERT testPriceBook;
        
        return testPriceBook;
    }
    
    public static Product2 createProduct2(Boolean doInsert) {
        
        Product2 testProduct = new Product2(Name = 'Test Product', ProductCode = 'Test Code');
        
        if(doInsert) INSERT testProduct;
        
        return testProduct;
    }
    
    public static PricebookEntry createPricebookEntry (Pricebook2 newPricebook, Product2 prod, Boolean doInsert) {
        System.debug('***** Inserting Standard PriceBookEntry first');
        PricebookEntry standardPB = new PricebookEntry();
        standardPB.pricebook2Id = Test.getStandardPricebookId();
        standardPB.product2id = prod.id;
        standardPB.unitprice = 1249.0;
        standardPB.isactive = true;
        INSERT standardPB;
        
        System.debug('***** Inserting Custom PriceBookEntry');
        PricebookEntry customPB = new PricebookEntry();
        customPB.pricebook2Id = newPricebook.id;
        customPB.product2id = prod.id;
        customPB.UseStandardPrice = false;
        customPB.unitprice = 1250.00;
        customPB.ATM_Fee_in_other_currencies__c = 'Free';
        customPb.Card_Replacement_Cost__c = 50.00;
        customPb.CurrencyIsoCode = 'EUR';
        customPB.isactive = true;
        
        if(doInsert) INSERT customPB;
        
        return customPB;
    }
    public static Contact createContact(Id productId, Id pricebookId, Id accId, Boolean doInsert) {
        Contact testContact= new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = accId,
            Product__c = productId,
            Home_Country__c = pricebookId
        );
        
        if(doInsert) INSERT testContact;
        
        return testContact;
    }
    
    public static Case createCase(Id contactId, Boolean doInsert) {
        Case testCase =  new Case(
            ContactId = contactId,
            Status = 'Working',
            Origin = 'Phone'
        );
        
        if(doInsert) INSERT testCase;
        
        return testCase;
    }
    
    public static Account createAccount(String accountName, Boolean doInsert) {
        Account acc = new Account(Name = accountName);
        if(doInsert) INSERT acc;
        return acc;
    }
    
    public static Product2 getProduct2(String productName, String description, Boolean doInsert) {
        Product2 product = new Product2(Name = productName, Description = description, ProductCode = 'Test Code', IsActive = true);
        if(doInsert) INSERT product;
        
        return product;
    }
    
    public static Pricebook2 getPricebook2(String pricebookName, Boolean doInsert) {
        Pricebook2 pricebook = new Pricebook2(Name = pricebookName, IsActive = true);
        if(doInsert) INSERT pricebook;
        return pricebook;
    }
    
    
    public static Contact getContact(Id accountId, String firstName, String lastName, Boolean doInsert) {
        Contact contact = new Contact(AccountId = accountId, FirstName = firstName, LastName = lastName, Product__c = null, Home_Country__c = null);
        if(doInsert) INSERT contact;
        return contact;
    }
    
    public static Case getCase(Id contactId, Boolean doInsert) {
        Case caseRecord = new Case(ContactId = contactId);
        if(doInsert) INSERT caseRecord;
        return caseRecord;
    }
    
}