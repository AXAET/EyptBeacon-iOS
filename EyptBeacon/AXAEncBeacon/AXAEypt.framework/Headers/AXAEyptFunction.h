//
//  AXAEyptFunction.h
//  AXAEypt
//
//  Created by AXAET_APPLE on 16/5/4.
//  Copyright © 2016年 axaet. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface AXAEyptFunction : NSObject
//加解密密钥

//倒序
void AxaBeacon_Reverse(unsigned char *data, unsigned char len);


//加密
void AxaBeacon_Encrypt(unsigned char *data, unsigned char len);


//解密
void AxaBeacon_Decrypt(unsigned char *data, unsigned char len);

@end
