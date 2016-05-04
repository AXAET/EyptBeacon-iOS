//
//  SendDataManager.m
//  Eddystone_B
//
//  Created by AXAET_APPLE on 16/3/26.
//  Copyright © 2016年 axaet. All rights reserved.
//

#import "SendDataManager.h"
#import <AXAEypt/AXAEypt.h>

@interface SendDataManager()

@end

@implementation SendDataManager

#pragma mark - public method
+ (instancetype)sharedManager {
    static SendDataManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (void)sendHexString:(NSString *)hex {

    Byte byte[20];
    NSString *replaceStr = [hex stringByReplacingOccurrencesOfString:@"-" withString:@""];
    byte[0] = 0x01;
    for (int i = 0; i < 16; i++) {
        NSRange range = NSMakeRange(2 * i, 2);
        NSString *subStr = [replaceStr substringWithRange:range];
        NSScanner *scanner = [NSScanner scannerWithString:subStr];
        unsigned int hex2;
        [scanner scanHexInt:&hex2];
        byte[i + 1] = hex2;
    }
    for (int i = 17; i < 20; i++) {
        byte[i] = 0x00;
    }
    //加密
    AxaBeacon_Encrypt(byte, 20);

    NSData *data = [[NSData alloc] initWithBytes:byte length:20];
    [self sendCommand:data toPeripheral:self.peripheral];
}

- (void)sendUrl:(NSString *)url {

    Byte byte[40];
    byte[0] = 0x01;
    byte[2] = [self getUrlschemeByte:url];
    url = [url stringByReplacingOccurrencesOfString:[self getUrlsScheme:[self getUrlschemeByte:url]] withString:@""];
    NSString *temp;
    for (NSString *str in _urlArray) {
        NSRange range = [url rangeOfString:str];
        if (range.location != NSNotFound) {
            byte[range.location + 3] = [_urlArray indexOfObject:str];
            temp = str;
            break;
        }
    }
    NSString *tempUrl;
    if (temp) {
        tempUrl = [url stringByReplacingOccurrencesOfString:temp withString:@""];
        byte[1] = tempUrl.length + 2;
    } else {
        tempUrl = url;
        byte[1] = tempUrl.length + 1;
    }
    const char *ch = [tempUrl cStringUsingEncoding:NSASCIIStringEncoding];
    for (int i = 0; i < tempUrl.length; i++) {
        byte[i + 3] = ch[i];
    }

    AxaBeacon_Encrypt(byte, 20);
    NSData *data = [[NSData alloc] initWithBytes:byte length:tempUrl.length + 4];
    [self sendCommand:data toPeripheral:self.peripheral];
}

- (void)sendTurnOffDevice {

    Byte byte[20];
    byte[0] = 0x03;
    for (int i = 1; i < 20; i++) {
        byte[i] = 0x00;
    }
    AxaBeacon_Encrypt(byte, 20);
    NSData *data = [[NSData alloc] initWithBytes:byte length:20];
    [self sendCommand:data toPeripheral:self.peripheral];
}

- (void)sendPeriod:(NSString *)period Power:(NSString *)power {

    Byte byte[20];
    byte[0] = 0x2;
    byte[1] = [period intValue]/256;
    byte[2] = [period intValue]%256;
    byte[3] = [power intValue];
    for (int i = 4; i < 20; i++) {
        byte[i] = 0x00;
    }
    AxaBeacon_Encrypt(byte, 20);

    NSData *data = [[NSData alloc] initWithBytes:byte length:20];
    [self sendCommand:data toPeripheral:self.peripheral];
}

- (void)sendPeriod:(NSString *)period Power:(NSString *)power Major:(NSString *)major Minor:(NSString *)minor {

    Byte byte[20];
    byte[0] = 0x2;
    byte[1] = [major intValue]/256;
    byte[2] = [major intValue]%256;
    byte[3] = [minor intValue]/256;
    byte[4] = [minor intValue]%256;
    byte[5] = [period intValue]/256;
    byte[6] = [period intValue]%256;
    byte[7] = [power intValue];
    for (int i = 8; i < 20; i++) {
        byte[i] = 0x00;
    }
    AxaBeacon_Encrypt(byte, 20);
    NSData *data = [[NSData alloc] initWithBytes:byte length:20];
    [self sendCommand:data toPeripheral:self.peripheral];
}

- (void)sendPassword:(NSString *)password {

    Byte byte[20];
    byte[0] = 0x04;
    const char *a = [password UTF8String];
    for (int i = 0; i < 6; i++) {
        byte[i + 1] = a[i];
    }
    for (int i = 7; i < 20; i++) {
        byte[i] = 0x00;
    }

    AxaBeacon_Encrypt(byte, 20);
    NSData *data = [[NSData alloc] initWithBytes:byte length:20];
    [self sendCommand:data toPeripheral:self.peripheral];
}

- (void)sendName:(NSString *)name {

    Byte byte[20];
    byte[0] = 0x08;
    byte[1] = name.length;
    const char *a = [name UTF8String];
    for (int i = 0; i < name.length; i++) {
        byte[i + 2] = a[i];
    }
    for (int i = ((int)name.length + 2); i < 20; i++) {
        byte[i] = 0x00;
    }

    AxaBeacon_Encrypt(byte, 20);
    NSData *data = [[NSData alloc] initWithBytes:byte length:20];
    [self sendCommand:data toPeripheral:self.peripheral];
}

- (void)sendOldConfirmPassword:(NSString *)password {

    Byte byte[20];
    byte[0] = 0x09;
    const char *a = [password UTF8String];
    for (int i = 0; i < 12; i++) {
        byte[i + 1] = a[i];
    }
    for (int i = 13; i < 20; i++) {
        byte[i] = 0x00;
    }
    AxaBeacon_Encrypt(byte, 20);
    NSData *data = [[NSData alloc] initWithBytes:byte length:20];
    [self sendCommand:data toPeripheral:self.peripheral];
}

- (NSString *)getUrlsScheme:(char)hexChar {
    switch (hexChar) {
        case 0x00:
            return @"http://www.";
        case 0x01:
            return @"https://www.";
        case 0x02:
            return @"http://";
        case 0x03:
            return @"https://";
        default:
            return nil;
    }
}

- (NSString *)getEncodedString:(char)hexChar {
    switch (hexChar) {

        case 0x00:
            return @".com/";
        case 0x01:
            return @".org/";
        case 0x02:
            return @".edu/";
        case 0x03:
            return @".net/";
        case 0x04:
            return @".info/";
        case 0x05:
            return @".biz/";
        case 0x06:
            return @".gov/";
        case 0x07:
            return @".com";
        case 0x08:
            return @".org";
        case 0x09:
            return @".edu";
        case 0x0a:
            return @".net";
        case 0x0b:
            return @".info";
        case 0x0c:
            return @".biz";
        case 0x0d:
            return @".gov";
        default:
            return [NSString stringWithFormat:@"%c", hexChar];
    }
}

- (void)sendCommand:(NSData *)data toPeripheral:(CBPeripheral *)peripheral {
    [self writeToPeripheral:peripheral sUUIDString:kServiceUUIDString cUUIDString:kWriteReadCharacUUIDString byData:data];
}

- (void)writeToPeripheral:(CBPeripheral *)peripheral
              sUUIDString:(NSString *)sUUIDString
              cUUIDString:(NSString *)cUUIDString
                   byData:(NSData *)data {

    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUIDString]]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUIDString]]) {
                    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                    [peripheral readValueForCharacteristic:characteristic];
                }
            }
        }
    }
}

- (void)setNotifyForPeripheral:(CBPeripheral *)peripheral
                   sUUIDString:(NSString *)sUUIDString
                   cUUIDString:(NSString *)cUUIDString
                        enable:(BOOL)enable {

    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUIDString]]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUIDString]]) {
                    [peripheral setNotifyValue:enable forCharacteristic:characteristic];
                }
            }
        }
    }
}

- (Byte)getUrlschemeByte:(NSString *)url {

    if ([url hasPrefix:@"http://www."]) {
        return 0x00;
    }
    if ([url hasPrefix:@"https://www."]) {
        return 0x01;
    }
    if ([url hasPrefix:@"http://"]) {
        return 0x02;
    }
    if ([url hasPrefix:@"https://"]) {
        return 0x03;
    }
    return 0;
}

@end
