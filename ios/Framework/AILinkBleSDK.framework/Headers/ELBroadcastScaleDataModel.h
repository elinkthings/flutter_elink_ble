//
//  ELBroadcastScaleDataModel.h
//  Elink
//
//  Created by iot_user on 2020/8/21.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELBroadcastScaleBleHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELBroadcastScaleDataModel : NSObject

@property (nonatomic, assign) int cid;
@property (nonatomic, assign) int vid;
@property (nonatomic, assign) int pid;
@property (nonatomic, copy) NSString *mac;
//Data serial number（数据流水号）
@property (nonatomic, assign) int serialNumber;
//Measurement status(测量状态)
@property (nonatomic, assign) BroadcastScaleTestStatus testStatus;
//Measurement status（温度单位）
@property (nonatomic, assign) ELDeviceTemperatureUnit tempUnit;
//Weight unit（体重单位）
@property (nonatomic, assign) ELDeviceWeightUnit weightUnit;
//Weight decimal point（体重小数点）
@property (nonatomic, assign) int weightPoint;
//Weight type（体重类型）
@property (nonatomic, assign) BroadcastScaleWeightType weightType;
//weight（体重）
@property (nonatomic, copy) NSString *weight;
//impedance（阻抗）
@property (nonatomic, assign) int adc;
//Algorithm bit（算法位）
@property (nonatomic, assign) int algorithmId;
//temperature（温度）
@property (nonatomic, copy) NSString *temperature;
//time(时间)
@property (nonatomic, assign) long long createTime;


@property (nonatomic, assign) BOOL weightNegative;
@property (nonatomic, assign) UInt16 weightValue;

@end

NS_ASSUME_NONNULL_END
