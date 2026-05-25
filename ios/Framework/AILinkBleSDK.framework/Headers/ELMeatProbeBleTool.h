//
//  ELMeatProbeBleTool.h
//  AILinkBleSDK
//
//  Created by LarryZhang on 2022/11/22.
//

#import <Foundation/Foundation.h>
#import "ELSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct ELMeatProbeBleTemperatureStruct {
    BOOL isValid;
    //内部温度 实时温度
    NSInteger internalTemperature;
    ELDeviceTemperatureUnit internalTemperatureUnit;
    NSInteger internalTemperature_C;
    NSInteger internalTemperature_F;
    //环境温度 外部温度
    NSInteger ambientTemperature;
    ELDeviceTemperatureUnit ambientTemperatureUnit;
    NSInteger ambientTemperature_C;
    NSInteger ambientTemperature_F;
    //生成时间
    double createTime;
} ELMeatProbeBleTemperatureStruct;

@interface ELMeatProbeBleTool : NSObject

+ (NSArray<NSNumber *> *)cids;

+ (ELMeatProbeBleTemperatureStruct)parseTemperature:(NSData *)payload;

//打包和拆包温度数据
+ (UInt16)packTemperature:(NSInteger)temperature uint:(ELDeviceTemperatureUnit)unit;
+ (NSInteger)getTemperature:(UInt16)packedTemperature;
+ (ELDeviceTemperatureUnit)getUInt:(UInt16)packedTemperature;

//温度换算
+ (float)convertF2C:(float)fahrenheit;
+ (float)convertC2F:(float)celsius;

@end

NS_ASSUME_NONNULL_END
