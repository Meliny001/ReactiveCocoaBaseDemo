//
//  MVVMViewController.m
//  ReactiveCocoaBaseDemo
//
//  Created by Zhuge_Magic on 2016/12/16.
//  Copyright © 2016年 Magic. All rights reserved.
//

#import "MVVMViewController.h"
#import "ReactiveCocoa.h"
#import "LoginViewManager.h"

@interface MVVMViewController ()
@property (weak, nonatomic) IBOutlet UITextField *account;

@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property(nonatomic,strong)LoginViewManager * loginViewManager;

@end

@implementation MVVMViewController
- (LoginViewManager *)loginViewManager
{
    if (!_loginViewManager) {
        _loginViewManager = [[LoginViewManager alloc]init];
    }return _loginViewManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 绑定信号
    [self bindSiganlToViewManager];
    
    // 处理登录事件
    [self dealEvent];
    
}
- (void)bindSiganlToViewManager
{
    RAC(self.loginViewManager,account) = self.account.rac_textSignal;
    RAC(self.loginViewManager,password) = self.password.rac_textSignal;
}
- (void)dealEvent
{
    // 是否允许登录点击
    RAC(self.loginBtn,enabled) = self.loginViewManager.loginEnable;
    
    [[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.loginViewManager.command execute:@"login clicked"];
    }];
}

- (IBAction)dissmissClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    ZGLog(@"");
}

- (void)temp
{
    // 文本框业务逻辑
    RACSignal * signal = [RACSignal combineLatest:@[self.account.rac_textSignal,self.password.rac_textSignal] reduce:^id(NSString * account,NSString * password){
        
        return @(account.length>5 && password.length>5);
    }];
    
    RAC(self.loginBtn,enabled) = signal;
    
    // 创建命令信号
    RACCommand * command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        ZGLog(@"%@",input);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            // 请求数据
            ZGLog(@"正核实账号密码");
            
            [subscriber sendNext:@"可以登录啦"];
            
            return nil;
        }];
    }];
    
    // 订阅登录请求结果
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        ZGLog(@"%@",x);
    }];
    
    [[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [command execute:@"登录请求"];
    }];
}
@end
