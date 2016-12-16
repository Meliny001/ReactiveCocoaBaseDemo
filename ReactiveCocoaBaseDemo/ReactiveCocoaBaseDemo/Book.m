//
//  Book.m
//  ReactiveCocoaBaseDemo
//
//  Created by Zhuge_Magic on 2016/12/16.
//  Copyright © 2016年 Magic. All rights reserved.
//

#import "Book.h"

@implementation Book
+ (instancetype)bookWithDict:(NSDictionary *)dict
{
    Book *book = [[Book alloc] init];
    
    book.title = dict[@"title"];
    book.subtitle = dict[@"subtitle"];
    return book;
}
- (NSString *)description
{
    return [NSString stringWithFormat:@"title:%@-subtitle:%@",_title,_subtitle];
}
@end
