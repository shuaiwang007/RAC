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

//**RAC-bind**

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    // 2.绑定信号
   RACSignal *bindSignal = [subject bind:^RACStreamBindBlock{
       // block调用时刻：只要绑定信号订阅就会调用。不做什么事情，
        return ^RACSignal *(id value, BOOL *stop){
            // 一般在这个block中做事 ，发数据的时候会来到这个block。
            // 只要源信号（subject）发送数据，就会调用block
            // block作用：处理源信号内容
            // value:源信号发送的内容，
            value = @3; // 如果在这里把value的值改了，那么订阅绑定信号的值即44行的x就变了
            NSLog(@"接受到源信号的内容：%@", value);
            //返回信号，不能为nil,如果非要返回空---则empty或 alloc init。
        return [RACReturnSignal return:value]; // 把返回的值包装成信号
        };
    }];

    // 3.订阅绑定信号
    [bindSignal subscribeNext:^(id x) {
        
        NSLog(@"接收到绑定信号处理完的信号:%@", x);
    }];
    // 4.发送信号
    [subject sendNext:@"123"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


                /*************************总结**********************/

// bind（绑定）的使用思想和Hook的一样---> 都是拦截API从而可以对数据进行操作，，而影响返回数据。
// 发送信号的时候会来到30行的block。在这个block里我们可以对数据进行一些操作，那么35行打印的value和订阅绑定信号后的value就会变了。变成什么样随你喜欢喽。




@end
