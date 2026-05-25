//
//  ELbloodPresureBleWifiDataModel.h
//  AILinkBleSDK
//
//  Created by iot on 2022/7/12.
//  Copyright © 2022 IOT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELBloodBleSDKHeader.h"
NS_ASSUME_NONNULL_BEGIN

@interface ELbloodPresureBleWifiDataModel : NSObject
@property (nonatomic, copy) NSString *dia;//Diastolic blood pressure(舒张压)
@property (nonatomic, copy) NSString *sys; //Systolic blood pressure(收缩压)
@property (nonatomic, assign) int heartRate; //Heart rate(心率)
@property (nonatomic, assign) ELDeviceBloodPressureUnit unit;//单位
@property (nonatomic, assign) int point; //小数点
@property (nonatomic, assign) long long createTime;//时间
@end

NS_ASSUME_NONNULL_END
