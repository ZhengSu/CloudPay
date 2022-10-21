//
//  CloudPay.h
//  Cloud-Pay
//
//  Created by 郑隋 on 2022/10/19.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#define CLOUDPAY_RESULT @"CLOUDPAY_RESULT"


typedef NS_ENUM(NSInteger, CloudPay_Status)
{
    CloudPay_DataError = 0,         //【订单信息有误】
    CloudPay_DataSuccess,           //【订单信息正常】
    CloudPay_WXAppUnInstalled,      //【未安装微信】
    CloudPay_ALiPayAppUninstall,    //【未安装支付宝】
    
};
NS_ASSUME_NONNULL_BEGIN

@interface CloudPay : NSObject

+(instancetype)defaultManager;

/*! @brief 向微信终端程序注册第三方应用。
 *
 * 需要在每次启动第三方应用程序时调用。
 * @attention 请保证在主线程中调用此函数
 * @param appid 微信开发者ID
 * @param universalLink 微信开发者Universal Link
 * @return 成功返回YES，失败返回NO。
 */
- (BOOL)registerApp:(NSString *)appid universalLink:(NSString *)universalLink;


/*! @brief 处理H5返回的订单信息，从而根据用户选择拉起【微信】或【支付宝】
 *
 * @param webView  WKWebView
 * @param success  返回支付结果的URL
 * @param failure  用来处理支付状态，比如用户【未安装微信】或【未安装支付宝】
 */
- (void)cloudPayWithWebview:(WKWebView *)webView success:(void (^)(NSString *resultUrl))success failure:(void(^)(CloudPay_Status status))failure;


/*! @brief 【支付宝】通过URL Schemes 启动App时传递的数据
 *
 * 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用。
 * @param url 微信启动第三方应用时传递过来的URL
 * @return 成功返回YES，失败返回NO。
 */
+ (BOOL)handleOpenURL:(NSURL *)url;


/*! @brief 处理【微信】通过Universal Link启动App时传递的数据
 *
 * 需要在 application:continueUserActivity:restorationHandler:中调用。
 * @param userActivity 微信启动第三方应用时系统API传递过来的userActivity
 * @return 成功返回YES，失败返回NO。
 */
+ (BOOL)handleOpenUniversalLink:(NSUserActivity *)userActivity;

@end

NS_ASSUME_NONNULL_END
