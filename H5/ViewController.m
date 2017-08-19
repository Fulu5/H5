//
//  ViewController.m
//  H5
//
//  Created by 曹曹 on 2017/8/19.
//  Copyright © 2017年 Macgx. All rights reserved.
//

#import "ViewController.h"
#import <WebViewJavascriptBridge.h>
#import "Macro.h"

@interface ViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView                 *webView;
@property (nonatomic, strong) WebViewJavascriptBridge   *webViewBridge;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configWebView]; // 1 配置 webView
    
    [self configWebViewBridge]; // 2.配置 bridge
    
    [self registerNativeFunctions]; // 注册 JS 调用的 Navive 功能
}

#pragma mark -

- (void)configWebView {
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal; // UIWebView 滚动的比较慢，这里设置为正常速度
    
    [self loadLocalHtml];
    
//    [self loadRemoteHtml];
    
}

- (void)configWebViewBridge {
    
    [WebViewJavascriptBridge enableLogging]; // 启用调试功能
    
    // 这里不要为UIWebView设置代理，因为在创建WebViewJavascriptBridge的时候，UIWebView的代理已经被赋值给了WebViewJavascriptBridge
    // 2 创建WebViewJavascriptBridge
    _webViewBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    
    // {setWebViewDelegate}这个方法，可以将UIWebView的代理，从_webViewBridge中再传递出来。
    // 所以如果你要在控制器中实现UIWebView的代理方法时，添加下面这样代码，否则可以不写。
    [_webViewBridge setWebViewDelegate:self];
}

#pragma mark - load html

- (void)loadRemoteHtml {
    NSURL *url = [NSURL URLWithString:@"http://192.168.1.5/test1"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

- (void)loadLocalHtml {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"WebViewJavascriptBridgeDemo" ofType:@"html"];
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

#pragma mark - JS Call Native

- (void)registerNativeFunctions {
    /**
     * 注册方法,该方法是JS调用OC使用到的,凭借方法名建立对应关系
     * data -- JS传递给OC的参数
     * responseCallback -- OC向JS反馈的回调方法
     */
    [_webViewBridge registerHandler:@"pushNewPage" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self pushNewViewController];
        NSLog(@"uPshNewPage: %@", data);
    }];
    [_webViewBridge registerHandler:@"popPage" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self popCurrentViewController];
        NSLog(@"PopPage: %@", data);
    }];
    [_webViewBridge registerHandler:@"deviceInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback([self deviceInfo]);
        NSLog(@"DeviceInfo: %@", data);
    }];
}

- (void)pushNewViewController {
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor redColor];
    [self.navigationController pushViewController:[UIViewController new] animated:YES];
}

- (void)popCurrentViewController {
    if (self.navigationController.viewControllers.count > 1) {
        NSLog(@"JS调用了pop");
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        NSLog(@"Now is in root view controller");
    }
}

- (NSDictionary *)deviceInfo {
    NSDictionary *dic = @{@"device"     : @"iphone_6_plus",
                          @"other_info" : @""};
    return dic;
}

#pragma mark - OC Call JS

- (void)requestJSCurrentURL {
    /**
     * 注册方法, 该方法是OC调用JS使用到的,凭借方法名建立对应关系,该语句会在程序运行时自动执行
     * data -- OC传递给JS的参数
     */
    [_webViewBridge callHandler:@"currentURL" data:nil responseCallback:^(id responseData) {
        NSLog(@"received response : %@", responseData);
    }];
}

- (void)requestJSAlertMessage {
    [_webViewBridge callHandler:@"alertMessage" data:nil responseCallback:^(id responseData) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:responseData[@"title"] message:responseData[@"message" ] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:confirm];
        [alertVC addAction:cancel];
        [self showViewController:alertVC sender:nil];
    }];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
//    CGFloat buttonW = 140;
//    CGFloat buttonH = 26;
//    CGRect crurlBtnFrame = CGRectMake(20,  SCREEN_HEIGHT - 100, buttonW, buttonH);
//    CGRect alertBtnFrame = CGRectMake(20 * 2 + buttonW, SCREEN_HEIGHT - 100, buttonW, buttonH);
//    [self addButtonWithFrame:crurlBtnFrame
//                       title:@"currentUrl"
//                      target:self
//                      action:@selector(requestJSCurrentURL)
//                   inWebView:(UIWebView *)webView ];
//    
//    [self addButtonWithFrame:alertBtnFrame
//                       title:@"alertMessage"
//                      target:self
//                      action:@selector(requestJSAlertMessage)
//                   inWebView:(UIWebView *)webView ];
    
    [self addMoreButtonsWithAutoLayout];
}

- (void)addButtonWithFrame:(CGRect)frame
                     title:(NSString *)title
                    target:(nullable id)target
                    action:(SEL)action
                 inWebView:(UIWebView *)webView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectZero;
    button.layer.cornerRadius = button.frame.size.height / 2.0 - 1;
    button.layer.masksToBounds = YES;
    button.layer.borderWidth = 1;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [webView addSubview:button];
}

- (void)addMoreButtonsWithAutoLayout {
    CGFloat buttonH = 26;
    UIButton *current = [UIButton buttonWithType:UIButtonTypeCustom];
    current.frame = CGRectZero;
    current.layer.borderWidth = 1;
    current.layer.cornerRadius = buttonH / 2.0 - 2;
    current.layer.masksToBounds = YES;
    [current setTitle:@"currentURL" forState:UIControlStateNormal];
    [current setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [current addTarget:self action:@selector(requestJSCurrentURL) forControlEvents:UIControlEventTouchUpInside];
    [self.webView addSubview:current];
    
    
    current.translatesAutoresizingMaskIntoConstraints = NO;
    [current.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20].active = YES;
    [current.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-40].active = YES;
    [current.heightAnchor constraintEqualToConstant:buttonH].active = YES;
    
    UIButton *message = [UIButton buttonWithType:UIButtonTypeCustom];
    message.frame = CGRectZero;
    message.layer.borderWidth = 1;
    message.layer.cornerRadius = buttonH / 2.0 - 2;
    message.layer.masksToBounds = YES;
    [message setTitle:@"alertMessagebutton" forState:UIControlStateNormal];
    [message setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [message addTarget:self action:@selector(requestJSAlertMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.webView addSubview:message];
    
    message.translatesAutoresizingMaskIntoConstraints = NO;
    [message.leadingAnchor constraintEqualToAnchor:current.trailingAnchor constant:20].active = YES;
    [message.bottomAnchor constraintEqualToAnchor:current.bottomAnchor].active = YES;
    [message.heightAnchor constraintEqualToConstant:buttonH].active = YES;
}

@end
