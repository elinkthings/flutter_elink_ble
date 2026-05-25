//
//  ELFasciaGunBleDataModel.h
//  AILinkBleSDK
//
//  Created by LarryZhang on 2022/1/15.
//  Copyright © 2022 IOT. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(UInt8, FasciaGunChargingStatus);

@interface ELFasciaGunBleDataModel : NSObject

@property (nonatomic, assign) BOOL started;

@property (nonatomic, assign) UInt16 workingTime;


@property (nonatomic, assign) UInt8 currentGear;
@property (nonatomic, assign) UInt8 maxGear;


@property (nonatomic, assign) BOOL countdownEnabled;
@property (nonatomic, assign) UInt16 countdownTime;


@property (nonatomic, assign) UInt8 pressureValue;


@property (nonatomic, assign) FasciaGunChargingStatus chargingStatus;
@property (nonatomic, assign) UInt8 batteryLevel;

@end


typedef NS_ENUM(UInt8, FasciaGunChargingStatus) {
    FasciaGunChargingStatus_Uncharged       = 0x00,
    FasciaGunChargingStatus_Charging        = 0x01,
    FasciaGunChargingStatus_Full            = 0x02,
    
    FasciaGunChargingStatus_Unsupported     = 0xFF,
};

NS_ASSUME_NONNULL_END
