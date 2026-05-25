//
//  ELThermometerBleModel.h
//  Elink
//
//  Created by cliCk on 2019/5/28.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELThermometerBleModel : NSObject

@property (nonatomic,assign) ELDeviceTemperatureUnit unit;//单位
@property (nonatomic,assign) NSUInteger temperature;//温度
/// Stability flag: 0 real-time data, 1 stable data(稳定标志：0 实时数据，1 稳定数据)
@property (nonatomic,assign) BOOL dataType;
@property (nonatomic,copy) NSString *unitStr;
@property (nonatomic,assign) NSInteger tempPoint;   //小数点偏移位置

/// 数据时间戳
@property (nonatomic, assign) long long timeStamp;

@end



NS_ASSUME_NONNULL_END
