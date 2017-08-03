//
//  ServerManager.m
//  APITest
//
//  Created by Vasilii on 29.07.17.
//  Copyright © 2017 Vasilii Burenkov. All rights reserved.
//

#import "ServerManager.h"
#import <AFNetworking/AFNetworking.h>
#import "User.h"
#import "LoginViewController.h"
#import "AccessToken.h"

@interface ServerManager()

@property (strong, nonatomic) AFHTTPSessionManager *requesOperationManager;
@property (strong, nonatomic) AccessToken *assessToken;

@end

@implementation ServerManager

+ (ServerManager *)sharedManager {
    
    static ServerManager *manager = nil;
    //вызываем один раз
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ServerManager alloc] init];
    });
    return manager;
}


- (id)init
{
    self = [super init];
    if (self) {
        
        NSURL *url = [NSURL URLWithString:@"https://api.vk.com/method/"];
        self.requesOperationManager = [[AFHTTPSessionManager manager] initWithBaseURL:url];
    }
    return self;
}

- (void)authorizeUser:(void (^)(User *))complection {
    LoginViewController *vc = [[LoginViewController alloc] initWithCompletionBlock:^(AccessToken *token) {
        self.assessToken = token;
        
        if (token) {
            
            [self getUser:self.assessToken.userID
                onSuccess:^(User *user) {
                    if(complection) {
                        complection(user);
                    }
                }
                onFailure:^(NSError *error, NSInteger statusCode) {
                    if(complection) {
                        complection(nil);
                    }
                }];
            
        } else if(complection) {
            complection(nil);
        }

    }];
    
    //показываем контроллер
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    UIViewController *mainVC =  [[[UIApplication sharedApplication] windows] firstObject].rootViewController;

  // UIViewController* mainVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    
    [mainVC presentViewController:nav
                         animated:YES
                       completion:nil];
}

- (void) getUser:(NSString *) userID
       onSuccess:(void(^)(User *user)) success
       onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {

    
    NSDictionary* params = [NSDictionary
                            dictionaryWithObjectsAndKeys:
                            userID, @"user_ids",
                            @"photo_50", @"fields",
                            @"nom", @"name_case", nil];
    
    
    [self.requesOperationManager GET:@"users.get"
                  parameters:params
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary* responseObject) {
                         
                         
                         NSArray *dictsArray = [responseObject objectForKey:@"response"];
                         
                         if ([dictsArray count] > 0) {
                             User *user = [[User alloc] initWithServerResponse:[dictsArray firstObject]];
                             if (success) {
                                 success(user);
                             }
                         } else {
                             if (failure) {
                                 failure(nil, [(NSHTTPURLResponse*)[task response] statusCode]);
                             }
                         }

                         
                     } failure:^(NSURLSessionTask *operation, NSError *error) {
                         NSLog(@"Error: %@", error);
                         
                     }];
    

    
}


- (void) getFriendsWithOffset:(NSInteger) offset // смещение
                        count:(NSInteger) count  //количество
                    onSuccess:(void(^)(NSArray *friends)) success
                    onFailure:(void(^)(NSError *error, NSInteger statusCode)) falure {
    
    //@(count) сокращение для NSNumber
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"263292877", @"user_id",
                            @"name",      @"order",
                            @(count),     @"count",
                            @(offset),    @"offset",
                            @"photo_50",  @"fields",
                            @"non",       @"name_case",
                            nil];
    
    //AFHTTPSessionManager *manager = [AFHTTPSessionManager manager] initWithBaseURL:<#(nullable NSURL *)#>;
    
    [self.requesOperationManager
     GET:@"friends.get"
     parameters:params
     progress:nil
     success:^(NSURLSessionTask *task, NSDictionary *responseObject) {
        NSLog(@"JSON: %@", responseObject);
         
         NSArray *dictsArray = [responseObject objectForKey:@"response"];
         
         NSMutableArray *objectArray = [NSMutableArray array];
         
         for (NSDictionary *dict in dictsArray) {
             User *user = [[User alloc] initWithServerResponse:dict];
             [objectArray addObject:user];
         }
         
         if (success) {
             success(objectArray);
         }
         
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
    
}

@end
