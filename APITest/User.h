//
//  User.h
//  APITest
//
//  Created by Vasilii on 29.07.17.
//  Copyright © 2017 Vasilii Burenkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSURL *imageURL;

-(id) initWithServerResponse:(NSDictionary *) responseObject;

@end
