//
//  AppDelegate.m
//  Cloud-Pay
//
//  Created by 郑隋 on 2022/10/18.
//

#import "AppDelegate.h"
#import "CloudPay.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


#pragma mark -- 通过 URL Schemes 启动App时调用
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    BOOL result = [CloudPay handleOpenURL:url];
    
    if(!result){
        //这里处理其他SDK(例如QQ登录,微博登录等)
    }
    return result;
}

#pragma mark -- 通过 Universal Link 启动App时调用
-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler{
    BOOL result = [CloudPay handleOpenUniversalLink:userActivity];
    
    if(!result){
        //这里处理其他SDK(例如QQ登录,微博登录等)
    }
    return result;
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[CloudPay defaultManager] registerApp:@"wx7d217bf812c8828f" universalLink:@"https://catering.yonyou.com/"];
    return YES;
}

@end
