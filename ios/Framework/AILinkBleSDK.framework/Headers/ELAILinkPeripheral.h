//
//  ELAILinkPeripheral.h
//  AILinkBleSDK
//
//  Created by LarryZhang on 2023/3/31.
//

#import <Foundation/Foundation.h>

@class CBPeripheral;

NS_ASSUME_NONNULL_BEGIN

@interface ELAILinkPeripheral : NSObject

@property (nonatomic, strong) CBPeripheral *peripheral;

@property (nonatomic, strong) NSDictionary *advertisementData;

@property (nonatomic, strong) NSNumber *RSSI;

@property (nonatomic, assign) NSTimeInterval timestamp;

@property (nonatomic, copy) NSString *macAddressString;
@property (nonatomic, strong) NSData *macData;

@property (nonatomic, assign) UInt16 cid;

@property (nonatomic, assign) UInt16 vid;

@property (nonatomic, assign) UInt16 pid;

@property (nonatomic, strong) NSUUID *identifier;

@end

NS_ASSUME_NONNULL_END
