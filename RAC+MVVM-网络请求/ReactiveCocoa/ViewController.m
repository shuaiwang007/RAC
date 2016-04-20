//
//  ViewController.m
//  ReactiveCocoa
//
//  Created by Mr.Wang on 16/4/19.
//  Copyright © 2016年 Mr.wang. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveCocoa.h"
#import "RACReturnSignal.h"
#import "RequestViewModel.h"

@interface ViewController ()
// 请求视图模型
@property(nonatomic, strong)RequestViewModel *requestVM;

@end

@implementation ViewController

- (RequestViewModel *)requestVM {
    if (!_requestVM) {
        _requestVM = [[RequestViewModel alloc] init];
    }
    return _requestVM;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // GET  https://api.douban.com/v2/book/search
    
    // 发送请求
   RACSignal *signal = [self.requestVM.requestCommand execute:nil];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

