//
//  ELForeheadBleDataModel.h
//  Elink
//
//  Created by iot_user on 2019/5/10.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELForeheadHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELForeheadBleDataModel : NSObject

@property (nonatomic, assign) NSString * temperature;//温度
@property (nonatomic, assign) ELDeviceTemperatureUnit unit;//单位
@property (nonatomic, assign) NSInteger point;//小数点
@property (nonatomic, assign) long long createTime;//时间


@end

NS_ASSUME_NONNULL_END
