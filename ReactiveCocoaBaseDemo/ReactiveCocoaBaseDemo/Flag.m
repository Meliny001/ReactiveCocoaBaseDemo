//
//  Flag.m
//  ReactiveCocoaBaseDemo
//
//  Created by Magic on 2016/12/16.
//  Copyright © 2016年 Magic. All rights reserved.
//

#import "Flag.h"

@implementation Flag
+ (instancetype)flagWithDict:(NSDictionary *)dict
{
    Flag * flag = [[Flag alloc]init];
    [flag setValuesForKeysWithDictionary:dict];
    return flag;
}
@end
