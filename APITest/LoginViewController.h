//
//  LoginViewController.h
//  APITest
//
//  Created by Vasilii on 31.07.17.
//  Copyright © 2017 Vasilii Burenkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AccessToken;

typedef void(^LoginCompletionBlock)(AccessToken *token);

@interface LoginViewController : UIViewController

- (id) initWithCompletionBlock:(LoginCompletionBlock) completionBlock;

@end
