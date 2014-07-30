//
//  ScanQRViewController.h
//  ScanQRCode
//
//  Created by JuLong on 14-7-29.
//  Copyright (c) 2014年 julong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScanQRViewControllerDelegate;
@interface ScanQRViewController : UIViewController

@property (nonatomic, assign) id<ScanQRViewControllerDelegate> delegate;

@end


@protocol ScanQRViewControllerDelegate <NSObject>

@optional
- (void)scanQRViewController:(ScanQRViewController *)scanQRViewController didScanResult:(NSString *)result;
- (void)scanQRViewControllerDidCancel:(ScanQRViewController *)scanQRViewController;

@end



