//
//  ELUnitChangeTool.h
//  Elink
//
//  Created by steven wu on 2019/9/21.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELWeightAlgorithmusModel.h"
#import "ELHeightAlgorithmusModel.h"
#import "ELSDKHeader.h"

#define StLbSymbol              WeightUnitST_LBDelimiter
#define FeetSymbol              ELHeightFeetSymbol
#define InchSymbol              ELHeightInchSymbol

#define KG_LB_CONST     ELWeightKG_LB_CONST
#define ST_LB_CONST     ELWeightST_LB_CONST

#define INCH_CM_CONST       ELHeight_INCH_CM_CONST
#define FEET_INCH_CONST     ELHeight_FEET_INCH_CONST


@interface ELUnitConvertTool : NSObject

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

+ (NSString *)getHeightShowStrWithTargetUnit:(ELDeviceHeightUnit)targetUnit origHeightShow:(NSString *)origHeightShow origHeightUnit:(ELDeviceHeightUnit)origHeightUnit origHeightPoint:(NSUInteger)origHeightPoint;


/**
 Display data returned from the server or converted from the original Bluetooth data: such as 5: 6.5, 56.2, etc., converted to kg for drawing or conversion
   @param weightShow The data read directly from the database, or the AILink protocol Bluetooth returns to the interface 68.56 (kg) 120.6 (lb)
   @param unit kg / lb / st: lb / jin
   @param point 1,2
   @return is converted to the value of kg (the number of kg used for drawing or conversion, rounded to 2 decimal places)
 将服务器返回或者蓝牙原始数据转换来的显示数据：如5:6.5、56.2等数据转换为kg,用来画图或者换算
 // weightShow 从数据库中直接读出来的，或者AILink协议蓝牙返给界面的数据 68.56(kg) 120.6(lb)
 // unit kg/lb/st:lb/jin
 // point 1,2
 // 转换为kg的值(用于绘图或换算的kg数，一律四舍五入保留2位小数)
 */
+ (NSString *)getKgWithWeightShowStr:(NSString *)weightShow weightUnit:(ELDeviceWeightUnit)unit weightPoint:(NSUInteger)point;

+ (NSString *)getCmWithHeightShowStr:(NSString *)heightShow heightUnit:(ELDeviceHeightUnit)unit heightPoint:(NSUInteger)point;


@end

