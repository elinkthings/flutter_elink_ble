//
//  ELExSupportDeviceType.h
//  AILinkSDKDemo
//
//  Created by iot_user on 2023/4/11.
//  Copyright © 2019 IOT. All rights reserved.
//

#ifndef ELExSupportDeviceType_h
#define ELExSupportDeviceType_h

/****
 ELSupportDeviceType 将转移到 App 层更新维护，不再SDK中更新2023/4/11
****/

//Device types supported by Elink: Please communicate with the hardware to set(Elink支持的设备类型：请与硬件沟通后设置)
typedef NS_ENUM(NSUInteger, ELSupportDeviceType) {
    ELSupportDeviceTypeUnkonwn        = 0x0000 ,     //unknown(未知)
    ELSupportDeviceTypeBlood          = 0x0001 ,     //sphygmomanometer(血压计)
    ELSupportDeviceTypeForehead       = 0x0002 ,     //Temperature gun(额温枪)
    ELSupportDeviceTypeThermometer    = 0x0003 ,     //thermometer(体温计)
    ELSupportDeviceTypeBabyScale      = 0x0004 ,     //Baby scale(婴儿秤)
    ELSupportDeviceTypeHeightGauge    = 0x0005 ,     //Height meter(身高仪)
    ELSupportDeviceTypeSmartLock      = 0x000B ,     //Smart door lock(智能门锁)
    ELSupportDeviceTypeRemoteControl  = 0x000C ,     //Internal projection vision tester(内投影视力检查仪)
    ELSupportDeviceTypeWheelMonitor   = 0x000D ,     //TPMS(胎压转接板)
    ELSupportDeviceTypeBodyFatScale   = 0x000E ,     //Body fat scale(体脂秤)
    ELSupportDeviceTypeSmatLockRemote = 0x0010 ,     //Smart door lock remote control(智能门锁遥控器)
    ELSupportDeviceTypeBLE_WIFIScale  = 0x0011 ,     //Ble and wifi Scale(蓝牙Wifi体脂秤)
    ELSupportDeviceTypeBLE_WIFIToothbrush = 0x0012,  //Bluetooth and wifi toothbrush(蓝牙wifi牙刷)
    ELSupportDeviceTypeBLE_EightScale = 0x0013 ,     //Eight electrode scale（八电极蓝牙秤）
    ELSupportDeviceTypeAnemometer     = 0x0014 ,     //anemometer（风速计）,0x0014
    ELSupportDeviceTypeClampMeter     = 0x0015 ,     //clamp meter(钳表)
    ELSupportDeviceTypeWatch          = 0x001D ,     //华盛达手表
    
    ELSupportDeviceTypeBloodSugar     = 0x001C ,     //blood sugar(血糖仪)
    ELSupportDeviceTypeInfThermt      = 0x0020 ,     //Infrared Thermometer(红外测温仪)
    ELSupportDeviceTypeOximeter       = 0x0021 ,     //Oximeter （血氧仪）
    ELSupportDeviceTypeFaceMask       = 0x0022 ,     //face mask(智能口罩)
    
    ELSupportDeviceTypeCoffeeScale    = 0x0024 ,     //咖啡秤
    
    ELSupportDeviceTypeHeightBodyFatScale = 0x0026 ,    //身高体脂秤
    ELSupportDeviceTypeHeightScale = 0x0028 ,    //身高体重仪，CID：40 (0x0028)
    ELSupportDeviceTypeFoodThermometer = 0x002B,  //Food Thermometer(食品温度计)
    
    
    ELSupportDeviceTypeBLEToothbrush = 0x002D,  //Bluetooth toothbrush(蓝牙牙刷)
    ELSupportDeviceTypeHygrothermograph = 0x002E ,      //温湿度计
    
    ELSupportDeviceTypeSkip             = 0x002F ,      //跳绳
    ELSupportDeviceTypeBLE_BfrEightScale = 0x0032, //MCU会计算体脂信息的八电极蓝牙秤
    ELSupportDeviceTypeElectricScooter= 0x0033 ,     //滑板车
    ELSupportDeviceTypeNutritionScale = 0x0034 , //营养秤(蓝牙连接)
    ELSupportDeviceType_WiFi_Hygrothermograph = 0x0036 , //wifi温湿度计
    ELSupportDeviceTypeAiFreshNutritionScale = 0x0037 , //好营养营养秤(蓝牙连接)
    ELSupportDeviceTypeBLE_WIFIBlood = 0x0038 , //Bluetooth and wifi Blood(蓝牙wifi智能血压计)
    ELSupportDeviceTypeFasciaGun        = 0x003B , //筋膜枪
    
    ELSupportDeviceType_4G_Hygrothermograph = 0x003A ,  //4g温湿度计
    
    ELSupportDeviceTypeAutomaticThermometer        = 0x003D , //61 //测温仪(蓝牙)
    
    ELSupportDeviceType_BraceletWatch  = 0x003E, //Leap手环
    
    ELSupportDeviceTypeMeatProbe  = 0x003F, //食物探针
    
    ELSupportDeviceTypeVictorClampMeter  = 0x0040, //Victor钳表
    
    ELSupportDeviceTypeVictorNoiseMeter  = 0x0043, //胜利噪音计
    
    ELSupportDeviceTypeVictorAnemometer  = 0x0044, //胜利风速计
    
    ELSupportDeviceTypeVictorLuxMeter  = 0x0045, //胜利照度计
    
    ELSupportDeviceTypeAirDetector  = 0x0048, //环境气体检测仪
    
    ELSupportDeviceTypeTPMS智能胎压  = 0x0049, //智能胎压
    
    ELSupportDeviceType电动自行车  = 0x004A, //电动自行车
    
    ELSupportDeviceType电动自行车4G  = 0x004B, //电动自行车 4G
    
    ELSupportDeviceType电动车  = 0x004C, //电动车
    
    ELSupportDeviceType电动车4G  = 0x004D, //电动车 4G
    
    ELSupportDeviceType电动平衡车  = 0x004E, //电动平衡车
    
    ELSupportDeviceType电动平衡车4G  = 0x004F, //电动平衡车 4G
    
    ELSupportDeviceTypeBLEWiFiNoiseMeter  = 0x0050, //噪音计(WiFi+BLE)
    
    ELSupportDeviceType智能仪表  = 0x0051, //CM01-C02智能仪表
    
    ELSupportDeviceType双频八电极体脂秤  = 0x0052, //双频八电极体脂秤
    
    ELSupportDeviceTypeAirDetectorLite  = 0x0053, //环境气体检测仪 不支持MQTT
    
    ELSupportDeviceTypeHPLuxMeter  = 0x0054, //华普照度计
    
    ELSupportDeviceTypeMeatProbeBox  = 0x0055, //食物探针充电盒
    
    ELSupportDeviceTypeBodyScale  = 0x0056, //Body scale(no body fat) 体重秤(无体脂)
    
    ELSupportDeviceTypeSmartRing = 0x005D, //0x5D  智能戒指

    ELSupportDeviceTypeAIFitScale = 0x005E, //好身材体脂秤(蓝牙连接)
    
    ELSupportDeviceTypeBodyCompositionAnalyzer = 0x0065, //人体成份分析仪(蓝牙连接)

    ELSupportDeviceTypeHMIBodyFatScale = 0x0076, //HMI体脂秤 CID：0x0076（118）
    
    ELSupportDeviceTypeBroadcastScale = (0xffff +0x01)  ,     //655536 Broadcast body fat scale(AILink广播体脂秤)
    ELSupportDeviceTypeBroadcastHeightGauge = (0xffff + 0x03) , //65538 广播身高仪
    ELSupportDeviceTypeBroadcastScale_Lingyang = (0xffff +0x16)  ,     //65557 凌阳广播体脂秤
    ELSupportDeviceTypeBroadcastBodyScale = (0xFFFF + 0x07)  ,     //Broadcast body scale AILink广播体重秤(无体脂)
    
    ELSupportDeviceTypeBroadcastNutritionFoodScale = (0xffff + 0x04) , //65539 广播营养秤
    ELSupportDeviceTypeBroadcastHygrothermograph = (0xffff + 0x06) , //65541 广播温湿度计
    
    ELSupportDeviceTypeBroadcastScale_OKOK = (0xffff + 0x08) , //65543 OKOK广播体脂秤
    
    ELSupportDeviceTypeBroadcastScale_T6 = (0xffff + 0x09) , //65544 T6广播体脂秤

    ELSupportDeviceType_dualFrequencyEightelectrodeMCUAlgorithm  = 0x0068, //双频八电极MCU算法秤
    
    ELSupportDeviceTypeElectricScooter_CM01TouchScreen = 0x0025, // 电动滑板车（邦凯定制）-CM01触摸屏
    ELSupportDeviceTypeElectricScooter_4G = 0x0046,  //电动滑板车(4G)
};

#endif /* ELExSupportDeviceType_h */
