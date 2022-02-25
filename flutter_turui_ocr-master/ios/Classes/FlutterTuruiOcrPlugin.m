#import "FlutterTuruiOcrPlugin.h"

#import "Globaltypedef.h"
#import "SCCaptureCameraController.h"
#import "IOSOCRAPI.h"
#import "OCRImageUtils.h"

#ifdef __OBJC__
#ifdef DEBUG
#define DLog(fmt, ...) {NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
#else
#define DLog(...)
#endif
#endif

@interface FlutterTuruiOcrPlugin () <SCNavigationControllerDelegate>
@property(nonatomic, copy) NSMutableDictionary *callbackData;

@property(nonatomic, copy) FlutterResult mResult;
@end

@implementation FlutterTuruiOcrPlugin {
    BOOL _engineInit;
}

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
            methodChannelWithName:@"exchange.sgp.flutter/flutter_turui_ocr"
                  binaryMessenger:[registrar messenger]];
    FlutterTuruiOcrPlugin *instance = [[FlutterTuruiOcrPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"initSdk" isEqualToString:call.method]) {
        [self initSdk:result];
    } else if ([@"identify" isEqual:call.method]) {
        [self actionIDCardIdentification:call result:result];
    } else if ([@"deInitSdk" isEqualToString:call.method]) {
        [self deInit];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - 初始化sdk

- (void)initSdk:(FlutterResult)result {
    if (_engineInit) {
        result(@YES);
        return;
    }
    // 打开引擎
    Gint ret = TREC_StartUP(TREC_GetEngineTimeKEY());
    if (ret == 100) {
        DLog(@"引擎过期\n");
    }
    if (ret == 101) {
        DLog(@"引擎绑定失败\n");
    }

    if (ret == 1) {
        _engineInit = YES;
        result(@NO);
    } else {
        result(@YES);
    }
}

#pragma mark - 实名认证

- (void)actionIDCardIdentification:(FlutterMethodCall *)call result:(FlutterResult)result {
    
    if (!_engineInit) {
        DLog(@"请先初始化OCR引擎!");
        result(@NO);
        return;
    }
    
    self.mResult = result;
    

    [self.callbackData removeAllObjects];

    SCCaptureCameraController *con = [[SCCaptureCameraController alloc] init];
    con.scNaigationDelegate = self;
    con.iCardType = TIDCARD2;
    con.isDisPlayTxt = YES;
    con.ScanMode = TIDC_SCAN_MODE;
    con.modalPresentationStyle = UIModalPresentationFullScreen;

    UIViewController *presentingController = [UIApplication sharedApplication].delegate.window.rootViewController;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:con];
    nav.navigationBar.hidden = YES;
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [presentingController presentViewController:nav animated:YES completion:nil];
}


#pragma mark - 反初始化

- (void)deInit {
    if (_engineInit == YES) {
        TREC_ClearUP();
    }
}

#pragma  mark - 识别回调

- (void)sendRNCallback {
    if (self.mResult == nil) {
        return;
    }
    BOOL isFront = [self.callbackData[@"isFront"] boolValue];
    if (isFront) {
        // 1. 姓名
        // 2. 身份证号
        // 3. 图片路径
        // 4. 头像路径
        // 5. 是否是正面
        if (self.callbackData.allKeys.count >= 5) {
            self.mResult(self.callbackData);
        } else {
            self.mResult(@NO);
        }
    } else {
        // 1. 图片路径
        // 2. 是否是正面
        if (self.callbackData.allKeys.count >= 2) {
            self.mResult(self.callbackData);
        } else {
            self.mResult(@NO);
        }
    }
    [self.callbackData removeAllObjects];
    self.mResult = nil;
}

- (void)sendAllValue:(NSString *)text {

}

- (void)sendIDCValue:(NSString *)name SEX:(NSString *)sex FOLK:(NSString *)folk BIRTHDAY:(NSString *)birthday ADDRESS:(NSString *)address NUM:(NSString *)num {
    DLog(@"name: %@, sex: %@, folk: %@, num: %@", name, sex, folk, num);
    self.callbackData[@"realName"] = [NSString stringWithFormat:@"%@", name];
    self.callbackData[@"idCardNum"] = [NSString stringWithFormat:@"%@", num];
}

- (void)sendIDCBackValue:(NSString *)issue PERIOD:(NSString *)period IDCPASSNUM:(NSString *)passnum {
    DLog(@"issue: %@, period: %@, passnum: %@", issue, period, passnum);
    [self sendRNCallback];
}

- (void)sendTakeImage:(TCARD_TYPE)iCardType image:(UIImage *)cardImage {
    DLog(@"sendTakeImage = %d %@\n", iCardType, cardImage);
    self.callbackData[@"isFront"] = iCardType == TIDCARD2 ? @(YES) : @(NO);
    if (cardImage != NULL) {
        NSString *imagePath = [OCRImageUtils saveImageToTemporaryDic:[OCRImageUtils compressImageSize:cardImage toByte:15000]];
        self.callbackData[@"image"] = imagePath;
    }
}

- (void)sendCardFaceImage:(UIImage *)image {
    if (image != NULL) {
        NSString *imagePath = [OCRImageUtils saveImageToTemporaryDic:[OCRImageUtils compressImageSize:image toByte:8000]];
        self.callbackData[@"headImage"] = imagePath;
        DLog(@"headiamge = %@\n", image);
    }
    [self sendRNCallback];
}

- (void)sendFieldImage:(TFIELDID)filed image:(UIImage *)fieldimage {
    DLog(@"sendFieldImage = %d %@\n", filed, fieldimage);
    if (self.mResult != nil) {
        self.mResult(@NO);
    }
}

- (NSMutableDictionary *)callbackData {
    if (_callbackData == nil) {
        _callbackData = [NSMutableDictionary new];
    }
    return _callbackData;
}

@end
