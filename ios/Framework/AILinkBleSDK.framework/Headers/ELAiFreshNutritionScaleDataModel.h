//
//  ELAiFreshNutritionScaleDataModel.h
//  Elink
//
//  Created by LarryZhang on 2021/12/2.
//  Copyright © 2021 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELAiFreshNutritionScaleBleHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELAiFreshNutritionScaleDataModel : NSObject


//Measurement status(测量状态)
@property (nonatomic, assign) AiFreshNutritionScaleTestStatus testStatus;
//weight（重量数据）
@property (nonatomic, assign) UInt32 weight;
//Weight unit（重量单位）
@property(nonatomic, assign) AiFreshNutritionScaleWeightUnit weightUnit;
//Weight decimal point（体重小数点）
@property(nonatomic, assign) Byte weightPoint;
//Weight negative（是否负数）
@property(nonatomic, assign, getter=isNegative) BOOL negative;

//timestamp(时间戳)
@property(nonatomic, assign) long long timestamp;

@end


NSString *AiFreshNutritionScaleWeightUnitString(AiFreshNutritionScaleWeightUnit unit);

NS_ASSUME_NONNULL_END
