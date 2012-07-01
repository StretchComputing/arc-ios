//
//  DwollaAPI.h
//  DwollaSDK
//
//  Created by Nick Schulze on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  A class used to access the Dwolla API, must have an oauth 
//  token for most of the methods

#import <Foundation/Foundation.h>
#import "SBJson.h"
#import "DwollaUser.h"
#import "DwollaTransactions.h"
#import "DwollaFundingSources.h"
#import "DwollaTransactionStats.h"
#import "DwollaContacts.h"

static NSString *const dwollaAPIBaseURL;

@interface DwollaAPI : NSObject

/**
 * checks to see if the user has a valid access token
 *
 * @return YES if a valid access token is present, false otherwise
 **/
+(BOOL)hasToken;

/**
 * gets the stored access token
 *
 * @return a string representing the access token
 **/
+(NSString*)getAccessToken;

/**
 * sets the access token
 *
 * @param token: the string representing the token
 **/
+(void)setAccessToken:(NSString*) token;

/**
 * clears the access token
 **/
+(void)clearAccessToken;

/**
 * sends money to the indicated user
 *
 * @param pin: the pin of the user sending the money (required)
 * @param destinationID: the id of the user receiving the money (required)
 * @param type: the type of account receiving the money, may be null
 * @param amount: the amount of money to be sent (required)
 * @param facilitatorAmount: the amount of money the facilitator gets from the transaction
 *                           may be null, can't exceed 25% of the amount
 * @param assumeCost: values accepted are either YES or NO, indicates if the user wants to 
 *                    assume the costs of the transaction, may be null
 * @param notes: notes to be delivered with the transaction, may be null
 * @param fundingSourceID: id of the funding source funds will be sent from, may be null
 *
 * @return string representing the transaction id
 * @throws NSException if parameters are invalid, no access token is available, or request fails
 **/
+(NSString*)sendMoneyWithPIN:(NSString*)pin 
               destinationID:(NSString*)destinationID 
             destinationType:(NSString*)type
                      amount:(NSString*)amount
           facilitatorAmount:(NSString*)facAmount
                 assumeCosts:(NSString*)assumeCosts
                       notes:(NSString*)notes
             fundingSourceID:(NSString*)fundingID;

/**
 * requests money from the indicated user
 *
 * @param pin: the pin of the user requesting the money (required)
 * @param sourceID: the id of the user money is being requested from (required)
 * @param sourceType: the type of account money is being requested from, may be null
 * @param amount: the amount of money to be sent (required)
 * @param facilitatorAmount: the amount of money the facilitator gets from the transaction
 *                           may be null, can't exceed 25% of the amount
 * @param notes: notes to be delivered with the transaction, may be null
 *
 * @return string representing the request id
 * @throws NSException if parameters are invalid, no access token is available, or request fails
 **/
+(NSString*)requestMoneyWithPIN:(NSString*)pin 
                       sourceID:(NSString*)sourceID
                     sourceType:(NSString*)type
                         amount:(NSString*)amount
              facilitatorAmount:(NSString*)facAmount
                          notes:(NSString*)notes;
   
/**
 * shows the balance of the current user
 *
 * @return JSON representation of the request see: https://www.dwolla.com/developers/endpoints/balance/account
 * @throws NSException if no access token is available, or request fails
 **/
+(NSDictionary*)getJSONBalance;

/**
 * shows the balance of the current user
 *
 * @return string representation of the balance
 * @throws NSException if no access token is available, or request fails
 **/
+(NSString*)getBalance;

/**
 * gets users contacts
 *
 * @param name: search term to search the contacts, may be null
 * @param types: the types of account to be returned, may be null
 * @param limit: the number of contacts to be returned
 *
 * @return JSON representation of the request see: https://www.dwolla.com/developers/endpoints/contacts/user
 * @throws NSException if parameters are invalid, no access token is available, or request fails
 **/
+(NSDictionary*)getJSONContactsByName:(NSString*)name 
                                types:(NSString*)types
                                limit:(NSString*)limit;

/**
 * gets users contacts
 *
 * @param name: search term to search the contacts, may be null
 * @param types: the types of account to be returned, may be null
 * @param limit: the number of contacts to be returned
 *
 * @return a DwollaContacts object containing the results of the request
 * @throws NSException if parameters are invalid, no access token is available, or request fails
 **/
+(DwollaContacts*)getContactsByName:(NSString*)name 
                              types:(NSString*)types
                              limit:(NSString*)limit;

/**
 * gets nearby contacts
 *
 * @param latitude: the latitude to search from
 * @param longitude: the longitude to search from
 * @param limit: the number of contacts to be returned
 * @param range: the distance a contact may be from the latitude and longitude
 *
 * @return JSON representation of the request see: https://www.dwolla.com/developers/endpoints/contacts/nearby
 * @throws NSException if parameters are invalid, no access token is available, or request fails
 **/
+(NSDictionary*)getJSONNearbyWithLatitude:(NSString*)lat 
                                Longitude:(NSString*)lon
                                    Limit:(NSString*)limit
                                    Range:(NSString*)range;

/**
 * gets nearby contacts
 *
 * @param latitude: the latitude to search from
 * @param longitude: the longitude to search from
 * @param limit: the number of contacts to be returned
 * @param range: the distance a contact may be from the latitude and longitude
 *
 * @return a DwollaContacts object containing the results of the request
 * @throws NSException if parameters are invalid, no access token is available, or request fails
 **/
+(DwollaContacts*)getNearbyWithLatitude:(NSString*)lat 
                            Longitude:(NSString*)lon
                                Limit:(NSString*)limit
                                Range:(NSString*)range;

/**
 * gets the funding sources of the current user
 *
 * @return JSON representation of the request see https://www.dwolla.com/developers/endpoints/fundingsources/list
 * @throws NSException if no access token is available, or request fails
 **/
+(NSDictionary*)getJSONFundingSources;

/**
 * gets the funding sources of the current user
 *
 * @return a DwollaFundingSources object containing the results of the request
 * @throws NSException if no access token is available, or request fails
 **/
+(DwollaFundingSources*)getFundingSources;

/**
 * gets the funding source details of the provided funding source
 *
 * @param sourceID: a string representation of the id of the funding source
 *
 * @return JSON representation of the request see https://www.dwolla.com/developers/endpoints/fundingsources/details
 * @throws NSException if parameters are invalid, no access token is available, or request fails
 **/
+(NSDictionary*)getJSONFundingSource:(NSString*)sourceID;

/**
 * gets the funding source details of the provided funding source
 *
 * @param sourceID: a string representation of the id of the funding source
 *
 * @return a DwollaFundingSource object containing the result of the request
 * @throws NSException if parameters are invalid, no access token is available, or request fails
 **/
+(DwollaFundingSource*)getFundingSource:(NSString*)sourceID;

/**
 * gets the account information of the user
 *
 * @return JSON representation of the request see https://www.dwolla.com/developers/endpoints/users/accountinformation
 * @throws NSException if no access token is available, or request fails
 **/
+(NSDictionary*)getJSONAccountInfo;

/**
 * gets the account information of the user
 *
 * @return a DwollaUser object containing the result of the request
 * @throws NSException if no access token is available, or request fails
 **/
+(DwollaUser*)getAccountInfo;

/**
 * gets the account information of the user with the given id
 *
 * @param accountID: a string representation of the id of the account
 *
 * @return JSON representation of the request see https://www.dwolla.com/developers/endpoints/users/basicinformation
 * @throws NSException if parameters are invalid, no access token is available, or request fails
 **/
+(NSDictionary*)getJSONBasicInfoWithAccountID:(NSString*)accountID;

/**
 * gets the account information of the user with the given id
 *
 * @param accountID: a string representation of the id of the account
 *
 * @return a DwollaUser object containing the result of the request
 * @throws NSException if parameters are invalid, no access token is available, or request fails
 **/
+(DwollaUser*)getBasicInfoWithAccountID:(NSString*)accountID;

/**
 * registers a new user
 *
 * @param email: the email of the new user (required)
 * @param password: the password of the new user (required)
 * @param pin: the pin of the new user (required)
 * @param firstName: the first name of the new user (required)
 * @param lastName:  the last name of the new user (required)n
 * @param address:  the street address of the new user (required) 
 * @param address2: the secondary street address of the new user, may be null
 * @param city:  the city of the new user (required)
 * @param state: the state of the new user (required) -> uses two character identifier ex: IA == Iowa
 * @param zip:  the zip code of the new user (required)
 * @param phone: the phone number of the new user (required) -> formatted like **********
 * @param birthDate: the birthday of the new user (required) -> formatted like **-**-**** month-day-year
 * @param type:  the account type of the new user, may be null
 * @param organization:  the organization of the new user (required for commercial and nonprofit) 
 * @param ein: the ein of the new user (required for commercial and nonprofit)
 * @param accept: if the user accepts the terms, must be YES
 *
 * @return a DwollaUser object containing the result of the request
 * @throws NSException if parameters are invalid, no access token is available, accept terms is NO, or request fails
 **/
+(DwollaUser*)registerUserWithEmail:(NSString*)email 
                           password:(NSString*)password 
                                pin:(NSString*)pin
                          firstName:(NSString*)first
                           lastName:(NSString*)last
                            address:(NSString*)address
                           address2:(NSString*)address2
                               city:(NSString*)city
                              state:(NSString*)state
                                zip:(NSString*)zip
                              phone:(NSString*)phone
                          birthDate:(NSString*)dob
                               type:(NSString*)type
                       organization:(NSString*)organization
                                ein:(NSString*)ein
                        acceptTerms:(BOOL)accept;

/**
 * gets recent transactions
 *
 * @param date: the date to begin pulling transactions from 
 * @param limit: the number of transactions to be returned
 * @param skip: the number of transactions to skip
 *
 * @return JSON representation of the request see: https://www.dwolla.com/developers/endpoints/transactions/list
 * @throws NSException if parameters are invalid, no access token is available, or request fails
 **/
+(NSDictionary*)getJSONTransactionsSince:(NSString*)date 
                                   limit:(NSString*)limit
                                    skip:(NSString*)skip;

/**
 * gets recent transactions
 *
 * @param date: the date to begin pulling transactions from 
 * @param limit: the number of transactions to be returned
 * @param skip: the number of transactions to skip
 *
 * @return a DwollaTransactions object contiaining the results of the request
 * @throws NSException if parameters are invalid, no access token is available, or request fails
 **/
+(DwollaTransactions*)getTransactionsSince:(NSString*)date 
                                     limit:(NSString*)limit
                                      skip:(NSString*)skip;

/**
 * gets the transaction details of the provided transactionID
 *
 * @param transactionID: a string representation of the id of the transaction
 *
 * @return JSON representation of the request see https://www.dwolla.com/developers/endpoints/transactions/details
 * @throws NSException if parameters are invalid, no access token is available, or request fails
 **/
+(NSDictionary*)getJSONTransaction:(NSString*)transactionID;

/**
 * gets the transaction details of the provided transactionID
 *
 * @param transactionID: a string representation of the id of the transaction
 *
 * @return a DwollaTransaction object containing the result of the request
 * @throws NSException if parameters are invalid, no access token is available, or request fails
 **/
+(DwollaTransaction*)getTransaction:(NSString*)transactionID;

/**
 * gets the transaction stats for the user
 *
 * @param start: the date to begin pulling the stats from
 * @param end: the date to stop pulling the stats from
 *
 * @return JSON representation of the request see https://www.dwolla.com/developers/endpoints/transactions/stats
 * @throws NSException if parameters are invalid, no access token is available, or request fails
 **/
+(NSDictionary*)getJSONTransactionStats:(NSString*)start 
                                    end:(NSString*)end;

/**
 * gets the transaction stats for the user
 *
 * @param start: the date to begin pulling the stats from
 * @param end: the date to stop pulling the stats from
 *
 * @return a DwollaTransactionStats object containing the results of the request
 * @throws NSException if parameters are invalid, no access token is available, or request fails
 **/
+(DwollaTransactionStats*)getTransactionStats:(NSString*)start 
                                          end:(NSString*)end;

/**
 * helper class used to generate the url to request an oauth token
 *
 * @param key: the application key provided to the developer
 * @param redirect: the url to redirect the user to
 * @param response: the response the developer expects -> should be @"code"
 * @param redirect: the url to redirect the user to
 *
 * @return url request to be run by the client
 * @throws NSException if parameters are invalid, or if key or secret are invalid
 **/
+(NSURLRequest*)generateURLWithKey:(NSString*)key
                          redirect:(NSString*)redirect
                          response:(NSString*)response
                            scopes:(NSArray*)scopes;

/**
 * helper method that generates a url request
 *
 * @param request the string to be used to generate the url
 *
 * @return ur request to be run by the methods
 **/
+(NSMutableURLRequest*)generateRequestWithString:(NSString*)request;

/**
 * helper method that generates a dictionary given the data returned by the request
 *
 * @param data: the data returned by the request
 *
 * @return dictionary containing the results of the response
 **/
+(NSDictionary*)generateDictionaryWithData:(NSData*)data;

/**
 * helper method that generates a DwollaContact from the given string
 *
 * @param contact: the string containing the DwollaContact data
 *
 * @return DwollaContact object containing the contents of the string
 **/
+(DwollaContact*)generateContactWithString:(NSString*)contact;

/**
 * helper method that generates a DwollaTransaction from the given string
 *
 * @param transasction: the string containing the DwollaTransaction data
 *
 * @return DwollaTransaction object containing the contents of the string
 **/
+(DwollaTransaction*)generateTransactionWithString:(NSString*)transasction;

/**
 * helper method that parses the string to get the needed value
 *
 * @param string: the string to parse the value from
 *
 * @return a string representation of the value
 **/
+(NSString*)findValue:(NSString*)string;

/**
 * helper method that generates a DwollaFundingSource from the given string
 *
 * @param source: the string containing the DwollaFundingSource data
 *
 * @return DwollaFundingSource object containing the contents of the string
 **/
+(DwollaFundingSource*)generateSourceWithString:(NSString*)source;

/**
 * helper method that encodes the url
 *
 * @param string: the string to be encoded
 *
 * @return the correctly encoded string
 **/
+(NSString*)encodedURLParameterString:(NSString*)string;

@end
