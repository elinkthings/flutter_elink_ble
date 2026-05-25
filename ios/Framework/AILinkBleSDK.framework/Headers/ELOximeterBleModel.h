//
//  ELOximeterBleModel.h
//  Elink
//
//  Created by cliCk on 2020/11/16.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ELOximeter_Max_Pleth 1000.0f
#define ELOximeter_Min_Pleth 0.0f

NS_ASSUME_NONNULL_BEGIN

@interface ELOximeterBleModel : NSObject

/** 血氧（%）0-100 %，若该值无效则为负数 */
@property (nonatomic, assign) NSInteger SpO2;

/** 脉率（bpm）0-250 */
@property (nonatomic, assign) NSInteger pulseRate;

/** PI （血流灌注指数， 无单位 ， 1 位小数） 0-254（对应 0.0-25.4）*/
@property (nonatomic, assign) NSInteger pi;

/** 电量（%）（power ，单位%） 0-100 */
@property (nonatomic, assign) NSInteger power;
/** 呼吸频率 Respiratory Rate（RR/min ，大端序，一位小数点）0.0-100.0 若该值无效，则为 0xFFFF*/
@property (nonatomic, assign) NSInteger rrValue;
/**脉率曲线值（ Plethysmogram 体积描记图，大端序） 0-0xFFFE 若该值无效，则为 0xFFFF*/
@property (nonatomic, assign) NSInteger pleth;
/**脉率曲线波谷（棒图，大端序，暂时废弃不用） 0-0xFFFF 若该值无效，则为 0xFFFF*/
@property (nonatomic, assign) NSInteger pleth2;
/**佩戴状态 0：未佩戴 1：已佩戴*/
@property (nonatomic, assign) NSInteger wearState;
 
@end

NS_ASSUME_NONNULL_END
