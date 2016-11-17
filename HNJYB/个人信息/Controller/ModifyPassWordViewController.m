//
//  ModifyPassWordViewController.m
//  CZT_HN_Longrise
//
//  Created by OSch on 16/5/20.
//  Copyright © 2016年 OSch. All rights reserved.
//

#import "ModifyPassWordViewController.h"
#import "LoginViewController.h"
#import "DESCript.h"
#import "NavViewController.h"
#import "LoginViewController.h"

@interface ModifyPassWordViewController ()<UITextFieldDelegate>
{
    
}
@end

@implementation ModifyPassWordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"修改密码";
    self.oldPWTextField.delegate = self;
    self.pWTextField.delegate = self;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.view endEditing:YES];
}

-(void)showHudWithMessage:(NSString *)msg font:(CGFloat)size hideAfterDelay:(NSTimeInterval)second
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    hud.mode = MBProgressHUDModeText;
    hud.label.font = HNFont(size);
    hud.label.text = msg;
    [hud hideAnimated:YES afterDelay:second];
}

#pragma mark - 确认修改
- (IBAction)sureBtnClick:(id)sender {
    
    [self.view endEditing:YES];
    //旧密码
    NSString *oldPassword = [UserDefaultsUtil getDataForKey:@"password"];
    
    if (!self.oldPWTextField.text.length) {
        [self showHudWithMessage:@"当前密码不能为空!" font:14 hideAfterDelay:1];
        return;
    }
    if (!self.pWTextField.text.length)
    {
        [self showHudWithMessage:@"新密码不能为空!" font:14 hideAfterDelay:1];
        return;
    }
    if (![self.oldPWTextField.text isEqualToString:oldPassword])
    {
        [self showHudWithMessage:@"您输入的当前密码错误，请重新输入" font:12 hideAfterDelay:1.5];
        return;
    }
    if (![self checkPassWordRationality:self.pWTextField.text])
    {
        [self showHudWithMessage:@"请输入6~15位由字母和数字组合的新密码" font:12 hideAfterDelay:1.5];
        return;
    }
    else
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"正在上传...";
        
        NSString *oldPassword = [DESCript encrypt:self.oldPWTextField.text encryptOrDecrypt:kCCEncrypt key:[Util getKey]];
        NSString *newPassword = [DESCript encrypt:self.pWTextField.text encryptOrDecrypt:kCCEncrypt key:[Util getKey]];
        
        NSMutableDictionary *bean = [[NSMutableDictionary alloc] init];
        [bean setValue:[Globle getInstance].userflag forKey:@"userflag"];
        [bean setValue:oldPassword forKey:@"passwordold"];
        [bean setValue:newPassword forKey:@"passwordnew"];
        [bean setValue:[Globle getInstance].token forKey:@"token"];
        
        [LSHttpManager requestUrl:HNServiceURL serviceName:@"jjappusermodifypwd" parameters:bean complete:^(id result, ResultType resultType) {
            
            [hud hideAnimated:YES];
            
            if (result != nil) {
                if ([result[@"restate"] isEqualToString:@"1"]) {
                    
                    [UserDefaultsUtil saveNSUserDefaultsForObject:@"" forKey:@"username"];
                    [UserDefaultsUtil saveNSUserDefaultsForObject:@"" forKey:@"password"];
                    
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"密码修改成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    alertView.tag = 100;
                    [alertView show];
                }
                else
                {
                    [self showHudWithMessage:result[@"redes"] font:14 hideAfterDelay:1];
                }
            }
            else
            {
                [self showHudWithMessage:@"密码修改失败，请检查您的网络!" font:14 hideAfterDelay:1];
            }

        }];
        
    }
}

#pragma mark - 是否显示密码
- (IBAction)showOldEntryClick:(id)sender {
    self.oldPWTextField.secureTextEntry = !self.oldPWTextField.secureTextEntry;
    [self.showEntryBtn1 setImage:self.oldPWTextField.secureTextEntry == YES ? [UIImage imageNamed:@"eyes"] : [UIImage imageNamed:@"eyes_select"] forState:UIControlStateNormal];
}

- (IBAction)showNewEntryClick:(id)sender {
    self.pWTextField.secureTextEntry = !self.pWTextField.secureTextEntry;
    [self.showEntryBtn2 setImage:self.pWTextField.secureTextEntry == YES ? [UIImage imageNamed:@"eyes"] : [UIImage imageNamed:@"eyes_select"] forState:UIControlStateNormal];
}

#pragma mark- alertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        NavViewController *nav = [[NavViewController alloc] initWithRootViewController:[LoginViewController new]];
        [self presentViewController:nav animated:YES completion:nil];
    }
    
}

#pragma mark - 正则验证用户名和密码
- (BOOL)checkPassWordRationality:(NSString *)rationalityString
{
    NSString *pattern = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z_]{6,15}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pattern];
    BOOL isMatch = [predicate evaluateWithObject:rationalityString];
    return isMatch;
}

@end
