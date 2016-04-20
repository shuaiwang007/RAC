//
//  RequestViewModel.h
//  ReactiveCocoa
//
//  Created by Mr.Wang on 16/4/20.
//  Copyright © 2016年 yz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"
#import "AFNetworking.h"

@interface RequestViewModel : NSObject
@property(nonatomic, strong, readonly)RACCommand *requestCommand;
@end
