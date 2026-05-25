//
//  ELAIFitScaleBleHeader.h
//  Pods
//
//  Created by LarryZhang on 2023/8/11.
//

#ifndef ELAIFitScaleBleHeader_h
#define ELAIFitScaleBleHeader_h


typedef NS_ENUM(NSUInteger, AIFitScaleStatus) { //Byte[6]
    
    AIFitScaleStatusRealTime = 0xCE,//0xCE：实时重量，0xCA：稳定重量
    
    AIFitScaleStatusStable = 0xCA,//0xCE：实时重量，0xCA：稳定重量
    
    AIFitScaleStatusImpedance = 0xCB,//阻抗功能标识码
    
    AIFitScaleStatusUniversal = 0xCC,//通用标识码
    
};

/*Weight unit(重量单位)*/
typedef NS_ENUM(NSInteger, AIFitScaleWeightUnit) {
    AIFitScaleWeightUnitKG             = 0 ,
    AIFitScaleWeightUnitLB             = 1 ,
    AIFitScaleWeightUnitSTLB             = 2 ,
    AIFitScaleWeightUnitJIN             = 3 ,
    
};
typedef NS_ENUM(NSInteger, MeasureStatus) {
    MeasureStatus_Unstable = 0,
    MeasureStatus_Stable,
    MeasureStatus_Complete,
};

typedef NS_ENUM(NSInteger, AdcMeasureStatus) {
    AdcMeasureStatus_Measuring,
    AdcMeasureStatus_Success,
    AdcMeasureStatus_Failed,
};

typedef NS_ENUM(NSInteger, HistoryStatus) {
    HistoryStatus_NoHistory = 0,
    HistoryStatus_StartSendHistory,
    HistoryStatus_ReceiveOneHistory,
    HistoryStatus_EndSendHistory,
};


#endif /* ELAIFitScaleBleHeader_h */
