//
//  ModalViewController.m
//  ReactiveCocoaBaseDemo
//
//  Created by Magic on 2016/12/16.
//  Copyright © 2016年 Magic. All rights reserved.
//

#import "ModalViewController.h"
#import "ReactiveCocoa.h"

@interface ModalViewController ()

@property(nonatomic,strong) RACSignal * signal;
@end

@implementation ModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self);
    
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // block中保证不被销毁
        @strongify(self);
        
        ZGLog(@"%@",self);
        return nil;
    }];
    _signal = signal;// 无法释放
}
- (IBAction)dissmissClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)dealloc
{
    ZGLog(@"");
}
@end
