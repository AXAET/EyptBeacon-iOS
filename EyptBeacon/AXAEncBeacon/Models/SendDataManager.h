//
//  SendDataManager.h
//  Eddystone_B
//
//  Created by AXAET_APPLE on 16/3/26.
//  Copyright © 2016年 axaet. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreBluetooth;

@interface SendDataManager : NSObject

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSArray *urlArray;

+ (instancetype)sharedManager;

- (void)sendHexString:(NSString *)hex;

- (void)sendUrl:(NSString *)url;

- (void)sendTurnOffDevice;

- (void)sendPeriod:(NSString *)period Power:(NSString *)power;

- (void)sendPeriod:(NSString *)period
             Power:(NSString *)power
             Major:(NSString *)major
             Minor:(NSString *)minor;

- (void)sendPassword:(NSString *)password;

- (void)sendName:(NSString *)name;

- (void)sendOldConfirmPassword:(NSString *)password;

- (NSString *)getUrlsScheme:(char)hexChar;

- (NSString *)getEncodedString:(char)hexChar;

- (void)setNotifyForPeripheral:(CBPeripheral *)peripheral
                   sUUIDString:(NSString *)sUUIDString
                   cUUIDString:(NSString *)cUUIDString
                        enable:(BOOL)enable;

@end
