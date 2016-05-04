//
//  PMCustomKeyboard.m
//  ModifedIbeacon
//
//  Created by AXAET_APPLE on 15/4/22.
//  Copyright (c) 2015年 axaet. All rights reserved.
//

#import "PMCustomKeyboard.h"

@implementation PMCustomKeyboard

- (IBAction)pressBDelete:(id)sender {
    [[UIDevice currentDevice] playInputClick];
    [self.textField deleteBackward];
}
//pressReturn
- (IBAction)pressBClear:(id)sender {
    [[UIDevice currentDevice] playInputClick];
    [self.textField insertText:@"\n"];
}
- (IBAction)pressBNumbers:(id)sender {
    UIButton *button = (UIButton *)sender;
    [[UIDevice currentDevice] playInputClick];
    NSString *character = [NSString stringWithString:button.titleLabel.text];
    [self.textField insertText:character];
}

- (instancetype)init {
    CGRect frame = [UIApplication sharedApplication].keyWindow.bounds;
    self = [super initWithFrame:CGRectMake(0, 0, frame.size.width, 240)];
    if (self) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PMCustomKeyboard" owner:self options:nil];
        [[nib objectAtIndex:0] setFrame:frame];
        self = [nib objectAtIndex:0];
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    }
    
    return self;
}

@end
