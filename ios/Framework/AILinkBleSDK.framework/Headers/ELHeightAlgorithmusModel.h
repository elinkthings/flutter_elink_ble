//
//  ELHeightAlgorithmusModel.h
//  Elink
//
//  Created by iot_user on 2020/6/9.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELSDKHeader.h"
NS_ASSUME_NONNULL_BEGIN

//inch转cm的系数
extern double const ELHeight_INCH_CM_CONST;
//feet转inch的系数
extern double const ELHeight_FEET_INCH_CONST;
extern NSString *const ELHeightFeetSymbol;
extern NSString *const ELHeightInchSymbol;

@interface ELHeightAlgorithmusModel : NSObject

/// 获取身高显示值
/// @param targetUnit 要显示的单位
/// @param origHeightShow 原来的显示数据
/// @param origHeightUnit 原来数据的单位
/// @param origHeightPoint 原来的数据小数点
+ (NSString *)getHeightShowStrWithTargetUnit:(ELDeviceHeightUnit)targetUnit origHeightShow:(NSString *)origHeightShow origHeightUnit:(ELDeviceHeightUnit)origHeightUnit origHeightPoint:(NSUInteger)origHeightPoint;

/// 获取身高（CM）
/// @param heightShow 原有数据
/// @param unit 原有数据单位
/// @param point 小数点
+ (NSString *)getCmWithHeightShowStr:(NSString *)heightShow heightUnit:(ELDeviceHeightUnit)unit heightPoint:(NSUInteger)point;
@end

NS_ASSUME_NONNULL_END
