import { LightningElement, wire, api } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CUSTOMER_PRODUCT_INFO_COLUMNS } from "./constants";

// Importing the getProductInfo function from the ProductInfoController Apex class
import Get_Product_Info from "@salesforce/apex/ProductInfoController.getProductInfo";

// Importing functions to get data from a Salesforce record
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

// Importing field APIs for the Case object
import PRODUCT_ID from '@salesforce/schema/Case.Contact.Product__c';
import PRICEBOOK_ID from '@salesforce/schema/Case.Contact.Home_Country__c';

export default class CustomerProductInformationComponent extends LightningElement {

    // Declaring properties
    @api recordId; // ID of the Salesforce record associated with this component
    productInfo = []; // Array of product information to be displayed in the table
    error; // Error message to be displayed if an error occurs
    columns = CUSTOMER_PRODUCT_INFO_COLUMNS; // Columns for the product information table

    // Wire decorator to call getRecord to retrieve customer's product and pricebook IDs
    @wire(getRecord, { recordId: '$recordId', fields: [PRODUCT_ID, PRICEBOOK_ID] })
    wiredProductInfo({ error, data }) {
        if (data) {
            // If data is returned, call getProductInfo with the product and pricebook IDs
            this.getProductInfo(getFieldValue(data, PRODUCT_ID), getFieldValue(data, PRICEBOOK_ID));
        } else if (error) {
            // If an error occurs, display a toast message with the error message
            console.error(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error occured while Retrieving Customer\'s Product Information',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }

    // Function to retrieve product information based on the product and pricebook IDs
    getProductInfo(productId, priceBookId) {

        Get_Product_Info({ productId: productId, priceBookId: priceBookId })
            .then(resp => {

                // Map the data to required format
                this.productInfo = resp.map((entry) => {
                    return {
                        Id: entry.Id,
                        CurrencyIsoCode: entry.currencyCode,
                        productName: entry.productName,
                        costperCalendarMonth: entry.costperCalendarMonth,
                        atmFeeOtherCurrencies: entry.atmFeeOtherCurrencies,
                        cardReplacementCost: entry.cardReplacementCost,
                        countryName: entry.countryName
                    };
                });
            })
            .catch((error) => {
                // If an error occurs, display a toast message with the error message
                console.error(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error occured while Retrieving Customer\'s Product Information',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    //getter method to return country name from productInfo array
    get getcountryName() {

        return this.productInfo.length > 0 ? this.productInfo[0].countryName : '';


    }
}