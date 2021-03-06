#import "FlutterAimallFaceRecognitionPlugin.h"
#import "AimallManager.h"
#import "FaceActionDetectorManager.h"
#import "FaceInputtingViewController.h"
#import "AimoFaceUtils.h"
#import "FaceLivenessManager.h"
#import "FacedetectorManager.h"
#import "FaceExtractorManager.h"
#import "FaceLoginViewController.h"
#import "LivenessCollectionViewController.h"
#import "FaceManager.h"
#import "CardViewController.h"
#import "FaceLanguageManager.h"
@interface FlutterAimallFaceRecognitionPlugin ()

@property(nonatomic, copy) NSString *aimoKey;
@property(nonatomic, copy) FlutterResult mResult;

@end

@implementation FlutterAimallFaceRecognitionPlugin

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
            methodChannelWithName:@"flutter_aimall_face_recognition"
                  binaryMessenger:[registrar messenger]];
    FlutterAimallFaceRecognitionPlugin *instance = [[FlutterAimallFaceRecognitionPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    _mResult = result;
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if ([@"initImoSDK" isEqualToString:call.method]) {
        _aimoKey = call.arguments[@"imoKey"];
        [[FaceLanguageManager shareManager] setupUserLanguage:call.arguments[@"languageType"]];
        _mResult(@{@"code": @200});
    } else if ([@"actionLiving" isEqualToString:call.method]) {
        [self actionLiving];
    } else if ([@"silentLiving" isEqualToString:call.method]) {
        [self silentLiving];
    } else if ([@"livingSampling" isEqualToString:call.method]) {
        [self livingSampling];
    } else if ([@"faceSimilarityComparison" isEqualToString:call.method]) {
        [self faceSimilarityComparison:call.arguments[@"originImage"] targetImages:call.arguments[@"targetImages"]];
    } else if ([@"saveFaceToLocal" isEqualToString:call.method]) {
        [self saveFaceToLocal:call.arguments];
    } else if ([@"updateFaceToken" isEqualToString:call.method]) {
        [self updateFaceToken:call.arguments[@"userId"] faceToken:call.arguments[@"faceToken"]];
    } else if ([@"deleteFaceToken" isEqualToString:call.method]) {
        [self deleteFaceToken:call.arguments[@"faceToken"]];
    } else if ([@"deleteAllUserFace" isEqualToString:call.method]) {
        [self deleteAllUserFace];
    } else if ([@"cleanCache" isEqualToString:call.method]) {
        [self cleanCache];
    } else if ([@"takeCardImage" isEqualToString:call.method]) {
        [self takeCardImage];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

/**
 * ??????????????????
 */
- (void)actionLiving {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[AimallManager sharedInstance] initSDKWithKey:weakSelf.aimoKey success:^{
            DLog(@"????????????????????????????????????");
            [[FaceActionDetectorManager sharedInstance] initSDK:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    FaceInputtingViewController *vc = [FaceInputtingViewController new];
                    vc.livingScore = 0.75f;
                    [vc actionDetector:^(UIImage *faceImage) {
                        DLog(@"image: %@", faceImage);
                        NSString *filePath = [AimoFaceUtils saveImageToTemporaryDic:faceImage];
                        [[FaceActionDetectorManager sharedInstance] deinit];
                        [[AimallManager sharedInstance] deinit];
                        [weakSelf sendMessage:@{@"code": @200, @"image": filePath}];
                    }       faceCancel:^(NSInteger code) {
                        DLog(@"faceCancel: %ld", code);
                        [weakSelf sendMessage:@{@"code": @(code)}];
                    }];
                    UIViewController *presentingController = [UIApplication sharedApplication].delegate.window.rootViewController;
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    nav.navigationBar.hidden = YES;
                    nav.modalPresentationStyle = UIModalPresentationFullScreen;
                    [presentingController presentViewController:nav animated:YES completion:nil];
                });
            }                                             error:^(NSInteger code, NSString *msg) {
                DLog(@"???????????????, %ld, %@", code, msg);
                [[AimallManager sharedInstance] deinit];
                [weakSelf sendMessage:@{@"code": @(code), @"message": msg}];
            }];
        }                                        error:^(NSInteger code, NSString *msg) {
            DLog(@"???????????????, %ld, %@", code, msg);
            [weakSelf sendMessage:@{@"code": @(code), @"message": msg}];
        }];
    });
}

/**
 * ????????????
 */
- (void)silentLiving {
    __weak typeof(self) weakSelf = self;

    [[AimallManager sharedInstance] initSDKWithKey:_aimoKey success:^{
        // ????????????
        [[FaceLivenessManager sharedInstance] initSDK:^{
            // ????????????
            [[FacedetectorManager sharedInstance] initSDK:^{
                // ????????????
                [[FaceExtractorManager sharedInstance] initSDK:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        FaceLoginViewController *vc = [FaceLoginViewController new];
                        vc.livingScore = 0.75f;
                        [vc faceLiveness:0.7f success:^(UserFace *_Nonnull userFace, UIImage *_Nonnull image) {

                            NSString *filePath = [AimoFaceUtils saveImageToTemporaryDic:image];

                            [[FaceExtractorManager sharedInstance] deinit];
                            [[FacedetectorManager sharedInstance] deinit];
                            [[FaceLivenessManager sharedInstance] deinit];
                            [[AimallManager sharedInstance] deinit];

                            if (userFace == nil) {
                                DLog(@"??????????????????????????????!!!!");
                                DLog(@"image: %@", image);
                            } else {
                                DLog(@"????????????????????????!!!!");
                                DLog(@"%@", userFace);
                            }

                            if (userFace != nil) {
                                [weakSelf sendMessage:@{@"code": @200, @"image": filePath, @"faceToken": userFace.faceToken}];
                            } else {
                                [weakSelf sendMessage:@{@"code": @200, @"image": filePath}];
                            }
                            

                        }     faceCancel:^(NSInteger code) {
                            DLog(@"faceCancel: %ld", code);
                            [[FaceExtractorManager sharedInstance] deinit];
                            [[FacedetectorManager sharedInstance] deinit];
                            [[FaceLivenessManager sharedInstance] deinit];
                            [[AimallManager sharedInstance] deinit];
                            [weakSelf sendMessage:@{@"code": @(code)}];
                        }];
                        UIViewController *presentingController = [UIApplication sharedApplication].delegate.window.rootViewController;
                        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                        nav.navigationBar.hidden = YES;
                        nav.modalPresentationStyle = UIModalPresentationFullScreen;
                        [presentingController presentViewController:nav animated:YES completion:nil];
                    });
                }                                        error:^(NSInteger code, NSString *msg) {
                    DLog(@"???????????????, %ld, %@", code, msg);
                    [[FaceLivenessManager sharedInstance] deinit];
                    [[FacedetectorManager sharedInstance] deinit];
                    [[AimallManager sharedInstance] deinit];
                    [weakSelf sendMessage:@{@"code": @(code), @"message": msg}];
                }];
            }                                       error:^(NSInteger code, NSString *msg) {
                DLog(@"???????????????, %ld, %@", code, msg);
                [[FaceLivenessManager sharedInstance] deinit];
                [[AimallManager sharedInstance] deinit];
                [weakSelf sendMessage:@{@"code": @(code), @"message": msg}];
            }];
        }                                       error:^(NSInteger code, NSString *msg) {
            DLog(@"???????????????, %ld, %@", code, msg);
            [[AimallManager sharedInstance] deinit];
            [weakSelf sendMessage:@{@"code": @(code), @"message": msg}];
        }];
    }                                        error:^(NSInteger code, NSString *msg) {
        DLog(@"???????????????, %ld, %@", code, msg);
        [weakSelf sendMessage:@{@"code": @(code), @"message": msg}];
    }];
}

/**
 * ????????????????????????
 */
- (void)livingSampling {
    __weak typeof(self) weakSelf = self;
    [[AimallManager sharedInstance] initSDKWithKey:_aimoKey success:^{
        // ????????????
        [[FaceLivenessManager sharedInstance] initSDK:^{
            // ????????????
            [[FacedetectorManager sharedInstance] initSDK:^{

                dispatch_async(dispatch_get_main_queue(), ^{

                    LivenessCollectionViewController *vc = [LivenessCollectionViewController new];
                    vc.livingScore = 0.75f;
                    [vc livenessCollection:^(NSArray<UIImage *> *images, NSURL *videoURL) {
                        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
                        params[@"code"] = @200;

                        // ??????????????????
                        int index = 1;
                        for (UIImage *image in images) {
                            NSString *filePath = [AimoFaceUtils saveImageToTemporaryDic:image];
                            params[[NSString stringWithFormat:@"image%d", index]] = filePath;
                            index++;
                        }

                        // ????????????
                        NSFileManager *fs = [NSFileManager defaultManager];
                        NSURL *videoToUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [AimoFaceUtils getCacheDir], videoURL.relativePath.lastPathComponent]];
                        [fs moveItemAtPath:videoURL.path toPath:videoToUrl.path error:nil];
                        [fs removeItemAtURL:videoURL error:nil];

                        params[@"video"] = videoToUrl.path;

                        [[FacedetectorManager sharedInstance] deinit];
                        [[FaceLivenessManager sharedInstance] deinit];
                        [[AimallManager sharedInstance] deinit];

                        [weakSelf sendMessage:params];

                    }           faceCancel:^(NSInteger code) {
                        [[FacedetectorManager sharedInstance] deinit];
                        [[FaceLivenessManager sharedInstance] deinit];
                        [[AimallManager sharedInstance] deinit];
                        [weakSelf sendMessage:@{@"code": @(code)}];
                    }];
                    UIViewController *presentingController = [UIApplication sharedApplication].delegate.window.rootViewController;
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    nav.navigationBar.hidden = YES;
                    nav.modalPresentationStyle = UIModalPresentationFullScreen;
                    [presentingController presentViewController:nav animated:YES completion:nil];
                });
            }                                       error:^(NSInteger code, NSString *msg) {
                DLog(@"???????????????, %ld, %@", code, msg);
                [[FaceLivenessManager sharedInstance] deinit];
                [[AimallManager sharedInstance] deinit];
                [weakSelf sendMessage:@{@"code": @(code), @"message": msg}];
            }];
        }                                       error:^(NSInteger code, NSString *msg) {
            DLog(@"???????????????, %ld, %@", code, msg);
            [[AimallManager sharedInstance] deinit];
            [weakSelf sendMessage:@{@"code": @(code), @"message": msg}];
        }];
    }                                        error:^(NSInteger code, NSString *msg) {
        DLog(@"???????????????, %ld, %@", code, msg);
        [weakSelf sendMessage:@{@"code": @(code), @"message": msg}];
    }];
}

/**
 * ?????????????????????
 * @param originImagePath ??????
 * @param targetImages ???????????????????????????
 */
- (void)faceSimilarityComparison:(NSString *)originImagePath targetImages:(NSArray *)targetImages {
    __weak typeof(self) weakSelf = self;

    [[AimallManager sharedInstance] initSDKWithKey:_aimoKey success:^{
        [[FaceExtractorManager sharedInstance] initSDK:^{
            [[FacedetectorManager sharedInstance] initSDK:^{
                NSMutableArray<NSNumber *> *originImageFeature = [weakSelf syncExtractorFaceFeature:originImagePath];
                float maxScore = 0;
                for (NSString *targetImagePath in targetImages) {
                    NSMutableArray<NSNumber *> *imageFeature = [weakSelf syncExtractorFaceFeature:targetImagePath];
                    float score = [[FaceExtractorManager sharedInstance] faceCompare:originImageFeature faceFeature2:imageFeature];
                    if (score >= maxScore) {
                        maxScore = score;
                    }
                }

                [[FaceExtractorManager sharedInstance] deinit];
                [[FacedetectorManager sharedInstance] deinit];
                [[AimallManager sharedInstance] deinit];

                [weakSelf sendMessage:@{@"code": @200, @"score": @(maxScore)}];
            } error:^(NSInteger code, NSString *msg) {
                DLog(@"???????????????, %ld, %@", code, msg);
                [weakSelf sendMessage:@{@"code": @(code), @"message": msg}];
            }];
        }                                        error:^(NSInteger code, NSString *msg) {
            DLog(@"???????????????, %ld, %@", code, msg);
            [[AimallManager sharedInstance] deinit];
            [weakSelf sendMessage:@{@"code": @(code), @"message": msg}];
        }];
    }                                        error:^(NSInteger code, NSString *msg) {
        DLog(@"???????????????, %ld, %@", code, msg);
        [weakSelf sendMessage:@{@"code": @(code), @"message": msg}];
    }];
}

/**
 * ???????????????????????????
 * @param imagePath ????????????
 * @return ???????????????
 */
- (NSMutableArray<NSNumber *> *)syncExtractorFaceFeature:(NSString *)imagePath {
    __block NSMutableArray<NSNumber *> *userFaceFeature;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    UIImage *originImage = [UIImage imageWithContentsOfFile:imagePath];
    [[FaceExtractorManager sharedInstance] faceExtractorImage:originImage captureDevicePosition:AVCaptureDevicePositionFront block:^(NSMutableArray<NSNumber *> *faceFeature) {
        userFaceFeature = [NSMutableArray arrayWithArray:faceFeature];
        dispatch_semaphore_signal(sema);
    }];

    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    return userFaceFeature;
}

/**
 * ???????????????????????????
 * @param args ??????
 */
- (void)saveFaceToLocal:(id)args {
    __weak typeof(self) weakSelf = self;
      [[AimallManager sharedInstance] initSDKWithKey:_aimoKey success:^{
            [[FaceExtractorManager sharedInstance] initSDK:^{

                [[FacedetectorManager sharedInstance] initSDK:^{
                    FaceManager *fm = [FaceManager sharedInstance];
                    UserFace *userFace = [UserFace new];
                    userFace.userId = args[@"userId"];
                    userFace.email = args[@"email"];
                    userFace.mobile = args[@"mobile"];
                    userFace.faceToken = args[@"faceToken"];
                    NSMutableArray<NSNumber *> *originImageFeature = [weakSelf syncExtractorFaceFeature:args[@"faceImage"]];
                    userFace.faceFeature = [NSKeyedArchiver archivedDataWithRootObject:originImageFeature];
                    [fm saveUserFace:userFace];

                    [[FacedetectorManager sharedInstance] deinit];
                    [[FaceExtractorManager sharedInstance] deinit];
                    [[AimallManager sharedInstance] deinit];
                            } error:^(NSInteger code, NSString *msg) {
                                DLog(@"???????????????, %ld, %@", code, msg);
                                [[FacedetectorManager sharedInstance] deinit];
                                [[AimallManager sharedInstance] deinit];
                                [weakSelf sendMessage:@{@"code": @(code), @"message": msg}];
                            }];
                [weakSelf sendMessage:@{@"code": @200}];
            }                                        error:^(NSInteger code, NSString *msg) {
                DLog(@"???????????????, %ld, %@", code, msg);
                [[AimallManager sharedInstance] deinit];
                [weakSelf sendMessage:@{@"code": @(code), @"message": msg}];
            }];
        }                                        error:^(NSInteger code, NSString *msg) {
            DLog(@"???????????????, %ld, %@", code, msg);
            [weakSelf sendMessage:@{@"code": @(code), @"message": msg}];
        }];
}

/**
 * ??????????????????
 *
 * @param userId ??????id
 * @param faceToken ??????token
 */
- (void)updateFaceToken:(NSString *)userId faceToken:(NSString *)faceToken {
    FaceManager *fm = [FaceManager sharedInstance];
    UserFace *userFace = [UserFace new];
    userFace.userId = userId;
    userFace.faceToken = faceToken;
    [fm saveUserFace:userFace];

    [self sendMessage:@{@"code": @200}];
}

/**
 * ??????????????????
 * @param faceToken ??????token
 */
- (void)deleteFaceToken:(NSString *)faceToken {
    FaceManager *fm = [FaceManager sharedInstance];
    UserFace *userFace = [UserFace new];
    userFace.faceToken = faceToken;
    [fm deleteUserFace:userFace];

    [self sendMessage:@{@"code": @200}];
}

/**
 * ??????????????????????????????
 */
- (void)deleteAllUserFace {
    FaceManager *fm = [FaceManager sharedInstance];
    [fm deleteAllUserFace];
    [self sendMessage:@{@"code": @200}];
}

/**
 * ??????????????????
 */
- (void)cleanCache {
    NSFileManager *fs = [NSFileManager defaultManager];
    NSURL *cacheDir = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [AimoFaceUtils getCacheDir]]];
    [fs removeItemAtURL:cacheDir error:nil];
    [self sendMessage:@{@"code": @200}];
}

/**
 * ??????????????????
 */
- (void)takeCardImage {
    __weak typeof(self) weakSelf = self;
    [[AimallManager sharedInstance] initSDKWithKey:_aimoKey success:^{
        [[FacedetectorManager sharedInstance] initSDK:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                CardViewController *vc = [CardViewController new];
                [vc cardView:^(UIImage *_Nonnull image, UIImage *_Nonnull faceImage) {
                    NSString *imagePath = [AimoFaceUtils saveImageToTemporaryDic:image];
                    NSString *faceImagePath = [AimoFaceUtils saveImageToTemporaryDic:faceImage];

                    [[FacedetectorManager sharedInstance] deinit];
                    [[AimallManager sharedInstance] deinit];

                    [weakSelf sendMessage:@{@"code": @200, @"image": imagePath, @"headImage": faceImagePath}];
                } userCancel:^(NSInteger code) {
                    [[FacedetectorManager sharedInstance] deinit];
                    [[AimallManager sharedInstance] deinit];
                    [weakSelf sendMessage:@{@"code": @(code)}];
                }];
                UIViewController *presentingController = [UIApplication sharedApplication].delegate.window.rootViewController;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                nav.navigationBar.hidden = YES;
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [presentingController presentViewController:nav animated:YES completion:nil];
            });
        }                                       error:^(NSInteger code, NSString *msg) {
            DLog(@"???????????????, %ld, %@", code, msg);
            [[AimallManager sharedInstance] deinit];
            [weakSelf sendMessage:@{@"code": @(code), @"message": msg}];
        }];
    }                                        error:^(NSInteger code, NSString *msg) {
        DLog(@"???????????????, %ld, %@", code, msg);
        [weakSelf sendMessage:@{@"code": @(code), @"message": msg}];
    }];
}

// ???????????????????????????
- (void)sendMessage:(id)msg {
    if (msg == nil) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.mResult(msg);
    });
}

@end
