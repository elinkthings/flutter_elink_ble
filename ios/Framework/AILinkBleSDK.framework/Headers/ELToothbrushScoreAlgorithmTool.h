//
//  ELToothbrushScoreAlgorithmTool.h
//  AILinkBleSDK
//
//  Created by LarryZhang on 2022/11/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELToothbrushScoreAlgorithmTool : NSObject

//总得分
+ (int)totalScoreDefaultTime:(int)defaultTime
                   totalTime:(int)totalTime
                    leftTime:(int)leftTime
                   rightTime:(int)rightTime;

//刷牙时长
+ (int)durationScoreDefaultTime:(int)defaultTime
                      totalTime:(int)totalTime
                       leftTime:(int)leftTime
                      rightTime:(int)rightTime;

//刷牙范围
+ (int)rangeScoreDefaultTime:(int)defaultTime
                   totalTime:(int)totalTime
                    leftTime:(int)leftTime
                   rightTime:(int)rightTime;

//刷牙均匀度
+ (int)uniformityScoreDefaultTime:(int)defaultTime
                        totalTime:(int)totalTime
                         leftTime:(int)leftTime
                        rightTime:(int)rightTime;

@end

NS_ASSUME_NONNULL_END
