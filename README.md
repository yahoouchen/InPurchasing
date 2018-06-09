# InPurchasing 内购集成

在你使用到的 地方直接调用

注：ProductId 为产品内购id,测试的时候需要先添加沙盒测试账号

```
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
```

