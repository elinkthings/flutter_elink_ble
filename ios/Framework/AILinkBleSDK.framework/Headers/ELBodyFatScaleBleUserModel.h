//
//  ELBodyFatScaleBleUserModel.h
//  Elink
//
//  Created by iot_user on 2019/7/18.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELBodyFatScaleBleHeader.h"

NS_ASSUME_NONNULL_BEGIN


/**
 APP下发当前用户或者用户列表前需要将appUser转换为如下bleUser
 */
@interface ELBodyFatScaleBleUserModel : NSObject

@property (nonatomic, assign) long long createTime;
@property (nonatomic, assign) NSUInteger usrID;
@property (nonatomic, assign) BodyFatScaleRole role;    //角色
@property (nonatomic, assign) ELBluetoothUserSex sex;      //性别
@property (nonatomic, assign) NSUInteger age;           //Age 28 (only counts for the whole year)(年龄28(只算整年))
@property (nonatomic, assign) NSUInteger  height;       //Height 170 (Unit fixed to death: cm, accuracy 1)(身高170(单位定死:cm,精度1))
@property (nonatomic, assign) NSUInteger  weight;       //Weight 562 (Unit fixed death: kg, accuracy 0.1) 120lb-》 54.4lkg-》 545(体重562(单位定死:kg,精度0.1) 120lb-》54.4lkg-》545)

@property (nonatomic, assign) NSUInteger adc;//Impedance 1230 (accuracy is 1Ω)(阻抗1230(精度为 1Ω))

@end

NS_ASSUME_NONNULL_END
