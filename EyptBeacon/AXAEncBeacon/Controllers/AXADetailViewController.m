//
//  AXADetailViewController.m
//  AXAEncBeacon
//
//  Created by AXAET_APPLE on 16/4/7.
//  Copyright © 2016年 axaet. All rights reserved.
//

#import "AXADetailViewController.h"
#import "PMCustomKeyboard.h"
#import "PasswordViewController.h"
#import "SendDataManager.h"
#import "MBProgressHUD.h"
#import "NSString+Category.h"
#import <AXAEypt/AXAEypt.h>

#define kPassword       @" Password:"
#define kName           @" Name:"
#define kwidth          50.f

@interface AXADetailViewController ()<UITextFieldDelegate>
{
    UIView *accessoryView;

}

/** state */
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
/** uuid */
@property (weak, nonatomic) IBOutlet UITextField *uuidField;
/** major */
@property (weak, nonatomic) IBOutlet UITextField *majorField;
/** minor */
@property (weak, nonatomic) IBOutlet UITextField *minorField;
/** period */
@property (weak, nonatomic) IBOutlet UITextField *periodField;
/** password */
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
/** name */
@property (weak, nonatomic) IBOutlet UITextField *nameField;
/** power */
@property (weak, nonatomic) IBOutlet UITextField *powerField;
/** 发送数据管理对象 */
@property (nonatomic, strong) SendDataManager *sendDataManager;

@property (nonatomic, strong) MBProgressHUD *progressHUD;

@property (strong, nonatomic) UIBarButtonItem *leftBarButton;
@property (strong, nonatomic) UIBarButtonItem *rightBarButton;

@property (nonatomic) NSUInteger length;

@property (nonatomic, strong) PasswordViewController *passwordViewController;

@end

@implementation AXADetailViewController
#pragma mark - view left cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _isModifyPassword = NO;

    _passwordViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PasswordViewController"];
    _passwordViewController.pwdPeripheral = self.activePeripheral;

    [self setUpUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.sendDataManager = [SendDataManager sharedManager];
    self.sendDataManager.peripheral = self.activePeripheral;

    [self.activePeripheral discoverServices:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDisconnect:) name:bKey_Device_Disconnect object:nil];

    self.passwordField.text = @"";
    self.nameField.text = @"";
    self.passwordField.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.uuidField resignFirstResponder];
    [self.majorField resignFirstResponder];
    [self.minorField resignFirstResponder];
    [self.periodField resignFirstResponder];
    [self.powerField resignFirstResponder];
    [self.nameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
   
}

#pragma mark - action method
- (void)hiddenKeyboard {

    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];

    [self.uuidField resignFirstResponder];
    [self.majorField resignFirstResponder];
    [self.minorField resignFirstResponder];
    [self.periodField resignFirstResponder];
    [self.powerField resignFirstResponder];
    [self.nameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (void)selectLeftBarButton {

    [self.activeCentralManager cancelPeripheralConnection:self.activePeripheral];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pressRight:(UIButton *)button {

    [self.navigationController pushViewController:self.passwordViewController animated:YES];
}

- (IBAction)pressModify:(id)sender {
    if (self.passwordField.text.length != 6) {
        [self showHUDWithLabelText:@"length of password must be 6"];
    }
    if ([self.passwordField.text isChinese]) {
        [self showHUDWithLabelText:@"there is Chinese"];
    }
    [self.sendDataManager sendPassword:self.passwordField.text];
}

#pragma mark - PeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    pFuncMethod;
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    pFuncMethod;
    if (error) {
        NSLog(@"%s,%@",__func__, error);
    }

    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:kWriteReadCharacUUID]) {
            [peripheral readValueForCharacteristic:characteristic];
        }
        if ([characteristic.UUID isEqual:kNotifyCharacUUID]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    [self.sendDataManager setNotifyForPeripheral:self.activePeripheral sUUIDString:kServiceUUIDString cUUIDString:kNotifyCharacUUIDString enable:YES];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    pFuncMethod;
    if (_isModifyPassword) {
        [self showHUDWithLabelText:@"modify success"];
    }
    _isModifyPassword = NO;
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    pFuncMethod;
    if (error) {
        NSLog(@"%s,%@",__func__, error);
    }

    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFF1"]]) {
        NSLog(@"读写数据%@",characteristic);

    }
    Byte byte[20];
    [characteristic.value getBytes:byte length:characteristic.value.length];

    AxaBeacon_Decrypt(byte, 20);

    if (byte[0] == 0x11) {
        NSString *uuid = [NSString stringWithFormat:@"%02X", byte[1]];
        for (int i = 2; i < 17; i++) {
            uuid = [uuid stringByAppendingString:[NSString stringWithFormat:@"%2X", byte[i]]];
            if (i == 4 || i==6 || i == 8 || i == 10) {
                uuid = [uuid stringByAppendingString:@"-"];
            }
        }
        self.uuidField.text = [uuid stringByReplacingOccurrencesOfString:@" " withString:@"0"];
    }

    else if (byte[0] == 0x12) {
        NSString *major = [NSString stringWithFormat:@"%d", byte[1] * 256 + byte[2]];
        self.majorField.text = major;
        NSString *minor = [NSString stringWithFormat:@"%d", byte[3] * 256 + byte[4]];
        self.minorField.text = minor;
        NSString *period = [NSString stringWithFormat:@"%d", byte[5] * 256 + byte[6]];
        self.periodField.text = period;
        if (byte[7] < 3) {
            self.powerField.text = [NSString stringWithFormat:@"%d", byte[7]];
        } else {
            NSString *power = [NSString stringWithFormat:@"%d", byte[7] - 256];
            self.powerField.text = power;
        }
    }

    else if (byte[0] == 0x05) {
        NSLog(@"0x05");
        _isModifyPassword = YES;
        sleep(1);
        [self showHUDWithLabelText:@"send password right"];

        [[NSNotificationCenter defaultCenter] postNotificationName:bKey_Device_Password_Right object:nil];
        [self handlePasswordRight];
    }

    else if (byte[0] == 0x0a) {
        NSLog(@"0x0a");
    }

    else if (byte[0] == 0x0b) {
        //设备请求发送密码
        NSLog(@"0x0b");
    }

    else if (byte[0] == 0x06) {
        NSLog(@"0x06");
        [self showHUDWithLabelText:@"send password wrong"];
        [[NSNotificationCenter defaultCenter] postNotificationName:bKey_Device_Password_Wrong object:nil];
    }

    else if (byte[0] == 0x07) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Password_Modify_Right object:nil];
        //修改密码成功
        NSLog(@"0x0d");
    }

}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {

    int offset;
    offset = CGRectGetMaxY(textField.frame) - CGRectGetHeight(self.view.frame) + 360;

    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    if(offset > 0)
    {
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        self.view.frame = rect;
    }
    [UIView commitAnimations];
}

/**限制密码文本框输入不超过6位*/
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.passwordField) {
        NSString *updateText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (updateText.length > 6) {
            return NO;
        }
    }
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if (([change[NSKeyValueChangeOldKey] intValue] == 7) && ([change[NSKeyValueChangeNewKey] intValue] == 8)) {
        [self.uuidField insertText:@"-"];
    }
    else if (([change[NSKeyValueChangeOldKey] intValue] == 12) && ([change[NSKeyValueChangeNewKey] intValue] == 13)) {
        [self.uuidField insertText:@"-"];
    }
    else if (([change[NSKeyValueChangeOldKey] intValue] == 17) && ([change[NSKeyValueChangeNewKey] intValue] == 18)) {
        [self.uuidField insertText:@"-"];
    }
    else if (([change[NSKeyValueChangeOldKey] intValue] == 22) && ([change[NSKeyValueChangeNewKey] intValue] == 23)) {
        [self.uuidField insertText:@"-"];
    }
}

- (void)textfieldDidChanged {
    self.length = self.uuidField.text.length;
}

#pragma mark - private method
- (void)setUpUI {

    self.view.backgroundColor = [UIColor whiteColor];

    self.automaticallyAdjustsScrollViewInsets = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textfieldDidChanged) name:UITextFieldTextDidChangeNotification object:nil];
    [self addObserver:self forKeyPath:@"length" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld  context:@"length"];

    self.navigationItem.title = @"search";
    self.leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(selectLeftBarButton)];
    self.navigationItem.leftBarButtonItem = self.leftBarButton;
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"passwordicon"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(pressRight:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;


    self.stateLabel.text = @"disconnected";
    self.stateLabel.adjustsFontSizeToFitWidth = YES;

    PMCustomKeyboard *customKeyboard = [[PMCustomKeyboard alloc] init];
    customKeyboard.textField = self.uuidField;
    self.uuidField.inputView = customKeyboard;

    UILabel *password = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kwidth, CGRectGetHeight(self.passwordField.frame))];
    password.adjustsFontSizeToFitWidth = YES;
    password.text = kPassword;
    self.passwordField.leftView = password;
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordField.hidden = NO;
    self.passwordField.placeholder = @"the length of password is six";
    self.passwordField.textAlignment = NSTextAlignmentCenter;

    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kwidth, CGRectGetHeight(self.nameField.frame))];
    name.adjustsFontSizeToFitWidth = YES;
    name.text = kName;
    self.nameField.leftView = name;
    self.nameField.leftViewMode = UITextFieldViewModeAlways;
    self.nameField.hidden = NO;
    self.nameField.placeholder = @"the length of name must less then twelve";
    self.nameField.textAlignment = NSTextAlignmentCenter;

    self.majorField.delegate = self;
    self.minorField.delegate = self;
    self.periodField.delegate = self;
    self.powerField.delegate = self;
    self.passwordField.delegate = self;
    self.nameField.delegate = self;

    self.uuidField.adjustsFontSizeToFitWidth = YES;
    self.majorField.keyboardType = UIKeyboardTypeNumberPad;
    self.minorField.keyboardType = UIKeyboardTypeNumberPad;
    self.periodField.keyboardType = UIKeyboardTypeNumberPad;
    self.powerField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;

    accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    accessoryView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    UIButton *accessoryBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    accessoryBtn.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 80, 0, 70, 40);
    [accessoryView addSubview:accessoryBtn];
    [accessoryBtn addTarget:self action:@selector(hiddenKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [accessoryBtn setTitle:@"Hidden" forState:UIControlStateNormal];

    self.uuidField.inputAccessoryView = accessoryView;
    self.majorField.inputAccessoryView = accessoryView;
    self.minorField.inputAccessoryView = accessoryView;
    self.periodField.inputAccessoryView = accessoryView;
    self.powerField.inputAccessoryView = accessoryView;
    self.passwordField.inputAccessoryView = accessoryView;
    self.nameField.inputAccessoryView = accessoryView;


    if (self.activePeripheral.state == CBPeripheralStateConnected) {
        self.stateLabel.text = @"connected";
    } else {
        self.stateLabel.text = @"disconnected";
    }

    self.uuidField.text = @"";
    self.majorField.text = @"";
    self.minorField.text = @"";
    self.periodField.text = @"";
    self.powerField.text = @"";


}

- (void)showHUDWithLabelText:(NSString *)text {

    _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _progressHUD.mode = MBProgressHUDModeText;
    _progressHUD.labelText = text;
    _progressHUD.labelFont = [UIFont systemFontOfSize:12];
    _progressHUD.removeFromSuperViewOnHide = YES;
    [_progressHUD hide:YES afterDelay:1];
}

- (void)handlePasswordRight {
    
    NSString *replaceStr = [self.uuidField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if (replaceStr.length != 32) {
        [self showHUDWithLabelText:@"length of uuid must be 32"];
        return;
    }
    if ([self.majorField.text intValue] > 65535 || [self.majorField.text intValue] < 0) {
        [self showHUDWithLabelText:@"major must be 0 to 65535"];
        return;
    }
    if ([self.minorField.text intValue] > 65535 || [self.minorField.text intValue] < 0) {
        [self showHUDWithLabelText:@"minor must be 0 to 65535"];
        return;
    }
    if ([self.periodField.text intValue] > 9000 || [self.periodField.text intValue] < 100) {
        [self showHUDWithLabelText:@"period must be 100 to 9000"];
        return;
    }
    if ([self.powerField.text intValue] > 2 || [self.powerField.text intValue] < -21) {
        [self showHUDWithLabelText:@"power must be -21 to 2"];
        return;
    }
    if ([self.periodField.text isChinese] || [self.minorField.text isChinese] || [self.majorField.text isChinese] || [self.uuidField.text isChinese] || [self.powerField.text isChinese]) {
        [self showHUDWithLabelText:@"there is Chinese"];
        return;
    }
    if (self.nameField.text.length) {
        if (self.nameField.text.length >= 12) {
            [self showHUDWithLabelText:@"length of name must be less than 12"];
            return;
        }
        if ([self.nameField.text isChinese]) {
            [self showHUDWithLabelText:@"there is Chinese"];
            return;
        }
        [self.sendDataManager sendName:self.nameField.text];
    }
    [self.sendDataManager sendHexString:self.uuidField.text];
    [self.sendDataManager sendPeriod:self.periodField.text Power:self.powerField.text  Major:self.majorField.text Minor:self.minorField.text];
    [self.sendDataManager sendTurnOffDevice];
}

- (void)handleDisconnect:(NSNotification *)notification {
    [self.navigationController popViewControllerAnimated:YES];
}



@end
