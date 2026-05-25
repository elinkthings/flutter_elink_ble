//
//  ELBabyScaleBleWeightModel.h
//  Elink
//
//  Created by iot_user on 2019/4/23.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELBabyScaleBleWeightModel : NSObject

@property (nonatomic, assign) ELDeviceWeightUnit unit;//unit(单位)
@property (nonatomic, assign) int weight;//weight(重量)
@property (nonatomic, assign) BOOL dataType;//Stable mark: 0 real-time weight, 1 stable weight(稳定标志：0 实时重量，1 稳定重量)
@property (nonatomic, copy) NSString *unitStr;
@property (nonatomic, assign) NSInteger weightPoint;//Decimal offset position(小数点偏移位置)

@end

NS_ASSUME_NONNULL_END
