//
//  ELVictorLuxMeterBleTool.h
//  AILinkBleSDK
//
//  Created by LarryZhang on 2022/11/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELVictorLuxMeterBleTool : NSObject

///按键类型
typedef NS_ENUM(NSUInteger, VictorLuxMeterButtonType){
    VictorLuxMeterButtonType_Null  =  0,        //Bit3Bit2Bit1Bit0=0000 >>无按键按下
    
    VictorLuxMeterButtonType_MAX_MIN = 0b0001,        //Bit3Bit2Bit1Bit0=0001 >>短按MAX/MIN键
    VictorLuxMeterButtonType_HOLD_BL = 0b0010,        //Bit3Bit2Bit1Bit0=0010 >>短按HOLD/BL键
    VictorLuxMeterButtonType_SELECT = 0b0011,        //Bit3Bit2Bit1Bit0=0011 >>短按SELECT键
    VictorLuxMeterButtonType_POWER = 0b0100,        //Bit3Bit2Bit1Bit0=0100 >>短按POWER键
    VictorLuxMeterButtonType_RANG = 0b0101,        //Bit3Bit2Bit1Bit0=0101 >>短按RANG键
    VictorLuxMeterButtonType_REL = 0b0110,        //Bit3Bit2Bit1Bit0=0110 >>短按REL键
    VictorLuxMeterButtonType_LONG_POWER = 0b0111,        //Bit3Bit2Bit1Bit0=0111 >>长按2S POWER键
    VictorLuxMeterButtonType_LONG_MAXMIN = 0b1000,        //Bit3Bit2Bit1Bit0=1000 >>长按2S MAX/MIN键
    VictorLuxMeterButtonType_LONG_HOLD_BL = 0b1001,        //Bit3Bit2Bit1Bit0=1001 >>长按2S HOLD/BL键
    
};

+ (NSArray<NSNumber *> *)cids;

+ (NSData *)payloadOfButton:(VictorLuxMeterButtonType)button;

@end

NS_ASSUME_NONNULL_END
