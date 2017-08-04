//
//  ViewController.m
//  CustomAlertDemo
//
//  Created by hechao on 16/9/4.
//  Copyright © 2016年 hechao. All rights reserved.
//

#import "ViewController.h"
#import "HCAlertView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *aButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    aButton.center = self.view.center;
    [aButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [aButton setTitle:@"Alert" forState:UIControlStateNormal];
    [aButton addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:aButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonPressed
{
    NSString *message = @"Test alert view with image and title icon,you can also alert a user defined view";
    HCAlertView *alert = [[HCAlertView alloc] initWithImage:[UIImage imageNamed:@"git"]
                                                      title:@"TEST"
                                                  titleIcon:[UIImage imageNamed:@"git"]
                                                    message:message
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确认", nil];
    [alert show];
    alert.buttonAction = ^(NSInteger selectedIndex){
        NSLog(@"%ld",selectedIndex);
    };
}

@end
