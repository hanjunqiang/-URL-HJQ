
//
//  JQMapTool.m
//  测试
//
//  Created by 韩军强 on 2017/7/7.
//  Copyright © 2017年 iOS. All rights reserved.
//

#import "JQMapTool.h"
#import <MapKit/MapKit.h>
#import "LSGetCurrentLocation.h"

@implementation JQMapTool

//防止获取当前经纬度时多次回调。
static NSString *isFirst;

+(void)jq_navigationToLocation:(CLLocationCoordinate2D)endCoordinate2D
{
    //http://blog.csdn.net/a416863220/article/details/51220739
    
    isFirst = @"1";
    
    //获取自己的当前位置
    [[LSGetCurrentLocation shareManager] beginLocate];
    
    [LSGetCurrentLocation shareManager].locationBlock = ^(double longitude, double latitude) {
        
        if (longitude>=0&&latitude>=0) {
            
            [[LSGetCurrentLocation shareManager] stopLocation];//结束定位
            
            if ([isFirst integerValue]) {
                
                isFirst = @"0";
                
                CLLocationCoordinate2D startCoordinate2D;
                startCoordinate2D.latitude = latitude;
                startCoordinate2D.longitude = longitude;
                
                //把开始和结束的位置传过去，返回可以打开的APP以及对应的URL
                NSArray * arry = [self jq_startNavgationStartLocation:startCoordinate2D endLocation:endCoordinate2D];
                
                
                //初始化提示框；
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择导航地图" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                for (int i=0; i<arry.count; i++) {
                    
                    
                    NSDictionary *dic = [arry objectAtIndex:i];
                    
                    NSString *title = [dic objectForKey:@"title"];
                    
                    [alert addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        NSString *urlString = dic[@"url"];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                        
                    }]];
                    
                }
                
                [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                    
                    
                }]];
                
                //弹出提示框；
                [self.jq_currentVC presentViewController:alert animated:true completion:nil];
            }
            
        }
        
    };
    
    
}

+(NSMutableArray *)jq_startNavgationStartLocation:(CLLocationCoordinate2D)startCoordinate2D endLocation:(CLLocationCoordinate2D)endCoordinate2D
{
    
    /**
     
     {
     origin	起点名称或经纬度，或者可同时提供名称和经纬度，此时经纬度优先级高，将作为导航依据，名称只负责展示。	必选
     1、名称：天安门
     2、经纬度：39.98871<纬度>,116.43234<经度>。
     3、名称和经纬度：name:天安门|latlng:39.98871,116.43234（注意：“name:天安门|”是必须要写的！）
     }
     
     {
     region	城市名或县名  必选
     （当给定region时，认为起点和终点都在同一城市，除非单独给定起点或终点的城市。）
     }
     name	线路名称	必选
     zoom	展现地图的级别，默认为视觉最优级别。	可选
     src	调用来源，规则：webapp.line.yourCompanyName.yourAppName	必选
     location	lat<纬度>,lng<经度>	必选
     title      标注点显示标题     必选
     product下可直接跟方法，当然产品线也可增加一个service级别
     content	标注点显示内容     必选
     mode导航模式，固定为transit、driving、navigation、walking，riding分别表示公交、驾车、导航、步行和骑行
     
     {
     coord_type	坐标类型，可选参数，默认为bd09ll。	可选
     允许的值为bd09ll、bd09mc、gcj02、wgs84。
     bd09ll表示百度经纬度坐标，
     bd09mc表示百度墨卡托坐标，
     gcj02表示经过国测局加密的坐标，
     wgs84表示gps获取的坐标。
     }
     
     举例：
     baidumap://map/direction?origin=中关村&destination=五道口&mode=driving&region=北京
     //本示例是通过该URL启动地图app并进入北京市从中关村到五道口的驾车导航路线图
     
     
     */
    
    
    NSMutableArray *maps = [NSMutableArray array];
    
    //百度地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        NSMutableDictionary *baiduMapDic = [NSMutableDictionary dictionary];
        baiduMapDic[@"title"] = @"百度地图";
        
        
        CLLocationCoordinate2D baiduStartCoordinate = startCoordinate2D;
        CLLocationCoordinate2D baiduEndCoordinate = endCoordinate2D;
        
        //地球坐标转火星坐标
        baiduStartCoordinate = [self jq_transitionToHuoXingCoordinate:baiduStartCoordinate];
        
        //高德坐标转百度坐标
        baiduStartCoordinate = [self BD09FromGCJ02:baiduStartCoordinate];
        baiduEndCoordinate = [self BD09FromGCJ02:baiduEndCoordinate];
        
        /**
         注意：“name:当前位置|”必须要在latlng之前写上！！！
         
         >1,起始位置：origin=name:当前位置|latlng:%f,%f
         >2,终点位置：destination=name:终点位置|latlng:%lf,%lf
         */
        NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin=name:当前位置|latlng:%f,%f&destination=name:终点位置|latlng:%lf,%lf&mode=riding&coord_type=gcj02",baiduStartCoordinate.latitude,baiduStartCoordinate.longitude,baiduEndCoordinate.latitude,baiduEndCoordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        baiduMapDic[@"url"] = urlString;
        [maps addObject:baiduMapDic];
    }
    
    
    //高德地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        NSMutableDictionary *gaodeMapDic = [NSMutableDictionary dictionary];
        gaodeMapDic[@"title"] = @"高德地图";
        
        /**
         sourceApplication : APP名称
         backScheme  :   URL Scheme（用于从高德返回到APP，唯一标识）
         lat：纬度
         lon：经度
         dev和style固定传就可以了
         */
        NSString *urlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%.1f&lon=%.1f&dev=0&style=2",@"乐送APP",@"GaoDeMap1001",endCoordinate2D.latitude,endCoordinate2D.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        gaodeMapDic[@"url"] = urlString;
        [maps addObject:gaodeMapDic];
    }
    
    //    //谷歌地图
    //    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
    //        NSMutableDictionary *googleMapDic = [NSMutableDictionary dictionary];
    //        googleMapDic[@"title"] = @"谷歌地图";
    //        NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving",@"导航测试",@"nav123456",endCoordinate2D.latitude, endCoordinate2D.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //        googleMapDic[@"url"] = urlString;
    //        [maps addObject:googleMapDic];
    //    }
    //
    //    //腾讯地图
    //    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
    //        NSMutableDictionary *qqMapDic = [NSMutableDictionary dictionary];
    //        qqMapDic[@"title"] = @"腾讯地图";
    //        NSString *urlString = [[NSString stringWithFormat:@"qqmap://map/routeplan?from=我的位置&type=drive&tocoord=%f,%f&to=终点&coord_type=1&policy=0",endCoordinate2D.latitude, endCoordinate2D.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //        qqMapDic[@"url"] = urlString;
    //        [maps addObject:qqMapDic];
    //    }
    
    
    return maps;
}


/**
 
 1、地球坐标 ：（ 代号：GPS、WGS84 ）--- 有W就是世界通用的
 也就是原始坐标体系，这是国际公认的世界标准坐标体系；
 
 注意：>1,使用 WGS84 坐标系统的产品有:  苹果的 CLLocationManager 获取的坐标
 
 2，百度坐标系统 （代号：BD-09）
 
 3,火星坐标： （代号：GCJ-02）--- G国家 C测绘 J局 02年测绘的
 
 注意：>1,使用 GCJ-02 火星坐标系统的产品有:
 高德地图、腾讯地图、阿里云地图、灵图51地图
 
 注意：现在苹果系统自带的地图使用的是高德地图，所以苹果自带的地图应用，用的是GCJ-02的坐标系统。
 ！！！但是代码中CLLocationManager获取到的是WGS84坐标系的坐标
 
 
 //---------------------------------------------------------------
 地球坐标 ---> 火星坐标
 */
+ (CLLocationCoordinate2D)jq_transitionToHuoXingCoordinate:(CLLocationCoordinate2D)coordinate
{
    
    double longitude = coordinate.longitude;
    double latitude = coordinate.latitude;
    
    // 首先判断坐标是否属于天朝
    if (![self isInChinaWithlat:latitude lon:longitude]) {
        
        CLLocationCoordinate2D resultCoordinate;
        resultCoordinate.latitude = latitude;
        resultCoordinate.longitude = longitude;
        return resultCoordinate;
        
    }
    
    double a = 6378245.0;
    double ee = 0.00669342162296594323;
    
    double dLat = [self transform_earth_from_mars_lat_lat:(latitude - 35.0) lon:(longitude - 35.0)];
    double dLon = [self transform_earth_from_mars_lng_lat:(latitude - 35.0) lon:(longitude - 35.0)];
    double radLat = latitude / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    
    double newLatitude = latitude + dLat;
    double newLongitude = longitude + dLon;
    
    
    CLLocationCoordinate2D resultCoordinate;
    resultCoordinate.longitude = newLongitude;
    resultCoordinate.latitude = newLatitude;
    
    return resultCoordinate;
}

+ (BOOL)isInChinaWithlat:(double)lat lon:(double)lon {
    if (lon < 72.004 || lon > 137.8347)
        return NO;
    if (lat < 0.8293 || lat > 55.8271)
        return NO;
    return YES;
}
+ (double)transform_earth_from_mars_lat_lat:(double)y lon:(double)x {
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 3320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

+ (double)transform_earth_from_mars_lng_lat:(double)y lon:(double)x {
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}


/**
 百度坐标转高德坐标
 */
+ (CLLocationCoordinate2D)GCJ02FromBD09:(CLLocationCoordinate2D)coor
{
    CLLocationDegrees x_pi = 3.14159265358979324 * 3000.0 / 180.0;
    CLLocationDegrees x = coor.longitude - 0.0065, y = coor.latitude - 0.006;
    CLLocationDegrees z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    CLLocationDegrees theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    CLLocationDegrees gg_lon = z * cos(theta);
    CLLocationDegrees gg_lat = z * sin(theta);
    return CLLocationCoordinate2DMake(gg_lat, gg_lon);  //注意这里反着传经纬度
}

/**
 高德坐标转百度坐标
 */
+ (CLLocationCoordinate2D)BD09FromGCJ02:(CLLocationCoordinate2D)coor
{
    CLLocationDegrees x_pi = 3.14159265358979324 * 3000.0 / 180.0;
    CLLocationDegrees x = coor.longitude, y = coor.latitude;
    CLLocationDegrees z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi);
    CLLocationDegrees theta = atan2(y, x) + 0.000003 * cos(x * x_pi);
    CLLocationDegrees bd_lon = z * cos(theta) + 0.0065;
    CLLocationDegrees bd_lat = z * sin(theta) + 0.006;
    return CLLocationCoordinate2DMake(bd_lat, bd_lon);  //注意这里反着传经纬度
}




/** 
    获取当前所在控制器
 */
+ (UIViewController *)jq_currentVC{
    
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    // modal
    if (vc.presentedViewController) {
        if ([vc.presentedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navVc = (UINavigationController *)vc.presentedViewController;
            vc = navVc.visibleViewController;
        }
        else if ([vc.presentedViewController isKindOfClass:[UITabBarController class]]){
            UITabBarController *tabVc = (UITabBarController *)vc.presentedViewController;
            if ([tabVc.selectedViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navVc = (UINavigationController *)tabVc.selectedViewController;
                return navVc.visibleViewController;
            }
            else{
                return tabVc.selectedViewController;
            }
        }
        else{
            vc = vc.presentedViewController;
        }
    }
    // push
    else{
        if ([vc isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabVc = (UITabBarController *)vc;
            if ([tabVc.selectedViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navVc = (UINavigationController *)tabVc.selectedViewController;
                return navVc.visibleViewController;
            }
            else{
                return tabVc.selectedViewController;
            }
        }
        else if([vc isKindOfClass:[UINavigationController class]]){
            UINavigationController *navVc = (UINavigationController *)vc;
            vc = navVc.visibleViewController;
        }
    }
    return vc;
}


@end

