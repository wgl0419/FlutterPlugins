//
//  CameraDrawView.h
//
//  Created by Magel on 10-12-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globaltypedef.h"
#define kTimeInterval	0.2f

#define kLength 40
#define ScanValue 7
#define ScanValue_S 15
//#define kVerticalMargin ([[UIScreen mainScreen] bounds].size.height-KWidth*1.58)*0.5
@interface CameraDrawView : UIView {
    id delegate;
    UIColor *boundColor;
    BOOL beat;
    CGSize preSize;
    UIColor *textColor;
    int textSize;
    
    UIColor *lineColor;
    int lineSize;
    
    int kVerticalMargin ;
    int KHeight ;
    int kHorizontalMargin ;
}
@property(nonatomic,assign)BOOL  isPortrait;
@property (nonatomic, retain) id delegate;
@property(nonatomic,assign)CGPoint  beginPoint;
@property(nonatomic,assign)CGPoint endPoint;
@property(nonatomic,strong)UILabel *lable;
@property(nonatomic,strong)UILabel *TRlable;

-(CGPoint)getBeginPoint;
-(CGPoint)getEndPoint;
-(void)showLineUP:(BOOL)up right:(BOOL)right bottom:(BOOL)bottom left:(BOOL)left;
-(void)SetPreSize:(TCARD_TYPE) iCardType size:(CGSize)size;
-(void)showText:(NSString *)text;
-(void)showCopyRightText:(NSString *)text color:(UIColor *)textColor;
-(void)SetTextColor:(UIColor *)pTextColor;
-(void)SetTextSize:(int)ntextSize;
-(void)SetLineColor:(UIColor *)pLineColor;
-(void)SetLineSize:(int)nlineSize;
-(void)SetPortrait:(BOOL)isport;
@end
