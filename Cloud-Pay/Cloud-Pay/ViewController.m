//
//  ViewController.m
//  Cloud-Pay
//
//  Created by 郑隋 on 2022/10/18.
//

#import "ViewController.h"
#import "WKWebVC.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    payBtn.frame = CGRectMake(20, 100, self.view.frame.size.width - 40, 50);
    payBtn.backgroundColor = [UIColor lightGrayColor];
    [payBtn setTitle:@"去支付" forState:0];
    [payBtn addTarget:self action:@selector(payClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:payBtn];
}
- (void)payClick{
    [self.navigationController pushViewController:[WKWebVC new] animated:YES];
}

@end
