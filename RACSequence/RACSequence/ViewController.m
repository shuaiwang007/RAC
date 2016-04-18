//
//  ViewController.m
//  RACSequence
//
//  Created by 王帅 on 16/4/18.
//  Copyright © 2016年 Mr.wang. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveCocoa.h"

@interface ViewController ()
@property(nonatomic, strong)NSArray *flags;

@end

@implementation ViewController

// 使用场景---： 可以快速高效的遍历数组和字典。

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self test1];
}

- (void)test1 {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"flags.plist" ofType:nil];
    NSArray *dictArr = [NSArray arrayWithContentsOfFile:path];
    [dictArr.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    } error:^(NSError *error) {
        NSLog(@"===error===");
    } completed:^{
        NSLog(@"ok---完毕");
    }];

}

- (void)test2 {
    
//    NSDictionary *dict = @{@"key":@1, @"key2":@2};
//    [dict.rac_sequence.signal subscribeNext:^(id x) {
//        NSLog(@"%@", x);
//        NSString *key = x[0];
//        NSString *value = x[1];
//        // RACTupleUnpack宏：专门用来解析元组
//        // RACTupleUnpack 等会右边：需要解析的元组 宏的参数，填解析的什么样数据
//        // 元组里面有几个值，宏的参数就必须填几个
//        RACTupleUnpack(NSString *key, NSString *value) = x;
//        NSLog(@"%@ %@", key, value);
//    } error:^(NSError *error) {
//        NSLog(@"===error");
//    } completed:^{
//        NSLog(@"-----ok---完毕");
//    }];
}







/**
 *  点击屏幕开始字典数组转模型数组。开发中可以快速高效的遍历数组和字典、字典转模型等
 */



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
