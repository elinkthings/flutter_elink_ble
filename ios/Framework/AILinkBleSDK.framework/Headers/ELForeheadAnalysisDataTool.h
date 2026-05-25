//
//  ELForeheadAnalysisDataTool.h
//  Elink
//
//  Created by iot_user on 2019/5/10.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELForeheadBleDataModel.h"
#import "ELForeheadHeader.h"


NS_ASSUME_NONNULL_BEGIN

@interface ELForeheadAnalysisDataTool : NSObject

/**
 解析温度数据

 @param playload 原始数据
 @return ELForeheadBleDataModel
 */
+(ELForeheadBleDataModel *)analysisStabilityData:(NSData *)playload;

/**
 解析设置单位

 @param playload 原始数据
 @return 结果
 */
+(ELSetBluetoothResponseType)analysisSetUnitResult:(NSData *)playload;

/**
 解析异常

 @param playload 原始数据
 @return 异常
 */
+(ForeheadFailCode)analysisFailCode:(NSData *)playload;

@end

NS_ASSUME_NONNULL_END
