//
//  NELMacAddressModel.h
//  Elink
//
//  Created by LarryZhang on 2022/8/15.
//  Copyright © 2022 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NELMacAddressModel : NSObject


@property (nonatomic, copy, readonly) NSString *macAddressString;

// 例：{0xA1, 0xB2, 0xC3, 0xD4, 0xE5, 0xF6} ==> "A1:B2:C3:D4:E5:F6"
+ (instancetype)macWithBigEndianBytes:(Byte *)bytes;

// 例：{0xF6, 0xE5, 0xD4, 0xC3, 0xB2, 0xA1} ==> "A1:B2:C3:D4:E5:F6"
+ (instancetype)macWithLittleEndianBytes:(Byte *)bytes;

// 例：<A1B2C3D4 E5F6> ==> "A1:B2:C3:D4:E5:F6"
+ (instancetype)macWithBigEndianData:(NSData *)data;

// 例：<F6E5D4C3 B2A1> ==> "A1:B2:C3:D4:E5:F6"
+ (instancetype)macWithLittleEndianData:(NSData *)data;

// 只支持格式："A1:B2:C3:D4:E5:F6"
+ (instancetype)macWithMacString:(NSString *)macString;

// 例：0xA1B2C3D4E5F6 ==> "A1:B2:C3:D4:E5:F6"
+ (instancetype)macWithUIntValue:(UInt64)value;

//// 例：0xF6E5D4C3B2A1 ==> "A1:B2:C3:D4:E5:F6"
//+ (instancetype)macWithBigEndianUIntValue:(UInt64)value;
//
//// 例：0xA1B2C3D4E5F6 ==> "A1:B2:C3:D4:E5:F6"
//+ (instancetype)macWithLittleEndianUIntValue:(UInt64)value;



//+ (BOOL)isEqual:(ZZMacAddressModel *)mac with:(ZZMacAddressModel *)otherMac;

- (BOOL)isEqualToMac:(NELMacAddressModel *)mac;


#ifdef DEBUG
+ (void)demo;
#endif

@end

NS_ASSUME_NONNULL_END
