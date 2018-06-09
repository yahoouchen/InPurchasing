//
//  InAppPruchaseValidate.m
//  TMPayKit
//
//  Created by teamotto on 2018/5/18.
//  Copyright © 2018年 teamotto. All rights reserved.
//

#import "InAppPurchaseValidate.h"

@implementation InAppPurchaseValidate

//+(NSString *)productIdentifierWithPaymentTransaction:(SKPaymentTransaction *)transaction
//{
//    NSString *productIdentifier = transaction.payment.productIdentifier;
//    return productIdentifier;
//}

+(void)loadReceiptWithSuccessBlock:(SuccessBlock)successBlock failBlock:(FailBlock)failBlock {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [[NSBundle mainBundle]appStoreReceiptURL];
    NSURLSessionDataTask *task=[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error) {
            if(failBlock) failBlock(error);
            return ;
        }
        NSString *transactionReceiptsString = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        if(successBlock) successBlock(transactionReceiptsString);
    }];
    
    [task resume];
    
}

+(void)validateWithReceipt:(NSString *)recepiptString successBlock:(SuccessBlock)successBlock failBlock:(FailBlock)failBlock {
    NSAssert(![KK_RECEIPT_VALIDATAURL isEqualToString:@""], @"KK_RECEIPT_VALIDATAURL 未配置，不能为空");
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:KK_RECEIPT_VALIDATAURL]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [recepiptString dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error) {
            if(failBlock) failBlock(error);
            return ;
        }
        if(successBlock) successBlock(data);
    }];
    
    [dataTask resume];
}

+(void)ValidatReceipteWithSuccessBlock:(SuccessBlock)successBlock failBlock:(FailBlock)failBlock {
    [InAppPurchaseValidate loadReceiptWithSuccessBlock:^(id response) {
        [InAppPurchaseValidate validateWithReceipt:response successBlock:^(id responesData) {
            if(successBlock) successBlock(responesData);
        } failBlock:^(NSError *error) {
            if(failBlock) failBlock(error);
        }];
    } failBlock:^(NSError *error) {
        if(failBlock) failBlock(error);
    }];
}



@end
