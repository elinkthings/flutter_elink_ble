//
//  ELTLVModel.h
//  AILinkBleSDK
//
//  Created by LarryZhang on 2022/9/6.
//  Copyright © 2022 IOT. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//***** type 1 Byte  lengh 1 Byte

@interface ELTLVModel : NSObject

@property(nonatomic, assign) UInt8 type; //T

@property(nonatomic, assign, readonly) UInt8 length; //L

@property(nonatomic, strong) NSData *value; //V

//@property(nonatomic, strong) NSNumber *_Nullable cmd; //cmd属性 (独立属性，不包含在tlvData)

@property(nonatomic, strong, readonly) NSData *data;
@property(nonatomic, strong, readonly) NSData *tlvData; //same as data


- (instancetype)initWithType:(UInt8)type;

- (instancetype)initWithType:(UInt8)type value:(NSData *)value;

@end

@interface ELTLVModel (Tool)

+ (NSArray<ELTLVModel *> *)objectArrayWithData:(NSData * _Nonnull)payloadData;

@end

NS_ASSUME_NONNULL_END
