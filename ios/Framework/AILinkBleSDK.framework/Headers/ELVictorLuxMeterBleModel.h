//
//  ELVictorLuxMeterBleModel.h
//  AILinkBleSDK
//
//  Created by LarryZhang on 2022/11/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELVictorLuxMeterBleModel : NSObject

//照度数据(LED数码管显示值)
@property (nonatomic, assign, readonly) UInt16 led; //Byte[4]~Byte[5]

//Byte[6] 功能描述 (0>>不显示 1>>显示)
@property (nonatomic, assign, readonly) BOOL bTimeLcd;//Bit0    b_time_lcd    超时自动关机状态
@property (nonatomic, assign, readonly) BOOL bBluetoothLcd;//Bit2    b_bluetooth_lcd    蓝牙连接状态
@property (nonatomic, assign, readonly) BOOL bRelLcd;//Bit3    b_rel_lcd    相对值状态
@property (nonatomic, assign, readonly) BOOL bLuxLcd;//Bit4    b_lux_lcd    照度单位勒克斯状态
@property (nonatomic, assign, readonly) BOOL bFcLcd;//Bit5    b_fc_lcd    照度单位尺烛光状态
@property (nonatomic, assign, readonly) BOOL bHoldLcd;//Bit6    b_hold_lcd    数据保持状态


//Byte[7] 功能描述 (0>>不显示 1>>显示)
//X10/X100状态显示 Bit2Bit1=00>>不显示 Bit2Bit1=01>>X10显示 Bit2Bit1=11>>X100显示
@property (nonatomic, assign, readonly) UInt8 x10AndX100Lcd;
//20/200/2000/20000/200000状态显示
//Bit7Bit6Bit5Bit4Bit3=00000
//>>不显示
//Bit7Bit6Bit5Bit4Bit3=00010
//>>20显示
//Bit7Bit6Bit5Bit4Bit3=00110
//>>200显示
//Bit7Bit6Bit5Bit4Bit3=01110
//>>2000显示
//Bit7Bit6Bit5Bit4Bit3=11110
//>>20000显示
//Bit7Bit6Bit5Bit4Bit3=11111
//>>200000显示
@property (nonatomic, assign, readonly) UInt8 icon200000;

//Byte[8] 功能描述 (0>>不显示 1>>显示)
@property (nonatomic, assign, readonly) BOOL bAutoLcd;//Bit0    b_auto_lcd    自动挡状态
@property (nonatomic, assign, readonly) BOOL bMaxLcd;//Bit1    b_max_lcd    最大数据状态
@property (nonatomic, assign, readonly) BOOL bBatLcd;//Bit2    b_bat_lcd    电池低压状态
@property (nonatomic, assign, readonly) BOOL bMinLcd;//Bit3    b_min_lcd    最小数据状态
@property (nonatomic, assign, readonly) BOOL bHiLcd;//Bit4    超量程HI    超量程状态 超量程显示HI
@property (nonatomic, assign, readonly) BOOL bNegativeLcd;//Bit5    正负符号位    相对值状态显示时 0>>正符号不显示 1>>负符号显示
//Bit7Bit6=00>>不显示
//Bit7Bit6=01>>小数点保留 1 位
//Bit7Bit6=10>>小数点保留 2 位
@property (nonatomic, assign, readonly) UInt8 decimalStatus;//Bit6bit7    小数点状态    小数点状态显示



+ (instancetype)modelWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
