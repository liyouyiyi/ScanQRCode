//
//  ScanAnimationView.h
//  ScanQRCode
//
//  Created by JuLong on 14-7-30.
//  Copyright (c) 2014年 julong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanAnimationView : UIView

@property (assign, nonatomic) CGRect foucsBounds;

- (void)addScanLineAnimation;
- (void)stopScanLineAnimation;

@end
