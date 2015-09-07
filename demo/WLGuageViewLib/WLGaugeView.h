/*
 * WLGaugeView.h
 *
 * Copyright (C) 2015 <1542997454@qq.com>
 *
 */

#import <UIKit/UIKit.h>

typedef enum
{
    WLGaugeViewSubdivisionsAlignmentTop,
    WLGaugeViewSubdivisionsAlignmentCenter,
    WLGaugeViewSubdivisionsAlignmentBottom
}
WLGaugeViewSubdivisionsAlignment;

typedef enum
{
    WLGaugeViewNeedleStyle3D,
    WLGaugeViewNeedleStyleFlatThin
}
WLGaugeViewNeedleStyle;

typedef enum
{
    WLGaugeViewNeedleScrewStyleGradient,
    WLGaugeViewNeedleScrewStylePlain
}
WLGaugeViewNeedleScrewStyle;

typedef enum
{
    WLGaugeViewInnerBackgroundStyleGradient,
    WLGaugeViewInnerBackgroundStyleFlat
}
WLGaugeViewInnerBackgroundStyle;

@interface WLGaugeView : UIView

@property (nonatomic) bool showInnerBackground;
@property (nonatomic) bool showInnerRim;
@property (nonatomic) CGFloat innerRimWidth;
@property (nonatomic) CGFloat innerRimBorderWidth;
@property (nonatomic) WLGaugeViewInnerBackgroundStyle innerBackgroundStyle;

@property (nonatomic) CGFloat needleWidth;
@property (nonatomic) CGFloat needleHeight;
@property (nonatomic) CGFloat needleScrewRadius;
@property (nonatomic) WLGaugeViewNeedleStyle needleStyle;
@property (nonatomic) WLGaugeViewNeedleScrewStyle needleScrewStyle;

@property (nonatomic) CGFloat scalePosition;
@property (nonatomic) CGFloat scaleStartAngle;
@property (nonatomic) CGFloat scaleEndAngle;
@property (nonatomic) CGFloat scaleDivisions;
@property (nonatomic) CGFloat scaleSubdivisions;
@property (nonatomic) bool showScaleShadow;
@property (nonatomic) WLGaugeViewSubdivisionsAlignment scalesubdivisionsaligment;
@property (nonatomic) CGFloat scaleDivisionsLength;
@property (nonatomic) CGFloat scaleDivisionsWidth;
@property (nonatomic) CGFloat scaleSubdivisionsLength;
@property (nonatomic) CGFloat scaleSubdivisionsWidth;

@property (nonatomic, strong) UIColor *scaleDivisionColor;
@property (nonatomic, strong) UIColor *scaleSubDivisionColor;

@property (nonatomic, strong) UIFont *scaleFont;

@property (nonatomic) CGFloat rangeLabelsWidth;

@property (nonatomic) float value;
@property (nonatomic) float minValue;
@property (nonatomic) float maxValue;

@property (nonatomic) bool showRangeLabels;
@property (nonatomic) CGFloat rangeLabelsFontKerning;
@property (nonatomic, strong) NSArray *rangeValues;
@property (nonatomic, strong) NSArray *rangeColors;
@property (nonatomic, strong) NSArray *rangeLabels;

@property (nonatomic, strong) NSString *unitOfMeasurement;
@property (nonatomic) bool showUnitOfMeasurement;

- (void)setValue:(float)value animated:(BOOL)animated;

@end
