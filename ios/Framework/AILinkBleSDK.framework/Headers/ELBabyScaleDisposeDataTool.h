//
//  ELBabyScaleDisposeDataTool.h
//  Elink
//
//  Created by iot_user on 2019/4/23.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import "ELBleDisposeDataTool.h"
#import "ELBabyScaleBleWeightModel.h"
#import "ELBabyScaleBleHeightModel.h"
#import "ELBabyScaleBleHeader.h"



NS_ASSUME_NONNULL_BEGIN

@interface ELBabyScaleDisposeDataTool : ELBleDisposeDataTool
#pragma mark  ============ 蓝牙数据处理 ==============
#pragma mark 重量
+(ELBabyScaleBleWeightModel *)disposeWeightData:(Byte *)dataByte;
#pragma mark 体重单位切换
+(ELDeviceWeightUnit)disposeChangeWeightUnit:(Byte *)dataByte;
/**
 MARK:Hold
 0：保持hold,1：取消hold
 MCU与APP都可触发这条指令，当此指令触发，则APP与MCU都把重量锁住或释放
 */
+(HoldDataType)disposeHoldData:(Byte *)dataByte;
#pragma mark 身高
+(ELBabyScaleBleHeightModel *)disposeHeightData:(Byte *)dataByte;
#pragma mark 身高单位切换
+(ELDeviceHeightUnit)disposeChangeHeightUnit:(Byte *)dataByte;
#pragma mark  ============ 其他方法 ==============

@end

NS_ASSUME_NONNULL_END
