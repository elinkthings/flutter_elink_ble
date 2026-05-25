//
//  ELPeripheralModel.h
//  Elink
//
//  Created by iot_user on 2019/4/22.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ELSDKHeader.h"



NS_ASSUME_NONNULL_BEGIN

/**
 Bluetooth peripheral out model(蓝牙扫描出来的外设模型)
 */
@interface ELPeripheralModel : NSObject
/**
 CID
 */
@property (nonatomic, assign) ELSupportDeviceType deviceType;// DEPRECATED_MSG_ATTRIBUTE("use ‘cid’ instead");
@property (nonatomic, assign) ELSupportDeviceType cid;

/**
 VID
 */
@property (nonatomic, assign) NSInteger vendorID;
@property (nonatomic, assign) NSInteger vid;

/**
 PID
 */
@property (nonatomic, assign) NSInteger productID;
@property (nonatomic, assign) NSInteger pid;

@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *macAddress;

@property (nonatomic, assign) NSInteger rssi;
@property (nonatomic, strong) CBPeripheral *peripheral;

/**
 6 bytes: small endian(6个byte:小端序)
 */
@property (nonatomic, copy) NSData *macData;

/**
 2 bytes
 */
@property (nonatomic, copy) NSData *deviceTypeData;



/** Device with unit: support unit string
      Unitless equipment
         Smart Door Lock: Supported unlock type
 有单位的设备：支持单位字符串
    无单位的设备
       智能门锁：支持的开锁类型
 */
@property (nonatomic, copy) NSString *supportUnit;

/** Device version numbe(设备版本号) */
@property (nonatomic, copy) NSString *version;

/**
 * 华盛达手表要用这个属性: 是否已经跟系统配对
 */
@property(nonatomic, assign) BOOL  paired;

/** 广播秤的广播数据 */
@property (nonatomic, strong) NSData *manufactureData;

/**
 Screening equipment（筛选设备）

 @param peripherals All devices scanned by the parent class（父类扫描到的所有设备）
 @param type Equipment type（设备类型）
 @return Array of corresponding devices（对应设备的数组）
 */
+(NSArray<ELPeripheralModel *> *)getDevicesWithPeripherals:(NSArray<__kindof ELPeripheralModel *> *)peripherals supportDeviceType:(ELSupportDeviceType)type;

#pragma mark Screen multiple devices(筛选多个设备)
+(NSArray<ELPeripheralModel *> *)getDevicesWithPeripherals:(NSArray<__kindof ELPeripheralModel *> *)peripherals supportDeviceTypes:(NSArray<NSNumber *> *)types;

//Descending order(降序)
-(NSComparisonResult)compareRSSI:(ELPeripheralModel *)model;
@end

NS_ASSUME_NONNULL_END
