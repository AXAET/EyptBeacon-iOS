//
//  PMCustomKeyboard.h
//  ModifedIbeacon
//
//  Created by AXAET_APPLE on 15/4/22.
//  Copyright (c) 2015年 axaet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMCustomKeyboard : UIView<UIInputViewAudioFeedback>
@property (strong, nonatomic) IBOutlet UIButton *bDelete;
@property (nonatomic, strong) UITextField *textField;

@end
