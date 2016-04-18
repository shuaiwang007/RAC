//
//  ViewController.m
//  RAC-Notification
//
//  Created by 王帅 on 16/4/18.
//  Copyright © 2016年 Mr.wang. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveCocoa.h"
#import "TwoViewController.h"

@interface ViewController ()
@property(nonatomic, copy)UIButton * button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self buildUI];
}

- (void)buildUI {
    self.button.frame = CGRectMake(100, 100, 80, 30);
    [self.view addSubview:self.button];
}

#pragma mark---lazy loading
- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc] init];
        [_button setBackgroundColor:[UIColor redColor]];
        [_button setTitle:@"push" forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(btnOnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}
#pragma mark--btnOnClick
- (void)btnOnClick {
    TwoViewController *twoVC = [[TwoViewController alloc] init];
    
    
    twoVC.subject = [RACSubject subject];
    [twoVC.subject subscribeNext:^(id x) {  // 这里的x便是sendNext发送过来的信号
        NSLog(@"%@", x);
        [self.button setTitle:x forState:UIControlStateNormal];
    }];
    
    [self.navigationController pushViewController:twoVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
