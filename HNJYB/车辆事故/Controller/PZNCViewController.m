//
//  PZNCViewController.m
//  HNJYB
//
//  Created by Mag1cPanda on 16/8/1.
//  Copyright © 2016年 Mag1cPanda. All rights reserved.
//

#import "AccidentHeader.h"
#import "JCAlertView.h"
#import "MoreCarViewController.h"
#import "OneCarViewController.h"
#import "PZNCCell.h"
#import "PZNCViewController.h"
#import "SRBlockButton.h"

@interface PZNCViewController () < UITableViewDataSource, UITableViewDelegate >
{
    AccidentHeader *header;
    UITableView *table;
    NSArray *iconArr;
    NSArray *titleArr;
    JCAlertView *jcAlert;
}
@end

@implementation PZNCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"选择事故类型";
    iconArr = @[ @"IP011", @"IP012" ];
    titleArr = @[ @"单车事故", @"双车事故" ];

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 45, 30);
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:1 << 6];

    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 18, 13)];
    icon.image = [UIImage imageNamed:@"IP020"];
    icon.center = backBtn.center;
    [backBtn addSubview:icon];

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = item;

    header = [[AccidentHeader alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 100)];
    header.icon.image = [UIImage imageNamed:@"IP013"];
    header.topLab.text = @"请您在保证自身安全的情况下操作";
    header.bottemLab.text = @"请选择事故类型";
    [self.view addSubview:header];

    table = [[UITableView alloc] initWithFrame:CGRectMake(10, 100, ScreenWidth - 20, ScreenHeight - 164) style:UITableViewStylePlain];
    table.tableFooterView = [UIView new];
    table.backgroundColor = HNBackColor;
    table.delegate = self;
    table.dataSource = self;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:table];

    [table registerNib:[UINib nibWithNibName:@"PZNCCell" bundle:nil] forCellReuseIdentifier:@"PZNCCell"];
}

#pragma mark - tableView Delegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PZNCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PZNCCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.icon.image = [UIImage imageNamed:iconArr[indexPath.section]];
    cell.contentLab.text = titleArr[indexPath.section];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth - 20, 10)];
    view.backgroundColor = HNBackColor;
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    //输出格式为：2010-10-27 10:22:13
    NSLog(@"%@", currentDateStr);

    GlobleInstance.casehaptime = currentDateStr;

    
    //获取案件编号
    NSMutableDictionary* bean = [NSMutableDictionary dictionary];
    [bean setValue:GlobleInstance.areaid forKey:@"areaid"];
    [bean setValue:GlobleInstance.userflag forKey:@"username"];
    [bean setValue:GlobleInstance.token forKey:@"token"];
    
    MBProgressHUD* caseNumHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [LSHttpManager requestUrl:HNServiceURL serviceName:@"jjappkckpCreateAppCaseNo" parameters:bean complete:^(id result, ResultType resultType) {
        
        [caseNumHud hideAnimated:true];
        
        //获取案件编号成功后才让用户进入拍照界面
        if ([result[@"restate"] isEqualToString:@"1"]) {
            NSLog(@"案件编号 -> %@", [Util objectToJson:result]);
            NSString* appcaseno = [NSString stringWithFormat:@"%@", result[@"data"][@"appcaseno"]];
            GlobleInstance.appcaseno = appcaseno;
            
            if (indexPath.section == 0)
            {
                OneCarViewController *vc = [OneCarViewController new];
                GlobleInstance.isOneCar = YES; //单车
                [self.navigationController pushViewController:vc animated:YES];
            }
            
            else
            {
                MoreCarViewController *vc = [MoreCarViewController new];
                GlobleInstance.isOneCar = NO; //双车
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        }
        
        else {
            SHOWALERT(@"生成案件编号失败");
        }
        
    }];
    
    
}

@end
