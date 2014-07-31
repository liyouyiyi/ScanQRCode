//
//  HomeViewController.m
//  ScanQRCode
//
//  Created by Darren Xie on 14-7-29.
//  Copyright (c) 2014年 Darren Xie. All rights reserved.
//

#import "HomeViewController.h"
#import "Constants.h"
#import "ScanQRViewController.h"

@interface HomeViewController () <UITextFieldDelegate, ScanQRViewControllerDelegate>

@property (nonatomic, strong) UITextField *resultTextField;
@property (nonatomic, strong) ScanQRViewController *scanQRViewController;

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.resultTextField == nil) {
        self.resultTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 80, SCREEN_WIDTH - 40, 200)];
        self.resultTextField.returnKeyType = UIReturnKeyDone;
        self.resultTextField.delegate = self;
        self.resultTextField.font = [UIFont systemFontOfSize:14.0f];
        self.resultTextField.borderStyle = UITextBorderStyleLine;
        self.resultTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        self.resultTextField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.view addSubview:self.resultTextField];
    }
    
    UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [scanButton setFrame:CGRectMake((SCREEN_WIDTH - 80) / 2, 30 + 200 + 80, 80, 40)];
    [scanButton setTitle:@"Scan" forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(scanQR) forControlEvents:UIControlEventTouchUpInside];
    scanButton.titleLabel.font = [UIFont systemFontOfSize:20.0f];
    scanButton.layer.borderWidth = 1.0f;
    scanButton.layer.cornerRadius = 5.0f;
    [self.view addSubview:scanButton];

}

- (void)scanQR {
    if (self.scanQRViewController == nil) {
        self.scanQRViewController = [[ScanQRViewController alloc] init];
    }
    self.scanQRViewController.title = @"扫描二维码";
    self.scanQRViewController.delegate = self;
    [self.navigationController pushViewController:self.scanQRViewController animated:YES];
}

#pragma - mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [_resultTextField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma - mark ScanQRViewControllerDelegate

- (void)scanQRViewController:(ScanQRViewController *)scanQRViewController didScanResult:(NSString *)result {
    if (result == nil) {
        return;
    }
    
    [self.navigationController popToViewController:self animated:YES];
    
    NSLog(@"scan result = %@", result);
    _resultTextField.text = result;
}


#pragma - mark  Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    _resultTextField = nil;
    _scanQRViewController = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
