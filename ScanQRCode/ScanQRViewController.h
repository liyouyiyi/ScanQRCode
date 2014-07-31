//
//  ScanQRViewController.h
//  ScanQRCode
//
//  Created by Darren Xie on 14-7-29.
//  Copyright (c) 2014年 Darren Xie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScanQRViewControllerDelegate;

@interface ScanQRViewController : UIViewController

@property (nonatomic, weak) id<ScanQRViewControllerDelegate> delegate;

@end




@protocol ScanQRViewControllerDelegate <NSObject>

@optional
- (void)scanQRViewController:(ScanQRViewController *)scanQRViewController didScanResult:(NSString *)result;
- (void)scanQRViewControllerDidCancel:(ScanQRViewController *)scanQRViewController;

@end



