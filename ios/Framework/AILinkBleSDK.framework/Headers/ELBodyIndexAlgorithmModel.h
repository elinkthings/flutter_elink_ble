//
//  ELBodyIndexAlgorithmModel.h
//  Elink
//
//  Created by iot_user on 2020/6/8.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELSDKHeader.h"

typedef NS_ENUM(NSInteger, PHSex) {
    PHSex_FEMALE   = 0, //女
    PHSex_MALE     = 1,//男
};

//矿物质重量
typedef NS_ENUM(NSUInteger, AILinkMineralWeightType) {
    AILinkMineralWeightTypeUnknown = 0,//未知
    AILinkMineralWeightTypeInsufficient = 1,//不足
    AILinkMineralWeightTypeStandard = 2,//标准
    AILinkMineralWeightTypeExcellent    = 3,//偏高
};


//四肢肌肉指数
typedef NS_ENUM(NSUInteger, AILinkLimbMuscleIndexType) {
    AILinkLimbMuscleIndexTypeUnknown = 0,//未知
    AILinkLimbMuscleIndexTypeInsufficient = 1,//不足
    AILinkLimbMuscleIndexTypeStandard = 2,//标准
    AILinkLimbMuscleIndexTypeExcellent    = 3,//优
};


//肥胖等级 标准判断
typedef NS_ENUM(NSUInteger, AILinkFatLevelType) {
    AILinkFatLevelTypeUnknown = 0,//未知
    AILinkFatLevelTypeStandard = 1,//标准
    AILinkFatLevelTypeThin     = 2,//偏瘦
    AILinkFatLevelTypeBiased   = 3,//偏重
    AILinkFatLevelTypeUnderWeight = 4,//体重不足
    AILinkFatLevelTypeOverWeight = 5, //超重
};


//蛋白量判断标准
typedef NS_ENUM(NSUInteger, AILinkProteinMassType) {
    AILinkProteinMassTypeUnknown      = 0,//未知
    AILinkProteinMassTypeInsufficient = 1,//不足
    AILinkProteinMassTypeStandard     = 2,//标准
    AILinkProteinMassTypeExcellent    = 3,//优
};
//肌肉量判断标准
typedef NS_ENUM(NSUInteger, AILinkMuscleMassType) {
    AILinkMuscleMassTypeUnknown      = 0,//未知
    AILinkMuscleMassTypeInsufficient = 1,//不足
    AILinkMuscleMassTypeStandard     = 2,//标准
    AILinkMuscleMassTypeExcellent    = 3,//优
};

//脂肪量判断标准
typedef NS_ENUM(NSInteger, AILinkFatMassType) {
    AILinkFatMassTypeUnknown = 0,
    AILinkFatMassTypeLow = 1, //偏低
    AILinkFatMassTypeStandard = 2 , //标准
    AILinkFatMassTypeLittleHigh = 3 , //偏高
    AILinkFatMassTypeHigh     = 4 , //高
};

//身体年龄判断标准
typedef NS_ENUM(NSUInteger, AILinkPhysicalAgeType) {
    AILinkPhysicalAgeTypeUnknown      = 0,//未知
    AILinkPhysicalAgeTypeExcellent    = 1,//优
    AILinkPhysicalAgeTypeStandard     = 2,//标准
    AILinkPhysicalAgeTypeTooLarge     = 3,//偏大
};

//蛋白率判断标准
typedef NS_ENUM(NSUInteger, AILinkProteinRateType) {
    AILinkProteinRateTypeUnknown      = 0,//未知
    AILinkProteinRateTypeInsufficient = 1,//不足
    AILinkProteinRateTypeStandard     = 2,//标准
    AILinkProteinRateTypeExcellent    = 3,//优
};

//皮下脂肪判断标准
typedef NS_ENUM(NSUInteger, AILinkSubcutaneousFatType) {
    AILinkSubcutaneousFatTypeUnknown      = 0,//未知
    AILinkSubcutaneousFatTypeInsufficient = 1,//不足
    AILinkSubcutaneousFatTypeStandard     = 2,//标准
    AILinkSubcutaneousFatTypeHigh         = 3,//偏高
};

//内脏脂肪判断标准
typedef NS_ENUM(NSUInteger, AILinkVisceralFatType) {
    AILinkVisceralFatTypeUnknown      = 0,//未知
    AILinkVisceralFatTypeStandard     = 1,//标准
    AILinkVisceralFatTypeWarning      = 2,//警惕
    AILinkVisceralFatTypeDanger       = 3,//危险
};

//基础代谢率判断标准
typedef NS_ENUM(NSUInteger, AILinkBMRType) {
    AILinkBMRTypeUnknown      = 0,//未知
    AILinkBMRTypeLow          = 1,//偏低
    AILinkBMRTypeExcellent    = 2,//优
    AILinkBMRTypeStandard     = 3,//标准
};


//骨量判断标准
typedef NS_ENUM(NSUInteger, AILinkBoneMassType) {
    AILinkBoneMassTypeUnknown      = 0,//未知
    AILinkBoneMassTypeInsufficient = 1,//不足
    AILinkBoneMassTypeStandard     = 2,//标准
    AILinkBoneMassTypeExcellent    = 3,//优
};
//水分判断标准
typedef NS_ENUM(NSUInteger, AILinkMoistureType) {
    AILinkMoistureTypeUnknown      = 0,//未知
    AILinkMoistureTypeInsufficient = 1,//不足
    AILinkMoistureTypeStandard     = 2,//标准
    AILinkMoistureTypeExcellent    = 3,//优
};


//肌肉率判断标准
typedef NS_ENUM(NSUInteger, AILinkMuscleRateType) {
    AILinkMuscleRateTypeUnknown      = 0,//未知
    AILinkMuscleRateTypeInsufficient = 1,//不足
    AILinkMuscleRateTypeStandard     = 2,//标准
    AILinkMuscleRateTypeExcellent    = 3,//优
};


//体脂率BFR判断标准
typedef NS_ENUM(NSInteger, AILinkBFRType) {
    AILinkBFRTypeUnknown = 0,
    AILinkBFRTypeLow = 1, //偏低
    AILinkBFRTypeStandard = 2 , //标准
    AILinkBFRTypeLittleHigh = 3 , //偏高
    AILinkBFRTypeHigh     = 4 , //高
};

//BMI判断标准
typedef NS_ENUM(NSUInteger, AILinkBMIType) {
    AILinkBMITypeUnknown = 0,//未知
    AILinkBMITypeThin = 1,//偏瘦
    AILinkBMITypeStandard = 2,//标准
    AILinkBMITypeFatty = 3,//偏胖
    AILinkBMITypeObesity = 4 //肥胖
};

//体重判断标准
typedef NS_ENUM(NSUInteger, AILinkWeightType) {
    AILinkWeightTypeUnknown = 0, //未知
    AILinkWeightTypeThin = 1,//偏瘦
    AILinkWeightTypeStandard = 2,//标准
    AILinkWeightTypeFatty = 3,//偏胖
    AILinkWeightTypeObesity = 4 //肥胖
};


NS_ASSUME_NONNULL_BEGIN

@interface ELBodyIndexAlgorithmModel : NSObject
#pragma mark  ============ 标准判断临界值数组 ==============


/// 四肢肌肉指数 标准判断
/// @param sex 性别
/// @param cmHeight 身高（cm）
+(NSArray<NSString *> *)getLimbMuscleIndexScopeWithSex:(PHSex)sex cmHeight:(float)cmHeight;

/// 蛋白量 标准判断
/// @param weight 体重(KG)
/// @param sex 性别
/// @param weightUnit 体重单位
+ (NSArray<NSString *> *)getProteinScope:(NSString *)weight sex:(PHSex)sex weightUnit:(ELDeviceWeightUnit)weightUnit;

/// 肌肉量 标准判断2个临界值
/// @param weight 体重（kg）
/// @param sex 性别
/// @param weightUnit 体重单位
+ (NSArray<NSString *> *)getMuscleMassScope:(NSString *)weight Sex:(PHSex)sex weightUnit:(ELDeviceWeightUnit)weightUnit;

/// 脂肪量 标准判断3个临界值
/// @param weight 体重（kg）
/// @param sex 性别
/// @param age 年龄
/// @param weightUnit 体重单位
+ (NSArray<NSString *> *)getFatScope:(NSString *)weight sex:(PHSex)sex age:(float)age weightUnit:(ELDeviceWeightUnit)weightUnit;
/// 身体年龄 标准判断2个临界值
/// @param age 年龄 
+ (NSArray<NSString *> *)getPhysicalAgeScopeAge:(int)age;

/// 蛋白率 标准判断
/// @param sex 性别
+ (NSArray<NSString *> *)getProteinRateScopeSex:(PHSex)sex;

/// 皮下脂肪 标准判断2个临界值
/// @param sex 性别
+ (NSArray<NSString *> *)getSubcutaneousFatScopeSex:(PHSex)sex;

/// 内脏脂肪 标准判断2个临界值
+ (NSArray<NSString *> *)getVisceralfatScope;

/// 基础代谢率 标准判断1个临界值
/// @param BMR 基础代谢率
/// @param age 年龄
/// @param weight 体重（kg）
/// @param sex 性别
+ (NSArray<NSString *> *)getBMRScope:(float)BMR age:(float)age weight:(float)weight sex:(PHSex)sex;
/// 骨量 标准判断2个临界值
/// @param sex 性别
/// @param weight 体重（kg）
/// @param weightUnit 体重单位
+ (NSArray<NSString *> *)getBonemassScopeSex:(PHSex)sex weight:(float)weight weightUnit:(ELDeviceWeightUnit)weightUnit;

/// 水分 标准判断2个临界值
/// @param sex 性别
+ (NSArray<NSString *> *)getMoistureScopeSex:(PHSex)sex;
/// 肌肉率 标准判断2个临界值
/// @param sex 性别
+ (NSArray<NSString *> *)getMuscleScopeSex:(PHSex)sex;
/// 体脂率 标准判断三个临界值
/// @param sex 性别
/// @param age 年龄
+ (NSArray<NSString *> *)getFatRateScopeSex:(PHSex)sex age:(float)age;
/// BMI 标准判断的三个临界值
/// @param sex 性别
/// @param age 年龄
+ (NSArray<NSString *> *)getBMIWithSex:(PHSex)sex age:(float)age;

/// 体重标准判断的三个临界值
/// @param height 身高（cm）
/// @param weightUnit 体重单位
+ (NSArray<NSString *> *)getWeightScopeHeight:(NSString *)height weightUnit:(ELDeviceWeightUnit)weightUnit;

/// 骨骼肌量 标准判断2个临界值 单位KG
/// @param sex 性别
/// @param age 年龄
+ (NSArray<NSString *> *)getSkeletalMuscleMassScopeSex:(PHSex)sex age:(float)age;

/// 水分重量 标准判断2个临界值
/// @param sex 性别
/// @param weight 体重
+ (NSArray<NSString *> *)getWaterWeightScopeSex:(PHSex)sex weight:(float)weight;

/// 皮下脂肪量 标准判断2个临界值
/// @param sex 性别
/// @param weight 体重
+ (NSArray<NSString *> *)getSubcutaneousFatMassScopeSex:(PHSex)sex weight:(float)weight;
#pragma mark  ============ 判断标准数组 ==============
//四肢肌肉指数标准词条
+(NSArray<NSNumber *> *)getLimbMuscleIndexStandardArray;
///1 体重 判断标准词条Array<AILinkWeightType>
+ (NSArray<NSNumber *> *)getWeightStandardArray;
///2 BMI 判断标准词条Array<AILinkBMIType>
+ (NSArray<NSNumber *> *)getBMIStandardArray;
///3 体脂率 判断标准词条Array<AILinkBFRType>
+ (NSArray<NSNumber *> *)getFatRateStandardArray;
///4 肌肉率 判断标准词条Array<AILinkMuscleRateType>
+ (NSArray<NSNumber *> *)getMuscleStandardArray;
///5 水分 判断标准词条Array<AILinkMoistureType>
+ (NSArray<NSNumber *> *)getMoistureStandardArray;
///6 骨量 判断标准词条Array<AILinkBoneMassType>
+ (NSArray<NSNumber *> *)getBonemassStandardArray;
///7 基础代谢率 判断标准词条Array<AILinkBMRType>
+ (NSArray<NSNumber *> *)getBMRStandardArray;
///8 内脏脂肪 判断标准词条Array<AILinkVisceralFatType>
+ (NSArray<NSNumber *> *)getVisceralfatStandardArray;
///9 皮下脂肪 判断标准词条Array<AILinkSubcutaneousFatType>
+ (NSArray<NSNumber *> *)getSubcutaneousFatStandardArray;
///10 蛋白率 判断标准词条Array<AILinkProteinRateType>
+ (NSArray<NSNumber *> *)getProteinRateStandardArray;
///11 身体年龄 判断标准词条Array<AILinkPhysicalAgeType>
+ (NSArray<NSNumber *> *)getPhysicalAgeStandardArray;
///14 脂肪量 判断标准词条Array<AILinkFatMassType>（与体脂率是一样的）
+ (NSArray<NSNumber *> *)getFatmassStandardArray;
///16 肌肉量 判断标准词条Array<AILinkMuscleMassType>（与肌肉率是一样的）
+ (NSArray<NSNumber *> *)getMuscleMassStandardArray;
///17 蛋白量 判断标准词条Array<AILinkProteinMassType>（与蛋白率是一样的）
+ (NSArray<NSNumber *> *)getProteinStandardArray;
///18 肥胖等级 判断标准词条Array<AILinkFatLevelType>
+ (NSArray<NSNumber *> *)getFatlevelStandardArray;

#pragma mark  ============ 标准判断 ==============

/// 获取四肢肌肉指数等级
/// @param index 四肢肌肉指数
/// @param sex 性别
+(AILinkLimbMuscleIndexType)getLimbDisplay:(float)index sex:(PHSex)sex cmHeight:(float)cmHeight;

/**
 *  18 肥胖等级 标准判断
 *
 *  @param fatlevel 传入0~4
 *
 *  @return 标准、偏瘦、偏重、体重不足、超重、@""
 */
+ (AILinkFatLevelType)getFatlevelDisplay:(NSInteger)fatlevel;

///17 蛋白量 标准判断（与蛋白率是一样的）
/// @param proteinMass 蛋白量（kg）
/// @param sex 性别
/// @param kgWeight 体重（kg）
+ (AILinkProteinMassType)getProteinDisplay:(float)proteinMass sex:(PHSex)sex kgWeight:(float)kgWeight;

///16 肌肉量 标准判断（与肌肉率是一样的）
/// @param muscle 肌肉量（KG）
/// @param sex 性别
/// @param kgWeight 体重（KG）
+ (AILinkMuscleMassType)getMuscleMassDisplay:(float)muscle sex:(PHSex)sex kgWeight:(float)kgWeight;

///14 脂肪量 标准判断（与体脂率是一样的）
/// @param fatMass 脂肪量（KG）
/// @param sex 性别
/// @param age 年龄
/// @param kgWeight 体重（KG）
+ (AILinkFatMassType)getFatDisplay:(float)fatMass sex:(PHSex)sex age:(float)age kgWeight:(float)kgWeight;

/**
 *  身体年龄 标准判断
 *
 *  @param physicalAge 身体年龄
 *  @param age         年龄
 *
 *  @return 偏大、标准、偏小、Null
 */
+ (AILinkPhysicalAgeType)getPhysicalAgeDisplay:(int)physicalAge age:(int)age;

/**
 *  蛋白率 标准判断
 *
 *  @param proteinRate 蛋白率
 *  @param sex         性别
 *
 *  @return 偏低、标准、偏高、Null
 */
+ (AILinkProteinRateType)getProteinRateDisplay:(float)proteinRate sex:(PHSex)sex;

/**
 *  皮下脂肪 标准判断
 *
 *  @param proteinRate 皮下脂肪
 *  @param sex         性别
 *
 *  @return --.--
 */
+ (AILinkSubcutaneousFatType)getSubcutaneousFatDisplay:(float)proteinRate sex:(PHSex)sex;

/**
 *  内脏脂肪 标准判断
 *
 *  @param visceralfat 内脏脂肪
 *
 *  @return 标准、偏高、高、Null
 */
+ (AILinkVisceralFatType)getVisceralfatDisplay:(float)visceralfat;

/**
 *  基础代谢率 标准判断
 *
 *  @param BMR    基础代谢率
 *  @param age    年龄
 *  @param weight 体重
 *  @param sex    性别
 *
 *  @return 标准、未达标
 */
+ (AILinkBMRType)getBMRDisplay:(float)BMR age:(float)age weight:(float)weight sex:(PHSex)sex;

/**
 *  骨量 标准判断
 *
 *  @param bonemass 骨量
 *  @param sex      性别
 *  @param weight   体重
 *
 *  @return 偏低、标准、偏高、Null
 */
+ (AILinkBoneMassType)getBonemassDisplay:(float)bonemass sex:(PHSex)sex weight:(float)weight;

/**
 *  水分标准
 *
 *  @param moisture 水分
 *  @param sex      性别
 *
 *  @return 偏低、标准、偏高、Null
 */
+ (AILinkMoistureType)getMoistureDisplay:(float)moisture sex:(PHSex)sex;

/**
 *  肌肉率 标准判断
 *
 *  @param muscle 肌肉量（kg）
 *  @param sex    性别
 *  @return 偏低、标准、偏高、Null
 *
 */
+ (AILinkMuscleRateType)getMuscleDisplay:(float)muscle sex:(PHSex)sex;

/**
 *  体脂率 标准判断
 *  @param fatRate 体脂率
 *  @param sex     性别
 *  @param age     年龄
 *  @return 偏低、标准、偏高、高、Null
 */
+ (AILinkBFRType)getFatRateDisplay:(float)fatRate sex:(PHSex)sex age:(float)age;

/**
 *  BMI 标准判断
 *
 *  @param BMI BMI
 *
 *  @return 偏瘦、标准、偏胖、肥胖、--.--
 */
+ (AILinkBMIType)getBMIDisplay:(float)BMI sex:(PHSex)sex age:(float)age;
/**
 *  体重 标准判断
 *
 *  @param height 身高
 *  @param weight 体重
 *
 *  @return 偏瘦、标准、偏胖、肥胖、Null
 */
+ (AILinkWeightType)getWeightDisplay:(NSString *)height weight:(NSString *)weight;


/// 获取标准体重(单位：kg)
/// @param sex 性别
/// @param height 身高（CM）
+ (double) getStandardWeight:(NSInteger)sex andheight:(NSInteger)height;


/// 获取肥胖等级
/// @param weight 体重（KG）
/// @param standardWeight 标准体重（KG）
+ (AILinkFatLevelType)getfatLevelWithweight:(double)weight andStandardWeight:(double)standardWeight;


#pragma mark -  新增指标
/**
 *  矿物质重量 标准判断
 *
 *  @param mineralWeightValue 体重（KG）
 *  @param weight 体重
 *
 *  @return 不足、标准、偏高、Null
 */
+ (AILinkMineralWeightType)getMineralWeightType:(float)mineralWeightValue;

@end

NS_ASSUME_NONNULL_END
