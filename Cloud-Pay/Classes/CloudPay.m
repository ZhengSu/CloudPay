//
//  CloudPay.m
//  Cloud-Pay
//
//  Created by 郑隋 on 2022/10/19.
//

#import "CloudPay.h"
#import "WXAPI.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WKWebViewJavascriptBridge.h"
@interface CloudPay()<WXApiDelegate>
@property (nonatomic, strong) WKWebViewJavascriptBridge *bridge;
@property (nonatomic, strong) NSString *appid;
@property (nonatomic, strong) NSString *universalLink;

@end
@implementation CloudPay


+(instancetype)defaultManager{
    static dispatch_once_t onceToken;
    static CloudPay *instance;
    dispatch_once(&onceToken, ^{
        instance = [[CloudPay alloc] init];
    });
    return instance;
}

- (BOOL)registerApp:(NSString *)appid universalLink:(NSString *)universalLink{
    
    self.appid = appid;
    self.universalLink = universalLink;
    
    return [WXApi registerApp:appid universalLink:universalLink];
}

- (void)cloudPayWithWebview:(WKWebView *)webView success:(void (^)(NSString *resultUrl))success failure:(void(^)(CloudPay_Status status))failure{
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:webView];
    
    [self.bridge callHandler:@"registerAppid" data:@{@"appid":self.appid,@"universalLink":self.universalLink} responseCallback:^(id responseData) {
        NSLog(@"注册成功");
    }];
    
    [self.bridge registerHandler:@"getEnv" handler:^(id data, WVJBResponseCallback responseCallback) {
       if (responseCallback) {
             // 反馈给JS
             responseCallback(@"iOS");
        }
    }];

    [self.bridge registerHandler:@"getAppId" handler:^(id data, WVJBResponseCallback responseCallback) {
       if (responseCallback) {
             // 反馈给JS
           responseCallback(@{@"WXAppId":self.appid});
        }
    }];
    
    //注册原生事件 callTradePay 供 JavaScript 调用, data 是 JavaScript 传给原生的数据。responseCallback 是原生给 JavaScript 回传数据
    [self.bridge registerHandler:@"callTradePay" handler:^(NSDictionary *data, WVJBResponseCallback responseCallback) {
        NSDictionary *payData = data[@"payResponse"];
        NSString *paySource = payData[@"paySource"];//来源
        NSString *payStatus = payData[@"payStatus"];//支付状态
        NSString *payResulturl = payData[@"url"]; //支付结果URL
        
        if([payStatus isEqualToString:@"success"]){
            NSDictionary *payDataResponse = payData[@"wxPayData"];
            
            if([paySource isEqualToString:@"wechat"]){
                if(!WXApi.isWXAppInstalled){
                    if(failure){
                        //提示用户 【请先安装微信】
                        failure(CloudPay_WXAppUnInstalled);
                        return;
                    }
                }
                if(payDataResponse == nil ){
                    if(failure){
                        //提示用户 【请先安装微信】
                        failure(CloudPay_DataError);
                        return;
                    }
                }
                if(success){
                    success(payResulturl);
                }
                PayReq *request = [[PayReq alloc] init];
                
                request.partnerId = payDataResponse[@"partnerId"];
                request.prepayId = payDataResponse[@"prepayId"];
                request.nonceStr = payDataResponse[@"nonceStr"];
                request.timeStamp = [payDataResponse[@"timeStamp"] intValue];
                request.package = payDataResponse[@"package"];
                request.sign = payDataResponse[@"sign"] ;
                [WXApi sendReq:request completion:nil];
                
                
            }else if([paySource isEqualToString:@"alipay"]){
                NSURL *alipayUrl = [NSURL URLWithString:@"CloudAliPay://"];
                
                if(![[UIApplication sharedApplication] canOpenURL:alipayUrl]){
                    if(failure){
                        //提示用户 【请先安装支付宝】
                        failure(CloudPay_ALiPayAppUninstall);
                        return;
                    }                    
                }
                NSString *appScheme = @"CloudAliPay";
                if(payDataResponse == nil ){
                    if(failure){
                        //提示用户 【请先安装支付宝】
                        failure(CloudPay_DataError);
                        return;
                    }
                }
                if(success){
                    success(payResulturl);
                }
                NSString *orderString = payData[@"aliPayData"];//"后台给的订单拼接字符串"
                [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *result) {
                    NSLog(@"支付宝支付结果 %@",result);
                }];
            }
        }
    }];
}

+(BOOL)handleOpenURL:(NSURL *)url{
    NSString *string = url.absoluteString;
    NSString *urlStr=(__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)string, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
        if([url.host isEqualToString:@"safepay"] && [urlStr containsString:@"CloudAliPay"]){
            //跳转支付宝客户端进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                NSLog(@"result = %@",resultDic);
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                param[@"CloudPay_Type"] = @"alipay";
                param[@"result"] = resultDic;
                [[NSNotificationCenter defaultCenter] postNotificationName:CLOUDPAY_RESULT object:nil userInfo:param];
            }];
            return true;
        }else if([url.host isEqualToString:@"catering.yonyou.com"]){
            return [WXApi handleOpenURL:url delegate:[CloudPay defaultManager]];
        }
    return false;
}

+ (BOOL)handleOpenUniversalLink:(NSUserActivity *)userActivity{
    NSURL *url = [userActivity webpageURL];
    NSString *urlStr = [url absoluteString];
    if ([urlStr containsString:@"catering.yonyou.com"] && [urlStr containsString:@"pay"]){
        if([url.host isEqualToString:@"safepay"]){
            [[AlipaySDK defaultService]processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                param[@"CloudPay_Type"] = @"alipay";
                param[@"result"] = resultDic;
                [[NSNotificationCenter defaultCenter] postNotificationName:CLOUDPAY_RESULT object:nil userInfo:param];
            }];
        }else if([url.host isEqualToString:@"catering.yonyou.com"]){
            return [WXApi handleOpenUniversalLink:userActivity delegate:[CloudPay defaultManager]];
            
        }
        return true;
    }
    return false;
}

#pragma mark ---WXApiDelegate
-(void)onResp:(BaseResp *)resp{
    if([resp isKindOfClass:[PayResp class]]){
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        param[@"CloudPay_Type"] = @"weXin";
        param[@"result"] = resp;
        [[NSNotificationCenter defaultCenter] postNotificationName:CLOUDPAY_RESULT object:nil userInfo:param];
    }
    
}
@end
