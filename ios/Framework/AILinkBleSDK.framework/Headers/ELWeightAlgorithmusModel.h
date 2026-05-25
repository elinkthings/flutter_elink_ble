//
//  ELWeightAlgorithmusModel.h
//  Elink
//
//  Created by iot_user on 2020/6/4.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN
//体重单位st:lb分隔符 @":"
extern NSString *const WeightUnitST_LBDelimiter;
//kg转lb的系数=2.2046226f
extern double const ELWeightKG_LB_CONST;
//st转lb的系数=14.0f
extern double const ELWeightST_LB_CONST;

@interface ELWeightAlgorithmusModel : NSObject

/// 体重数据转换成体重显示值的方法
/// @param weight 蓝牙发送的体重数据
/// @param weightPoint 体重小数点
/// @param weightUnit 体重单位
+(NSString *)getWeightStringWithWeight:(int)weight weightPoint:(int)weightPoint weightUnit:(ELDeviceWeightUnit)weightUnit;

/**
 Convert the integer returned by Bluetooth to the character string required for interface display, the display unit is the current user unit
   @param weightInt AILink protocol integer returned by Bluetooth
   @param unit kg / lb / st: lb / jin
   @param point 1,2
   @return The weight displayed on the interface, such as 5: 6.5 st: lb
 将蓝牙返回的整数，转换为界面显示所需要的字符串，显示单位为当前用户单位
 // weightInt AILink协议蓝牙返回的整数
 // unit kg/lb/st:lb/jin
 // point 1,2
 // 界面显示的体重，如 5:6.5 st:lb
 */
+ (NSString *)getWeightShowStrWithTargetUnit:(ELDeviceWeightUnit)targetUnit bleWeightInt:(NSUInteger)weightInt bleWeightUnit:(ELDeviceWeightUnit)unit bleWeightPoint:(NSUInteger)point;

/**
 将服务器返回的5:6.5、56.2等数据转换为kg,用来画图或者换算
 @param weightShow 从数据库中直接读出来的，或者AILink协议蓝牙返给界面的数据 68.56(kg) 120.6(lb)
 @param unit kg/lb/st:lb/jin
 @param point 1,2
 @return 转换为kg的值(用于绘图或换算的kg数，一律四舍五入保留2位小数)
 */
+ (NSString *)getKgWithWeightShowStr:(NSString *)weightShow weightUnit:(ELDeviceWeightUnit)unit weightPoint:(NSUInteger)point;
@end

NS_ASSUME_NONNULL_END
