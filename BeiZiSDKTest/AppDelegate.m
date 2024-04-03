//
//  AppDelegate.m
//  BeiZiSDKTest
//
//  Created by 李永杰 on 2023/7/26.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>
#import <BeiZiSDK/BeiZiSDK.h>

@interface AppDelegate () <BeiZiSplashDelegate>

@property (nonatomic, strong) BeiZiSplash *splash;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[ViewController new]];
    [self.window makeKeyAndVisible];
    
    
    [BeiZiSDKManager configureWithApplicationID:@"21783"]; //20689
    
    // 延时请求广告
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self createSplash];
    });
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self requestIDFA];
}

- (void)requestIDFA {
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            // 授权完成回调，block可能不在主线程，如果在此请求广告请先调用回到主线程
        }];
    }
}

- (void)createSplash {
    self.splash = [[BeiZiSplash alloc]initWithSpaceID:@"106322" spaceParam:@"" lifeTime:5000]; //104569
    self.splash.delegate = self;
    self.splash.showLaunchImage = YES;
    [self.splash BeiZi_loadSplashAd];// 使用此方法加载开屏
}
// MARK: - splash

- (void)BeiZi_splashDidLoadSuccess:(BeiZiSplash *)beiziSplash {
    NSLog(@"Cookie:规定时间内广告请求成功");
    //主线程
    [self.splash BeiZi_showSplashAdWithWindow:self.window];
}

/**
 开屏展现
 */
- (void)BeiZi_splashDidPresentScreen:(BeiZiSplash *)beiziSplash {
    if (self.splash.isZoomOutAd) {
        [self.splash BeiZi_showZoomOutSplashAdWithController:[UIApplication sharedApplication].delegate.window.rootViewController];
    }
    NSLog(@"Cookie:开屏展示");
}
/**
 开屏点睛点击
 */
- (void)BeiZi_splashZoomOutDidClick:(BeiZiSplash *)beiziSplash {
    
}

/**
 开屏点睛关闭
 */
- (void)BeiZi_splashZoomOutDidClose:(BeiZiSplash *)beiziSplash {
    _splash = nil;
//    _splash.delegate = nil;
}

/**
 开屏点击
 */
- (void)BeiZi_splashDidClick:(BeiZiSplash *)beiziSplash {
    NSLog(@"Cookie:开屏点击");
}

/**
 开屏即将消失
 */
- (void)BeiZi_splashWillDismissScreen:(BeiZiSplash *)beiziSplash {
    NSLog(@"Cookie:开屏即将消失");
}

/**
 开屏消失
 */
- (void)BeiZi_splashDidDismissScreen:(BeiZiSplash *)beiziSplash {
    NSLog(@"Cookie:开屏消失");
    if (!self.splash.isZoomOutAd) {
        _splash = nil;
//        _splash.delegate = nil;
    }
}

- (void)BeiZi_splashAdLifeTime:(int)lifeTime {
    NSLog(@"Cookie:开屏倒计时%d", lifeTime);
}

/**
 开屏请求失败
 */
- (void)BeiZi_splash:(BeiZiSplash *)beiziSplash didFailToLoadAdWithError:(BeiZiRequestError *)error {
    NSLog(@"Cookie:规定时间内广告请求失败---开屏失r败---查看控制台打印时间");
    NSLog(@"Cookie:%@", error);
}


@end
