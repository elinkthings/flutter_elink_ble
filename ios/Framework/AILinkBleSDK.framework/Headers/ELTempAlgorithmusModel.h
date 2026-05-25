//
//  ELTempAlgorithmusModel.h
//  Elink
//
//  Created by iot_user on 2020/6/4.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELTempAlgorithmusModel : NSObject


/// 获取温度显示值
/// @param temp 蓝牙发送的温度数值
/// @param tempPoint 温度小数点
/// @param tempUnit 温度单位
+(NSString *)getTempStringWithTemp:(int)temp tempPoint:(int)tempPoint tempUnit:(ELDeviceTemperatureUnit)tempUnit;

@end

NS_ASSUME_NONNULL_END
