//
//  LoginViewManager.h
//  ReactiveCocoaBaseDemo
//
//  Created by Zhuge_Magic on 2016/12/16.
//  Copyright © 2016年 Magic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"

@interface LoginViewManager : NSObject

@property(nonatomic,copy)NSString * account;
@property(nonatomic,copy)NSString * password;

@property(nonatomic,strong,readonly)RACSignal * loginEnable;/**<是否允许点击登录*/
@property(nonatomic,strong,readonly)RACCommand * command;/**<登录命令信号*/

@end
