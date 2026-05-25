//
//  ELBodyFatScaleBodyDataModel.h
//  Elink
//
//  Created by iot_user on 2019/7/18.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Raw data received from ble: all integers(从ble接收的原始数据：都是整数)
 */
@interface ELBodyFatScaleBleWeightModel : NSObject

@property (nonatomic, assign) NSUInteger weight;
@property (nonatomic, assign) NSUInteger weightUnit;
@property (nonatomic, assign) NSUInteger weightPoint;
///Body fat rate, need / 10(体脂率,需要/10)
@property (nonatomic, assign) NSUInteger bfr;
///Subcutaneous fat rate, need / 10(皮下脂肪率,需要/10)
@property (nonatomic, assign) NSUInteger sfr;
///Visceral fat rate with an accuracy of 1(内脏脂肪率,精度为1)
@property (nonatomic, assign) NSUInteger uvi;
///Muscle rate, need / 10(肌肉率,需要/10)
@property (nonatomic, assign) NSUInteger rom;
///Basal metabolic rate with an accuracy of 1(基础代谢率,精度为1)
@property (nonatomic, assign) NSUInteger bmr;
///Bone quality, need / 10(骨骼质量,需要/10)
@property (nonatomic, assign) NSUInteger bm;
///Water content, need / 10(水含量,需要/10)
@property (nonatomic, assign) NSUInteger vwc;
///Body age with an accuracy of 1(身体年龄,精度为1)
@property (nonatomic, assign) NSUInteger bodyAge;
///Protein rate, need / 10(蛋白率,需要/10)
@property (nonatomic, assign) NSUInteger pp;
///Creation time with an accuracy of 1(创建时间,精度为1)
@property (nonatomic, assign) long long createTime;
///Impedance, accuracy is 1(阻抗,精度为1)
@property (nonatomic, assign) NSUInteger adc;
///Heart rate with an accuracy of 1(心率,精度为1)
@property (nonatomic, assign) NSUInteger heartRate;
///Algorithm ID(算法ID)
@property (nonatomic, assign) NSUInteger algNum;
///BMI, need / 10，When this value is 0, you need to calculate it yourself. BMI=Weight(kg)/Height(m)^2
///BMI，需要除以10, 如果蓝牙返回这个值为0，需要开发者自己计算 BMI=Weight(kg)/Height(m)^2
@property (nonatomic, assign) NSUInteger bmi;

@end

NS_ASSUME_NONNULL_END
