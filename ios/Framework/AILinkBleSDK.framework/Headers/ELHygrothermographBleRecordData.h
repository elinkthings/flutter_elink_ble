//
//  ELHygrothermographBleRecordData.h
//  AILinkBleSDK
//
//  Created by cliCk on 2021/5/8.
//  Copyright © 2021 IOT. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** 温湿度计历史记录对象模型 */
@interface ELHygrothermographBleRecordData : NSObject

/** 开机时间 */
@property (nonatomic, assign) long long bootTime;

/** 温度 摄氏度 */
@property (nonatomic, assign) float tem;

/** 湿度 % */
@property (nonatomic, assign) float hum;
 
@end

NS_ASSUME_NONNULL_END
