//
//  ViewController.m
//  ReactiveCocoaBaseDemo
//
//  Created by Zhuge_Mac on 16/12/15.
//  Copyright © 2016年 Magic. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveCocoa.h"
#import "ZGView.h"
#import "Flag.h"
#import "RACReturnSignal.h"
#import "RequestDataModel.h"

@interface ViewController ()

@property (nonatomic,strong) id<RACSubscriber> subscriber;

@property (weak, nonatomic) IBOutlet ZGView *disView;
@property(nonatomic,strong)Flag * flag;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextField *textFieldB;

@property(nonatomic,strong)RequestDataModel * dataModel;

@end

@implementation ViewController
- (RequestDataModel *)dataModel
{
    if (!_dataModel) {
        _dataModel = [[RequestDataModel alloc]init];
    }return _dataModel;
}
- (Flag *)flag
{
    if (!_flag) {
        _flag = [[Flag alloc]init];
        _flag.name = @"1";
    }return _flag;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self test20];
}

#pragma mark RACSignal
- (void)test1
{
    // 1.创建信号
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        // 3.订阅后进入block->sendNext
        [subscriber sendNext:@"123"];
        return nil;
    }];
    // 2.订阅信号
    [signal subscribeNext:^(id x) {
        // 4.发送了数据后进入block
        NSLog(@"%@",x);
    }];
}

#pragma mark RACDisposable/信号的主动取消
- (void)test2
{
    // 1.创建信号
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        _subscriber = subscriber;
        // 3.订阅后进入block->sendNext
        [subscriber sendNext:@"123"];
        return
        // 信号默认自动取消
        [RACDisposable disposableWithBlock:^{
            NSLog(@"信号被取消了");//6.清空资源
        }];
    }];
    // 2.订阅信号
    RACDisposable * disposable = [signal subscribeNext:^(id x) {
        // 4.发送了数据后进入block
        NSLog(@"%@",x);
    }];
    
    // 5.取消信号
    [disposable dispose];
}

#pragma mark RACSubject
- (void)test3
{
    // RACSubject 既能订阅也能发送信号
    // 创建订阅者
    RACSubject * subject = [RACSubject subject];
    
    // 订阅信号
    [subject subscribeNext:^(id x) {
        NSLog(@"订阅者1:%@",x);
    }];
    [subject subscribeNext:^(id x) {
        NSLog(@"订阅者2:%@",x);
    }];
    
    // 发送信号
    [subject sendNext:@"123"];
    
}

#pragma mark RACReplaySubject
- (void)test4
{
    // RACReplaySubject可以先发送信号(保存)->订阅的时候 取值
    RACReplaySubject * subject = [RACReplaySubject subject];
    
    [subject sendNext:@"111"];
    
    [subject subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark RAC代替代理
- (void)test5
{
    [self.disView.subject subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark RAC集合RACTuple/RACSequence
- (void)test6_1
{
    RACTuple * tuple = [RACTuple tupleWithObjectsFromArray:@[@"1",@"2",@3]];
    NSLog(@"%@",tuple[2]);
}
- (void)test6_2
{
    // 将集合转为信号
    NSArray * arr = @[@"1",@"2",@"3"];
    [arr.rac_sequence.signal subscribeNext:^(id x) {
//        NSLog(@"%@",x);
    }];
    
    NSDictionary * dict = @{@"key1":@"value1",@"key2":@"value2",@"key3":@"value3"};
    
    [dict.rac_sequence.signal subscribeNext:^(RACTuple * tuple) {
//        ZGLog(@"%@_%@",tuple[0],tuple[1]);
        
        RACTupleUnpack(NSString * key,NSString * value) = tuple;
        
        ZGLog(@"%@-%@",key,value);
    }];
}
- (void)test6_3
{
    // 解析数据
    NSString * path = [[NSBundle mainBundle]pathForResource:@"flags.plist" ofType:nil];
    NSArray * arr = [NSArray arrayWithContentsOfFile:path];
    
    // 映射
    NSArray * targetArr = [[arr.rac_sequence map:^Flag *(NSDictionary * value) {
        return [Flag flagWithDict:value];
    }] array];
    ZGLog(@"%@",targetArr);
}

#pragma mark 代理
- (void)test7
{
    [[self.disView rac_signalForSelector:NSSelectorFromString(@"btnclicked:")] subscribeNext:^(id x) {
        ZGLog(@"按钮被点击了");
    }];
}
#pragma mark KVO
- (void)test8
{
    [self.flag rac_observeKeyPath:@"name" options:NSKeyValueObservingOptionNew observer:nil block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent) {
        ZGLog(@"%@",value);
    }];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    static NSInteger num = 0;
    num ++;
    self.flag.name = [NSString stringWithFormat:@"name:%zi",num];
}
#pragma mark 通知
- (void)test9
{
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillChangeFrameNotification object:nil]subscribeNext:^(id x) {
        ZGLog(@"%@",x);
    }];
}
#pragma mark 监听事件
- (void)test10
{
    [[self.btn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        ZGLog(@"%@",x);
    }];
}
#pragma mark 文本框
- (void)test11
{
    [[self.textField rac_textSignal]subscribeNext:^(id x) {
        ZGLog(@"%@",x);
    }];
}

#pragma mark liftSelector
- (void)test12
{
    // hot
    RACSignal * hotSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"下载热销数据"];
        return nil;
    }];
    // new
    RACSignal * newSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"下载最新数据"];
        return nil;
    }];
    
    // 两个信号均发送完成时刷新UI
    [self rac_liftSelector:@selector(updateUIWithHotData:newData:) withSignals:hotSignal,newSignal, nil];
}
- (void)updateUIWithHotData:(NSString *)hotData newData:(NSString *)newData
{
    ZGLog(@"%@-%@",hotData,newData);
}

#pragma mark RAC常用宏
- (void)test13
{
    // RACTuplePack
    RACTuple * tuple = RACTuplePack(@"1",@3);
    ZGLog(@"%@",tuple[0]);
    
    // RACObserve
    [RACObserve(self.flag, name) subscribeNext:^(id x) {
        ZGLog(@"%@",x);
    }];
    
    // RAC 给self.flag的name属性绑定textField.text信号
    RAC(self.flag,name) = self.textField.rac_textSignal;
    
    // @weakify(...) @strongify(...) 解决block循环引用问题

}

#pragma mark RACMulticastConnection
- (void)test14
{
    // 业务场景:一个信号多次订阅,解决每次订阅都请求一次数据
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        ZGLog(@"请求数据");
        [subscriber sendNext:@"发送数据"];
        return nil;
    }];
    
    // 转换
//    RACMulticastConnection * connection = [signal publish];
    RACMulticastConnection * connection = [signal multicast:[RACReplaySubject subject]];// 信号可先发送
    
    // 订阅
    [connection.signal subscribeNext:^(id x) {
        ZGLog(@"订阅者1:%@",x);
    }];
    [connection.signal subscribeNext:^(id x) {
        ZGLog(@"订阅者2:%@",x);
    }];
    
    // 链接
    [connection connect];//RACReplaySubject可先链接
    
}

#pragma mark RACCommand(专门处理事件类型信号)
- (void)test15
{
    // RACCommand 发送一个指令,在接收到指令后处理业务逻辑(可监听指令处理状态)
    RACCommand * command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        
        // 传入命令
        ZGLog(@"%@",input);
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            // 执行命令产生的数据
            [subscriber sendNext:@"执行命令产生的数据"];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    
    // 发送命令
    // 方式1
//    [[command execute:@"1"] subscribeNext:^(id x) {
//        ZGLog(@"%@",x);
//    }];
    
    // 方式2(信号中的信号)
//    [command.executionSignals subscribeNext:^(id x) {
//        [x subscribeNext:^(id x) {
//            ZGLog(@"%@",x);
//        }];
//    }];
    //switchToLatest拿到信号中的信号
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        ZGLog(@"%@",x);
    }];
    
    // 查看执行状态
    [command.executing subscribeNext:^(id x) {
        if ([x boolValue] == YES)
        {
            ZGLog(@"正在执行");
        }else
        {
            ZGLog(@"执行开始/完毕");// 需主动发送完毕
        }
    }];
    
    [command execute:@"2"];
}

#pragma mark RAC核心方法bind
- (void)test16
{
    // 创建信号
    RACSubject * originalSiganl = [RACSubject subject];
    
    // 绑定信号
    RACSignal * bindSiganl = [originalSiganl bind:^RACStreamBindBlock{
       
        return ^RACSignal *(id value, BOOL *stop)
        {
            // value原始信息
            ZGLog(@"原始信息:%@",value);
            value = [NSString stringWithFormat:@"convert:%@",value];
            
            return [RACReturnSignal return:value];
        };
    }];
    
    // 订阅信号
    [bindSiganl subscribeNext:^(id x) {
        ZGLog(@"%@",x);
    }];
    
    // 发送数据
    [originalSiganl sendNext:@"111"];
}

#pragma mark 映射
- (void)test17_1
{
    // flattenMap信号中的信号
    RACSubject * subject = [RACSubject subject];
    
    RACSignal * bindSiganl = [subject flattenMap:^RACStream *(id value) {
        
        value = [NSString stringWithFormat:@"FlattenMap:%@",value];
        return [RACReturnSignal return:value];
    }];
    
    [bindSiganl subscribeNext:^(id x) {
        ZGLog(@"%@",x);
    }];
    
    [subject sendNext:@"111"];
}

- (void)test17_2
{
    // map 基本信号
    RACSubject * subject = [RACSubject subject];
    
    RACSignal * bindSiganl = [subject map:^id(id value) {
        
        value = [NSString stringWithFormat:@"Map:%@",value];
        return value;
    }];
    [bindSiganl subscribeNext:^(id x) {
        ZGLog(@"%@",x);
    }];
    
    [subject sendNext:@"111"];
}
#pragma mark RAC信号组合
- (void)test18_1
{
    // concat 应用场景:A完成->B开始
    RACSignal * signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        ZGLog(@"发送A信号数据");
        [subscriber sendNext:@"信号A"];
        
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal * signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        ZGLog(@"发送B信号数据");
        [subscriber sendNext:@"信号B"];
        return nil;
    }];
    
    // A信号完成后 信号B才发送执行
    RACSignal * signal = [signalA concat:signalB];
    
    [signal subscribeNext:^(id x) {
        ZGLog(@"%@",x);
    }];

}
- (void)test18_2
{
    // then 信号A完成执行信号B(忽略了信号A的值)
    RACSignal * signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        ZGLog(@"发送A信号数据");
        [subscriber sendNext:@"信号A"];
        
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal * signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        ZGLog(@"发送B信号数据");
        [subscriber sendNext:@"信号B"];
        return nil;
    }];
    
    RACSignal * signal = [signalA then:^RACSignal *{
        return signalB;
    }];
    
    [signal subscribeNext:^(id x) {
        ZGLog(@"%@",x);
    }];
}
- (void)test18_3
{
    // merge任何一个信号发送了数据均能订阅

    RACSubject * signalA = [RACSubject subject];
    RACSubject * signalB = [RACSubject subject];
    
    RACSignal * signal = [signalA merge:signalB];
    [signal subscribeNext:^(id x) {
        ZGLog(@"%@",x);
    }];
    
    [signalB sendNext:@"信号B"];
    [signalA sendNext:@"信号A"];

}
- (void)test18_4
{
    // zipWith 多个信号均发送数据时才执行
    RACSubject * signalA = [RACSubject subject];
    RACSubject * signalB = [RACSubject subject];
    
    RACSignal * signal = [signalA zipWith:signalB];
    [signal subscribeNext:^(id x) {
        ZGLog(@"%@",x);
    }];
    
    [signalB sendNext:@"信号B"];
//    [signalA sendNext:@"信号A"];
}
- (void)test18_5
{
    // combineLatest 信号组合后满足业务条件后订阅成功
    RACSignal * signal = [RACSignal combineLatest:@[self.textField.rac_textSignal,self.textFieldB.rac_textSignal] reduce:^id(NSString * textA,NSString * textB){
        
        return @(textA.length && textB.length);
    }];
    
    [signal subscribeNext:^(id x) {
       
        if ([x boolValue] == YES) {
            ZGLog(@"都有值啦");
        }
    }];
}

#pragma mark 信号的过滤
- (void)test19_1
{
    // filter满足业务条件后订阅成功
    [[self.textField.rac_textSignal filter:^BOOL(NSString * value) {
        
        return value.length >3;
    }] subscribeNext:^(id x) {
        
        ZGLog(@"%@",x);
    }];
}
- (void)test19_2
{
    // ignore 忽略部分值
    RACSubject * subject = [RACSubject subject];
    
    RACSignal * siganl = [subject ignore:@"1"];
    
    [siganl subscribeNext:^(id x) {
        ZGLog(@"%@",x);
    }];
    [subject sendNext:@"12"];
    
}
- (void)test19_3
{
    // 信号的截取
    RACSubject * subject = [RACSubject subject];
    RACSubject * subjectB = [RACSubject subject];
    
#if 0
    [[subject takeLast:2]subscribeNext:^(id x) {
        ZGLog(@"%@",x);
    }];
#endif
    [[subject takeUntil:subjectB]subscribeNext:^(id x) {
        ZGLog(@"%@",x);
    }];
    
    [subject sendNext:@1];
    [subjectB sendCompleted];// 信号B完成不再订阅
    [subject sendNext:@2];
    [subject sendNext:@3];
   
}
- (void)test19_4
{
    // distinctUntilChanged 遇到不同值得时候才会订阅到
    RACSubject * subject = [RACSubject subject];
    [[subject distinctUntilChanged] subscribeNext:^(id x) {
        ZGLog(@"%@",x);
    }];
    [subject sendNext:@1];
    [subject sendNext:@1];
    [subject sendNext:@"2"];
}
- (void)test19_5
{
    // skip 跳过前面多少个无用值后才能订阅到
    RACSubject * subject = [RACSubject subject];
    [[subject skip:3]subscribeNext:^(id x) {
        ZGLog(@"%@",x);
    }];
    [subject sendNext:@0];
    [subject sendNext:@1];
    [subject sendNext:@"2"];
    [subject sendNext:@"3"];
}
#pragma mark 模拟网络请求
- (void)test20
{
    [[self.dataModel.command execute:@"requestdata"] subscribeNext:^(NSArray * arr) {
        ZGLog(@"%@",arr.firstObject);
    }];
}
@end
