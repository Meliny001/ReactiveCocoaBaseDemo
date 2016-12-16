//
//  LoginViewManager.m
//  ReactiveCocoaBaseDemo
//
//  Created by Zhuge_Magic on 2016/12/16.
//  Copyright © 2016年 Magic. All rights reserved.
//

#import "LoginViewManager.h"

@implementation LoginViewManager
- (instancetype)init
{
    if (self = [super init]) {
        [self baseSet];
    }
    return self;
}
- (void)baseSet
{
    // 是否允许登录点击
    _loginEnable = [RACSignal combineLatest:@[RACObserve(self, account),RACObserve(self, password)] reduce:^id(NSString * account,NSString * password){
        return @(account.length>3 && password.length>3);
    }];
    
    _command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        ZGLog(@"%@",input);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            //
            ZGLog(@"登录请求中...");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [subscriber sendNext:@"登录请求成功"];
                [subscriber sendCompleted];
            });
            return nil;
        }];
    }];
    
    // 进度
    [[_command.executing skip:1] subscribeNext:^(id x) {
        if ([x boolValue] == YES) {
            ZGLog(@"logining...");
        }else
        {
            ZGLog(@"success");
        }
    }];
    
    // 订阅是否成功
    [_command.executionSignals.switchToLatest subscribeNext:^(id x) {
       
        ZGLog(@"%@",x);
    }];
}

@end
