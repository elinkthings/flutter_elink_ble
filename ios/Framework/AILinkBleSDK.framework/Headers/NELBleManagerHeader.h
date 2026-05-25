//
//  NELBleManagerHeader.h
//  Elink
//
//  Created by LarryZhang on 2022/9/15.
//  Copyright © 2022 iot_iMac. All rights reserved.
//

#ifndef NELBleManagerHeader_h
#define NELBleManagerHeader_h


typedef NS_ENUM(NSInteger, NELBleManagerConnectState) {
    NELBleManagerConnectStateUnknown = 0x00,
    
    NELBleManagerConnectStateDisconnected = 0x01,
    NELBleManagerConnectStateFailed = 0x02,
    NELBleManagerConnectStateConnecting = 0x03,
    NELBleManagerConnectStateConnected = 0x04,
    NELBleManagerConnectStateHandShaking = 0x05,
    NELBleManagerConnectStatePassed = 0x06,
    
    NELBleManagerConnectStateFailedValidation = 0x0F,
    
    
    NELBleManagerConnectStateCentralScanning = 0x80,
    
    NELBleManagerConnectStateCentralUnknown = 0xF0,
    NELBleManagerConnectStateCentralResetting = 0xF1,
    NELBleManagerConnectStateCentralUnsupported = 0xF2,
    NELBleManagerConnectStateCentralUnauthorized = 0xF3,
    NELBleManagerConnectStateCentralPowerOff = 0xF4,
    NELBleManagerConnectStateCentralPowerOn = 0xF5,
    
};

#endif /* NELBleManagerHeader_h */
