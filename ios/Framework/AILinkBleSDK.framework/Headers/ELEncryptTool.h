//
//  ELEncryptTool.h
//  AILinkSDK
//
//  Created by iot_user on 2019/5/7.
//  Copyright © 2019 IOT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELSDKHeader.h"


NS_ASSUME_NONNULL_BEGIN


@interface ELEncryptTool : NSObject

/**
 app与ble握手的数据

 @return：app与ble握手的数据
 */
+(NSData *)handshake;

/**
 将蓝牙发送的请求握手数据的3〜18位数据加密后再得到符合条件的数据发送给蓝牙

 @param receiveData 蓝牙发送的请求握手数据的3〜18位数据
 @return 送给蓝牙的握手验证数据
 */
+(NSData *)blueToothHandshakeWithData:(NSData *)receiveData;


/**
 加密验证方法1

 @param handshake 3-18位置的数据
 @return:加密后的数据
 */
+ (NSData *)encryptTEA:(NSData * _Nonnull)handshake;

/**
 TEA加密

 @param v 要加密的数据
 @param k 密钥
 */
+ (void)encrypt_tea:(uint32_t *)v key:(uint32_t *)k;

/**
 加密验证方法2

 @param macXOR mac地址对应的数据，传ELPeripheralModel的macXOR
 @param deviceTypeXOR 设备类型对应的数据，传ELPeripheralModel的deviceTypeXOR
 @param dataXOR 要加密的数据
 @return 加密后的数据
 */
+ (NSData *)encryptXOR:(NSData *)macXOR deviceTypeXOR:(NSData *)deviceTypeXOR withXORData:(NSData *)dataXOR;

/// 对广播设备数据进行加密
/// @param handshake 原始数据
/// @param cid cid
/// @param vid vid
/// @param pid pid
+ (NSData *)broadcastDecryptTEA:(NSData * _Nonnull)handshake cid:(Byte)cid vid:(Byte)vid pid:(Byte)pid;

///对跳绳数据进行加密
+ (NSData *)skipEncryptTEA:(NSData *_Nonnull)baseData;

@end

NS_ASSUME_NONNULL_END
