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

/** 脂肪量 kg */
@property (nonatomic, assign) float fatMass;

/** 体水分量 kg */
@property (nonatomic, assign) float bodyWaterWeight;

/** 骨盐量 kg */
@property (nonatomic, assign) float boneSaltContent;

/** 无机盐 kg */
@property (nonatomic, assign) float inorganicSalts;

/** 蛋白质量 kg */
@property (nonatomic, assign) int proteinContent;

/** 肌肉量 kg */
@property (nonatomic, assign) float muscleMass;

/** 去脂体重 kg */
@property (nonatomic, assign) float leanBodyMass;

/** 骨骼肌 kg */
@property (nonatomic, assign) float skeletalMuscle;

/** 身体得分 */
@property (nonatomic, assign) int physicalScore;

/** 身体质量指数（精度0.1kg/m^2） */
@property (nonatomic, assign) float bodyMassIndex;

/** 标准体重 */
@property (nonatomic, assign) int standardWeight;

/** 肌肉控制 */
@property (nonatomic, assign) int muscleControl;

/** 腰臀比 */
@property (nonatomic, assign) float whr;

/** 体型控制 */
@property (nonatomic, assign) int bodyShapeControl;

/** 脂肪控制 */
@property (nonatomic, assign) int fatControl;

/** 体重控制 */
@property (nonatomic, assign) int weightControl;

/** 左上脂肪占比 */
@property (nonatomic, assign) float upperLeftFatPercentage;

/** 右上脂肪占比 */
@property (nonatomic, assign) float upperRightFatPercentage;

/** 躯干脂肪占比 */
@property (nonatomic, assign) float trunkFatPercentage;

/** 左下脂肪占比 */
@property (nonatomic, assign) float lowerLeftFatPercentage;

/** 右下脂肪占比 */
@property (nonatomic, assign) float lowerRightFatPercentage;

/** 左上肌肉占比 */
@property (nonatomic, assign) float leftUpperMusclePercentage;

/** 右上肌肉占比 */
@property (nonatomic, assign) float rightUpperMusclePercentage;

/** 躯干肌肉占比 */
@property (nonatomic, assign) float trunkMusclePercentage;

/** 左下肌肉占比 */
@property (nonatomic, assign) float leftLowerMusclePercentage;

/** 右下肌肉占比 */
@property (nonatomic, assign) float rightLowerMusclePercentage;

@end


/** 八电极需要用户数据对象模型 */
@interface ELEightScaleBleUserModel : NSObject

/** 旧用户特征 */
@property (nonatomic, assign) enum EightScaleRole role;

/** 新用户特征 */
@property (nonatomic, assign) int userMode;

/** 当前用户所属好身材用户编号 */
@property (nonatomic, assign) int number;

/** 性别 1男，0女 */
@property (nonatomic, assign) int gender;

/** 年龄 */
@property (nonatomic, assign) int age;

/** 身高 cm */
@property (nonatomic, assign) int height;

/** 当前体重重量 0.1kg 需要转成整数*/
@property (nonatomic, assign) int currentWeight;

/** 初始体重重量 0.1kg 需要转成整数*/
@property (nonatomic, assign) int initialWeight;

/** 目标体重重量 0.1kg 需要转成整数*/
@property (nonatomic, assign) int targetWeight;

/** 用户ID */
@property (nonatomic, assign) NSInteger userId;
@end


// ========== 定义协议 ==========
@protocol ELEightScaleHistoryRecordProtocol <NSObject>
/**记录时间戳**/
@property (nonatomic, assign) long long createTime;
/** 当前用户所属好身材用户编号 */
@property (nonatomic, assign) int number;
/**用户模式**/
@property (nonatomic, assign) int userMode;
/**性别**/
@property (nonatomic, assign) ELBluetoothUserSex sex;
/**年龄**/
@property (nonatomic, assign) NSUInteger age;
/**身高（1cm）**/
@property (nonatomic, assign) int height;
/**Kg初始重量数据低字节（0.1kg）**/
@property (nonatomic, assign) float initialWeight;
/** 目标体重重量 0.1kg */
@property (nonatomic, assign) float targetWeight;
/** 用户ID */
@property (nonatomic, assign) NSInteger userID;
/** 当前体重重量 **/
@property (nonatomic, assign) float currentWeight;
/** 重量数据精度 **/
@property (nonatomic, assign) int weightPoint;
/** 当前单位：
 0：kg
 1：斤
 4：st:lb
 6：lb **/
@property (nonatomic, assign) int weightUnit;
@end

/** 八电极MCU算法历史记录数据对象模型 */
@interface ELEightScaleMCUAlgorithmHistoryDataModel: ELEightScaleBleBfrDataModel <ELEightScaleHistoryRecordProtocol>

/**记录时间戳**/
@property (nonatomic, assign) long long createTime;
/** 当前用户所属好身材用户编号 */
@property (nonatomic, assign) int number;
/**用户模式**/
@property (nonatomic, assign) int userMode;
/**性别**/
@property (nonatomic, assign) ELBluetoothUserSex sex;
/**年龄**/
@property (nonatomic, assign) NSUInteger age;
/**Kg初始重量数据低字节（0.1kg）**/
@property (nonatomic, assign) float initialWeight;
/** 目标体重重量 0.1kg */
@property (nonatomic, assign) float targetWeight;
/** 用户ID */
@property (nonatomic, assign) NSInteger userID;
/** 当前体重重量 **/
@property (nonatomic, assign) float currentWeight;
/** 重量数据精度 **/
@property (nonatomic, assign) int weightPoint;
/** 当前单位：
 0：kg
 1：斤
 4：st:lb
 6：lb **/
@property (nonatomic, assign) int weightUnit;

@end


/** 八电极APP算法单频历史记录数据对象模型 */
@interface ELEightScaleAPPAlgorithmSingleFrequencyHistoryDataModel: NSObject <ELEightScaleHistoryRecordProtocol>

/**记录时间戳**/
@property (nonatomic, assign) long long createTime;
/** 当前用户所属好身材用户编号 */
@property (nonatomic, assign) int number;
/**用户模式**/
@property (nonatomic, assign) int userMode;
/**性别**/
@property (nonatomic, assign) ELBluetoothUserSex sex;
/**年龄**/
@property (nonatomic, assign) NSUInteger age;
/**身高（1cm）**/
@property (nonatomic, assign) int height;
/**Kg初始重量数据低字节（0.1kg）**/
@property (nonatomic, assign) float initialWeight;
/** 目标体重重量 0.1kg */
@property (nonatomic, assign) float targetWeight;
/** 用户ID */
@property (nonatomic, assign) NSInteger userID;
/** 当前体重重量 **/
@property (nonatomic, assign) float currentWeight;
/** 重量数据精度 **/
@property (nonatomic, assign) int weightPoint;
/** 当前单位：
 0：kg
 1：斤
 4：st:lb
 6：lb **/
@property (nonatomic, assign) int weightUnit;

#pragma mark 阻抗 单电极体脂秤的阻抗数据(只有这一条阻抗数据),双电极体脂秤的20kHZ频率的阻抗数据)
/**0x00 阻抗值1(双脚阻抗)**/
@property (nonatomic, assign) int footImpedanceAt20kHz;
/**双脚阻抗值**/
@property (nonatomic, assign) NSInteger footImpedanceAt20kHzValue;
/**0x01 阻抗值2(双手阻抗)**/
@property (nonatomic, assign) int handImpedanceAt20kHz;
/**双手阻抗值**/
@property (nonatomic, assign) NSInteger handImpedanceAt20kHzValue;
/**0x02 阻抗值3(左手阻抗)**/
@property (nonatomic, assign) int leftHandImpedanceAt20kHz;
/**左手阻抗值**/
@property (nonatomic, assign) NSInteger leftHandImpedanceAt20kHzValue;
/**0x03 阻抗值4(右手阻抗)**/
@property (nonatomic, assign) int rightHandImpedanceAt20kHz;
/**左手阻抗值**/
@property (nonatomic, assign) NSInteger rightHandImpedanceAt20kHzValue;
/**0x04 阻抗值5(左脚阻抗)**/
@property (nonatomic, assign) int leftFootImpedanceAt20kHz;
/**左脚阻抗值**/
@property (nonatomic, assign) NSInteger leftFootImpedanceAt20kHzValue;
/**0x05 阻抗值6(右脚阻抗)**/
@property (nonatomic, assign) int rightFootImpedanceAt20kHz;
/**右脚阻抗值**/
@property (nonatomic, assign) NSInteger rightFootImpedanceAt20kHzValue;
/**0x06 阻抗值7(左全身阻抗)**/
@property (nonatomic, assign) int leftFullBodyImpedanceAt20kHz;
/**左全身阻抗值**/
@property (nonatomic, assign) NSInteger leftFullBodyImpedanceAt20kHzValue;
/**0x07 阻抗值8(右全身阻抗)**/
@property (nonatomic, assign) int rightFullBodyImpedanceAt20kHz;
/**右全身阻抗值**/
@property (nonatomic, assign) NSInteger rightFullBodyImpedanceAt20kHzValue;
/**0x08 阻抗值9(右手左脚阻抗)**/
@property (nonatomic, assign) int rightHandLeftFootImpedanceAt20kHz;
/**右手左脚阻抗值**/
@property (nonatomic, assign) NSInteger rightHandLeftFootImpedanceAt20kHzValue;
/**0x09 阻抗值10(左手右脚阻抗)**/
@property (nonatomic, assign) int leftHandRightFootImpedanceAt20kHz;
/**左手右脚阻抗值**/
@property (nonatomic, assign) NSInteger leftHandRightFootImpedanceAt20kHzValue;
/**0x0A 阻抗值11(躯干阻抗)**/
@property (nonatomic, assign) int trunkImpedanceAt20kHz;
/**躯干阻抗值**/
@property (nonatomic, assign) NSInteger trunkImpedanceAt20kHzValue;
/**算法标识**/
@property (nonatomic, assign) int algorithmID;

@end


/** 八电极APP算法双频历史记录数据对象模型 */
@interface ELEightScaleAPPAlgorithmDoubleFrequencyHistoryDataModel: ELEightScaleAPPAlgorithmSingleFrequencyHistoryDataModel <ELEightScaleHistoryRecordProtocol>

#pragma mark -数据部分3(双电极体脂秤的100kHZ频率的阻抗数据,单电极没有这条指令)
/**0x00 阻抗值1(双脚阻抗)**/
@property (nonatomic, assign) int footImpedanceAt100kHz;
/**双脚阻抗值**/
@property (nonatomic, assign) NSInteger footImpedanceAt100kHzValue;
/**0x01 阻抗值2(双手阻抗)**/
@property (nonatomic, assign) int handImpedanceAt100kHz;
/**双手阻抗值**/
@property (nonatomic, assign) NSInteger handImpedanceAt100kHzValue;
/**0x02 阻抗值3(左手阻抗)**/
@property (nonatomic, assign) int leftHandImpedanceAt100kHz;
/**左手阻抗值**/
@property (nonatomic, assign) NSInteger leftHandImpedanceAt100kHzValue;
/**0x03 阻抗值4(右手阻抗)**/
@property (nonatomic, assign) int rightHandImpedanceAt100kHz;
/**左手阻抗值**/
@property (nonatomic, assign) NSInteger rightHandImpedanceAt100kHzValue;
/**0x04 阻抗值5(左脚阻抗)**/
@property (nonatomic, assign) int leftFootImpedanceAt100kHz;
/**左脚阻抗值**/
@property (nonatomic, assign) NSInteger leftFootImpedanceAt100kHzValue;
/**0x05 阻抗值6(右脚阻抗)**/
@property (nonatomic, assign) int rightFootImpedanceAt100kHz;
/**右脚阻抗值**/
@property (nonatomic, assign) NSInteger rightFootImpedanceAt100kHzValue;
/**0x06 阻抗值7(左全身阻抗)**/
@property (nonatomic, assign) int leftFullBodyImpedanceAt100kHz;
/**左全身阻抗值**/
@property (nonatomic, assign) NSInteger leftFullBodyImpedanceAt100kHzValue;
/**0x07 阻抗值8(右全身阻抗)**/
@property (nonatomic, assign) int rightFullBodyImpedanceAt100kHz;
/**右全身阻抗值**/
@property (nonatomic, assign) NSInteger rightFullBodyImpedanceAt100kHzValue;
/**0x08 阻抗值9(右手左脚阻抗)**/
@property (nonatomic, assign) int rightHandLeftFootImpedanceAt100kHz;
/**右手左脚阻抗值**/
@property (nonatomic, assign) NSInteger rightHandLeftFootImpedanceAt100kHzValue;
/**0x09 阻抗值10(左手右脚阻抗)**/
@property (nonatomic, assign) int leftHandRightFootImpedanceAt100kHz;
/**左手右脚阻抗值**/
@property (nonatomic, assign) NSInteger leftHandRightFootImpedanceAt100kHzValue;
/**0x0A 阻抗值11(躯干阻抗)**/
@property (nonatomic, assign) int trunkImpedanceAt100kHz;
/**躯干阻抗值**/
@property (nonatomic, assign) NSInteger trunkImpedanceAt100kHzValue;

@end

NS_ASSUME_NONNULL_END
