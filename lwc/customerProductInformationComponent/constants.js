export const CUSTOMER_PRODUCT_INFO_COLUMNS = [
    { label: 'Card Type', fieldName: 'productName', type: 'text', cellAttributes: { alignment: 'left' } },
    { label: 'Cost per Calendar Month', fieldName: 'costperCalendarMonth', type: 'currency', cellAttributes: { alignment: 'left' }, typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' } } },
    { label: 'ATM Fee in Other Currencies', fieldName: 'atmFeeOtherCurrencies', type: 'text', cellAttributes: { alignment: 'left' } },
    { label: 'Card Replacement Cost', fieldName: 'cardReplacementCost', type: 'currency', cellAttributes: { alignment: 'left' }, typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' } } }
]