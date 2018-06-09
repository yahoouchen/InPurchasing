//
//  SKProduct+LocalizedPrice.h
//  GaojiaNiuNiu-appstore
//
//  Created by Zero Zheng on 2018/4/23.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end
