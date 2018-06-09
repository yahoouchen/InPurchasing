//
//  ViewController.m
//  TMPayKit
//
//  Created by teamotto on 2018/5/9.
//


#import "ViewController.h"
#import "InAppPurchaseManager.h"

#define ALIPAY_SCHEME  @"teamOtto"


@interface ViewController ()
{
    
}
@property (nonatomic, strong) NSArray *arr;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arr = [[NSArray alloc]initWithObjects:@"qwe123",nil];
    
}

- (IBAction)clickPay3:(id)sender {
    [self inAppPurchase];
}

#pragma mark- 内购
-(void)inAppPurchase {

    /// itunes connection产品id
    [[InAppPurchaseManager getInstance] addProductIdentifiers:@[@"com.test1.020.App009",@"com.test1.020.App010",@"com.test1.020.112"]];
    
    // 购买产品
    [[InAppPurchaseManager getInstance] purchaseWithProductId:@"com.test1.020.App009" purchaseStatusBlock:^(SKPaymentTransaction *paymentTransaction, InAppPurchaseStatus status) {
       
        if(status == InAppPurchaseFailure) {
            NSLog(@"未完成支付");
            return;
        }
        
        NSString *productIdentifier = paymentTransaction.payment.productIdentifier;
        
        // 方法一 获取票据并向服务端提交票据信息
        // 需要KK_RECEIPT_VALIDATAURL 配置服务端地址
        {
            [InAppPurchaseValidate ValidatReceipteWithSuccessBlock:^(id responesData) {
                // 提交成功
                NSLog(@"服务端已返回验证结果responesData");
            } failBlock:^(NSError *error) {
                NSLog(@"error:%@",error);
            }];
        }
        
        // 方法二 仅获取票据信息
        {
//            [InAppPurchaseValidate loadReceiptWithSuccessBlock:^(id response) {
//                NSString *transactionReceiptsString =  (NSString *)response;
//                NSLog(@"%@",transactionReceiptsString);
//                // 向服务端提交票据信息
//                // 需要KK_RECEIPT_VALIDATAURL 配置服务端地址
//                [InAppPurchaseValidate validateWithReceipt:transactionReceiptsString successBlock:^(id responesData) {
//
//                } failBlock:^(NSError *error) {
//
//                }];
//
//            } failBlock:^(NSError *error) {
//                NSLog(@"error:%@",error);
//            }];
        }
        
    }];
}


-(void)dealloc {
    NSLog(@"shifang");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
