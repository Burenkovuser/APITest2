//
//  LoginViewController.m
//  APITest
//
//  Created by Vasilii on 31.07.17.
//  Copyright © 2017 Vasilii Burenkov. All rights reserved.
//

#import "LoginViewController.h"
#import "AccessToken.h"

@interface LoginViewController ()<UIWebViewDelegate>

@property (copy, nonatomic) LoginCompletionBlock completionBlock;
@property (weak, nonatomic) UIWebView *webView;

@end

@implementation LoginViewController

- (id) initWithCompletionBlock:(LoginCompletionBlock) completionBlock {

self = [super init];
if (self) {
    
    self.completionBlock = completionBlock;
}
return self;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // добавляем вебвью
    CGRect r = self.view.bounds;
    r.origin = CGPointZero;
    
    UIWebView *webview = [[UIWebView alloc] initWithFrame:r];
    
    webview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth ;
    
    [self.view addSubview:webview];
    
    self.webView = webview;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                          target:self
                                                                          action:@selector(actionCancel:)];
    [self.navigationItem setRightBarButtonItem:item animated:NO];
    
    self.navigationItem.title = @"Login";
    
    NSString* urlString =@"https://oauth.vk.com/authorize?"
                           "client_id=6131916&"
                           "display=mobile&"
                           "redirect_uri=https://oauth.vk.com/blank.html&"
                           "scope=139286&" // + 2 + 4 + 16 + 131072 + 8192
                           "response_type=token&"
                           "v=5.65&"
                           "state=123456&"
                           "revoke=1";//revoke удалить потом
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    
    webview.delegate = self;
    
    [webview loadRequest: request];
    
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    self.webView.delegate = nil;
}

#pragma mark - Actions

- (void) actionCancel:(UIBarButtonItem *) item {
    
    if (self.completionBlock) {
        self.completionBlock(nil);
    }
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}


#pragma mark - UIWebViewDelegete

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString* urlString = [request.URL absoluteString];
    
   //разбиваем на части приходящий объект
    
    //if ([[[request URL] host] isEqualToString:@"https://oauth.vk.com/blank.html&"]) {
    
    if ([urlString hasPrefix:@"https://oauth.vk.com/blank.html#access_token="]) {
        
        AccessToken * token = [[AccessToken alloc] init];
        
        NSString *query = [[request URL] description];
        
        NSArray *array = [query componentsSeparatedByString:@"#"];
        
        if ([array count] > 1) {
            query = [array lastObject];
        }
        
        NSArray *pairs = [query componentsSeparatedByString:@"&"];
        
        for (NSString* pair in pairs) {
            
            NSArray* values = [pair componentsSeparatedByString:@"="];
            
            if (values.count == 2) {
                
                NSString* key = [values firstObject];
                
                if ([key isEqualToString:@"access_token"]) {
                    
                    token.token = [values lastObject];
                    
                } else if ([key isEqualToString:@"expires_in"]) {
                    
                    NSString* intervalString = [values lastObject];
                    
                    NSTimeInterval interval = [intervalString doubleValue];
                    
                    NSDate* expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
                    
                    token.expirationDate = expirationDate;
                    
                } else if ([key isEqualToString:@"user_id"]) {
                    
                    //NSInteger userIdInt = [[values lastObject] intValue];
                    
                    //NSNumber* userIdVal = [NSNumber numberWithInteger:userIdInt];
                    
                    token.userID = [values lastObject];
                }
            }
        }
        self.webView.delegate = nil;
        
        if (self.completionBlock) {
            self.completionBlock(token);
        }
        
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
    
    
        return NO;
    }
    
   // NSLog(@"%@", [request URL]);
    return YES;
    
}

@end
