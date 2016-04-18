//
//  TwoViewController.m
//  RAC-Notification
//
//  Created by 王帅 on 16/4/18.
//  Copyright © 2016年 Mr.wang. All rights reserved.
//

#import "TwoViewController.h"
#import "ViewController.h"

@interface TwoViewController ()
@property(nonatomic, copy)UIButton *button;

@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor brownColor];
    [self buildUI];
}
- (void)buildUI {
    
    self.button.frame = CGRectMake(50, 100, 50, 30);
    self.view.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:self.button];
}

#pragma mark---lazy loading
- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc] init];
        [_button setBackgroundColor:[UIColor grayColor]];
        [_button setTitle:@"pop" forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(btnOnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}
#pragma mark -- btnOnClick
- (void)btnOnClick {
    
    [self.subject sendNext:@"ws"];
    
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  总结：
 我们完全可以用RACSubject代替代理/通知，确实方便许多
 这里我们点击TwoViewController的pop的时候 将字符串"ws"传给了ViewController的button的title。
 步骤：
 // 1.创建信号
 RACSubject *subject = [RACSubject subject];
 
 // 2.订阅信号
 [subject subscribeNext:^(id x) {
 // block:当有数据发出的时候就会调用
 // block:处理数据
 NSLog(@"%@",x);
 }];
 
 // 3.发送信号
 [subject sendNext:value];
 **注意：~~**
 RACSubject和RACReplaySubject的区别
 RACSubject必须要先订阅信号之后才能发送信号， 而RACReplaySubject可以先发送信号后订阅.
 RACSubject 代码中体现为：先走TwoViewController的sendNext，后走ViewController的subscribeNext订阅
 RACReplaySubject 代码中体现为：先走ViewController的subscribeNext订阅，后走TwoViewController的sendNext
 可按实际情况各取所需。

 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
