//
//  RequestViewModel.m
//  ReactiveCocoa
//
//  Created by Mr.Wang on 16/4/20.
//  Copyright © 2016年 yz. All rights reserved.
//

#import "RequestViewModel.h"

@implementation RequestViewModel

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    _requestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        // 执行命令
        // 发送请求
        // 创建信号 把发送请求的代码包装到信号里面。
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            [manager GET:@"https://api.douban.com/v2/book/search" parameters:@{@"q":@"帅哥"} progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [responseObject writeToFile:@"/Users/wang/Desktop/plist/sg.plist" atomically:YES];
                // 请求成功的时候调用
//                NSLog(@"%@", responseObject);
                // 在这里就可以拿到数据，将其丢出去
                NSArray *dictArr = responseObject[@"books"];
                // 便利books字典数组，将其映射为模型数组
                NSArray *modelArr = [[dictArr.rac_sequence map:^id(id value) {
                    return [[NSObject alloc] init];
                }] array];
                
                [subscriber sendNext:modelArr];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
            }];
            return nil;
        }];
        
        return signal;  // 模型数组
    }];
    
}
@end
