//
//  JQMapTool.h
//  测试
//
//  Created by 韩军强 on 2017/7/7.
//  Copyright © 2017年 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface JQMapTool : NSObject


/**
 endCoordinate2D:结束位置的经纬度
 */
+(void)jq_navigationToLocation:(CLLocationCoordinate2D)endCoordinate2D;



/**
 地球坐标 ---> 火星坐标
 */
+ (CLLocationCoordinate2D)jq_transitionToHuoXingCoordinate:(CLLocationCoordinate2D)coordinate;

@end

