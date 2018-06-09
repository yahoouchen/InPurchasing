//
//  InAppPruchaseValidate.h
//  TMPayKit
//
//  Created by teamotto on 2018/5/18.
//  Copyright © 2018年 teamotto. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessBlock)(id response);

typedef void (^FailBlock)(NSError *error);


#define KK_RECEIPT_VALIDATAURL @"http://10.0.0.110:8001/api/pay/callback_iap"

@interface InAppPurchaseValidate : NSObject

/**
 获取收据信息

 @param successBlock 成功回调
 @param failBlock 失嵊回调
 */
+(void)loadReceiptWithSuccessBlock:(SuccessBlock)successBlock failBlock:(FailBlock)failBlock;

/**
 验证收据信息
 
 配置KK_RECEIPT_VALIDATAURL 为提交receipt到服务端地址
 @param recepiptString AppStore返回的收据信息
 @param successBlock 成功回调
 @param failBlock 失嵊回调
 */
+(void)validateWithReceipt:(NSString *)recepiptString successBlock:(SuccessBlock)successBlock failBlock:(FailBlock)failBlock;


/**
 合并loadReceiptWithSuccessBlock:与validateWithReceipt:获取recpipt信息并向服务器提交验证

 配置KK_RECEIPT_VALIDATAURL 为提交receipt到服务端地址
 @param successBlock 成功回调
 @param failBlock 失嵊回调
 */
+(void)ValidatReceipteWithSuccessBlock:(SuccessBlock)successBlock failBlock:(FailBlock)failBlock;


@end
