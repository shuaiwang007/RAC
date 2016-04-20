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

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self skip];
}

// 跳跃 ： 如下，skip传入2 跳过前面两个值
// 实际用处： 在实际开发中比如 后台返回的数据前面几个没用，我们想跳跃过去，便可以用skip
- (void)skip {
    RACSubject *subject = [RACSubject subject];
    [[subject skip:2] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
}

//distinctUntilChanged:-- 如果当前的值跟上一次的值一样，就不会被订阅到
- (void)distinctUntilChanged {
    RACSubject *subject = [RACSubject subject];
    [[subject distinctUntilChanged] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@2]; // 不会被订阅
}

// take:可以屏蔽一些值,去前面几个值---这里take为2 则只拿到前两个值
- (void)take {
    RACSubject *subject = [RACSubject subject];
    [[subject take:2] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
}

//takeLast:和take的用法一样，不过他取的是最后的几个值，如下，则取的是最后两个值
//注意点:takeLast 一定要调用sendCompleted，告诉他发送完成了，这样才能取到最后的几个值
- (void)takeLast {
    RACSubject *subject = [RACSubject subject];
    [[subject takeLast:2] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
    [subject sendCompleted];
}

// takeUntil:---给takeUntil传的是哪个信号，那么当这个信号发送信号或sendCompleted，就不能再接受源信号的内容了。
- (void)takeUntil {
    RACSubject *subject = [RACSubject subject];
    RACSubject *subject2 = [RACSubject subject];
    [[subject takeUntil:subject2] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject2 sendNext:@3];  // 1
//    [subject2 sendCompleted]; // 或2
    [subject sendNext:@4];
}

// ignore: 忽略掉一些值
- (void)ignore {
    //ignore:忽略一些值
    //ignoreValues:表示忽略所有的值
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    // 2.忽略一些值
    RACSignal *ignoreSignal = [subject ignore:@2]; // ignoreValues:表示忽略所有的值
    // 3.订阅信号
    [ignoreSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 4.发送数据
    [subject sendNext:@2];

}

// 一般和文本框一起用，添加过滤条件
- (void)fliter {
    // 只有当文本框的内容长度大于5，才获取文本框里的内容
    [[self.textField.rac_textSignal filter:^BOOL(id value) {
        // value 源信号的内容
        return [value length] > 5;
        // 返回值 就是过滤条件。只有满足这个条件才能获取到内容
    }] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
