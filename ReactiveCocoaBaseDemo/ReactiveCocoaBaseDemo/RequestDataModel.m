//
//  RequestDataModel.m
//  ReactiveCocoaBaseDemo
//
//  Created by Zhuge_Magic on 2016/12/16.
//  Copyright © 2016年 Magic. All rights reserved.
//

#import "RequestDataModel.h"
#import "AFNetworking.h"
#import "Book.h"

@implementation RequestDataModel
- (instancetype)init
{
    if (self = [super init]) {
        [self baseSet];
    }return self;
}

- (void)baseSet
{
    _command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        
        // 网络请求API包装一层RACSignal以便订阅数据
        RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            // 处理数据请求
            AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
            
            [mgr GET:@"https://api.douban.com/v2/book/search" parameters:@{@"q":@"美女"} success:^(AFHTTPRequestOperation * _Nonnull operation, NSDictionary * _Nonnull responseObject) {
                // 请求成功的时候调用
                ZGLog(@"success");
                
                // 数据处理
                NSArray *dictArr = responseObject[@"books"];
                
                NSArray *modelArr = [[dictArr.rac_sequence map:^id(id value) {
                    
                    return [Book bookWithDict:value];
                }] array];
                
                
                // 发送最终数据
                [subscriber sendNext:modelArr];
                
                
            } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                
            }];
            
            return nil;
        }];
        return signal;
    }];
}
@end
