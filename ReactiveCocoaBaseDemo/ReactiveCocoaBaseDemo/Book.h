//
//  Book.h
//  ReactiveCocoaBaseDemo
//
//  Created by Zhuge_Magic on 2016/12/16.
//  Copyright © 2016年 Magic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSString *title;

+ (instancetype)bookWithDict:(NSDictionary *)dict;
@end
