//
//  ServerManager.h
//  APITest
//
//  Created by Vasilii on 29.07.17.
//  Copyright © 2017 Vasilii Burenkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface ServerManager : NSObject

@property (strong, nonatomic, readonly) User *currentUser; //пользоваетль который залогигин, readonly чтобы можно было изменить


//синглтон
+ (ServerManager *) sharedManager;

- (void) authorizeUser:(void(^)(User * user)) complection;

- (void) getUser:(NSString *) userID
       onSuccess:(void(^)(User *user)) success
       onFailure:(void(^)(NSError *error, NSInteger statusCode)) falure;

// получаем друзей и записываем в блок если успех (функция делаяется мной)
- (void) getFriendsWithOffset:(NSInteger) offset
                        count:(NSInteger) count
                    onSuccess:(void(^)(NSArray *friends)) success
                    onFailure:(void(^)(NSError *error, NSInteger statusCode)) falure;

@end
