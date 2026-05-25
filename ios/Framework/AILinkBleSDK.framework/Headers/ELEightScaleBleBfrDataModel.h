//
//  ELEightScaleBleBfrDataModel.h
//  AILinkBleSDK
//
//  Created by cliCk on 2021/8/25.
//  Copyright © 2021 IOT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELEightScaleSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

/** 秤端计算的体脂数据 */
@interface ELEightScaleBleBfrDataModel : NSObject

@property (nonatomic, assign) float BMI;

/** 全身体脂率 % */
@property (nonatomic, assign) float bodyBfr;

/** 全身肌肉率 % */
@property (nonatomic, assign) float bodyRom;

/** 左上肢脂肪量 kg */
@property (nonatomic, assign) float leftHandFatMass;
/** 右上肢脂肪量 kg */
@property (nonatomic, assign) float rightHandFatMass;
/** 躯干脂肪量 kg */
@property (nonatomic, assign) float bodyFatMass;
/** 左下肢脂肪量 kg */
@property (nonatomic, assign) float leftFootFatMass;
/** 右下肢脂肪量 kg */
@property (nonatomic, assign) float rightFootFatMass;


/** 左上肢肌肉量 kg */
@property (nonatomic, assign) float leftHandMuscleMass;
/** 右上肢肌肉量 kg */
@property (nonatomic, assign) float rightHandMuscleMass;
/** 躯干肌肉量 kg */
@property (nonatomic, assign) float bodyMuscleMass;
/** 左下肢肌肉量 kg */
@property (nonatomic, assign) float leftFootMuscleMass;
/** 右下肢肌肉量 kg */
@property (nonatomic, assign) float rightFootMuscleMass;

/** 身体水分 % */
@property (nonatomic, assign) float bodyWater;

/** 骨重 kg */
@property (nonatomic, assign) float BoneMass;

/** 基础代谢率 kcal */
@property (nonatomic, assign) int BMR;

/** 蛋白率 % */
@property (nonatomic, assign) float ProteinRate;

/** 内脏脂肪指数 */
@property (nonatomic, assign) int uvi;

/** 皮下脂肪 % */
@property (nonatomic, assign) float sfr;

/** 身高 cm */
@property (nonatomic, assign) int height;

/** 身体年龄 */
@property (nonatomic, assign) int bodyAge;

@end


/** 八电极需要用户数据对象模型 */
@interface ELEightScaleBleUserModel : NSObject

/** 用户特征 */
@property (nonatomic, assign) enum EightScaleRole role;

/** 当前用户所属好身材用户编号 */
@property (nonatomic, assign) int number;

/** 性别 1男，0女 */
@property (nonatomic, assign) int gender;

/** 年龄 */
@property (nonatomic, assign) int age;

/** 身高 cm */
@property (nonatomic, assign) int height;

@end


NS_ASSUME_NONNULL_END
