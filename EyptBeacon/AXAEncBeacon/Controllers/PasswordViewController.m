//
//  PasswordViewController.m
//  EddystoneDemo
//
//  Created by AXAET_APPLE on 16/1/6.
//  Copyright © 2016年 WuJunjie. All rights reserved.
//

#import "PasswordViewController.h"
#import "MBProgressHUD.h"
#import "NSString+Category.h"
#import "SendDataManager.h"

@interface PasswordViewController () <UITextFieldDelegate>
{
    MBProgressHUD *progressHUD_;
}

@property (weak, nonatomic) IBOutlet UITextField *password1;
@property (weak, nonatomic) IBOutlet UITextField *password2;
@property (weak, nonatomic) IBOutlet UITextField *password3;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@property (nonatomic, strong) SendDataManager *sendDataManager;

@end

@implementation PasswordViewController


#pragma mark - view left cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.sendDataManager = [SendDataManager sharedManager];
    self.sendDataManager.peripheral = self.pwdPeripheral;

    _password1.delegate = self;
    _password2.delegate = self;
    _password3.delegate = self;
    
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [leftBtn setTitle:@"Back" forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(pressLeft:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    _password1.text = @"";
    _password2.text = @"";
    _password3.text = @"";
    _okButton.enabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBleNotify:) name:bKey_Device_Connect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBleNotify:) name:bKey_Device_Disconnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBleNotify:) name:bKey_Device_UpdataValue object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBleNotify:) name:bKey_Device_Password_Right object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBleNotify:) name:bKey_Device_Password_Wrong object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBleNotify:) name:Password_Modify_Right object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - action method
- (IBAction)pressOK:(UIButton *)sender {
    if (_password1.text.length != 6) {
        [self showHUDWithString:@"length of old password must be 6"];
        return;
    }
    
    if (_password2.text.length != 6) {
        [self showHUDWithString:@"length of new password must be 6"];
        return;
    }
    
    if (![_password3.text isEqualToString:_password2.text]) {
        [self showHUDWithString:@"Confirm password is not equal to new"];
        return;
    }
    
    if ([self.password1.text isChinese] || [self.password2.text isChinese] || [self.password3.text isChinese]) {
        [self showHUDWithString:@"there is Chinese"];
        return;
    }
    
    [self.sendDataManager sendPassword:_password1.text];
}

- (void)pressLeft:(id)sender {
    _detailViewController.isModifyPassword = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_password1 resignFirstResponder];
    [_password2 resignFirstResponder];
    [_password3 resignFirstResponder];
    return YES;
}

/**限制密码文本框输入不超过6位*/
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    NSString *updateText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (updateText.length > 6) {
            return NO;
        }

    return YES;
}


#pragma mark - private method
- (void)handleBleNotify:(NSNotification *)notify {
    if ([notify.name isEqualToString:bKey_Device_Connect]) {

    }
    else if ([notify.name isEqualToString:bKey_Device_Disconnect]) {
        if ([[self.navigationController.viewControllers lastObject] isEqual:self]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    else if ([notify.name isEqualToString:bKey_Device_UpdataValue]) {
        
    }
    else if ([notify.name isEqualToString:bKey_Device_Password_Right]) {
        [self.sendDataManager sendOldConfirmPassword:[_password1.text stringByAppendingString:_password2.text]];
        [self.sendDataManager sendTurnOffDevice];
    }
    else if ([notify.name isEqualToString:bKey_Device_Password_Wrong]) {
        [self showHUDWithString:@"old password is wrong"];
    }

    else if ([notify.name isEqualToString:Password_Modify_Right]) {
        [self showHUDWithString:@"modify password success"];
    }
}

- (void)showHUDWithString:(NSString *)string {
    progressHUD_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHUD_.mode = MBProgressHUDModeText;
    progressHUD_.labelText = string;
    progressHUD_.labelFont = [UIFont systemFontOfSize:12];
    progressHUD_.removeFromSuperViewOnHide = YES;
    [progressHUD_ hide:YES afterDelay:1];
}

@end
