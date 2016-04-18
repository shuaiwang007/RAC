//
//  ViewController.m
//  RACMulticastConnection
//
//  Created by 王帅 on 16/4/18.
//  Copyright © 2016年 Mr.wang. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveCocoa.h"

@interface ViewController ()

@end

@implementation ViewController

/**
 *  当有多个订阅者，但是我们只想发送一个信号的时候怎么办？这时我们就可以用RACMulticastConnection，来实现。代码示例如下
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self test2];
    
}

- (void)test // 普通写法, 这样的缺点是：没订阅一次信号就得重新创建并发送请求，这样很不友好
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // didSubscribeblock中的代码都统称为副作用。
        // 发送请求---比如afn
        NSLog(@"发送请求啦");
        // 发送信号
        [subscriber sendNext:@"ws"];
        return nil;
    }];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];

}

- (void)test2 { // 比较好的做法。 使用RACMulticastConnection，无论有多少个订阅者，无论订阅多少次，我只发送一个。
    // 1.发送请求，用一个信号内包装，不管有多少个订阅者，只想发一次请求
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"发送请求啦");
        // 发送信号
        [subscriber sendNext:@"ws"];
        return nil;
    }];
    //2. 创建连接类
    RACMulticastConnection *connection = [signal publish];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    [connection.signal subscribeNext:^(id x) {
         NSLog(@"%@", x);
    }];
    [connection.signal subscribeNext:^(id x) {
         NSLog(@"%@", x);
    }];
    //3. 连接。只有连接了才会把信号源变为热信号
    [connection connect];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
