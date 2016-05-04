//
//  AXAEncBeaconModel.h
//  AXAEncBeacon
//
//  Created by AXAET_APPLE on 16/4/7.
//  Copyright © 2016年 axaet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AXAEncBeaconModel : NSObject

@property (nonatomic, strong) NSUUID *identifier;

@property (nonatomic, strong) NSString *localName;

@property (nonatomic, strong) NSNumber *rssi;

@property (nonatomic, strong) NSNumber *connectable;

@property (nonatomic, strong) NSString *major;

@property (nonatomic, strong) NSString *minor;

@property (nonatomic, strong) NSString *period;

@property (nonatomic, strong) NSString *power;

@property (nonatomic, strong) NSString *UUID;

@end
