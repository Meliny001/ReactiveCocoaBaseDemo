//
//  RequestDataModel.h
//  ReactiveCocoaBaseDemo
//
//  Created by Zhuge_Magic on 2016/12/16.
//  Copyright © 2016年 Magic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"

@interface RequestDataModel : NSObject

@property(nonatomic,strong,readonly)RACCommand * command;

@end
