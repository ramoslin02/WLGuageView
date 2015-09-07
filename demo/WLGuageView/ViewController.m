//
//  ViewController.m
//  WLGuageView
//
//  Created by ChampOn on 15/9/7.
//  Copyright (c) 2015年 com.champontech. All rights reserved.
//

#import "ViewController.h"
#import "WLGaugeView.h"

#define kScreenFrame [[UIScreen mainScreen] applicationFrame]
#define kRGBColor(r,g,b)         [UIColor colorWithRed:(r)/225.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.0] // RGBColor


@interface ViewController ()



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:[self setupGaugeView]];
}


#pragma mark 初始化话电量表视图
- (UIView *) setupGaugeView
{
    CGFloat width = 250;
    WLGaugeView * guageView = [[WLGaugeView alloc] initWithFrame:CGRectMake((kScreenFrame.size.width-width)/2,110 , width, width)];
    guageView.backgroundColor = [UIColor clearColor];
    guageView.maxValue = 2400;
    // 电量计的实时功率计量表
    guageView.scaleStartAngle = 40.0f;
    guageView.scaleEndAngle   = 320.0f;
    guageView.innerBackgroundStyle = WLGaugeViewInnerBackgroundStyleGradient; // 原先是Gradient效果
    guageView.needleStyle = WLGaugeViewNeedleStyle3D;
    guageView.needleScrewStyle = WLGaugeViewNeedleScrewStylePlain;
    guageView.showRangeLabels = YES;
    guageView.rangeValues = @[@2400.0];
    guageView.rangeColors = @[kRGBColor(250, 245, 255)];
    
    guageView.unitOfMeasurement = @"WATTS";
    guageView.showUnitOfMeasurement = YES;
    
    // 显示具体的实时功率
    CGFloat Labelwidth = 100;
    UILabel * realTimerPowerLabel = [[UILabel alloc] initWithFrame:CGRectMake((width-Labelwidth) * 0.5, guageView.frame.size.height+100-160, Labelwidth, 30)];
    [guageView addSubview:realTimerPowerLabel];
    realTimerPowerLabel.backgroundColor = [UIColor clearColor];
    realTimerPowerLabel.textAlignment = NSTextAlignmentCenter;
    realTimerPowerLabel.textColor = [UIColor whiteColor];
    
    return guageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
