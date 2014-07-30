//
//  ScanAnimationView.m
//  ScanQRCode
//
//  Created by JuLong on 14-7-30.
//  Copyright (c) 2014年 julong. All rights reserved.
//

#import "ScanAnimationView.h"
#import "Constants.h"

#define kAnimationKeyPath @"position"
#define kCornerLength 10.0f

@interface ScanAnimationView() {
    CALayer *scanLineLayer_;
}

@end

@implementation ScanAnimationView

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"init with frame...");
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    CGRect tmpFocusBounds;
    
    float scanWidth = SCREEN_WIDTH  * 2.0f / 3.0f;
    tmpFocusBounds = CGRectMake(0, 0, scanWidth, scanWidth);
    CGRect bounds = self.bounds;
    tmpFocusBounds.size.width = MIN(bounds.size.width, tmpFocusBounds.size.width);
    tmpFocusBounds.size.height = MIN(bounds.size.height, tmpFocusBounds.size.height);
    tmpFocusBounds.origin.x = 0.5 * (bounds.size.width - tmpFocusBounds.size.width);
    tmpFocusBounds.origin.y = 0.5 * (bounds.size.height - tmpFocusBounds.size.height);
    
    CGPoint scanLineStartPosition;
    scanLineStartPosition = CGPointMake(CGRectGetMidX(tmpFocusBounds), CGRectGetMinY(tmpFocusBounds));
    scanLineLayer_ = [CALayer layer];
    scanLineLayer_.frame = CGRectMake(0, 0, tmpFocusBounds.size.width - 10, 12);
    scanLineLayer_.contents = (id)[UIImage imageNamed:@"QRScanLine"].CGImage;
    scanLineLayer_.position = scanLineStartPosition;
    
    [self.layer addSublayer:scanLineLayer_];
    self.foucsBounds = tmpFocusBounds;
    [self addScanLineAnimation];

}

- (void)addScanLineAnimation
{
    [self stopScanLineAnimation];
    CGRect tmpFocusBounds = self.foucsBounds;
    CGPoint scanLineStartPosition, scanLineEndPosition;
    scanLineStartPosition = CGPointMake(CGRectGetMidX(tmpFocusBounds), CGRectGetMinY(tmpFocusBounds));
    scanLineEndPosition = CGPointMake(CGRectGetMidX(tmpFocusBounds), CGRectGetMaxY(tmpFocusBounds));
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:kAnimationKeyPath];
    [animation setFromValue:[NSValue valueWithCGPoint:scanLineStartPosition]];
    [animation setToValue:[NSValue valueWithCGPoint:scanLineEndPosition]];
    [animation setDuration:2.50f];
    [animation setRepeatCount:100000];
    [scanLineLayer_ addAnimation:animation forKey:kAnimationKeyPath];
}

- (void)stopScanLineAnimation
{
    if ([scanLineLayer_ animationForKey:kAnimationKeyPath]) {
        [scanLineLayer_ removeAnimationForKey:kAnimationKeyPath];
    }
}

- (void)drawRect:(CGRect)rect
{
    self.backgroundColor = [UIColor whiteColor];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    UIColor *color = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    [color set];
    UIRectFill(self.bounds);
    
    UIColor *clearColor = [UIColor clearColor];
    [clearColor set];
    UIRectFill(self.foucsBounds);
    
    //画边框
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextStrokeRectWithWidth(context, CGRectInset(self.foucsBounds, -1, -1), 1.0);
    
    CGPoint leftUp = self.foucsBounds.origin;
    CGPoint rightUp = CGPointMake(CGRectGetMaxX(self.foucsBounds), leftUp.y);
    CGPoint rightDown = CGPointMake(rightUp.x, CGRectGetMaxY(self.foucsBounds));
    
    //左上角
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, leftUp.x, leftUp.y + kCornerLength);
    CGPathAddLineToPoint(path, NULL, leftUp.x, leftUp.y);
    CGPathAddLineToPoint(path, NULL, leftUp.x + kCornerLength, leftUp.y);
    //右上角
    CGPathMoveToPoint(path, NULL, rightUp.x - kCornerLength, rightUp.y);
    CGPathAddLineToPoint(path, NULL, rightUp.x, rightUp.y);
    CGPathAddLineToPoint(path, NULL, rightUp.x, rightUp.y + kCornerLength);
    //右下角
    CGPathMoveToPoint(path, NULL, rightDown.x, rightDown.y - kCornerLength);
    CGPathAddLineToPoint(path, NULL, rightDown.x, rightDown.y);
    CGPathAddLineToPoint(path, NULL, rightDown.x - kCornerLength, rightDown.y);
    //左下角
    CGPathMoveToPoint(path, NULL, leftUp.x, rightDown.y - kCornerLength);
    CGPathAddLineToPoint(path, NULL, leftUp.x, rightDown.y);
    CGPathAddLineToPoint(path, NULL, leftUp.x + kCornerLength, rightDown.y);
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.2 green:1.0 blue:0.2 alpha:1.0].CGColor);
    CGContextSetLineWidth(context, 4.0);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    
    CGPathRelease(path);
}


@end
