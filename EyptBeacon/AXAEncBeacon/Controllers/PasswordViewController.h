//
//  PasswordViewController.h
//  EddystoneDemo
//
//  Created by AXAET_APPLE on 16/1/6.
//  Copyright © 2016年 WuJunjie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AXADetailViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface PasswordViewController : UIViewController
@property (nonatomic, strong) AXADetailViewController *detailViewController;
@property (nonatomic, strong) CBPeripheral *pwdPeripheral;

@end
