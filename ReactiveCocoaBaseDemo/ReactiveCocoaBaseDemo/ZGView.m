//
//  ZGView.m
//  ReactiveCocoaBaseDemo
//
//  Created by Magic on 2016/12/16.
//  Copyright © 2016年 Magic. All rights reserved.
//

#import "ZGView.h"


@implementation ZGView

- (RACSubject *)subject
{
    if (!_subject) {
        _subject = [RACSubject subject];
    }return _subject;
}

- (IBAction)btnclicked:(id)sender
{
    [self.subject sendNext:@"按钮被点击了"];
}

@end
