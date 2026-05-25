//
//  ELBroadcastNutritionFoodScaleDataModel.h
//  Elink
//
//  Created by iot_user on 2020/8/21.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELBroadcastNutritionFoodScaleBleHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELBroadcastNutritionFoodScaleDataModel : NSObject

@property(nonatomic, assign) int cid;
@property(nonatomic, assign) int vid;
@property(nonatomic, assign) int pid;
@property(nonatomic, copy) NSString *mac;


//Data serial number（数据流水号）
@property(nonatomic, assign) Byte serialNumber;
//Measurement status(测量状态)
@property (nonatomic, assign) BroadcastNutritionFoodScaleStatus testStatus;
//weight（重量数据）
@property (nonatomic, assign) UInt32 weight;
//Weight unit（重量单位）
@property(nonatomic, assign) BroadcastNutritionFoodScaleWeightUnit weightUnit;
//Weight decimal point（体重小数点）
@property(nonatomic, assign) Byte weightPoint;
//Weight negative（是否负数）
@property(nonatomic, assign, getter=isNegative) BOOL negative;
//Power（电量 0~100%）
@property(nonatomic, assign) Byte power;
//Error（异常标志）
@property(nonatomic, assign) BroadcastNutritionFoodScaleErrorStatus errorStatus;


//timestamp(时间戳)
@property(nonatomic, assign) long long timestamp;


@end

NSString *BroadcastNutritionFoodScaleWeightUnitString(BroadcastNutritionFoodScaleWeightUnit unit);

NS_ASSUME_NONNULL_END
