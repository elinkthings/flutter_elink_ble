//
//  ELAIFitScaleBleDataModel.h
//  Pods
//
//  Created by LarryZhang on 2023/8/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELAIFitScaleBleDataModel : NSObject


//@property (nonatomic, assign) double weightTimeStamp;


/// weight 565
@property (nonatomic, assign) float weightsum;

@property (nonatomic, assign) NSUInteger weightPoint;

/// TEMP
@property (nonatomic, assign) float temperature;

/// BMI
@property (nonatomic, assign) float BMI;

/// bfr
@property (nonatomic, assign) float fatRate;

/// rom
@property (nonatomic, assign) float muscle;

/// vwc
@property (nonatomic, assign) float moisture;

/// bm
@property (nonatomic, assign) float boneMass;

/// sfr
@property (nonatomic, assign) float subcutaneousFat;

/// bmr
@property (nonatomic, assign) float BMR;

/// pp
@property (nonatomic, assign) float proteinRate;

/// uvi
@property (nonatomic, assign) float visceralFat;

/// bodyAge
@property (nonatomic, assign) float physicalAge;

/// adc
@property (nonatomic, assign) float adc;

///Creation time with an accuracy of 1(创建时间,精度为1)
@property (nonatomic, assign) long long createTime;

///Algorithm ID(算法ID)
@property (nonatomic, assign) NSUInteger algNum;
@end

NS_ASSUME_NONNULL_END

/**
 APP下发当前用户或者用户列表前需要将appUser转换为如下bleUser
 */
@interface ELAIFitScaleBleUserModel : NSObject

@property (nonatomic, assign) long long createTime;
@property (nonatomic, assign) NSUInteger usrID;
@property (nonatomic, assign) NSUInteger sex;           //性别
@property (nonatomic, assign) NSUInteger age;           //Age 28 (only counts for the whole year)(年龄28(只算整年))
@property (nonatomic, assign) NSUInteger  height;       //Height 170 (Unit fixed to death: cm, accuracy 1)(身高170(单位定死:cm,精度1))
@property (nonatomic, assign) NSUInteger  weight;       //Weight 562 (Unit fixed death: kg, accuracy 0.1) 120lb-》 54.4lkg-》 545(体重562(单位定死:kg,精度0.1) 120lb-》54.4lkg-》545)

@property (nonatomic, assign) NSUInteger adc;//Impedance 1230 (accuracy is 1Ω)(阻抗1230(精度为 1Ω))

@end
