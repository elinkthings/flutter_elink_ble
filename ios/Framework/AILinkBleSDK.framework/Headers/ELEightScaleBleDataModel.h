//
//  ELEightScaleDataModel.h
//  Elink
//
//  Created by iot_user on 2020/6/4.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELEightScaleSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN


@interface ELEightScaleBleDataModel : NSObject
//Weight display data(体重显示数据)
@property (nonatomic, copy) NSString *weight;
//Weight decimal point(体重小数点)
@property (nonatomic, assign) NSInteger weightPoint;
//Weight unit(体重单位)
@property (nonatomic, assign) ELDeviceWeightUnit weightUnit;
//Impedance type(阻抗类型)
@property (nonatomic, assign) EightScaleAdcType adcType;
//Impedance value(阻抗值)
@property (nonatomic, assign)unsigned int feetAdc;//Two-foot impedance(双脚阻抗)
@property (nonatomic, assign)unsigned int handsAdc;//Hands resistance(双手阻抗)
@property (nonatomic, assign)unsigned int leftHandAdc;//Left hand impedance(左手阻抗)
@property (nonatomic, assign)unsigned int rightHandAdc;//Right hand impedance(右手阻抗)
@property (nonatomic, assign)unsigned int leftFootAdc;//Left foot impedance(左脚阻抗)
@property (nonatomic, assign)unsigned int rightFootAdc;//Right foot impedance(右脚阻抗)
@property (nonatomic, assign)unsigned int LWholeBodyAdc;//Right foot impedance(左全身阻抗)
@property (nonatomic, assign)unsigned int RWholeBodyAdc;//Right whole body impedance(右全身阻抗)
@property (nonatomic, assign)unsigned int RHand_LFootAdc;//Impedance of right hand and left foot(右手左脚阻抗)
@property (nonatomic, assign)unsigned int LHand_RFootAdc;//Impedance of left hand and right foot(左手右脚阻抗)
@property (nonatomic, assign)unsigned int trunkAdc;//Torso impedance(躯干阻抗)

//Algorithm Id(算法Id)
@property (nonatomic, assign) int algorithmID;
//Heart rate(心率)
@property (nonatomic, assign) int heartRate;

//Temperature display value(温度显示值)
@property (nonatomic, copy) NSString *temp;
//Temperature decimal point(温度小数点)
@property (nonatomic, assign) int tempPoint;
//Temperature unit(温度单位)
@property (nonatomic, assign) ELDeviceTemperatureUnit tempUnit;
//time(时间)
@property (nonatomic, assign) long long createTime;

@property (nonatomic, assign)unsigned int hz20leftHandAdc;//Left hand impedance(左手阻抗)
@property (nonatomic, assign)unsigned int hz20rightHandAdc;//Right hand impedance(右手阻抗)
@property (nonatomic, assign)unsigned int hz20leftFootAdc;//Left foot impedance(左脚阻抗)
@property (nonatomic, assign)unsigned int hz20rightFootAdc;//Right foot impedance(右脚阻抗)
@property (nonatomic, assign)unsigned int hz20trunkAdc;//Torso impedance(躯干阻抗)

@property (nonatomic, assign)unsigned int hz100leftHandAdc;//Left hand impedance(左手阻抗)
@property (nonatomic, assign)unsigned int hz100rightHandAdc;//Right hand impedance(右手阻抗)
@property (nonatomic, assign)unsigned int hz100leftFootAdc;//Left foot impedance(左脚阻抗)
@property (nonatomic, assign)unsigned int hz100rightFootAdc;//Right foot impedance(右脚阻抗)
@property (nonatomic, assign)unsigned int hz100trunkAdc;//Torso impedance(躯干阻抗)

@end

NS_ASSUME_NONNULL_END
