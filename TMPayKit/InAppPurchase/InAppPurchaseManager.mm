//
//  InAppPurchaseManager.m
//  GaojiaNiuNiu-appstore
//
//  Created by Zero Zheng on 2018/4/23.
//

#import "InAppPurchaseManager.h"
#import "InAppPurchaseValidate.h"

static NSMutableArray* productIdentifiers = nil;
static InAppPurchaseManager* m_pInstance = nil;

@interface InAppPurchaseManager()
{
    SKProductsRequest *productsRequest;
    SKProduct *startedPaymentProduct;
}
@property (nonatomic, copy, readwrite) LoadStoreDidBlock loadStoreDidBlock;
@property (nonatomic, copy, readwrite) PurchaseStatusBlock purchaseStatusBlock;

@end
@implementation InAppPurchaseManager

#pragma mark- init
+ (InAppPurchaseManager*) getInstance
{
    if (m_pInstance == nil){
        m_pInstance = [[InAppPurchaseManager alloc] init];
    }
    return m_pInstance;
}

+ (void) releaseInstance
{
    if (m_pInstance){
        m_pInstance = nil;
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    }
}

#pragma mark- ProductId
- (void)addProductIdentifiers:(NSArray*)identifiers
{
    if (productIdentifiers == nil)
    {
        productIdentifiers = [[NSMutableArray alloc] init];
    }
    
    [productIdentifiers addObjectsFromArray:identifiers];
    
}

- (void) clearProductIdentifiers
{
    if (productIdentifiers)
    {
        [productIdentifiers removeAllObjects];
    }
}


#pragma mark- Public methods

- (void)loadStore:(LoadStoreDidBlock)loadStoreDidBlock
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    self.loadStoreDidBlock = loadStoreDidBlock;

    [self requestProductData];
    
}

- (void)requestProductData
{
    if(productIdentifiers.count==0) {
        NSLog(@"error: no productId");
        return;
    }
    
    NSSet *productIdentifiersSet = [NSSet setWithArray:productIdentifiers];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiersSet];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

-(void)purchaseWithProductId:(NSString *)identifier purchaseStatusBlock:(PurchaseStatusBlock)purchaseStatusBlock
{
    self.purchaseStatusBlock = purchaseStatusBlock;
    startedPaymentProduct = nil;
    [self addProductIdentifiers:@[identifier]];
    if(self.productList == nil) {
        __weak typeof(self) weakSelf = self;
        [self loadStore:^{
            if(weakSelf.productList == nil)
                weakSelf.productList = [[NSArray alloc]init];
            [weakSelf purchaseWithProductId:identifier purchaseStatusBlock:purchaseStatusBlock];
        }];
        return;
    }
    
    for (int i = 0; i < self.productList.count; ++i) {
        SKProduct* p = [self.productList objectAtIndex:i];
        if ([[p productIdentifier] isEqualToString:identifier]) {
            startedPaymentProduct = p;
            break;
        }
    }
    
    if(startedPaymentProduct == nil) {
        NSLog(@"没有找到该商品");
        if(purchaseStatusBlock) purchaseStatusBlock(nil,InAppPurchaseFailure);
        return;
    }
    
    [self paymentWithProduct:startedPaymentProduct];
}
-(void)paymentWithProduct:(SKProduct *)product
{
    if (product == nil) {
        NSLog(@"err: startedPaymentProduct is nil");
        return;
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


#pragma mark-  SKProductsRequestDelegate
/// 接收商品信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if (self.productList) {
        self.productList = nil;
    }
    self.productList = response.products;
    
    NSMutableArray* productListArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.productList.count; ++i) {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        SKProduct* p = [self.productList objectAtIndex:i];
        [dict setObject:(p.localizedTitle != nil ? p.localizedTitle : @"") forKey:@"localizedTitle"];
        [dict setObject:(p.localizedDescription != nil ? p.localizedDescription : @"") forKey:@"localizedDescription"];
        [dict setObject:p.price forKey:@"price"];
        [dict setObject:p.productIdentifier forKey:@"productIdentifier"];
        [productListArray addObject:dict];
    }
    
    NSMutableArray* invalidProductArray = [[NSMutableArray alloc] init];
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        [invalidProductArray addObject:invalidProductId];
    }
    
    if(self.loadStoreDidBlock) self.loadStoreDidBlock();
    
}

#pragma mark - SKPaymentTransactionObserver methods

/// 监听交易操作与结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction{
    for(SKPaymentTransaction *tran in transaction){
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:
            {
                NSLog(@"交易完成");
                [self completeTransaction:tran];
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
            }break;
            case SKPaymentTransactionStatePurchasing:
            {
                NSLog(@"商品添加进列表");
            }break;
            case SKPaymentTransactionStateRestored:
            {
                NSLog(@"已经购买过商品");
                [self restoreTransaction:tran];
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
            }break;
            case SKPaymentTransactionStateFailed:
            {
                NSLog(@"交易失败%@",tran.error);
                [self failedTransaction:tran];
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
            }break;
            default:
            {
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
            }break;
        }
    }
}

//交易结束
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self finishTransaction:transaction status:0];
}

//交易失败
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
 
    [self finishTransaction:transaction status:1];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
        [self finishTransaction:transaction status:-1];
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction status:(int)status
{
    InAppPurchaseStatus inAppPurchasestatus = InAppPurchaseSuccess;
    if(status == 1) inAppPurchasestatus = InAppPurchaseRestore;
    if(status == -1) inAppPurchasestatus = InAppPurchaseFailure;

    if(self.purchaseStatusBlock) self.purchaseStatusBlock(transaction, inAppPurchasestatus);
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier isEqualToString:[startedPaymentProduct productIdentifier]]) {

    }
}

@end


