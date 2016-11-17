//
//  AJCXViewController.m
//  HNJYB
//
//  Created by Mag1cPanda on 2016/11/14.
//  Copyright © 2016年 Mag1cPanda. All rights reserved.
//

#import "AJCXViewController.h"

@interface AJCXViewController ()<UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UILabel *tipsLab;

@end

@implementation AJCXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"等待定责";
    
    self.tipsLab.text = [NSString stringWithFormat:@"抱歉，您的案件已被交警转为【%@】，您可以直接报警处理！",_tips];
}

#pragma mark - UIActionSheetDelegate
- (IBAction)confimBtnClicked:(id)sender
{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"确定拨打电话？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
    [action showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex -> %zi", buttonIndex);
    if (buttonIndex == 0)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://122"]]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
