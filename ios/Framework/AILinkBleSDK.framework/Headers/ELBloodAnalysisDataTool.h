//
//  ELBloodAnalysisDataTool.h
//  Elink
//
//  Created by iot_user on 2019/5/11.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELBloodBleDataModel.h"
#import "ELSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELBloodAnalysisDataTool : NSObject

+(ELBloodBleDataModel *)analysisBloodData:(NSData *)playload;

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
+(ELBloodFailCode)analysisFailCode:(NSData *)playload;
 
/**
 交互指令

 @param playload 原始数据
 @return 交互指令类型
 */
+(ELBloodInteractionType)analysisInteraction:(NSData *)playload;
@end

NS_ASSUME_NONNULL_END
