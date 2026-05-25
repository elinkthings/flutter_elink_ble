//
//  ELBluetoothManager+Settings.h
//  AILinkBleSDK
//
//  Created by steven wu on 2021/8/6.
//  Copyright © 2021 IOT. All rights reserved.
//

#import "ELBluetoothManager.h"

NS_ASSUME_NONNULL_BEGIN


@interface ELBluetoothManager (Settings)


#pragma mark  ============ A6 Set or query instructions(设置或查询指令)  ==============



/**
 Set the Bluetooth name(设置蓝牙名称)

 @param name Name, less than 14 bytes(名称,小于14个byte)
 */
-(void)setBluetoothName:(NSString * _Nonnull)name;

/**
 Set the broadcast interval(设置广播间隔时间)

 @param interval 20~2000
 */
-(void)setBroadcastInterval:(int)interval;


/**
 Set the connection interval 10(设置连接间隔)

 @param interval The interval range is 20~2000ms.(interval范围是20~2000ms)
 @param timeout  The timeout range is 1000~6000ms(timeout范围是1000~6000ms)
 @param latency  The latency range is 0~4(latency范围是0〜4)
 */
-(void)setConnectedInterval:(int)interval timeout:(int)timeout Latency:(int)latency;

/**
 Set the transmit power(设置发射功率)

 @param power The range of power is 0~10(power的范围是0~10)
 */
-(void)setTransmittingPower:(int)power;

/**
 Set the serial port baud rate(设置串口波特率)

 @param rate The range of rate is 0~5(rate的范围是0~5)
 0：9600
 1：19200
 2：38400
 3：57600
 4：115200
 5：921600
 */
-(void)setSerialPortbaudRate:(int)rate;

/**
 Set the MCU software and hardware version number(设置MCU软硬件版本号)

 @param hardware 硬件
 @param software 软件
 如果是:S1.1,S11.1,S111.1, .....
 请传：11,111,1111, ....
 @param type Manufacturer's own definition(厂家自己定义)
 @param year 年
 @param month 月
 @param day 日
 */
-(void)setMCUVersion:(unsigned int)hardware software:(unsigned int)software mcuType:(unsigned int)type year:(unsigned int)year month:(unsigned int)month day:(unsigned int)day;

/**
 Set the big endian or little endian of the Mac address in the broadcast manufacturer's custom data.(设置广播厂家自定义数据中Mac地址的大端序或小端序)

 @param type type
 0：Little endian (default)(小端序 （默认）)
 1：Big endian(大端序)
 */
-(void)setSetMACAddressType:(int)type;

/**
 Set up the module's service and feature services(设置模块的服务和特征服务)

 @param serverUUIDData server
 @param charateristicUUIDData charateristic
 @param type UUID length：
 0 : 16 bytes（default）
 1：2 bytes
 */
-(void)setBluetoothServerUUID:(NSData *)serverUUIDData charateristicUUID:(NSData *)charateristicUUIDData UUIDType:(int)type;

/**
 Set the master-slave mode of the module(设置模块的主从模式)

 @param type Value：
 0：Slave mode (default)(从机模式（默认）)
 1：Host mode(主机模式)
 */
-(void)setMCUModel:(int)type;

/**
 Set the module's automatic sleep time without connection(设置模块无连接的自动休眠时间)

 @param open Automatic sleep flag(自动睡眠标志位)：
 0：Do not turn on automatic sleep(不开启自动休眠)
 1：Turn on auto sleep, the module is not connected(开启自动休眠，模块没有连接)
 @param time Automatic sleep time (ms)(自动睡眠时间(ms))
 @param radio Whether to enable low frequency broadcast after sleep: (unit: ms)(睡眠后是否开启低频广播：（单位：ms）)
 0：Not open(不开启)
 1：Open(开启)
 @param interval 低频广播间隔时间,20~2000ms
 */
-(void)setAutoSleepTimeIsOpen:(BOOL)open autoSleepTime:(unsigned int)time isRadio:(BOOL)radio radioInterval:(int)interval;

/**
 Set to sleep(设置进入睡眠)

 @param radio Whether to enable low frequency broadcast after sleep: (in ms)(睡眠后是否开启低频广播：（单位 ms）)
 0：Not open(不开启)
 1：Open(开启)
 @param interval 低频广播间隔时间,20~2000ms
 */
-(void)setGotoSleepIsRadio:(BOOL)radio interval:(int)interval;

/**
 Set module wake up(设置模块唤醒)
 */
-(void)setMCUWakeUp;


/**
 Setting CID, VID, PID（设置CID、VID、PID）

 @param setC Whether to set the CID(是否设置CID)
 @param setV Whether to set the VID(是否设置VID)
 @param setP Whether to set the PID(是否设置PID)
 @param cid Product Type ID: Less than 65536(产品类型ID：小于65536)
 @param vid Manufacturer ID: less than 65536(厂家ID：小于65536)
 @param pid Product ID: Less than 65536(产品ID：小于65536)
 */
-(void)setC_V_P_IDWithIsSetCID:(BOOL)setC isSetVID:(BOOL)setV isSetPID:(BOOL)setP CID:(unsigned int)cid VID:(unsigned int)vid PID:(unsigned int)pid DEPRECATED_MSG_ATTRIBUTE("do not support this method any more since 20220505, as same as Android SDK");

/**
 Set module communication mode
 设置模块通信模式

 @param mode communication mode（通信模式）
 */
-(void)setCommunicationMode:(ELCommunicationModeType)mode;

/**
 Set module restart
 设置模块重启
 */
-(void)setMCURestart;

/**
 Set factory reset
 设置恢复出厂设置
 */
-(void)setFactoryDataReset;

/**
 Set the Bluetooth connection status（设置蓝牙连接状态）

 @param disconnect Active disconnect flag（主动断开连接标志位）
 1：Disconnect immediately（立刻断开连接）
 0：Not disconnected（不断开连接）
 */
-(void)setDisconnected:(BOOL)disconnect;


@end

NS_ASSUME_NONNULL_END
