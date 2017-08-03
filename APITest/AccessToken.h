//
//  AccessToken.h
//  APITest
//
//  Created by Vasilii on 31.07.17.
//  Copyright © 2017 Vasilii Burenkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccessToken : NSObject

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSDate *expirationDate;
@property (nonatomic, strong) NSString *userID;

@end
