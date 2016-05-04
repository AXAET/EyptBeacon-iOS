//
//  AXADetailViewController.h
//  AXAEncBeacon
//
//  Created by AXAET_APPLE on 16/4/7.
//  Copyright © 2016年 axaet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface AXADetailViewController : UIViewController<CBCentralManagerDelegate, CBPeripheralDelegate>



@property (nonatomic, strong) CBPeripheral *activePeripheral;
@property (nonatomic, strong) CBCentralManager *activeCentralManager;

@property (nonatomic, assign) BOOL isModifyPassword;
@end
