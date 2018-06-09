//
//  InAppPurchaseManager.h
//  GaojiaNiuNiu-appstore
//
//  Created by Zero Zheng on 2018/4/23.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "SKProduct+LocalizedPrice.h"
#import "InAppPurchaseValidate.h"


typedef NS_ENUM(NSInteger,InAppPurchaseStatus){
    InAppPurchaseSuccess,// 购买成功
    InAppPurchaseRestore,// 已购买过
    InAppPurchaseFailure// 购买失败
};

typedef void (^LoadStoreDidBlock)(void);
typedef void (^PurchaseStatusBlock)(SKPaymentTransaction *paymentTransaction,InAppPurchaseStatus status);

@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    
}
/// 商品信息
@property (nonatomic, copy) NSArray *productList;

@property (nonatomic, copy, readonly) LoadStoreDidBlock loadStoreDidBlock;

/// 初始化
+ (InAppPurchaseManager*)getInstance;
+ (void)releaseInstance;

/// 内购是否可用
- (BOOL)canMakePurchases;

/// 添加ProductId
- (void)addProductIdentifiers:(NSArray*)identifiers;
- (void)clearProductIdentifiers;

/// 载入商品信息
- (void)loadStore:(LoadStoreDidBlock)loadStoreDidBlock;

/// 购买
-(void)purchaseWithProductId:(NSString *)identifier purchaseStatusBlock:(PurchaseStatusBlock)purchaseStatusBlock;





@end


