//
//  ELSkipBleDataModel.h
//  AILinkBleSDK
//
//  Created by cliCk on 2021/6/17.
//  Copyright © 2021 IOT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELSkipBleHeader.h"

NS_ASSUME_NONNULL_BEGIN

/** 跳绳基础的数据模型 */
@interface ELSkipBleDataModel : NSObject

/** 模式 */
@property (nonatomic, assign) enum Skip_UseModeType modeType;

/** 倒计时跳绳或倒计数跳绳模式下的倒计时或倒计数 */
@property (nonatomic, assign) NSUInteger countdownNum;

/** 运动时间 */
@property (nonatomic, assign) NSUInteger sportTime;

/** 跳绳个数 */
@property (nonatomic, assign) NSUInteger sportNum;

@end



/** 绊绳数据对象模型 */
@interface ELSkipBleTripRopeModel : NSObject

/** 本次连跳的累计时间,字段弄短点，方便后台数据存储 */
@property (nonatomic, assign) long long t;

/** 本次连跳的累计个数 */
@property (nonatomic, assign) NSUInteger j;

@end



/** 跳绳记录数据模型 */
@interface ELSkipHistoryDataModel : NSObject

/** 开始时间戳 */
@property (nonatomic, assign) long long startTime;

/** 跳绳基础数据模型 */
@property (nonatomic, strong) ELSkipBleDataModel *dataModel;

/** 平均频次（次/分） */
@property (nonatomic, assign) NSUInteger avgRate;

/** 最快频次（次/分） */
@property (nonatomic, assign) NSUInteger maxRate;

/** 绊绳数据列表 */
@property (nonatomic, copy) NSArray<ELSkipBleTripRopeModel *> *tripRopeList;

@end

NS_ASSUME_NONNULL_END
