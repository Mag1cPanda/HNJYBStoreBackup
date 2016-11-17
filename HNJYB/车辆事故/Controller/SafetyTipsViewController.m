//
//  SafetyTipsViewController.m
//  CZT_HN_Longrise
//
//  Created by OSch on 16/5/14.
//  Copyright © 2016年 OSch. All rights reserved.
//

#import "JCAlertView.h"
#import "SafeTipsView.h"
#import "SafetyTipsViewController.h"
#import "WarmTipsViewController.h"

@interface SafetyTipsViewController ()
{
    UIScrollView *scroll;
    UIView *header;
    SafeTipsView *tipsView;
    MBProgressHUD *hud;
    JCAlertView *jcAlert;
}

@end

@implementation SafetyTipsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"安全提示";

    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc] init];
    //初始化地理编码类
    _geocodesearch = [[BMKGeoCodeSearch alloc] init];

    header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 100)];
    header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]];

    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, header.height - 20, header.height - 20)];
    icon.image = [UIImage imageNamed:@"IP013"];
    [header addSubview:icon];

    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(icon.maxX + 10, header.height / 2 - 20, ScreenWidth - icon.maxX - 20, 40)];
    titleLab.textColor = [UIColor whiteColor];
    [header addSubview:titleLab];
    titleLab.text = @"到达事故现场后，请务必确保警员及当事人已经撤离到安全地带";
    titleLab.numberOfLines = 0;
    titleLab.font = HNFont(16);
    if (ScreenWidth == 320)
    {
        titleLab.font = HNFont(14);
    }

    [self.view addSubview:header];

    scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, ScreenWidth, ScreenHeight - 164)];
    scroll.scrollEnabled = YES;
    [self.view addSubview:scroll];

    scroll.contentSize = CGSizeMake(ScreenWidth, 460);

    tipsView = [[NSBundle mainBundle] loadNibNamed:@"SafeTipsView" owner:nil options:nil][0];
    tipsView.frame = CGRectMake(0, 0, ScreenWidth, 460);
    [tipsView.confirmBtn addTarget:self action:@selector(confirmBtnClicked) forControlEvents:1 << 6];
    [scroll addSubview:tipsView];
}

- (void)confirmBtnClicked
{
    WarmTipsViewController *vc = [WarmTipsViewController new];
    [self.navigationController pushViewController:vc animated:YES];
    tipsView.confirmBtn.userInteractionEnabled = NO;
}

#pragma mark - Life Circle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    tipsView.confirmBtn.userInteractionEnabled = YES;
    //获取用户位置
    [self getPositionInfo];
    _locService.delegate = self;
    _geocodesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _locService.delegate = nil;
    _geocodesearch.delegate = nil; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

#pragma mark 获取位置信息
- (void)getPositionInfo
{
    //判读单例里面是否有定位信息
    if (!GlobleInstance.areaid ||
        !GlobleInstance.imageaddress ||
        !GlobleInstance.imagelat ||
        !GlobleInstance.imagelon)
    {
        //判断是非有定位权限
        if ([CLLocationManager locationServicesEnabled] &&
            ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse))
        {
            //定位功能可用，开始定位
            NSLog(@"开始定位");
            if (_locService != nil)
            {
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.label.text = @"正在定位";
                [_locService startUserLocationService];
            }
        }
        else
        {
            NSLog(@"定位功能不可用，提示用户");
        }
    }
    else
    {
        //上一次的时间戳
        NSNumber *tempNum;
        float lastTime = 0;
        if (tempNum != nil)
        {
            lastTime = tempNum.floatValue;
        }
        //当前时间戳
        float nowTime = [Util getCurrentTime];
        //判读时间是否超过10分钟
        if (nowTime - lastTime > 10 * 60 * 1000)
        {
            //超过十分钟重写定位
            if (_locService != nil)
            {
                [_locService startUserLocationService];
            }
        }
        else
        {
        }
    }
}

#pragma mark - 获取Areaid
- (void)getCurrentAreaId
{
    NSMutableDictionary *bean = [NSMutableDictionary dictionary];
    
    NSString *maplon = [NSString stringWithFormat:@"%f", GlobleInstance.imagelon];
    NSString *maplat = [NSString stringWithFormat:@"%f", GlobleInstance.imagelat];
    NSString *userflag = [NSString stringWithFormat:@"%@", GlobleInstance.userflag];
    NSString *token = [NSString stringWithFormat:@"%@", GlobleInstance.token];
    
    [bean setValue:maplon forKey:@"maplon"];
    [bean setValue:maplat forKey:@"maplat"];
    [bean setValue:userflag forKey:@"userflag"];
    [bean setValue:token forKey:@"token"];
    
    [LSHttpManager requestUrl:HNServiceURL serviceName:@"jjappgetweather" parameters:bean complete:^(id result, ResultType resultType) {
        
        if ([result[@"restate"] isEqualToString:@"1"])
        {
            NSLog(@"Areaid -> %@", [Util objectToJson:result]);
            
            NSString *areaid = result[@"data"];
            GlobleInstance.areaid = areaid;
        }
        
        else
        {
            NSLog(@"获取areaid不成功");
        }
        
    }];
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"定位失败");
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    //显示经纬度
    NSLog(@"用户位置更新后的经纬度：lat:%f,long:%f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);

    //停止定位
    if (nil != _locService)
    {
        [_locService stopUserLocationService];
    }

    lat = userLocation.location.coordinate.latitude;
    lon = userLocation.location.coordinate.longitude;
    //经纬度写死为河南
    //    lat = 34.7568711;
    //    lon = 113.663221;
    GlobleInstance.imagelat = lat;
    GlobleInstance.imagelon = lon;
    
    //根据经纬度获取Areaid
    [self getCurrentAreaId];

    //开始检索，将经纬度转化成具体地址
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){lat, lon};

    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if (flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
}

#pragma mark 经纬度转化成地址回调接口
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    hud.mode = MBProgressHUDModeText;

    if (error == BMK_SEARCH_NO_ERROR)
    {
        //        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        //        item.coordinate = result.location;
        //        item.title = result.address;
        hud.label.text = @"定位成功";
        NSLog(@"反向地理编码地址：%@", result.address);
        imageAddress = result.address;
        [Globle getInstance].imageaddress = result.address;

        //保存当前时间戳
        [UserDefaultsUtil saveNSUserDefaultsForObject:[[NSNumber alloc] initWithFloat:[[NSDate date] timeIntervalSince1970]] forKey:LocationTIMEKEY];
    }
    else
    {
        hud.label.text = @"定位失败";
        NSLog(@"经纬度转化成地址回调方法中反geo检索发送失败");
    }

    [hud hideAnimated:YES afterDelay:1.0];
}

@end
