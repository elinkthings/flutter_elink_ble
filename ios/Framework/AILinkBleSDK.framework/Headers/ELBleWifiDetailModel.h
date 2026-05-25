//
//  ELBleWifiDetailModel.h
//  Elink
//
//  Created by iot_user on 2019/12/30.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ELBleWifiSecureType) {
    ELBleWifiSecureTypeOpen             = 0,
    ELBleWifiSecureTypeWEP              = 1,
    ELBleWifiSecureTypeWPA_PSK          = 2,
    ELBleWifiSecureTypeWPA2_PSK         = 3,
    ELBleWifiSecureTypeWPA_WPA_2_PSK    = 4,
    ELBleWifiSecureTypeWPA2_ENTERPRISE  = 5,
};

typedef NS_ENUM(NSUInteger, ELBleWifiUseState) {
    ELBleWifiUseStateUnknown   = 0, //Strange wifi(陌生wifi)
    ELBleWifiUseStateSaved     = 1, //Wifi with saved password(保存过的密码的wifi)
    ELBleWifiUseStateConnected = 2, //Currently connected wifi(目前连接着的wifi)
};

NS_ASSUME_NONNULL_BEGIN

@interface ELBleWifiDetailModel : NSObject<NSCopying>
//wifi number(wifi编号)
@property (nonatomic, assign) int wifiNumber;
//wifi name(wifi 名字)
@property (nonatomic, copy) NSString *wifiName;
//wifi MAC address (little endian)(wifi MAC地址(小端序))
@property (nonatomic, copy) NSData *macData;
//Signal strength(信号强度)
@property (nonatomic, assign) int wifiRssi;
//Security type(安全类型)
@property (nonatomic, assign) ELBleWifiSecureType secureType;
//wifi status(wifi状态)
@property (nonatomic, assign) ELBleWifiUseState wifiState;

@end

NS_ASSUME_NONNULL_END
