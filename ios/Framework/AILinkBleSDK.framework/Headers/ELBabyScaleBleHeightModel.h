//
//  ELBabyScaleBleHeightModel.h
//  Elink
//
//  Created by iot_user on 2019/4/23.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELBabyScaleBleHeightModel : NSObject

@property (nonatomic, assign) NSUInteger height;    //height(身高)
@property (nonatomic, assign) ELDeviceHeightUnit unit;
@property (nonatomic, copy) NSString *unitStr;
@property (nonatomic, assign) NSInteger heightPoint;//Decimal offset position(小数点偏移位置)


@end

NS_ASSUME_NONNULL_END
