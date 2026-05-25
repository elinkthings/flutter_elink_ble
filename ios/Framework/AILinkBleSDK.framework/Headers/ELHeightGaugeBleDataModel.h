//
//  ELHeightGaugeBleDataModel.h
//  Elink
//
//  Created by iot_user on 2019/5/10.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ELHeightGaugeHeader.h"
#import "ELSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELHeightGaugeBleDataModel : NSObject


@property (nonatomic, assign)   NSUInteger height;     //ble raw data
@property (nonatomic, assign)   NSUInteger heightPoint; //decimal
@property (nonatomic, assign)   ELDeviceHeightUnit heightUnit;//单位

@property (nonatomic, assign)   long long createTime;//时间


@end

NS_ASSUME_NONNULL_END
