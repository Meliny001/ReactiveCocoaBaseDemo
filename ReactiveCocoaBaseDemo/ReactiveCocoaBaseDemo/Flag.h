//
//  Flag.h
//  ReactiveCocoaBaseDemo
//
//  Created by Magic on 2016/12/16.
//  Copyright © 2016年 Magic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Flag : NSObject
@property(nonatomic,copy)NSString * icon;
@property(nonatomic,copy)NSString * name;
+ (instancetype)flagWithDict:(NSDictionary *)dict;
@end
