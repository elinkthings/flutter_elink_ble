//
//  ELThermometerDisposeDataTool.h
//  Elink
//
//  Created by cliCk on 2019/5/28.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import "ELBleDisposeDataTool.h"
#import "ELThermometerBleModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELThermometerDisposeDataTool : ELBleDisposeDataTool

/** 温度数据 */
+ (ELThermometerBleModel *)disposeData:(Byte *)dataByte;

@end

NS_ASSUME_NONNULL_END
