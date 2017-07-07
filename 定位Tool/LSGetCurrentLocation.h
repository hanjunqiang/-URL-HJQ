//
//  LSGetCurrentLocation.h
//  LeSong
//
//  Created by 韩军强 on 2017/6/19.
//  Copyright © 2017年 韩军强. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^LocationBlock)(double longitude,double latitude);
@interface LSGetCurrentLocation : NSObject<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, copy) LocationBlock locationBlock;

+(instancetype)shareManager;

- (void)beginLocate;
-(void)stopLocation;

@end
