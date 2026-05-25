//
//  ELBodyFatScaleBleHeader.h
//  Elink
//
//  Created by iot_user on 2019/7/18.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#ifndef ELBodyFatScaleBleHeader_h
#define ELBodyFatScaleBleHeader_h

#import "ELSDKHeader.h"

//A6 Byte[2]=2B Byte[3]为A6二级指令(1~7) BLE <-> APP
typedef NS_ENUM(NSInteger , ELBodyFatScaleBleDataA6SubType) {
    
    /** 0x2B01 app下发离线用户列表 */
    ELBodyFatScaleBleDataA6SubType_AppSendUpdateOfflineUserList          = 0x01 ,
    /** 0x2B02 app结束发送离线用户列表 */
    ELBodyFatScaleBleDataA6SubType_AppFinishUpdateOfflineUserList         = 0x02 ,
    /** 0x2B03 app更新离线用户列表中单人信息 */
    ELBodyFatScaleBleDataA6SubType_AppSendUpdateSingleOfflineUser         = 0x03 ,
    /** 2B01~2B03操作的结果回调》2B0400/02:更新列表成功/失败 2B0401/03:更新单个成功/失败 */
    ELBodyFatScaleBleDataA6SubType_BleBackUpdateOfflineUserResult         = 0x04 ,
    
    /** 0x2B05 app请求历史记录及Ble回复都是用2B05》2B0500:无历史记录 2B0501:开始发送历史记录 2B0502:结束发送历史记录 */
    ELBodyFatScaleBleDataA6SubType_AppSendAndBleBackHistory          = 0x05 ,
    
    /** ble发给app有体脂数据的历史记录 */
    ELBodyFatScaleBleDataA6SubType_BleBackHistoryWithMCUAlgorithm         = 0x06 ,
    /** ble发给app无体脂数据的历史记录，app需要根据vip/pid确定使用哪种算法来计算8项体脂数据 */
    ELBodyFatScaleBleDataA6SubType_BleBackHistoryWithAppAlgorithm          = 0x07,
};


//A7 Byte[4]为指令类型(1~8)  MCU <-> APP
typedef NS_ENUM(NSInteger , ELBodyFatScaleBleDataType) {
    
    /** MCU发送实时体重 */
    ELBodyFatScaleBleDataType_MCUBackRealtimeWeight           = 0x01 ,
    /** MCU发送稳定体重 */
    ELBodyFatScaleBleDataType_MCUBackStableWeight             = 0x02 ,
    
    /** MCU发送温度 */
    ELBodyFatScaleBleDataType_MCUBackTemperature          = 0x03 ,
    /** MCU：阻抗测量中 */
    ELBodyFatScaleBleDataType_MCUBackAdcMeasuring         = 0x04 ,
    /** MCU：阻抗测量成功 */
    ELBodyFatScaleBleDataType_MCUBackAdcMeasureSuccess         = 0x05 ,
    /** MCU：阻抗测量失败 */
    ELBodyFatScaleBleDataType_MCUBackAdcMeasureFailed         = 0x06 ,
    /** MCU：阻抗测量成功并使用App算法(VID/PID决定算法) */
    ELBodyFatScaleBleDataType_MCUBackAdcMeasureSuccessWithAppAlgorithm         = 0x07 ,
    
    
    /** 开始称重前app下发当前称重用户的信息给MCU，以便进行体脂计算 */
    ELBodyFatScaleBleDataType_SyncCurrentUserInfo         = 0x08 , //2B0802 APP下发当前用户 2B0803/04 MCU回复下发当前用户成功/失败
    
    /** MCU发送体脂数据给App */
    ELBodyFatScaleBleDataType_MCUBackBodyFatData            = 0x09 ,
    
    /** MCU发送体脂数据给App,发送完毕(一次完整测量结束) */
    ELBodyFatScaleBleDataType_MCUBackBodyFatDataOver         = 0x0A ,
    
    /** MCU->APP:心率测量中 */
    ELBodyFatScaleBleDataType_MCUBackHeartRateMeasuring         = 0x0B ,
    /** MCU->APP:心率测量成功 */
    ELBodyFatScaleBleDataType_MCUBackHeartRateMeasureSuccess    = 0x0C ,
    /** MCU->APP:心率测量失败 */
    ELBodyFatScaleBleDataType_MCUBackHeartRateMeasureFailed     = 0x0D ,
    /** MCU->APP:MCU请求补全体脂数据 */
    ELBodyFatScaleBleDataType_MCUBackNeedsFillBodyData     = 0x0E ,
    /** MCU->APP:设备上报模式 */
    ELBodyFatScaleBleDataType_MCUReportingMode     = 0x0F ,

    /** App发送指令切换单位 */
    ELBodyFatScaleBleDataType_AppSendUnit                   = 0x81 ,
    /** MCU发送体脂数据给App,发送完毕(一次完整测量结束) */
    ELBodyFatScaleBleDataType_MCUBackSendUnitResult         = 0x82 ,
    /** 数据传输结束指令 */
    ELBodyFatScaleBleDataType_ReceivedDataResult            = 0xFE ,
    /** 设备上发错误码 */
    ELBodyFatScaleBleDataType_MCUBackErrorCode              = 0xFF ,
    
    
    /** APP请求支持的显示项 */
    ELBodyFatScaleBleDataType_MCUBackSupportDataList        = 0x11 ,
    /** 6.1.11APP下发显示项和顺序 */
    ELBodyFatScaleBleDataType_DeliverDisplayItemsTheirSequence       = 0x10 ,
};


//MCU请求App用户信息状态
typedef NS_ENUM(NSUInteger, BodyFatScaleMCURequestUserInfoStatus) {
    BodyFatScaleMCURequestUserInfoStatus_Get      = 0x01, //MCU requests App user information(MCU请求App用户信息)
    BodyFatScaleMCURequestUserInfoStatus_Success  = 0x03, //请求成功
    BodyFatScaleMCURequestUserInfoStatus_Fail     = 0x04, //失败
};

//Impedance measurement status(阻抗测量状态)
typedef NS_ENUM(NSUInteger, BodyFatScaleMeasureStatus) {
    BodyFatScaleMeasureStatus_Unstable = 0,
    BodyFatScaleMeasureStatus_Stable,
    BodyFatScaleMeasureStatus_Complete,
    BodyFatScaleMeasureStatus_Failed,
};

//Impedance measurement status (intentionally consistent with A7 command enumeration)(阻抗测量状态(故意和A7指令枚举保持一致))
typedef NS_ENUM(NSUInteger, BodyFatScaleAdcMeasureStatus) {
    BodyFatScaleAdcMeasureStatus_Testing       = 0x04,//测阻抗中
    BodyFatScaleAdcMeasureStatus_Success       = 0x05,//测阻抗成功
    BodyFatScaleAdcMeasureStatus_Fail          = 0x06,//测阻抗失败
    BodyFatScaleAdcMeasureStatus_SuccessCustom = 0x07,//The impedance measurement is successful, and the APP algorithm is used. The APP will identify the corresponding algorithm according to VID and PID(测阻抗成功，并使用 APP 算法，APP 会根据 VID,PID 来识 别对应算法)
};

//Heart rate measurement status (intentionally consistent with A7 command enumeration)(心率测量状态(故意和A7指令枚举保持一致))
typedef NS_ENUM(NSUInteger, BodyFatScaleHeartRateMeasureStatus) {
    BodyFatScaleHeartRateMeasureStatus_Testing       = 0x0B,//测心率中
    BodyFatScaleHeartRateMeasureStatus_Success       = 0x0C,//测心率成功
    BodyFatScaleHeartRateMeasureStatus_Fail          = 0x0D,//测心率失败
};


//Send success or failure callback for offline user list(发送离线用户列表的成功或失败回调)
typedef NS_ENUM(NSUInteger, BodyFatScaleUpdateRecordStatus) {
    BodyFatScaleUpdateRecordStatus_AllSuccess = 0x00,//Successfully updated list(更新列表成功)
    BodyFatScaleUpdateRecordStatus_OneSuccess = 0x01,//Successfully update individual users(更新个人用户成功)
    BodyFatScaleUpdateRecordStatus_AllFail    = 0x02,//Update list failed(更新列表失败)
    BodyFatScaleUpdateRecordStatus_OneFail    = 0x03,//Failed to update individual user(更新个人用户失败)
};
//Request offline history callback(请求离线历史记录回调)
typedef NS_ENUM(NSUInteger, BodyFatScaleSendHistoryDataStatus) {
    BodyFatScaleSendHistoryDataStatus_No     = 0x00,//无历史记录
    BodyFatScaleSendHistoryDataStatus_Begin  = 0x01,//开始发送历史记录
    BodyFatScaleSendHistoryDataStatus_End    = 0x02,//结束发送历史记录
};

//Character(角色)
typedef NS_ENUM(NSUInteger, BodyFatScaleRole) {
    BodyFatScaleRole_Ordinary   = 0x00,//Ordinary(普通人)
    BodyFatScaleRole_Athlete    = 0x01,//Athlete(运动员)
    BodyFatScaleRole_AthletePro = 0x02,//AthletePro(专业运动员)
    BodyFatScaleRole_Pregnancy = 0x03,//Pregnancy(孕妇)
};


#endif /* ELBodyFatScaleBleHeader_h */
