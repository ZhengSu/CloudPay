//
//  WKWebVC.m
//  Cloud-Pay
//
//  Created by 郑隋 on 2022/10/18.
//

#import "WKWebVC.h"
#import <WebKit/WebKit.h>
#import "CloudPay.h"
@interface WKWebVC ()
@property (nonatomic, strong) WKWebView *  webView;

@property (nonatomic, strong) NSString *payResulturl;

@end

@implementation WKWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.webView];
    
    [[CloudPay defaultManager] cloudPayWithWebview:self.webView success:^(NSString * _Nonnull resultUrl) {

        self.payResulturl = resultUrl;

    } failure:^(CloudPay_Status status) {

        if(status == CloudPay_WXAppUnInstalled){
            //提示用户 【请先安装微信】
        }else if(status == CloudPay_ALiPayAppUninstall){
            //提示用户 【请先安装支付宝】
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealPayResult:) name:CLOUDPAY_RESULT object:nil];
}
- (void)dealPayResult:(NSNotification *)noti{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.payResulturl]]];
}

- (WKWebView *)webView{
    if(_webView == nil){
        
        //创建网页配置对象
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://catering.uat.hhtdev.com/cloud-business-platform-mobile/#/mcashier/demo"]];
        [_webView loadRequest:request];
    }
    return _webView;
}

@end
