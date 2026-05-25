//
//  ELBroadcastHeightGaugeBleDataModel.h
//  AILinkBleSDK
//
//  Created by cliCk on 2021/3/19.
//  Copyright © 2021 IOT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELBroadcastHeightGaugeBleHeader.h"
#import "ELSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELBroadcastHeightGaugeBleDataModel : NSObject

@property (nonatomic, assign) int cid;
@property (nonatomic, assign) int vid;
@property (nonatomic, assign) int pid;
@property (nonatomic, copy) NSString *mac;

/** Data serial number 流水号 */
@property (nonatomic, assign) NSInteger serialNumber;

/** Measurement status 测量标识符 */
@property (nonatomic, assign) BroadcastHeightGuage_TestState testState;

/** 身高数据 */
@property (nonatomic, assign) NSUInteger height;

/** 身高小数点位 */
@property (nonatomic, assign) NSUInteger heightPoint;

/** 身高单位 */
@property (nonatomic, assign) ELDeviceHeightUnit heightUnit;

/** 体重数据 */
@property (nonatomic, assign) NSInteger weight;

/** 体重小数点位 */
@property (nonatomic, assign) NSUInteger weightPoint;

/** 体重单位 */
@property (nonatomic, assign) ELDeviceWeightUnit weightUnit;

/** 电量 0~100 ,如果值为负数，则代表该设备无电量检测 */
@property (nonatomic, assign) NSInteger power;

/** time(时间) */
@property (nonatomic, assign) long long createTime;

@end

NS_ASSUME_NONNULL_END
