//
//  ELForeHeadBleManager.h
//  Elink
//
//  Created by iot_user on 2019/4/18.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import "ELBluetoothManager.h"
#import "ELHeightGaugeBleDataModel.h"
#import "ELHeightGaugeHeader.h"


typedef NS_ENUM(NSUInteger, HeightGaugeBleDataType) {
    HeightGaugeBleDataTypeStabilityData  = 0x01,  //stable temperature
    HeightGaugeBleDataTypeAppSendUnit    = 0x81,  //set unit
    HeightGaugeBleDataTypeSetUnitResult  = 0x82,  //result of set unit
    HeightGaugeBleDataTypeFailCode       = 0xFF,  //error code
};


@protocol ELHeightGaugeBleManagerDelegate <NSObject>
@optional

/**
 call back ble status
 */
-(void)heightGaugeBleManagerUpdateBleState:(ELBluetoothState)state;

/**
 call back ble scan devices model
 */
-(void)heightGaugeBleManagerScanDevices:(NSArray<ELPeripheralModel *> *_Nullable)devices;

/**
 call back ELHeightGaugeBleDataModel
 */
-(void)heightGaugeBleManagerReceiceTestData:(ELHeightGaugeBleDataModel *_Nonnull)model;

/**
 call back the result of set unit
 */
-(void)heightGaugeBleManagerReceiveSetUnitResult:(ELSetBluetoothResponseType)type;

/**
 call back fail code
 */
-(void)heightGaugeBleManagerReceiveFailCode:(ELHeightGaugeFailCode)code;

@end


NS_ASSUME_NONNULL_BEGIN

@interface ELHeightGaugeBleManager : ELBluetoothManager


@property (nonatomic, weak) id<ELHeightGaugeBleManagerDelegate> heightGaugeDelegate;


+(instancetype)shareManager;


-(void)changeUnit:(ELDeviceHeightUnit)unit;

@end

NS_ASSUME_NONNULL_END
