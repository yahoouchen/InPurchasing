//
//  AppDelegate.h
//  TMPayKit
//
//  Created by teamotto on 2018/5/9.
//  Copyright © 2018年 teamotto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/// sharedApplication.delegate
+(AppDelegate *)tm_shareAppDelegate;

@end

