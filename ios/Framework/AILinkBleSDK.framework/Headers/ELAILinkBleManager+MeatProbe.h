//
//  ELAILinkBleManager+MeatProbe.h
//  AILinkBleSDK
//
//  Created by LarryZhang on 2022/11/22.
//

#import "ELAILinkBleManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELAILinkBleManager (MeatProbe)


//MeatProbe 设置设备信息 0x35
- (NSData *)meatProbeSendCustomData:(NSData *)customData;

//MeatProbe 设置设备信息 0x35 请求
- (NSData *)meatProbeRequestCustomData;

//切换温度单位 A7
- (NSData *)meatProbeSwitchUint:(ELDeviceTemperatureUnit)unit;


@end

NS_ASSUME_NONNULL_END
