//
//  AXABeaconCell.h
//  AXAEncBeacon
//
//  Created by AXAET_APPLE on 16/4/7.
//  Copyright © 2016年 axaet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AXABeaconCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *majorLabel;
@property (weak, nonatomic) IBOutlet UILabel *minorLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectable;

@end
