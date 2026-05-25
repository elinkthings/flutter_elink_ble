//
//  ELCoffeeScaleBleDataModel.h
//  Elink
//
//  Created by iot_user on 2020/9/30.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ELCoffeeScaleBleHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELCoffeeScaleBleDataModel : NSObject

/** 是否为稳定数据 */
@property (nonatomic, assign) BOOL stableData;

/** 质量单位 */
@property (nonatomic, assign) ELDeviceWeightUnit weightUnit;

/** 质量值 */
@property (nonatomic, copy) NSString *weightString;

/** 质量值 */
@property (nonatomic, assign) CGFloat weightValue;

/** 温度单位 */
@property (nonatomic, assign) ELDeviceTemperatureUnit temUnit;

/** 温度值 */
@property (nonatomic, assign) CGFloat tem;

/** 时间戳 */
@property (nonatomic, assign) NSTimeInterval timestamp;


//质量正负标识
@property (nonatomic, assign) BOOL rawWeightNegative;

//质量小数点位
@property (nonatomic, assign) NSInteger rawWeightPoint;

//质量
@property (nonatomic, assign) NSInteger rawWeight;

//异常状态 0无异常 1超重
@property (nonatomic, assign) NSInteger error;




+ (instancetype)dataWithPayloadData:(NSData *)data;


@end

NS_ASSUME_NONNULL_END
