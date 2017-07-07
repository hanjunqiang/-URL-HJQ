
//
//  LSGetCurrentLocation.m
//  LeSong
//
//  Created by 韩军强 on 2017/6/19.
//  Copyright © 2017年 韩军强. All rights reserved.
//

#import "LSGetCurrentLocation.h"

@implementation LSGetCurrentLocation

+(instancetype)shareManager
{
    static LSGetCurrentLocation *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LSGetCurrentLocation alloc] init];
    });
    
    return _instance;
}



#pragma mark CoreLocation deleagte (定位失败)
/*定位失败则执行此代理方法*/
/*定位失败弹出提示窗，点击打开定位按钮 按钮，会打开系统设置，提示打开定位服务*/
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    /*设置提示提示用户打开定位服务*/
//    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"允许\"定位\"提示" message:@"请在设置中打开定位" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction * ok =[UIAlertAction actionWithTitle:@"打开定位" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        /*打开定位设置*/
//        NSURL * settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//        [[UIApplication sharedApplication]openURL:settingsURL];
//    }];
//    UIAlertAction * cacel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        
//    }];
//    [alert addAction:ok];
//    [alert addAction:cacel];
//    [self.jq_currentVC presentViewController:alert animated:YES completion:nil];
    
//    [MBProgressHUD showError:@"请打开定位服务！"];
    
    
    NSLog(@"请打开定位服务！");
    self.locationBlock(0, 0);
}

//更新位置
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    //    locations 存放的是cllocations对象 一个对象代表一个位置
    CLLocation *location=[locations objectAtIndex:0];
    

    
    NSLog(@"%@",[NSString stringWithFormat:@"经度为：%f",location.coordinate.longitude]);
    
    NSLog(@"%@",[NSString stringWithFormat:@"纬度为：%f",location.coordinate.latitude]);
    NSLog(@"%@",[NSString stringWithFormat:@"海拔为：%f",location.altitude]);
    
    //获取到一次经纬度就停止获取。（这里更新位置会来多次。）
    if (location.coordinate.longitude&&location.coordinate.latitude) {
        
//        [self stopLocation]; //关闭定位
        //回调出去地址。
        self.locationBlock(location.coordinate.longitude, location.coordinate.latitude);
    }
    
}




#pragma mark - 定位
- (void)beginLocate{
    
    //实例化位置管理器
    self.locationManager=[[CLLocationManager alloc]init];
    self.locationManager.delegate=self;
    
    //kCLLocationAccuracyBest  设备使用电池供电时的最高精度
    //desiredAccuracy 所需的精度
    self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
        //[_locationManager requestWhenInUseAuthorization];//?只在前台开启定位
        [_locationManager requestAlwaysAuthorization];//在后台也可定位
    }
    // 5.iOS9新特性：将允许出现这种场景：同一app中多个location manager：一些只能在前台定位，另一些可在后台定位（并可随时禁止其后台定位）。
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        _locationManager.allowsBackgroundLocationUpdates = YES;
    }
    
    //移动了1000米通知委托方法进行更新
    //    self.locationManager.distanceFilter=1000;
    
    //每秒更新一次
    self.locationManager.distanceFilter=kCLHeadingFilterNone;
    [self.locationManager startUpdatingLocation];
    
}

-(void)stopLocation
{
    //定位停止
    [self.locationManager stopUpdatingLocation];
}

//#pragma mark - 去系统设置开启权限
//- (void)jumpToSetting{
//    
//    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//    
//    //info plist中URL type中添加一个URL Schemes添加一个prefs值
//    if([[UIApplication sharedApplication] canOpenURL:url]){
//        //跳转到定位
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
//    }
//    
//}



@end
