//
//  ViewController.m
//  PasswordBoxView
//
//  Created by LeeJin on 2018/9/14.
//  Copyright © 2018年 psylife. All rights reserved.
//

#import "ViewController.h"
#import "PasswordBoxView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    PasswordBoxView *DWQpbv = [[PasswordBoxView alloc] initWithFrame:CGRectMake(5, 60 + 80, self.view.frame.size.width - 10, 60)
                                                                       num:6
                                                                 lineColor:[UIColor blackColor]
                                                            textFont:30];
            //                //下划线
            //                v.hasUnderLine = YES;
            //分割线
            DWQpbv.hasSpaceLine = NO;
            //输入之后置空
            DWQpbv.emptyEditEnd = YES;
            DWQpbv.underLineAnimation = NO;
            //输入风格
            DWQpbv.type = PasswordBoxViewTypeDefault;
    DWQpbv.EndEditBlock = ^(NSString *text) {
        NSLog(@"%@",text);
    };
    [self.view addSubview:DWQpbv];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
