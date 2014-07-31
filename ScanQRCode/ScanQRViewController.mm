//
//  ScanQRViewController.m
//  ScanQRCode
//
//  Created by Darren Xie on 14-7-29.
//  Copyright (c) 2014年 Darren Xie. All rights reserved.
//

#import "ScanQRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"
#import <QRCodeReader.h>
#import <Decoder.h>
#import <TwoDDecoderResult.h>
#import "ScanAnimationView.h"

@interface ScanQRViewController() <AVCaptureVideoDataOutputSampleBufferDelegate, DecoderDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) ScanAnimationView *scanAnimationView;

@end

@implementation ScanQRViewController
@synthesize delegate = _delegate;

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
    
    [self initCapture];
    
    //添加动画
    if (self.scanAnimationView == nil) {
        
        self.scanAnimationView = [[ScanAnimationView alloc] initWithFrame:self.view.bounds];
        
        [self.view addSubview:self.scanAnimationView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.scanAnimationView startScanAnimation];
}

//初始化扫描
- (void)initCapture {
    
    if (self.captureSession == nil) {
        self.captureSession = [[AVCaptureSession alloc] init];
    } else {
        [self.captureSession startRunning];
        return;
    }
    
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *captureInpute = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:nil];
    [self.captureSession addInput:captureInpute];
    
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    [captureOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    NSString *key = (NSString *)kCVPixelBufferPixelFormatTypeKey;
    NSNumber *value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [captureOutput setVideoSettings:videoSettings];
    [self.captureSession addOutput:captureOutput];
    
    NSString *preset = 0;
    if (NSClassFromString(@"NSOrderedSet") &&
        [UIScreen mainScreen].scale > 1 &&
        [inputDevice supportsAVCaptureSessionPreset:AVCaptureSessionPresetiFrame960x540]) {
        
        preset = AVCaptureSessionPresetiFrame960x540;
    }
    if (!preset) {
        
        preset = AVCaptureSessionPresetMedium;
    }
    self.captureSession.sessionPreset = preset;
    
    if (!self.captureVideoPreviewLayer) {
        self.captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    }
    
    CGRect videoFrame = self.view.bounds;
    self.captureVideoPreviewLayer.frame = videoFrame;
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.captureVideoPreviewLayer];
    
    [self.captureSession startRunning];
}

//生成图片
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    size_t bytesPreRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (!colorSpace) {
        NSLog(@"CGColorSpaceCreateDeviceRGB failure");
        return nil;
    }
    
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
    
    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPreRow, colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little, provider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}

//图片解码
- (void)decodeImage:(UIImage *)image {
    NSMutableSet *qrReader = [[NSMutableSet alloc] init];
    QRCodeReader *qrcoderReader = [[QRCodeReader alloc] init];
    [qrReader addObject:qrcoderReader];
    
    Decoder *decoder  = [[Decoder alloc] init];
    decoder.delegate = self;
    decoder.readers = qrReader;
    [decoder decodeImage:image];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

//扫描产生的数据
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    [self decodeImage:image];
}


#pragma mark - DecoderDelegate

//图片解码的结果
- (void)decoder:(Decoder *)decoder didDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset withResult:(TwoDDecoderResult *)result {
    NSLog(@"result = %@", result.text);
    [self.captureSession stopRunning];
    if (_delegate && [_delegate respondsToSelector:@selector(scanQRViewController:didScanResult:)]) {
        [self.delegate scanQRViewController:self didScanResult:result.text];
    }
}

- (void)decoder:(Decoder *)decoder failedToDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset reason:(NSString *)reason {
//    NSLog(@"decode image error! reason: %@", reason);
}

#pragma -mark 

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.captureSession stopRunning];
    [self.scanAnimationView stopScanAnimation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    _delegate = nil;
    _captureVideoPreviewLayer = nil;
    _captureSession = nil;
    _scanAnimationView = nil;
}


@end
