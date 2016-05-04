//
//  AXAMainViewController.m
//  AXAEncBeacon
//
//  Created by AXAET_APPLE on 16/4/7.
//  Copyright © 2016年 axaet. All rights reserved.
//

#import "AXAMainViewController.h"
#import "AXADetailViewController.h"
#import "AXAEncBeaconModel.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "AXABeaconCell.h"
#import <AXAEypt/AXAEypt.h>

@interface AXAMainViewController ()<CBCentralManagerDelegate, CBPeripheralDelegate,UITableViewDataSource, UITableViewDelegate>
{
    BOOL _isPowerOn;//蓝牙开启状态
}

@property (nonatomic, strong) UITableView *tableView;
/**自定义按钮*/
@property (nonatomic, strong) UIButton *customBtn;
/**保存扫描到的beacon数组*/
@property (nonatomic, strong) NSMutableArray *scanEncBeaconArray;

@property (nonatomic, strong) AXADetailViewController *detailVC;
/**用于扫描外设的中央管理对象*/
@property (nonatomic, strong) CBCentralManager *centralManager;
/**连接的peripheral*/
@property (nonatomic, strong) CBPeripheral *myPeripheral;

@end

@implementation AXAMainViewController

#pragma mark - view left cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    _isPowerOn = NO;

    _detailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AXADetailViewController"];

    _scanEncBeaconArray = [NSMutableArray new];

    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];

    [self setUpUI];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [_scanEncBeaconArray removeAllObjects];
    [self.tableView reloadData];
    if (_isPowerOn) {
        [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"EEEE"]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

}

#pragma mark - private method
- (void)setUpUI {

    self.automaticallyAdjustsScrollViewInsets = YES;
    self.navigationItem.title = NSLocalizedString(@"EyptBeacon", nil);
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"titleView"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};

    [self.view addSubview:self.tableView];

    _customBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [_customBtn setBackgroundImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    [_customBtn addTarget:self action:@selector(pressRight:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_customBtn];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    [self scanAnimation];
}

- (void)scanAnimation {

    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.delegate = self;
    rotationAnimation.fromValue = @(0);
    rotationAnimation.toValue = @(2 * M_PI);
    rotationAnimation.duration = 1.0;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 1;

    [_customBtn.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self scanAnimation];
}
#pragma mark - action method
- (void)pressRight:(UIButton *)button {

    [_scanEncBeaconArray removeAllObjects];
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"EEEE"]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
    [self.tableView reloadData];
}

#pragma mark - CBCentralManagerDelegate
/**监听中央设备的蓝牙状态*/
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    _isPowerOn = YES;
        [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"EEEE"]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
}
/**监听已经发现了外设*/
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {

    NSString *name = advertisementData[CBAdvertisementDataLocalNameKey];
    NSNumber *connectable = advertisementData[CBAdvertisementDataIsConnectable];
    NSDictionary *advertiseDataDictionary = advertisementData[CBAdvertisementDataServiceDataKey];

    NSData *data = advertiseDataDictionary[[CBUUID UUIDWithString:@"EEEE"]];
    if (!data) {
        return;
    }
    Byte *byte = (Byte *)[data bytes];
    AxaBeacon_Decrypt(byte, 20);

    NSString *UUID = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", byte[0], byte[1], byte[2], byte[3], byte[4], byte[5], byte[6], byte[7], byte[8], byte[9], byte[10], byte[11], byte[12], byte[13], byte[14], byte[15]];

    NSString *major = [NSString stringWithFormat:@"%d", byte[16]*256 + byte[17]];
    NSString *minor = [NSString stringWithFormat:@"%d", byte[18]*256 + byte[19]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", peripheral.identifier];
    NSArray *array = [_scanEncBeaconArray filteredArrayUsingPredicate:predicate];
    if (array.count) {
        AXAEncBeaconModel *encBeacon = array.lastObject;
        encBeacon.localName = name;
        encBeacon.rssi = RSSI;
        encBeacon.connectable = connectable;
        encBeacon.UUID = UUID;
        encBeacon.major = major;
        encBeacon.minor = minor;
    }
    else {
        AXAEncBeaconModel *encBeacon = [[AXAEncBeaconModel alloc] init];
        encBeacon.identifier = peripheral.identifier;
        encBeacon.localName = name;
        encBeacon.rssi = RSSI;
        encBeacon.connectable = connectable;
        encBeacon.UUID = UUID;
        encBeacon.major = major;
        encBeacon.minor = minor;

        [_scanEncBeaconArray addObject:encBeacon];
    }

    NSArray *beacons = [_scanEncBeaconArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        AXAEncBeaconModel *edd1 = obj1;
        AXAEncBeaconModel *edd2 = obj2;
        return [edd2.rssi compare:edd1.rssi];
    }];
    _scanEncBeaconArray = [NSMutableArray arrayWithArray:beacons];

    [self.tableView reloadData];
}
/**监听已经连接上了外设*/
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {

    [self.centralManager stopScan];
    NSLog(@"didConnectPeripheral");
    _detailVC.activePeripheral = peripheral;
    _detailVC.activeCentralManager = central;
    peripheral.delegate = _detailVC;
    [self.navigationController pushViewController:_detailVC animated:YES];
}
/**监听连接外设失败*/
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"didFailToConnectPeripheral");
}
/**监听已经断开连接*/
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:bKey_Device_Disconnect object:peripheral];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.scanEncBeaconArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AXABeaconCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AXABeaconCell" owner:self options:nil] lastObject];
    }
    [self configureCell:cell forRowAtIndexPath:indexPath];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    AXAEncBeaconModel *model = self.scanEncBeaconArray[indexPath.row];
    NSArray *peripherals = [self.centralManager retrievePeripheralsWithIdentifiers:@[model.identifier]];
    CBPeripheral *peripheral = peripherals.lastObject;
    NSLog(@"peripheral:%@", peripheral);
    self.myPeripheral = peripheral;
    [self.centralManager connectPeripheral:peripheral options:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (void)configureCell:(AXABeaconCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AXAEncBeaconModel *model = self.scanEncBeaconArray[indexPath.row];
    cell.nameLabel.text = [NSString stringWithFormat:@"name:%@",model.localName];
    cell.nameLabel.adjustsFontSizeToFitWidth = YES;
    cell.uuidLabel.text = [NSString stringWithFormat:@"UUID:%@",model.UUID];
    cell.uuidLabel.adjustsFontSizeToFitWidth = YES;
    cell.majorLabel.text = [NSString stringWithFormat:@"major:%@",model.major];
    cell.majorLabel.adjustsFontSizeToFitWidth = YES;
    cell.minorLabel.text = [NSString stringWithFormat:@"minor:%@",model.minor];
    cell.minorLabel.adjustsFontSizeToFitWidth = YES;
    cell.rssiLabel.text = [NSString stringWithFormat:@"rssi:%@",[model.rssi stringValue]];
    cell.rssiLabel.adjustsFontSizeToFitWidth = YES;
    cell.connectable.text = [NSString stringWithFormat:@"connectable:%@",([model.connectable intValue] == 1) ? @"YES" : @"NO"];
    cell.connectable.adjustsFontSizeToFitWidth = YES;
}

#pragma mark - setter and getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}
@end
