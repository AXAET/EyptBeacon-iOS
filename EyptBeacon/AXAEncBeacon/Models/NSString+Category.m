//
//  NSString+Category.m
//  Eddystone_B
//
//  Created by AXAET_APPLE on 16/3/28.
//  Copyright © 2016年 axaet. All rights reserved.
//

#import "NSString+Category.h"

@implementation NSString (Category)

- (BOOL)isChinese {
    for (int i = 0; i < self.length; i++) {
        int a = [self characterAtIndex:i];
        if (a > 0x4e00 && a < 0x9ff) {
            return YES;
        }
    }
    return NO;
}

@end
