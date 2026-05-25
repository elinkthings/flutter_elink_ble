//
//  NSData+AILinkBle.h
//  AILinkBleSDK
//
//  Created by LarryZhang on 2022/11/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (AILinkBle)

- (UInt32)valueU32AtLoc:(NSUInteger)loc;
- (UInt32)u32:(NSUInteger)loc; //简化版

- (UInt16)valueU16AtLoc:(NSUInteger)loc;
- (UInt16)u16:(NSUInteger)loc; //简化版

- (UInt8)valueU8AtLoc:(NSUInteger)loc;
- (UInt8)u8:(NSUInteger)loc; //简化版

- (UInt32)valueU32LEAtLoc:(NSUInteger)loc;
- (UInt32)u32LE:(NSUInteger)loc; //简化版

- (UInt16)valueU16LEAtLoc:(NSUInteger)loc;
- (UInt16)u16LE:(NSUInteger)loc; //简化版

//转换 HexString
- (NSString *)elHexString;
+ (NSData *)elDataWithHexString:(NSString *)hexStr;

@end

NS_ASSUME_NONNULL_END
