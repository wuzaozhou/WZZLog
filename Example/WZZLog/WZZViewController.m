//
//  WZZViewController.m
//  WZZLog
//
//  Created by wuzaozhou on 12/30/2019.
//  Copyright (c) 2019 wuzaozhou. All rights reserved.
//

#import "WZZViewController.h"
#import "WZLogManager.h"

@interface WZZViewController ()

@end

@implementation WZZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self loger:@"dd0"];
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self loger:@"dd1"];
        
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loger:@"dd2"];
    });
}
- (void)loger:(NSString *)msd {
    WZLog(@"model", msd);
}
@end
