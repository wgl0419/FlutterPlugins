//
//  SCCaptureCameraController.m
//  SCCaptureCameraDemo
//
//  Created by Aevitx on 14-1-16.
//  Copyright (c) 2014年 Aevitx. All rights reserved.
//

#import "SCCaptureCameraController.h"
#import "SCSlider.h"
#import "SCCommon.h"
#include "IOSOCRAPI.h"
#import "targetconditionals.h"
#import "SCCaptureSessionManager.h"
#import "CameraBankDrawView.h"
#import "ScranResultViewController.h"
BOOL isClose = FALSE;
int  isStartStatus = 0;
#define SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE      0   //对焦框是否一直闪到对焦完成

#define SWITCH_SHOW_DEFAULT_IMAGE_FOR_NONE_CAMERA   1   //没有拍照功能的设备，是否给一张默认图片体验一下

//height
#define CAMERA_TOPVIEW_HEIGHT   44  //title
#define CAMERA_MENU_VIEW_HEIGH  56  //menu

//color
#define bottomContainerView_UP_COLOR     [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1.f]       //bottomContainerView的上半部分
#define bottomContainerView_DOWN_COLOR   [UIColor colorWithRed:68/255.0f green:68/255.0f blue:68/255.0f alpha:1.f]       //bottomContainerView的下半部分
#define DARK_GREEN_COLOR        [UIColor colorWithRed:10/255.0f green:107/255.0f blue:42/255.0f alpha:1.f]    //深绿色
#define LIGHT_GREEN_COLOR       [UIColor colorWithRed:143/255.0f green:191/255.0f blue:62/255.0f alpha:1.f]    //浅绿色


//对焦
#define ADJUSTINT_FOCUS @"adjustingFocus"
#define LOW_ALPHA   1.0f
#define HIGH_ALPHA  1.0f

//typedef enum {
//    bottomContainerViewTypeCamera    =   0,  //拍照页面
//    bottomContainerViewTypeAudio     =   1   //录音页面
//} BottomContainerViewType;

@interface SCCaptureCameraController () {
    int alphaTimes;
    CGPoint currTouchPoint;
}

@property (nonatomic, strong) SCCaptureSessionManager *captureManager;

@property (nonatomic, strong) UIView *topContainerView;//顶部view
@property (nonatomic, strong) UILabel *topLbl;//顶部的标题

@property (nonatomic, strong) UIView *bottomContainerView;//除了顶部标题、拍照区域剩下的所有区域
@property (nonatomic, strong) UIView *cameraMenuView;//网格、闪光灯、前后摄像头等按钮
@property (nonatomic, strong) NSMutableSet *cameraBtnSet;

@property (nonatomic, strong) UIView *doneCameraUpView;
@property (nonatomic, strong) UIView *doneCameraDownView;

@property (nonatomic, strong) CameraDrawView* drawView;
//对焦
@property (nonatomic, strong) UIImageView *focusImageView;
@property (nonatomic, strong) UIView *scanWindow;
@property (nonatomic, strong) UIImageView *scanNetImageView;

@property (nonatomic, strong) SCSlider *scSlider;
//@property (strong, nonatomic) ScranResultViewController *resultController;
@property(nonatomic,strong)UILabel *lable;
//@property (nonatomic) id runtimeErrorHandlingObserver;
//@property (nonatomic) BOOL lockInterfaceRotation;

@end

@implementation SCCaptureCameraController
//#if TARGET_IPHONE_SIMULATOR == 0
//#pragma mark -------------life cycle---------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        alphaTimes = -1;
        currTouchPoint = CGPointZero;
        
        _cameraBtnSet = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)viewDidLoad// 初始化界面
{
    [super viewDidLoad];
#if TARGET_IPHONE_SIMULATOR == 0
    /**外部如果有设置TimeKey使用外部设置，反之使用引擎内置KEY值*/
    if (_TimeKey != NULL) {
        isStartStatus = TREC_StartUP(_TimeKey);
    }
    else
        isStartStatus = TREC_StartUP(TREC_GetEngineTimeKEY());
    if (_iCardType == TIDCARDBACK) {
        _iCardType = TIDCARD2;
    }
    if (isStartStatus == 1 && _account != NULL) {
        TREC_SetParam(T_SET_PER_CALL_ACCOUNT, (void *)[_account cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    if (isStartStatus == 1 && _acckey != NULL) {
        TREC_SetParam(T_SET_PER_CALL_PASSWORD, (void *)[_acckey cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    if (isStartStatus == 1 && _timeout > 0) {
        TREC_SetParam(T_SET_PER_CALL_TIMEOUT, &_timeout);
    }
#endif

    if (self.navigationController && !self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    
    //status bar
    if (!self.navigationController) {
        _isStatusBarHiddenBeforeShowCamera = [UIApplication sharedApplication].statusBarHidden;
        if ([UIApplication sharedApplication].statusBarHidden == NO) {
            //iOS7，需要plist里设置 View controller-based status bar appearance 为NO
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        }
    }
    
    //notification
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationOrientationChange object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:kNotificationOrientationChange object:nil];
//
    //session manager
    SCCaptureSessionManager *manager = [[SCCaptureSessionManager alloc] init];
    
    //AvcaptureManager
    if (CGRectEqualToRect(_previewRect, CGRectZero)) {
        if (self.iCardType == TIDBANK
            || (self.iCardType == TIDCARD2 && self.ScanMode == TIDC_SCAN_MODE)
            || (self.iCardType == TIDLPR && self.ScanMode == TIDC_SCAN_MODE)) {
            self.previewRect = CGRectMake(0, 0, SC_DEVICE_SIZE.width, SC_DEVICE_SIZE.height);
        }
        else
        {
            self.previewRect = CGRectMake(0, 0, SC_APP_SIZE.width, SC_APP_SIZE.height);
        }
    }
    isClose = FALSE;
    self.drawView = [[CameraDrawView alloc]initWithFrame:self.previewRect ];
    [self.drawView setIsPortrait:self.isPortrait];
    [manager SetCardType:self.iCardType Mode:self.ScanMode];
//    [manager SetValuePoint:[self.drawView getBeginPoint] End:[self.drawView getEndPoint]];
    manager.delegate = self;
    [manager configureWithParentLayer:self.view previewRect:_previewRect];
    [manager setIsPortrait:self.isPortrait];
    self.captureManager = manager;
    
    [self addTextInfo];
//    [self addTopViewWithText:@"拍照"];
    
//    [self addbottomContainerView];
    [self addCameraMenuView];
    [self addFocusView];
    [self addCameraCover];
    [self addPinchGesture];
    
    
    [_captureManager.session startRunning];
    
#if SWITCH_SHOW_DEFAULT_IMAGE_FOR_NONE_CAMERA
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if ((![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])|| authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"设备不支持拍照功能或者拍照权限已关闭"delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
#endif
}

-(void)AutoFocus
{
    if (_captureManager != NULL) {
        [_captureManager focusInPoint:currTouchPoint];
    }
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
#if TARGET_IPHONE_SIMULATOR == 0
    TREC_ClearUP();
#endif
    if (!self.navigationController) {
        if ([UIApplication sharedApplication].statusBarHidden != _isStatusBarHiddenBeforeShowCamera) {
            [[UIApplication sharedApplication] setStatusBarHidden:_isStatusBarHiddenBeforeShowCamera withAnimation:UIStatusBarAnimationSlide];
        }
    }
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationOrientationChange object:nil];
    
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device && [device isFocusPointOfInterestSupported]) {
        [device removeObserver:self forKeyPath:ADJUSTINT_FOCUS context:nil];
    }
#endif
    
    self.captureManager = nil;
}

#pragma mark -------------UI---------------
//顶部标题
- (void)addTopViewWithText:(NSString*)text {
    if (!_topContainerView) {
        CGRect topFrame = CGRectMake(0, 0, SC_APP_SIZE.width, CAMERA_TOPVIEW_HEIGHT);
        
        UIView *tView = [[UIView alloc] initWithFrame:topFrame];
        tView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:tView];
        self.topContainerView = tView;
        
        UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, topFrame.size.width, topFrame.size.height)];
        emptyView.backgroundColor = [UIColor blackColor];
        emptyView.alpha = 0.4f;
        [_topContainerView addSubview:emptyView];
        
        topFrame.origin.x += 10;
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, topFrame.size.height)];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.font = [UIFont systemFontOfSize:25.f];
        [_topContainerView addSubview:lbl];
        self.topLbl = lbl;
    }
    _topLbl.text = text;
}

//bottomContainerView，总体
- (void)addbottomContainerView {
    
    CGFloat bottomY = _captureManager.previewLayer.frame.origin.y + _captureManager.previewLayer.frame.size.height;
    CGRect bottomFrame = CGRectMake(0, bottomY, SC_APP_SIZE.width, SC_APP_SIZE.height - bottomY);
    
    UIView *view = [[UIView alloc] initWithFrame:bottomFrame];
    view.backgroundColor = bottomContainerView_UP_COLOR;
    [self.view addSubview:view];
    self.bottomContainerView = view;
}
-(void)addTextInfo
{

    if (self.iCardType == TIDCARD2) {
        [self.drawView showText:@"请将身份证置于此区域  并尝试对齐边缘"];
    }
    else if(self.iCardType == TIDBANK)
    {
        [self.drawView showText:@"请将银行卡置于此区域  并尝试对齐边缘"];
    }
    else if(self.iCardType == TIDLPR)
    {
        [self.drawView showText:@"请将车牌置于此区域  并尝试对齐边缘"];
    }
    else if(self.iCardType == TIDJSZCARD)
    {
        [self.drawView showText:@"请将驾驶证置于此区域  并尝试对齐边缘"];
    }
    else if(self.iCardType == TIDXSZCARD)
    {
        [self.drawView showText:@"请将行驶证置于此区域  并尝试对齐边缘"];
    }
    else if(self.iCardType == TIDTICKET)
    {
        [self.drawView showText:@"请将火车票置于此区域  并尝试对齐边缘"];
    }
    else if(self.iCardType == TIDSSCCARD)
    {
        [self.drawView showText:@"请将社保卡置于此区域  并尝试对齐边缘"];
        
    }
    else if(self.iCardType == TIDPASSPORT)
    {
        [self.drawView showText:@"请将护照置于此区域  并尝试对齐边缘"];
    }
    else
    {
        [self.drawView showText:@"请将卡片置于此区域  并尝试对齐边缘"];
        
    }
    self.drawView.backgroundColor = [UIColor clearColor];
    [self.drawView SetPreSize:self.iCardType size: self.captureManager.previewLayer.bounds.size];
    CGPoint begine = [self.drawView getBeginPoint];
    CGRect rect = CGRectMake(0, 0, _previewRect.size.width, _previewRect.size.height);
    _lable = [[UILabel alloc] initWithFrame:rect];
    
    _lable.text = @"";//@"请将身份证置于此区域  并尝试对齐边缘";
    _lable.textColor = [UIColor whiteColor];
    _lable.font = [UIFont boldSystemFontOfSize:9];
    _lable.backgroundColor = [UIColor clearColor];
    _lable.transform=CGAffineTransformMakeRotation(M_PI/2);
    _lable.textAlignment = NSTextAlignmentLeft;
    
    _lable.numberOfLines = 20;//上面两行设置多行显示
    _lable.center = CGPointMake([[UIScreen mainScreen] bounds].size.width *3/ 4  ,[[UIScreen mainScreen] bounds].size.height/ 2);
    [self.view addSubview:_lable];
    
    [self.view addSubview:self.drawView];
    [self.captureManager SetValuePoint:[self.drawView getBeginPoint] End:[self.drawView getEndPoint]];

}
//拍照菜单栏
- (void)addCameraMenuView {
    
    //拍照按钮
    CGFloat downH = CAMERA_MENU_VIEW_HEIGH ;
    CGFloat cameraBtnLength = CAMERA_MENU_VIEW_HEIGH;
    
    
    //拍照的菜单栏view（屏幕高度大于480的，此view在上面，其他情况在下面）
    CGFloat menuViewY =  SC_DEVICE_SIZE.height - CAMERA_MENU_VIEW_HEIGH ;
    UIView *menuView = [[UIView alloc] initWithFrame:CGRectMake(0, menuViewY, self.view.frame.size.width, CAMERA_MENU_VIEW_HEIGH)];
    menuView.backgroundColor = (bottomContainerView_DOWN_COLOR );
//    menuView.backgroundColor = (isHigherThaniPhone4_SC ? bottomContainerView_DOWN_COLOR : [UIColor clearColor]);
    [self.view addSubview:menuView];
    self.cameraMenuView = menuView;
    
    [self addMenuViewButtons];
    if (self.iCardType != TIDBANK ) {
        if (self.ScanMode != TIDC_SCAN_MODE) {
            [self buildButton:CGRectMake((SC_APP_SIZE.width - cameraBtnLength*0.9) / 2, _cameraMenuView.frame.size.height  - cameraBtnLength*0.95 , CAMERA_MENU_VIEW_HEIGH*0.9, CAMERA_MENU_VIEW_HEIGH*0.9)
                 normalImgStr:@"shot"
              highlightImgStr:@"shot_h"
               selectedImgStr:@""
                       action:@selector(takePictureBtnPressed:)
                   parentView:_cameraMenuView];
        }
        
    }
    
}

//拍照菜单栏上的按钮
- (void)addMenuViewButtons {
    NSMutableArray *normalArr = [[NSMutableArray alloc] initWithObjects:@"close_cha_btn", @"flashing_off_btn", @"camera_line", @"switch_camera", nil];
    NSMutableArray *highlightArr = [[NSMutableArray alloc] initWithObjects:@"close_cha_h_btn", @"flashing_on_btn", @"", @"", nil];
    NSMutableArray *selectedArr = [[NSMutableArray alloc] initWithObjects:@"", @"", @"switch_camera_h", @"", nil];
    
    NSMutableArray *actionArr = [[NSMutableArray alloc] initWithObjects:@"dismissBtnPressed:", @"flashBtnPressed:", @"gridBtnPressed:", @"switchCameraBtnPressed:", nil];
    
    CGFloat eachW = 75;
//    SC_APP_SIZE.width / actionArr.count * 0.8;
    
    [SCCommon drawALineWithFrame:CGRectMake(eachW, 0, 1, CAMERA_MENU_VIEW_HEIGH) andColor:rgba_SC(102, 102, 102, 1.0000) inLayer:_cameraMenuView.layer];
    
    
    //屏幕高度大于480的，后退按钮放在_cameraMenuView；小于480的，放在_bottomContainerView
    for (int i = 0; i < 2; i++) {
        
    CGFloat theH = (CAMERA_MENU_VIEW_HEIGH);
        UIView *parent = ( _cameraMenuView);
        //CGFloat theH = (!isHigherThaniPhone4_SC && i == 0 ? _bottomContainerView.frame.size.height : CAMERA_MENU_VIEW_HEIGH);
        //UIView *parent = (!isHigherThaniPhone4_SC && i == 0 ? _bottomContainerView : _cameraMenuView);
        
        UIButton * btn = [self buildButton:CGRectMake(eachW * i, 0, eachW, theH)
                              normalImgStr:[normalArr objectAtIndex:i]
                           highlightImgStr:[highlightArr objectAtIndex:i]
                            selectedImgStr:[selectedArr objectAtIndex:i]
                                    action:NSSelectorFromString([actionArr objectAtIndex:i])
                                parentView:parent];
    
        btn.showsTouchWhenHighlighted = YES;
        btn.backgroundColor = (bottomContainerView_DOWN_COLOR );
        [_cameraBtnSet addObject:btn];
    }
}

- (UIButton*)buildButton:(CGRect)frame
            normalImgStr:(NSString*)normalImgStr
         highlightImgStr:(NSString*)highlightImgStr
          selectedImgStr:(NSString*)selectedImgStr
                  action:(SEL)action
              parentView:(UIView*)parentView {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    if (normalImgStr.length > 0) {
        NSBundle *cbundle = [NSBundle bundleForClass:[self class]];
        NSString *pathqwe = [cbundle pathForResource:@"flutter_turui_ocr_bundles" ofType:@"bundle"];
        NSBundle *bundleqwe = [NSBundle bundleWithPath:pathqwe];
        UIImage * image = [UIImage imageNamed:normalImgStr
          inBundle: bundleqwe compatibleWithTraitCollection:nil];
        
        [btn setImage:image forState:UIControlStateNormal];
    }
    if (highlightImgStr.length > 0) {
        NSBundle *cbundle = [NSBundle bundleForClass:[self class]];
        NSString *pathqwe = [cbundle pathForResource:@"flutter_turui_ocr_bundles" ofType:@"bundle"];
        NSBundle *bundleqwe = [NSBundle bundleWithPath:pathqwe];
        UIImage * image = [UIImage imageNamed:highlightImgStr
          inBundle: bundleqwe compatibleWithTraitCollection:nil];
        
        [btn setImage:image forState:UIControlStateHighlighted];
    }
    if (selectedImgStr.length > 0) {
        NSBundle *cbundle = [NSBundle bundleForClass:[self class]];
        NSString *pathqwe = [cbundle pathForResource:@"flutter_turui_ocr_bundles" ofType:@"bundle"];
        NSBundle *bundleqwe = [NSBundle bundleWithPath:pathqwe];
        UIImage * image = [UIImage imageNamed:selectedImgStr
          inBundle: bundleqwe compatibleWithTraitCollection:nil];
        
        [btn setImage:image forState:UIControlStateSelected];
    }
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [parentView addSubview:btn];
    
    return btn;
}

//对焦的框
- (void)addFocusView {
    
    NSBundle *cbundle = [NSBundle bundleForClass:[self class]];
    NSString *pathqwe = [cbundle pathForResource:@"flutter_turui_ocr_bundles" ofType:@"bundle"];
    NSBundle *bundleqwe = [NSBundle bundleWithPath:pathqwe];
    UIImage * image = [UIImage imageNamed:@"touch_focus_x"
      inBundle: bundleqwe compatibleWithTraitCollection:nil];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
    imgView.alpha = 0;
    [self.view addSubview:imgView];
    self.focusImageView = imgView;
    
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device && [device isFocusPointOfInterestSupported]) {
        [device addObserver:self forKeyPath:ADJUSTINT_FOCUS options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
#endif
}

//拍完照后的遮罩
- (void)addCameraCover {
    UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SC_APP_SIZE.width, 0)];
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];
    self.doneCameraUpView = upView;
    
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, _bottomContainerView.frame.origin.y, SC_APP_SIZE.width, 0)];
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];
    self.doneCameraDownView = downView;
}

- (void)showCameraCover:(BOOL)toShow {
    
    [UIView animateWithDuration:0.38f animations:^{
        CGRect upFrame = _doneCameraUpView.frame;
        upFrame.size.height = (toShow ? SC_APP_SIZE.width / 2 + CAMERA_TOPVIEW_HEIGHT : 0);
        _doneCameraUpView.frame = upFrame;
        
        CGRect downFrame = _doneCameraDownView.frame;
        downFrame.origin.y = (toShow ? SC_APP_SIZE.width / 2 + CAMERA_TOPVIEW_HEIGHT : _bottomContainerView.frame.origin.y);
        downFrame.size.height = (toShow ? SC_APP_SIZE.width / 2 : 0);
        _doneCameraDownView.frame = downFrame;
    }];
}

//伸缩镜头的手势
- (void)addPinchGesture {
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinch];
    
    //横向
    //    CGFloat width = _previewRect.size.width - 100;
    //    CGFloat height = 40;
    //    SCSlider *slider = [[SCSlider alloc] initWithFrame:CGRectMake((SC_APP_SIZE.width - width) / 2, SC_APP_SIZE.width + CAMERA_MENU_VIEW_HEIGH - height, width, height)];
    
    //竖向
    CGFloat width = 40;
    CGFloat height = _previewRect.size.height - 100;
    SCSlider *slider = [[SCSlider alloc] initWithFrame:CGRectMake(_previewRect.size.width - width, (_previewRect.size.height + CAMERA_MENU_VIEW_HEIGH - height) / 2, width, height) direction:SCSliderDirectionVertical];
    slider.alpha = 0.f;
    slider.minValue = MIN_PINCH_SCALE_NUM;
    slider.maxValue = MAX_PINCH_SCALE_NUM;
    
    WEAKSELF_SC
    [slider buildDidChangeValueBlock:^(CGFloat value) {
        [weakSelf_SC.captureManager pinchCameraViewWithScalNum:value];
    }];
    [slider buildTouchEndBlock:^(CGFloat value, BOOL isTouchEnd) {
        [weakSelf_SC setSliderAlpha:isTouchEnd];
    }];
    
    [self.view addSubview:slider];
    
    self.scSlider = slider;
}


- (void)setSliderAlpha:(BOOL)isTouchEnd {
    if (_scSlider) {
        _scSlider.isSliding = !isTouchEnd;
        
        if (_scSlider.alpha != 0.f && !_scSlider.isSliding) {
            double delayInSeconds = 3.88;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                if (_scSlider.alpha != 0.f && !_scSlider.isSliding) {
                    [UIView animateWithDuration:0.3f animations:^{
                        _scSlider.alpha = 0.f;
                    }];
                }
            });
        }
    }
}

#pragma mark -------------touch to focus---------------
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
//监听对焦是否完成了
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:ADJUSTINT_FOCUS]) {
        BOOL isAdjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1] ];
        //        SCDLog(@"Is adjusting focus? %@", isAdjustingFocus ? @"YES" : @"NO" );
        //        SCDLog(@"Change dictionary: %@", change);
        if (!isAdjustingFocus) {
            alphaTimes = -1;
        }
    }
}

- (void)showFocusInPoint:(CGPoint)touchPoint {
    
    [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        
        int alphaNum = (alphaTimes % 2 == 0 ? HIGH_ALPHA : LOW_ALPHA);
        self.focusImageView.alpha = alphaNum;
        alphaTimes++;
        
    } completion:^(BOOL finished) {
        
        if (alphaTimes != -1) {
            [self showFocusInPoint:currTouchPoint];
        } else {
            self.focusImageView.alpha = 0.0f;
        }
    }];
}
#endif

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //    [super touchesBegan:touches withEvent:event];
    
    alphaTimes = -1;
    
    UITouch *touch = [touches anyObject];
    currTouchPoint = [touch locationInView:self.view];
    
    if (CGRectContainsPoint(_captureManager.previewLayer.bounds, currTouchPoint) == NO) {
        return;
    }
    
    [_captureManager focusInPoint:currTouchPoint];
    
    //对焦框
    [_focusImageView setCenter:currTouchPoint];
    _focusImageView.transform = CGAffineTransformMakeScale(2.0, 2.0);
    
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
    [UIView animateWithDuration:0.1f animations:^{
        _focusImageView.alpha = HIGH_ALPHA;
        _focusImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        [self showFocusInPoint:currTouchPoint];
    }];
#else
    [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        _focusImageView.alpha = 1.f;
        _focusImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f delay:0.5f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            _focusImageView.alpha = 0.f;
        } completion:nil];
    }];
#endif
}

#pragma mark -------------button actions---------------
//拍照页面，拍照按钮
- (void)takePictureBtnPressed:(UIButton*)sender {
#if SWITCH_SHOW_DEFAULT_IMAGE_FOR_NONE_CAMERA
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if ((![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])|| authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"设备不支持拍照功能或者拍照权限已关闭"delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
#endif
    
    sender.userInteractionEnabled = NO;
    
    //[self showCameraCover:YES];
    
    __block UIActivityIndicatorView *actiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [actiView initWithFrame:CGRectMake(0, 0, SC_APP_SIZE.width, SC_APP_SIZE.height)];
    actiView.center = CGPointMake(self.view.center.x, self.view.center.y - CAMERA_TOPVIEW_HEIGHT);
    [actiView startAnimating];
    [self.view addSubview:actiView];
    
    WEAKSELF_SC
    [_captureManager takePicture:^(UIImage *stillImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //[SCCommon saveImageToPhotoAlbum:stillImage];//存至本机
            
            
        });
        
        [actiView stopAnimating];
        [actiView removeFromSuperview];
        actiView = nil;
        [self  RunOCR:stillImage];

        sender.userInteractionEnabled = YES;
        
    }];
}

#define TOP_LINE_EXIST1    (1<<0)//0x0001上边线
#define LEFT_LINE_EXIST1    (1<<1)//0x0010左边线
#define BOTTOM_LINE_EXIST1  (1<<2)//0x0100下边线
#define RIGHT_LINE_EXIST1  (1<<3)//0x1000右边线
// 身份证扫描主函数
- (void)didIDcardScanOcr:(UIImage*)image rect:(CGRect)rect
{
#if TARGET_IPHONE_SIMULATOR == 0
    
    int ret1 = TREC_SetSupportEngine(TIDCARD2);
    if (ret1 != 1) {
        NSLog(@"引擎不支持");
        //        [self cancelAction];
        return;
    }
    int width1 = CGImageGetWidth(image.CGImage);
    int height1 = CGImageGetHeight(image.CGImage);
    TREC_LoadImage(image);
    int x1 = rect.origin.y;
    int y1 = rect.origin.x;
    int x2 = rect.size.height;
    int y2 = rect.size.width;
    //NSLog(@"(%d,%d)  (%d,%d)",x1,y1,x2,y2);
    
    if(0){
        NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.jpg"];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *now;
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
        NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        now=[NSDate date];
        comps = [calendar components:unitFlags fromDate:now];
        NSInteger  week = [comps weekday];
        NSInteger month = [comps month];
        NSInteger day = [comps day];
        NSInteger hour = [comps hour];
        NSInteger min = [comps minute];
        NSInteger sec = [comps second];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* pImageName = [NSString stringWithFormat:@"%@/%d%d%d%d%d%@", [paths objectAtIndex:0],month , day , hour , min , sec ,@".jpg"];
        NSString* pImageName1 = [NSString stringWithFormat:@"%@/A_%d%d%d%d%d%@", [paths objectAtIndex:0],month , day , hour , min , sec ,@".jpg"];
        TREC_SaveImage(pImageName);
    }
    
    
    int result2 =  TREC_JudgeExist(x1,y1,x2,y2);
    
    int top = (result2 & TOP_LINE_EXIST1)==1?1:0;
    int left = (result2 & LEFT_LINE_EXIST1) ==2?1:0;
    int bottom = (result2 & BOTTOM_LINE_EXIST1) ==4?1:0;
    int right = (result2 & RIGHT_LINE_EXIST1) ==8?1:0;
    int ret = 0;
    int isReturnOk = 0;
    //NSLog(@"(%d %d %d %d)",top,left,bottom,right);
    //至少三边存在
    [self.drawView showLineUP:left right:top bottom:right left:bottom];
    [self.drawView setNeedsDisplay];
    if (((top + left + bottom + right)>=3)) {
        int Value[5] = {TIDC_SCAN_MODE,x1,y1,x2-x1,y2-y1};
        int val = 1;
        TREC_SetParam(T_SET_RECMODE,&Value[0]);
        TREC_SetParam(T_SET_AREA_LEFT,&Value[1]);
        TREC_SetParam(T_SET_AREA_TOP,&Value[2]);
        TREC_SetParam(T_SET_AREA_WIDTH,&Value[3]);
        TREC_SetParam(T_SET_AREA_HEIGHT,&Value[4]);
        TREC_SetParam(T_SET_HEADIMG,&val);
        ret = TREC_OCR();
        if(ret == 100)
        {
            NSLog(@"引擎过期");
        }
        isReturnOk = TREC_GetCardNumState();
        
        
    }
    TREC_FreeImage();
    /*返回异常状态直接提示信息并退出*/
    if (ret != 0 && ret != 1) {
        [_captureManager ShowErrorInfo:ret delegate:self.scNaigationDelegate];
        [self dismissBtnPressed:NULL];
        return;
    }
    if(isReturnOk == 1 && isClose == FALSE)
    {
        //[_captureManager.session stopRunning];
        if (self.isDisPlayView == YES) {
            UIImage *small_image = image;//TREC_GetHeadImage();
            NSString *astring = [[NSString alloc] initWithString:[NSString stringWithFormat:@"姓名  ： %@\n性别  ： %@\n民族  ： %@\n出生  ： %@\n地址  ： %@\n号码  ： %@\n签发机关  ： %@\n有效期限  ： %@\n",TREC_GetFieldString(NAME),TREC_GetFieldString(SEX),TREC_GetFieldString(FOLK),TREC_GetFieldString(BIRTHDAY),TREC_GetFieldString(ADDRESS),TREC_GetFieldString(NUM),TREC_GetFieldString(ISSUE),TREC_GetFieldString(PERIOD)]];
            ScranResultViewController *resultController =[[ScranResultViewController alloc] init];
            resultController.ScranViewDelegate = self;
            
            [resultController SetInfo:small_image Info:astring];
            [self presentViewController:resultController animated:YES completion:nil];
        }
        else
        {
            if (TIDCARD2 == TREC_GetCardType()) {
                UIImage *TarGetImg = image;
                NSString * text = TREC_GetOcrString();
                if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendAllValue:)]) { // 如果协议响应了sendIDcardValue:方法
                    [self.scNaigationDelegate sendAllValue:text]; // 通知执行协议方法
                }
                if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendTakeImage:image:)]) {
                    [self.scNaigationDelegate sendTakeImage:TIDCARD2 image:TarGetImg]; // 通知执行协议方法
                }
                if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendIDCValue:SEX:FOLK:BIRTHDAY:ADDRESS:NUM:)])
                {
                    [self.scNaigationDelegate sendIDCValue:TREC_GetFieldString(NAME) SEX:TREC_GetFieldString(SEX) FOLK:TREC_GetFieldString(FOLK) BIRTHDAY:TREC_GetFieldString(BIRTHDAY) ADDRESS:TREC_GetFieldString(ADDRESS) NUM:TREC_GetFieldString(NUM)]; // 通知执行协议方法
                }
                if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendCardFaceImage:)])
                {
                    [self.scNaigationDelegate sendCardFaceImage:TREC_GetHeadImage()]; // 通知执行协议方法
                }
               
                
            }
            else if (TIDCARDBACK == TREC_GetCardType())
            {
                //NSString *shaString = TREC_GetSha1NSString(image);
                UIImage *TarGetImg = image;
                NSString *text = TREC_GetOcrString();                if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendAllValue:)]) { // 如果协议响应了sendIDcardValue:方法
                    [self.scNaigationDelegate sendAllValue:text]; // 通知执行协议方法
                }
                if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendTakeImage:image:)]) { // 如果协议响应了sendIDcardValue:方法
                    [self.scNaigationDelegate sendTakeImage:TIDCARDBACK image:TarGetImg]; // 通知执行协议方法
                }
                if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendIDCBackValue:PERIOD:IDCPASSNUM:)])
                {
                    [self.scNaigationDelegate sendIDCBackValue:TREC_GetFieldString(ISSUE) PERIOD:TREC_GetFieldString(PERIOD)
                        IDCPASSNUM:TREC_GetFieldString(IDC_PASS_NUM)]; // 通知执行协议方法
                }
                
            }
            
            [self dismissBtnPressed:NULL];
        }
        
    }
    else
    {
        _captureManager.isRun1 = FALSE;
    }
#endif
}
// 银行卡扫描主函数
- (void)didBankOcr:(UIImage*)image rect:(CGRect)rect
{
#if TARGET_IPHONE_SIMULATOR == 0
    int width1 = CGImageGetWidth(image.CGImage);
    int height1 = CGImageGetHeight(image.CGImage);
    int ret1 = TREC_SetSupportEngine(TIDBANK);
    if (ret1 != 1) {
        NSLog(@"引擎不支持");
        //        [self cancelAction];
        return;
    }
    TBANK_LoadImage(image);
    int x1 = rect.origin.y;
    int y1 = rect.origin.x;
    int x2 = rect.size.height;
    int y2 = rect.size.width;
    //NSLog(@"(%d,%d)  (%d,%d)",x1,y1,x2,y2);
    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.jpg"];
    if(0){
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *now;
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
        NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        now=[NSDate date];
        comps = [calendar components:unitFlags fromDate:now];
        NSInteger  week = [comps weekday];
        NSInteger month = [comps month];
        NSInteger day = [comps day];
        NSInteger hour = [comps hour];
        NSInteger min = [comps minute];
        NSInteger sec = [comps second];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* pImageName = [NSString stringWithFormat:@"%@/%d%d%d%d%d%@", [paths objectAtIndex:0],month , day , hour , min , sec ,@".jpg"];
        NSString* pImageName1 = [NSString stringWithFormat:@"%@/A_%d%d%d%d%d%@", [paths objectAtIndex:0],month , day , hour , min , sec ,@".jpg"];
        TBANK_SaveImage(pImageName);
    }
    
    
    int result2 =  TBANK_JudgeExist(x1,y1,x2,y2);
    
    int top = (result2 & TOP_LINE_EXIST1)==1?1:0;
    int left = (result2 & LEFT_LINE_EXIST1) ==2?1:0;
    int bottom = (result2 & BOTTOM_LINE_EXIST1) ==4?1:0;
    int right = (result2 & RIGHT_LINE_EXIST1) ==8?1:0;
    int ret = 0;
    int isReturnOk = 0;
    //NSLog(@"(%d %d %d %d)",top,left,bottom,right);
    //至少三边存在
    [self.drawView showLineUP:left right:top bottom:right left:bottom];
    [self.drawView setNeedsDisplay];
    if (((top + left + bottom + right)>=3) || (top == 1 && bottom == 1) || (left == 1 && right == 1))
    {
        
        ret = TBANK_OCR();
        if(ret == 100)
        {
            NSLog(@"引擎过期");
        }
        isReturnOk = TREC_GetCardNumState();
    }
    TBANK_FreeImage();
    /*返回异常状态直接提示信息并退出*/
    if (ret != 0 && ret != 1) {
        [_captureManager ShowErrorInfo:ret delegate:self.scNaigationDelegate];
        [self dismissBtnPressed:NULL];
        return;
    }
    if(isReturnOk != 0 && isClose == FALSE)
    {
        
        //[_captureManager.session stopRunning];
        UIImage *small_image = TBANK_GetSmallImage();
        if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendBankCardInfo:BANK_NAME:BANK_ORGCODE:BANK_CLASS:CARD_NAME:)]) { // 如果协议响应了sendIDcardValue:方法
            [self.scNaigationDelegate sendBankCardInfo:TBANK_GetBankInfoString(T_GET_BANK_NUM) BANK_NAME:TBANK_GetBankInfoString(T_GET_BANK_NAME) BANK_ORGCODE:TBANK_GetBankInfoString(T_GET_BANK_ORGCODE) BANK_CLASS:TBANK_GetBankInfoString(T_GET_BANK_CLASS) CARD_NAME:TBANK_GetBankInfoString(T_GET_CARD_NAME)]; // 通知执行协议方法
        }
        if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendBankCardImage:)]) { // 如果协议响应了sendIDcardValue:方法
            [self.scNaigationDelegate sendBankCardImage:small_image]; // 通知执行协议方法
        }
        if (self.isDisPlayView == YES) {
            NSString *astring = [[NSString alloc] initWithString:[NSString stringWithFormat:@"卡号  ： %@\n发卡行 ： %@\n机构代码： %@\n卡种  ： %@\n卡名  ： %@\n \n",TBANK_GetBankInfoString(T_GET_BANK_NUM),TBANK_GetBankInfoString(T_GET_BANK_NAME),TBANK_GetBankInfoString(T_GET_BANK_ORGCODE),TBANK_GetBankInfoString(T_GET_BANK_CLASS),TBANK_GetBankInfoString(T_GET_CARD_NAME)]];
            ScranResultViewController *resultController =[[ScranResultViewController alloc] init];        resultController.ScranViewDelegate = self;
            
            [resultController SetInfo:small_image Info:astring];
            [self presentViewController:resultController animated:YES completion:nil];
        }
        else
        {
            [self dismissBtnPressed:NULL];
        }
        
    }
    else
    {
        _captureManager.isRun1 = FALSE;
    }
#endif
}

- (void)didLprScanOcr:(UIImage*)image rect:(CGRect)rect
{
#if TARGET_IPHONE_SIMULATOR == 0
    
    int ret1 = TREC_SetSupportEngine(TIDLPR);
    if (ret1 != 1) {
        NSLog(@"引擎不支持");
        //        [self cancelAction];
        return;
    }
    int width1 = CGImageGetWidth(image.CGImage);
    int height1 = CGImageGetHeight(image.CGImage);
    TREC_LoadImage(image);
    int x1 = rect.origin.y;
    int y1 = rect.origin.x;
    int x2 = rect.size.height;
    int y2 = rect.size.width;
    //NSLog(@"(%d,%d)  (%d,%d)",x1,y1,x2,y2);
    
    if(0){
        NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.jpg"];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *now;
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
        NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        now=[NSDate date];
        comps = [calendar components:unitFlags fromDate:now];
        NSInteger  week = [comps weekday];
        NSInteger month = [comps month];
        NSInteger day = [comps day];
        NSInteger hour = [comps hour];
        NSInteger min = [comps minute];
        NSInteger sec = [comps second];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* pImageName = [NSString stringWithFormat:@"%@/%d%d%d%d%d%@", [paths objectAtIndex:0],month , day , hour , min , sec ,@".jpg"];
        NSString* pImageName1 = [NSString stringWithFormat:@"%@/A_%d%d%d%d%d%@", [paths objectAtIndex:0],month , day , hour , min , sec ,@".jpg"];
        TREC_SaveImage(pImageName);
    }
    
    
    int result2 =  TREC_JudgeExist(x1,y1,x2,y2);
    
    int top = (result2 & TOP_LINE_EXIST1)==1?1:0;
    int left = (result2 & LEFT_LINE_EXIST1) ==2?1:0;
    int bottom = (result2 & BOTTOM_LINE_EXIST1) ==4?1:0;
    int right = (result2 & RIGHT_LINE_EXIST1) ==8?1:0;
    int ret = 0;
    int isReturnOk = 0;
    //NSLog(@"(%d %d %d %d)",top,left,bottom,right);
    //至少三边存在
//    [self.drawView showLineUP:left right:top bottom:right left:bottom];
//    [self.drawView setNeedsDisplay];
    if (1==1) {
        int Value[5] = {TIDC_SCAN_MODE,x1,y1,x2-x1,y2-y1};
        int val = 1;
        TREC_SetParam(T_SET_RECMODE,&Value[0]);
        TREC_SetParam(T_SET_AREA_LEFT,&Value[1]);
        TREC_SetParam(T_SET_AREA_TOP,&Value[2]);
        TREC_SetParam(T_SET_AREA_WIDTH,&Value[3]);
        TREC_SetParam(T_SET_AREA_HEIGHT,&Value[4]);
        TREC_SetParam(T_SET_HEADIMG,&val);
        ret = TREC_OCR();
        if(ret == 100)
        {
            NSLog(@"引擎过期");
        }
        isReturnOk = TREC_GetCardNumState();
        
        
    }
    TREC_FreeImage();
    /*返回异常状态直接提示信息并退出*/
    if (ret != 0 && ret != 1) {
        [_captureManager ShowErrorInfo:ret delegate:self.scNaigationDelegate];
        [self dismissBtnPressed:NULL];
        return;
    }
    if(isReturnOk == 1 && isClose == FALSE)
    {
        if (self.iCardType == TIDLPR) {
            if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendLPRValue:)])
            {
                [self.scNaigationDelegate sendLPRValue:TREC_GetFieldString(LPR_NUM)]; // 通知执行协议方法
            }
            
        }
        
        [self dismissBtnPressed:NULL];

        
    }
    else
    {
        _captureManager.isRun1 = FALSE;
    }
#endif
}
- (void)didCapturePhoto:(UIImage*)image rect:(CGRect)rect
{
    //NSLog(@"okxxxxxx\n");
//    TREC_StartUP();
    if (self.iCardType == TIDBANK) {
        return ([self didBankOcr:image rect:rect]);
    }
    else if(self.iCardType == TIDCARD2 && self.ScanMode == TIDC_SCAN_MODE)
    {
        return ([self didIDcardScanOcr:image rect:rect]);
    }
    else if(self.iCardType == TIDLPR && self.ScanMode == TIDC_SCAN_MODE)
    {
        return ([self didLprScanOcr:image rect:rect]);
    }
}
- (void)SendBankCardSta:(int)ret
{
    if (ret == 1) {
        isClose = TRUE;
        _captureManager.isRun1 = TRUE;
       
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                              (int64_t)(0.5 * NSEC_PER_SEC)),
        
                           dispatch_get_main_queue(), ^{
                               if (![self.presentedViewController isBeingDismissed]) {
        
                                   [self dismissViewControllerAnimated:YES completion:nil];
                                   
                               }});
    }
    else
    {
        isClose = FALSE;
        _captureManager.isRun1 = FALSE;
        [_captureManager.session startRunning];
        
    }
}

// 证件拍照识别入口
-(void) RunOCR:(UIImage *)image
{
    NSString *text1 = NULL;
    int val  = 1;
#if TARGET_IPHONE_SIMULATOR == 0
    int ret = 0;//TREC_StartUP();
    if (isStartStatus == 100) {
         _lable.text = @"试用版,已过期!";
        return;
    }
    ret = TREC_SetSupportEngine(self.iCardType);
    if (ret != 1) {
        _lable.text = @"引擎不支持!";
//        TREC_ClearUP();
        return;
    }
    ret = TREC_SetParam(T_SET_HEADIMG, &val);
    ret = TREC_LoadImage(image);
    ret = TREC_OCR();
    if (ret != 0 && ret != 1) {
        [_captureManager ShowErrorInfo:ret delegate:self.scNaigationDelegate];
    }
    if (self.iCardType == TIDCARD2) {
        if (TIDCARD2 == TREC_GetCardType()) {
            //NSString *shaString = TREC_GetSha1NSString(image);
            UIImage *TarGetImg = image;
            NSString * text = TREC_GetOcrString();
            //        NSLog(@"%@ %@ %@ %@ %@ %@",name,sex,folk,birthday,address,cardnum);
            if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendAllValue:)]) { // 如果协议响应了sendIDcardValue:方法
                [self.scNaigationDelegate sendAllValue:text]; // 通知执行协议方法
            }
            if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendTakeImage:image:)]) {
                [self.scNaigationDelegate sendTakeImage:TIDCARD2 image:TarGetImg]; // 通知执行协议方法
            }
            if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendIDCValue:SEX:FOLK:BIRTHDAY:ADDRESS:NUM:)])
            {
                [self.scNaigationDelegate sendIDCValue:TREC_GetFieldString(NAME) SEX:TREC_GetFieldString(SEX) FOLK:TREC_GetFieldString(FOLK) BIRTHDAY:TREC_GetFieldString(BIRTHDAY) ADDRESS:TREC_GetFieldString(ADDRESS) NUM:TREC_GetFieldString(NUM)]; // 通知执行协议方法
            }
            if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendCardFaceImage:)])
            {
                [self.scNaigationDelegate sendCardFaceImage:TREC_GetHeadImage()]; // 通知执行协议方法
            }
            if (self.isDisPlayTxt != NO) {
                _lable.text = text;
            }
                        
        }
        else if (TIDCARDBACK == TREC_GetCardType())
        {
            //NSString *shaString = TREC_GetSha1NSString(image);
            UIImage *TarGetImg = image;
            NSString *text = TREC_GetOcrString();
            //NSLog(@"%@ %@ ",issue,period);
            if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendAllValue:)]) { // 如果协议响应了sendIDcardValue:方法
                [self.scNaigationDelegate sendAllValue:text]; // 通知执行协议方法
            }
            if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendTakeImage:image:)]) { // 如果协议响应了sendIDcardValue:方法
                [self.scNaigationDelegate sendTakeImage:TIDCARDBACK image:TarGetImg]; // 通知执行协议方法
            }
            if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendIDCBackValue:PERIOD:IDCPASSNUM:)])
            {
                [self.scNaigationDelegate sendIDCBackValue:TREC_GetFieldString(ISSUE) PERIOD:TREC_GetFieldString(PERIOD)
                 IDCPASSNUM:TREC_GetFieldString(IDC_PASS_NUM)]; // 通知执行协议方法
            }
            if (self.isDisPlayTxt != NO) {
                _lable.text = text;
            }
            
        }
    }
    else
    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.resultController.resultImage.image = image;
//        });
        UIImage *TarGetImg = image;
        text1 = TREC_GetOcrString();
    if (self.isDisPlayTxt != NO) {
      _lable.text = text1;
    }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSString *astring = [[NSString alloc] initWithString:[NSString stringWithFormat:@" %@\n",text1]];
//            self.resultController.resultLabel.text = astring;
//        });
        //        NSLog(@"%@ %@ %@ %@ %@ %@",name,sex,folk,birthday,address,cardnum);
        if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendTakeImage:image:)]) { // 如果协议响应了sendIDcardValue:方法
            [self.scNaigationDelegate sendTakeImage:self.iCardType image:TarGetImg]; // 通知执行协议方法
        }
        if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendAllValue:)]) { // 如果协议响应了sendIDcardValue:方法
            [self.scNaigationDelegate sendAllValue:text1]; // 通知执行协议方法
        }
        if (self.iCardType == TIDLPR) {
            if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendLPRValue:)])
            {
                [self.scNaigationDelegate sendLPRValue:TREC_GetFieldString(LPR_NUM)]; // 通知执行协议方法
            }

        }
        else if(self.iCardType == TIDJSZCARD )
        {
            if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendJSZValue:DL_NAME:DL_SEX:DL_COUNTRY:DL_ADDRESS:DL_BIRTHDAY:DL_ISSUE_DATE:DL_CLASS:DL_VALIDFROM:DL_VALIDFOR:)])
            {
                [self.scNaigationDelegate sendJSZValue:TREC_GetFieldString(DL_NUM) DL_NAME:TREC_GetFieldString(DL_NAME) DL_SEX:TREC_GetFieldString(DL_SEX) DL_COUNTRY:TREC_GetFieldString(DL_COUNTRY) DL_ADDRESS:TREC_GetFieldString(DL_ADDRESS) DL_BIRTHDAY:TREC_GetFieldString(DL_BIRTHDAY) DL_ISSUE_DATE:TREC_GetFieldString(DL_ISSUE_DATE) DL_CLASS:TREC_GetFieldString(DL_CLASS) DL_VALIDFROM:TREC_GetFieldString(DL_VALIDFROM) DL_VALIDFOR:TREC_GetFieldString(DL_VALIDFOR)]; // 通知执行协议方法
            }

        }
        else if(self.iCardType == TIDXSZCARD)
        {
            if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendFieldImage:image:)])
            {
                [self.scNaigationDelegate sendFieldImage:(DP_PLATENO) image:TREC_GetFieldImage(DP_PLATENO)]; // 通知执行协议方法
                [self.scNaigationDelegate sendFieldImage:(DP_TYPE) image:TREC_GetFieldImage(DP_TYPE)]; // 通知执行协议方法
                [self.scNaigationDelegate sendFieldImage:(DP_OWNER) image:TREC_GetFieldImage(DP_OWNER)]; // 通知执行协议方法
                [self.scNaigationDelegate sendFieldImage:(DP_ADDRESS) image:TREC_GetFieldImage(DP_ADDRESS)]; // 通知执行协议方法
                [self.scNaigationDelegate sendFieldImage:(DP_USECHARACTER) image:TREC_GetFieldImage(DP_USECHARACTER)]; // 通知执行协议方法
                [self.scNaigationDelegate sendFieldImage:(DP_MODEL) image:TREC_GetFieldImage(DP_MODEL)]; // 通知执行协议方法
                [self.scNaigationDelegate sendFieldImage:(DP_VIN) image:TREC_GetFieldImage(DP_VIN)]; // 通知执行协议方法
                [self.scNaigationDelegate sendFieldImage:(DP_ENGINENO) image:TREC_GetFieldImage(DP_ENGINENO)]; // 通知执行协议方法
                [self.scNaigationDelegate sendFieldImage:(DP_REGISTER_DATE) image:TREC_GetFieldImage(DP_REGISTER_DATE)]; // 通知执行协议方法
                [self.scNaigationDelegate sendFieldImage:(DP_ISSUE_DATE) image:TREC_GetFieldImage(DP_ISSUE_DATE)]; // 通知执行协议方法

            }
            if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendXSZValue:DP_TYPE:DP_OWNER:DP_ADDRESS:DP_USECHARACTER:DP_MODEL:DP_VIN:DP_ENGINENO:DP_REGISTER_DATE:DP_ISSUE_DATE:)])
            {
                [self.scNaigationDelegate sendXSZValue:TREC_GetFieldString(DP_PLATENO) DP_TYPE:TREC_GetFieldString(DP_TYPE) DP_OWNER:TREC_GetFieldString(DP_OWNER) DP_ADDRESS:TREC_GetFieldString(DP_ADDRESS) DP_USECHARACTER:TREC_GetFieldString(DP_USECHARACTER) DP_MODEL:TREC_GetFieldString(DP_MODEL) DP_VIN:TREC_GetFieldString(DP_VIN) DP_ENGINENO:TREC_GetFieldString(DP_ENGINENO) DP_REGISTER_DATE:TREC_GetFieldString(DP_REGISTER_DATE) DP_ISSUE_DATE:TREC_GetFieldString(DP_ISSUE_DATE)]; // 通知执行协议方法
            }

        }
        else if (self.iCardType == TIDTICKET)
        {
            if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendTICValue:TIC_NUM:TIC_END:TIC_TIME:TIC_SEAT:TIC_NAME:)])
            {
                [self.scNaigationDelegate sendTICValue:TREC_GetFieldString(TIC_START) TIC_NUM:TREC_GetFieldString(TIC_NUM) TIC_END:TREC_GetFieldString(TIC_END) TIC_TIME:TREC_GetFieldString(TIC_TIME) TIC_SEAT:TREC_GetFieldString(TIC_SEAT) TIC_NAME:TREC_GetFieldString(TIC_NAME)]; // 通知执行协议方法
            }

        }
        else if (self.iCardType == TIDTICKET)
        {
            
            if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendPASSORTValue:PASS_INFO:)])
            {
                for (int i = PAS_PASNO; i <= PAS_MACHINE_RCODE; i++) {
                    [self.scNaigationDelegate sendPASSORTValue:(TFIELDID)i PASS_INFO:TREC_GetFieldString((TFIELDID)i )];
                }
                
            }
            
        }
        else if(self.iCardType == TIDSSCCARD)
        {
            if (self.scNaigationDelegate && [self.scNaigationDelegate respondsToSelector:@selector(sendSSCValue:SSC_NUM:SSC_SHORTNUM:SSC_PERIOD:SSC_BANKNUM:)])
            {
                [self.scNaigationDelegate sendSSCValue:TREC_GetFieldString(SSC_NAME) SSC_NUM:TREC_GetFieldString(SSC_NUM) SSC_SHORTNUM:TREC_GetFieldString(SSC_SHORTNUM) SSC_PERIOD:TREC_GetFieldString(SSC_PERIOD) SSC_BANKNUM:TREC_GetFieldString(SSC_BANKNUM)];
                
            }
        }
    }
    ret = TREC_FreeImage();
#endif
    [self dismissBtnPressed:NULL];

}

//拍照页面，"X"按钮
- (void)dismissBtnPressed:(id)sender {
    if (isClose == FALSE)
    {
        _captureManager.delegate = nil;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     
                                     (int64_t)(0.5 * NSEC_PER_SEC)),
                       
                       dispatch_get_main_queue(), ^{
                           if (self.navigationController) {
                               if (self.navigationController.viewControllers.count == 1) {
                                   [self.navigationController dismissModalViewControllerAnimated:YES];
                               } else {
                                   [self.navigationController popViewControllerAnimated:YES];
                               }
                           } else {
                               [self dismissModalViewControllerAnimated:YES];
                           }
                       });
        
    }
    
    
}


//拍照页面，网格按钮
- (void)gridBtnPressed:(UIButton*)sender {
    sender.selected = !sender.selected;
    [_captureManager switchGrid:sender.selected];
}

//拍照页面，切换前后摄像头按钮按钮
- (void)switchCameraBtnPressed:(UIButton*)sender {
    sender.selected = !sender.selected;
    [_captureManager switchCamera:sender.selected];
}

//拍照页面，闪光灯按钮
- (void)flashBtnPressed:(UIButton*)sender {

    sender.selected = !sender.selected;
    NSString *imgStr = @"";
    if (sender.isSelected == YES) { //打开闪光灯
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        if ([captureDevice hasTorch]) {
            BOOL locked = [captureDevice lockForConfiguration:&error];
            if (locked) {
                captureDevice.torchMode = AVCaptureTorchModeOn;
                [captureDevice unlockForConfiguration];
            }
        }
        imgStr = @"flashing_on_btn";
    }else{//关闭闪光灯
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch]) {
            [device lockForConfiguration:nil];
            [device setTorchMode: AVCaptureTorchModeOff];
            [device unlockForConfiguration];
        }
        imgStr = @"flashing_off_btn";
    }
    if (sender) {
        NSBundle *cbundle = [NSBundle bundleForClass:[self class]];
        NSString *pathqwe = [cbundle pathForResource:@"flutter_turui_ocr_bundles" ofType:@"bundle"];
        NSBundle *bundleqwe = [NSBundle bundleWithPath:pathqwe];
        UIImage * image = [UIImage imageNamed:imgStr
          inBundle: bundleqwe compatibleWithTraitCollection:nil];
        
        [sender setImage:image forState:UIControlStateNormal];
    }
}

#pragma mark -------------pinch camera---------------
//伸缩镜头
- (void)handlePinch:(UIPinchGestureRecognizer*)gesture {
    if (self.iCardType == TIDBANK
        || (self.iCardType == TIDCARD2 && self.ScanMode == TIDC_SCAN_MODE)
        || (self.iCardType == TIDLPR && self.ScanMode == TIDC_SCAN_MODE)) {
        return;
    }
    [_captureManager pinchCameraView:gesture];
    
    if (_scSlider) {
        if (_scSlider.alpha != 1.f) {
            [UIView animateWithDuration:0.3f animations:^{
                _scSlider.alpha = 1.f;
            }];
        }
        [_scSlider setValue:_captureManager.scaleNum shouldCallBack:NO];
        
        if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
            [self setSliderAlpha:YES];
        } else {
            [self setSliderAlpha:NO];
        }
    }
}


//#pragma mark -------------save image to local---------------
////保存照片至本机
//- (void)saveImageToPhotoAlbum:(UIImage*)image {
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//}
//
//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
//    if (error != NULL) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错了!" message:@"存不了T_T" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alert show];
//    } else {
//        SCDLog(@"保存成功");
//    }
//}

#pragma mark ------------notification-------------
//- (void)orientationDidChange:(NSNotification*)noti {
//
//    //    [_captureManager.previewLayer.connection setVideoOrientation:(AVCaptureVideoOrientation)[UIDevice currentDevice].orientation];
//
//    if (!_cameraBtnSet || _cameraBtnSet.count <= 0) {
//        return;
//    }
//    [_cameraBtnSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
//        UIButton *btn = ([obj isKindOfClass:[UIButton class]] ? (UIButton*)obj : nil);
//        if (!btn) {
//            *stop = YES;
//            return ;
//        }
//
//        btn.layer.anchorPoint = CGPointMake(0.5, 0.5);
//        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
//        switch ([UIDevice currentDevice].orientation) {
//            case UIDeviceOrientationPortrait://1
//            {
//                transform = CGAffineTransformMakeRotation(0);
//                break;
//            }
//            case UIDeviceOrientationPortraitUpsideDown://2
//            {
//                transform = CGAffineTransformMakeRotation(M_PI);
//                break;
//            }
//            case UIDeviceOrientationLandscapeLeft://3
//            {
//                transform = CGAffineTransformMakeRotation(M_PI_2);
//                break;
//            }
//            case UIDeviceOrientationLandscapeRight://4
//            {
//                transform = CGAffineTransformMakeRotation(-M_PI_2);
//                break;
//            }
//            default:
//                break;
//        }
//        [UIView animateWithDuration:0.3f animations:^{
//            btn.transform = transform;
//        }];
//    }];
//}

#pragma mark ---------rotate(only when this controller is presented, the code below effect)-------------
//<iOS6
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOrientationChange object:nil];
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}
//
//
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
////iOS6+
//- (BOOL)shouldAutorotate
//{
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOrientationChange object:nil];
//    return NO;
//}
//
//- (NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskAll;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    //    return [UIApplication sharedApplication].statusBarOrientation;
//  return UIInterfaceOrientationPortrait;
//}
//#endif
//#endif
@end
