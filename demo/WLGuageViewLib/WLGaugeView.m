/*
 * WLGaugeView.h
 *
 * Copyright (C) 2014 William Markezana <william.markezana@me.com>
 *
 */

#import "WLGaugeView.h"

#define DEGREES_TO_RADIANS(degrees) (degrees) / 180.0 * M_PI

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/255.0]
#define CGRGB(r,g,b) RGB(r,g,b).CGColor
#define iCGRGB(r,g,b) (id)CGRGB(r,g,b)
#define CGRGBA(r,g,b,a) RGBA(r,g,b,a).CGColor
#define iCGRGBA(r,g,b,a) (id)CGRGBA(r,g,b,a)

@implementation WLGaugeView
{
    CGRect fullRect;
    CGRect innerRimRect;
    CGRect innerRimBorderRect;
    CGRect faceRect;
    CGRect rangeLabelsRect;
    CGRect scaleRect;
    CGPoint center;
    CGFloat scaleRotation;
    CGFloat divisionValue;
    CGFloat subdivisionValue;
    CGFloat subdivisionAngle;
    double currentValue;
    double needleAcceleration;
    double needleVelocity;
    NSTimeInterval needleLastMoved;
    UIImage *background;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initialize];
}

- (void)initialize;
{
    _showInnerRim = NO;
    _showInnerBackground = YES;
    _innerRimWidth = 0.05;
    _innerRimBorderWidth = 0.005;
    _innerBackgroundStyle = WLGaugeViewInnerBackgroundStyleGradient;
    
    _needleWidth = 0.030;
    _needleHeight = 0.34;
    _needleScrewRadius = 0.04;
    _needleStyle = WLGaugeViewNeedleStyle3D;
    _needleScrewStyle = WLGaugeViewNeedleScrewStyleGradient;
    
    _scalePosition = 0.025;
    _scaleStartAngle = 30.0;
    _scaleEndAngle = 330.0;
    _scaleDivisions = 12.0;
    _scaleSubdivisions = 10.0;
    _showScaleShadow = YES;
    _scalesubdivisionsaligment = WLGaugeViewSubdivisionsAlignmentTop;
    _scaleDivisionsLength = 0.045;
    _scaleDivisionsWidth = 0.01;
    _scaleSubdivisionsLength = 0.015;
    _scaleSubdivisionsWidth = 0.01;
    
    _value = 0.0;
    _minValue = 0.0;
    _maxValue = 240.0;
    currentValue = 0.0;
    
    needleVelocity = 0.0;
    needleAcceleration = 0.0;
    needleLastMoved = -1;
    
    background = nil;
    
    _showRangeLabels = NO;
    _rangeLabelsWidth = 0.05;
    _rangeLabelsFontKerning = 1.0;
    _rangeValues = nil;
    _rangeColors = nil;
    _rangeLabels = nil;
    
    _scaleDivisionColor = RGB(68, 84, 105);
    _scaleSubDivisionColor = RGB(217, 217, 217);
    
    _scaleFont = nil;
    
    _unitOfMeasurement = @"";
    _showUnitOfMeasurement = NO;
    
    [self initDrawingRects];
    [self initScale];
    [self createGradientLayerView];
   
}

- (void) createGradientLayerView  {
    UIView * bgview = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:bgview];
    // 路径的Path.
    CGFloat radius = bgview.frame.size.width * 0.5-14;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:bgview.center radius:radius startAngle:DEGREES_TO_RADIANS(-228) endAngle:DEGREES_TO_RADIANS(48) clockwise:YES];
    CAShapeLayer *tracklayer = [CAShapeLayer layer];
    tracklayer.frame = bgview.bounds;
    tracklayer.fillColor = [[UIColor clearColor] CGColor];
    tracklayer.strokeColor = [[UIColor blueColor] CGColor];
    tracklayer.opacity = 1.0f;
    tracklayer.lineCap = kCALineCapSquare;
    tracklayer.lineWidth = 13.0f;
    tracklayer.path = [path CGPath];
    [bgview.layer addSublayer:tracklayer];
    
    
    CALayer *layer = [CALayer layer];
    CAGradientLayer *gradientOne = [CAGradientLayer layer];
    gradientOne.frame = CGRectMake(0, 0, bgview.frame.size.width/2, bgview.frame.size.height);
    [gradientOne setColors:[NSArray arrayWithObjects:(id)[[UIColor greenColor] CGColor],(id)[[UIColor yellowColor] CGColor], nil]];
    
    // 如果没有setLocations: 那么就会按比例来分配。
     //[gradientOne setLocations:@[@0.4,@0.6]];
    [gradientOne setStartPoint :CGPointMake (0.5,1)];
    [gradientOne setEndPoint: CGPointMake(0.5,0)];
    [layer addSublayer:gradientOne];
    
    CAGradientLayer  * gradientTwo = [CAGradientLayer layer];
    gradientTwo. frame =  CGRectMake(bgview.frame.size.width/ 2,0,bgview.frame.size. width/ 2, bgview.frame.size.height);
    [gradientTwo setColors :[NSArray  arrayWithObjects :(id)[[UIColor yellowColor] CGColor ],(id)[[ UIColor redColor] CGColor ],nil]];
    
    [gradientTwo setStartPoint :CGPointMake (0.5,0)];
    [gradientTwo setEndPoint: CGPointMake(0.5,1)];
    
    [layer addSublayer:gradientTwo];
    [layer setMask:tracklayer];
    [bgview.layer  addSublayer:layer];
}

- (void)initDrawingRects
{
    center = CGPointMake(0.5, 0.5);
    fullRect = CGRectMake(0.0, 0.0, 1.0, 1.0);
    
    _innerRimBorderWidth = _showInnerRim?_innerRimBorderWidth:0.0;
    _innerRimWidth = _showInnerRim?_innerRimWidth:0.0;
    
    innerRimRect = fullRect;
    innerRimBorderRect = CGRectMake(innerRimRect.origin.x + _innerRimBorderWidth,
                                    innerRimRect.origin.y + _innerRimBorderWidth,
                                    innerRimRect.size.width - 2 * _innerRimBorderWidth,
                                    innerRimRect.size.height - 2 * _innerRimBorderWidth);
    faceRect = CGRectMake(innerRimRect.origin.x + _innerRimWidth,
                          innerRimRect.origin.y + _innerRimWidth,
                          innerRimRect.size.width - 2 * _innerRimWidth,
                          innerRimRect.size.height - 2 * _innerRimWidth);
    rangeLabelsRect = CGRectMake(faceRect.origin.x + (_showRangeLabels ? _rangeLabelsWidth : 0.0),
                                 faceRect.origin.y + (_showRangeLabels ? _rangeLabelsWidth : 0.0),
                                 faceRect.size.width - 2 * (_showRangeLabels ? _rangeLabelsWidth : 0.0),
                                 faceRect.size.height - 2 * (_showRangeLabels ? _rangeLabelsWidth : 0.0));
    scaleRect = CGRectMake(rangeLabelsRect.origin.x + _scalePosition,
                           rangeLabelsRect.origin.y + _scalePosition,
                           rangeLabelsRect.size.width - 2 * _scalePosition,
                           rangeLabelsRect.size.height - 2 * _scalePosition);
    
    
}

- (void)rotateContext:(CGContextRef)context fromCenter:(CGPoint)center_ withAngle:(CGFloat)angle
{
    CGContextTranslateCTM(context, center_.x, center_.y);
    CGContextRotateCTM(context, angle);
    CGContextTranslateCTM(context, -center_.x, -center_.y);
}

- (void)drawRect:(CGRect)rect
{
    [self computeCurrentValue];
    
    if (background == nil)
    {
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(context, rect.size.width , rect.size.height);
        [self drawGauge:context];
        background = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    [background drawInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, rect.size.width , rect.size.height);
    
    [self drawNeedle:context];
}

- (void)drawGauge:(CGContextRef)context
{
    [self drawRim:context];
    if (_showInnerBackground)
        [self drawFace:context];
    if (_showUnitOfMeasurement)
        [self drawText:context];
    [self drawScale:context];
    if (_showRangeLabels)
        [self drawRangeLabels:context];
}

- (void)drawRim:(CGContextRef)context
{
    
}


#pragma mark 显示背景颜色。
- (void)drawFace:(CGContextRef)context
{
    switch (_innerBackgroundStyle)
    {
            // 显示3D效果图.
            // 显示效果在这里自定义。
        case WLGaugeViewInnerBackgroundStyleGradient:
        {
            // Default Face
            // CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
            // CGGradientRef gradient = CGGradientCreateWithColors(baseSpace, (CFArrayRef)@[iCGRGB(96, 96, 96), iCGRGB(68, 68, 68), iCGRGB(32, 32, 32)], (const CGFloat[]){0.35, 0.96, 0.99});
            //  CGColorSpaceRelease(baseSpace), baseSpace = NULL;
            //  CGContextAddEllipseInRect(context, faceRect);
            //  CGContextClip(context);
            //  CGContextDrawRadialGradient(context, gradient, center, 0, center, faceRect.size.width / 2.0, kCGGradientDrawsAfterEndLocation);
            //  CGGradientRelease(gradient), gradient = NULL;
            
#pragma mark 自定义的背景颜色 && 需要自定义背景颜色：
             CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
             CGGradientRef gradient = CGGradientCreateWithColors(baseSpace, (CFArrayRef)@[(id)[UIColor blackColor].CGColor,iCGRGB(245, 245, 255)],(const CGFloat[]){0.90,1.0});
              CGColorSpaceRelease(baseSpace), baseSpace = NULL;
              CGContextAddEllipseInRect(context, faceRect);
              CGContextClip(context);
              CGContextDrawRadialGradient(context, gradient, center, 0, center, faceRect.size.width / 2.0, kCGGradientDrawsAfterEndLocation);
            
            // 这个是RangeLabelsRect.
            CGContextAddEllipseInRect(context, rangeLabelsRect);
            CGContextDrawRadialGradient(context, gradient, center, 30, center, 330, kCGGradientDrawsAfterEndLocation);
             // CGContextDrawLinearGradient
              CGGradientRelease(gradient), gradient = NULL;
            
            
            //            // Shadow
            //            baseSpace = CGColorSpaceCreateDeviceRGB();
            //            gradient = CGGradientCreateWithColors(baseSpace, (CFArrayRef)@[iCGRGBA(40, 96, 170, 60), iCGRGBA(15, 34, 98, 80), iCGRGBA(0, 0, 0, 120), iCGRGBA(0, 0, 0, 140)], (const CGFloat[]){0.60, 0.85, 0.96, 0.99});
            //            CGColorSpaceRelease(baseSpace), baseSpace = NULL;
            //            CGContextAddEllipseInRect(context, faceRect);
            //            CGContextClip(context);
            //            CGContextDrawRadialGradient(context, gradient, center, 0, center, faceRect.size.width / 2.0, kCGGradientDrawsAfterEndLocation);
            //            CGGradientRelease(gradient), gradient = NULL;
            //
            //            // Border
            //            CGContextSetLineWidth(context, 0.005);
            //            CGContextSetStrokeColorWithColor(context, CGRGBA(81, 84, 89, 160));
            //            CGContextAddEllipseInRect(context, faceRect);
            //            CGContextStrokePath(context);
        }
        break;
        
        case WLGaugeViewInnerBackgroundStyleFlat:
        {
#pragma mark 这个是让中心的原点没有了。如果需要自己打开。
             #define EXTERNAL_RING_RADIUS    0.24
             #define INTERNAL_RING_RADIUS    0.1
             CGContextAddEllipseInRect(context, CGRectMake(center.x - EXTERNAL_RING_RADIUS, center.y - EXTERNAL_RING_RADIUS, EXTERNAL_RING_RADIUS * 2.0, EXTERNAL_RING_RADIUS * 2.0));
             CGContextSetFillColorWithColor(context, CGRGB(255, 104, 97));
             CGContextFillPath(context);
             CGContextAddEllipseInRect(context, CGRectMake(center.x - INTERNAL_RING_RADIUS, center.y - INTERNAL_RING_RADIUS, INTERNAL_RING_RADIUS * 2.0, INTERNAL_RING_RADIUS * 2.0));
             CGContextSetFillColorWithColor(context, CGRGB(242, 99, 92));
             CGContextFillPath(context);
        }
        break;
            
        default:
        break;
    }
}

#pragma mark 绘制Unit 单位的字体.
// 设置单位的字体.
- (void)drawText:(CGContextRef)context
{
    CGContextSetShadow(context, CGSizeMake(0.05, 0.05), 2.0);
    UIFont* font = [UIFont fontWithName:@"Helvetica" size:0.05];
    NSDictionary* stringAttrs = @{ NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor whiteColor] };
    NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:_unitOfMeasurement attributes:stringAttrs];
    CGSize fontWidth = [_unitOfMeasurement sizeWithAttributes:stringAttrs];
    [attrStr drawAtPoint:CGPointMake(0.5 - fontWidth.width / 2.0, 0.6)];
}

#pragma mark 绘制比例尺。
- (void)drawScale:(CGContextRef)context
{
    CGContextSaveGState(context);
    [self rotateContext:context fromCenter:center withAngle:DEGREES_TO_RADIANS(180 + _scaleStartAngle)];
    
    int totalTicks = _scaleDivisions * _scaleSubdivisions + 1;
    for (int i = 0; i < totalTicks; i++)
    {
        CGFloat offset = 0.0;
        if (_scalesubdivisionsaligment == WLGaugeViewSubdivisionsAlignmentCenter) offset = (_scaleDivisionsLength - _scaleSubdivisionsLength) / 2.0;
        if (_scalesubdivisionsaligment == WLGaugeViewSubdivisionsAlignmentBottom) offset = _scaleDivisionsLength - _scaleSubdivisionsLength;
        
        CGFloat y1 = scaleRect.origin.y;
        CGFloat y2 = y1 + _scaleSubdivisionsLength;
        CGFloat y3 = y1 + _scaleDivisionsLength;
        
        float value = [self valueForTick:i];
        float div = (_maxValue - _minValue) / _scaleDivisions;
        float mod = (int)value % (int)div;
        
        if ((fabsf(mod - 0) < 0.000001) || (fabsf(mod - div) < 0.000001))
        {
            UIColor *color = (_rangeValues && _rangeColors)?[self rangeColorForValue:value]:_scaleDivisionColor;
            
            // 绘制大的Division的颜色。
            CGContextSetStrokeColorWithColor(context, color.CGColor);
            CGContextSetLineWidth(context, _scaleDivisionsWidth);
            CGContextSetShadow(context, CGSizeMake(0.05, 0.05), _showScaleShadow?2.0:0.0);
            
            CGContextMoveToPoint(context, 0.5, y1);
            CGContextAddLineToPoint(context, 0.5, y3);
            CGContextStrokePath(context);
            
            NSString *valueString = [NSString stringWithFormat:@"%0.0f",value];
            UIFont* font = _scaleFont?_scaleFont:[UIFont fontWithName:@"Helvetica-Bold" size:0.05];
            NSDictionary* stringAttrs = @{ NSFontAttributeName : font, NSForegroundColorAttributeName : color};
            NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:valueString attributes:stringAttrs];
            CGSize fontWidth = [valueString sizeWithAttributes:stringAttrs];
            [attrStr drawAtPoint:CGPointMake(0.5 - fontWidth.width / 2.0, y3 + 0.005)];
        }
        else
        {
            
#pragma mark  这里是设置小的分割块的颜色。
//            // 绘制Subdivision的颜色。
//            UIColor *color = (_rangeValues && _rangeColors)?[self rangeColorForValue:value]:_scaleSubDivisionColor;
//            CGContextSetStrokeColorWithColor(context, color.CGColor);
//            CGContextSetLineWidth(context, _scaleSubdivisionsWidth);
//            CGContextMoveToPoint(context, 0.5, y1);
//            if (_showScaleShadow) CGContextSetShadow(context, CGSizeMake(0.05, 0.05), 2.0);
//            
//            CGContextMoveToPoint(context, 0.5, y1 + offset);
//            CGContextAddLineToPoint(context, 0.5, y2 + offset);
//            CGContextStrokePath(context);
        }
        
        [self rotateContext:context fromCenter:center withAngle:DEGREES_TO_RADIANS(subdivisionAngle)];
    }
    CGContextRestoreGState(context);
}

- (void) drawStringAtContext:(CGContextRef) context string:(NSString*)text withCenter:(CGPoint)center_ radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle
{
    CGContextSaveGState(context);
    
    UIFont* font = _scaleFont?_scaleFont:[UIFont fontWithName:@"Helvetica" size:0.05];
    NSDictionary* stringAttrs = @{ NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor whiteColor] };
    CGSize textSize = [text sizeWithAttributes:stringAttrs];
 
    float perimeter = 2 * M_PI * radius;
    float textAngle = textSize.width / perimeter * 2 * M_PI * _rangeLabelsFontKerning;
    float offset = ((endAngle - startAngle) - textAngle) / 2.0;

    float letterPosition = 0;
    NSString *lastLetter = @"";
    
    [self rotateContext:context fromCenter:center withAngle:startAngle + offset];
    for (int index = 0; index < [text length]; index++)
    {
        NSRange range = {index, 1};
        NSString* letter = [text substringWithRange:range];
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:letter attributes:stringAttrs];
        CGSize charSize = [letter sizeWithAttributes:stringAttrs];
  
        float totalWidth = [[NSString stringWithFormat:@"%@%@", lastLetter, letter] sizeWithAttributes:stringAttrs].width;
        float currentLetterWidth = [letter sizeWithAttributes:stringAttrs].width;
        float lastLetterWidth = [lastLetter sizeWithAttributes:stringAttrs].width;
        float kerning = (lastLetterWidth) ? 0 : ((currentLetterWidth + lastLetterWidth) - totalWidth);
        
        letterPosition += (charSize.width / 2) - kerning;
        float angle = (letterPosition / perimeter * 2 * M_PI) * _rangeLabelsFontKerning;
        CGPoint letterPoint = CGPointMake((radius - charSize.height / 2.0) * cos(angle) + center_.x, (radius - charSize.height / 2.0) * sin(angle) + center_.y);
        
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, letterPoint.x, letterPoint.y);
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(angle + M_PI_2);
        CGContextConcatCTM(context, rotationTransform);
        CGContextTranslateCTM(context, -letterPoint.x, -letterPoint.y);

        [attrStr drawAtPoint:CGPointMake(letterPoint.x - charSize.width/2 , letterPoint.y - charSize.height)];
        
        CGContextRestoreGState(context);
        
        letterPosition += charSize.width / 2;
        lastLetter = letter;
    }
    
    CGContextRestoreGState(context);
}

#pragma mark 这设置外环的
// 外环的颜色来自于Color数组的颜色，可以通过修改 UIColor * color = colors[i];
- (void)drawRangeLabels:(CGContextRef)context
{
//    CGContextSaveGState(context);
//    [self rotateContext:context fromCenter:center withAngle:DEGREES_TO_RADIANS(90 + _scaleStartAngle)];
//    CGContextSetShadow(context, CGSizeMake(0.0, 0.0), 0.0);
//    CGFloat maxAngle = _scaleEndAngle - _scaleStartAngle;
//    CGFloat lastStartAngle = 0.0f;
//
//    for (int i = 0; i < _rangeValues.count; i ++)
//    {
//        float value = ((NSNumber*)[_rangeValues objectAtIndex:i]).floatValue;
//        float valueAngle = (value - _minValue) / (_maxValue - _minValue) * maxAngle;
//        
//        UIBezierPath *path = [UIBezierPath bezierPath];
//        [path addArcWithCenter:center radius:rangeLabelsRect.size.width / 2.0 + 0.01 startAngle:DEGREES_TO_RADIANS(lastStartAngle) endAngle:DEGREES_TO_RADIANS(valueAngle) clockwise:YES];
//        
//        UIColor *color = _rangeColors[i];
//        [color setStroke];
//        path.lineWidth = _rangeLabelsWidth;
//        [path stroke];
//        
//        
//        [self drawStringAtContext:context string:(NSString*)_rangeLabels[i] withCenter:center radius:rangeLabelsRect.size.width / 2.0 + 0.008 startAngle:DEGREES_TO_RADIANS(lastStartAngle) endAngle:DEGREES_TO_RADIANS(valueAngle)];
//        
//        lastStartAngle = valueAngle;
//    }
//    
//    CGContextRestoreGState(context);
    
    
//    CGContextSaveGState(context);
//    [self rotateContext:context fromCenter:center withAngle:DEGREES_TO_RADIANS(90 + _scaleStartAngle)];
//    CGContextSetShadow(context, CGSizeMake(0.0, 0.0), 0.0);
//    CGFloat maxAngle = _scaleEndAngle - _scaleStartAngle;
//    CGFloat lastStartAngle = 0.0f;
//    
//    for (int i = 0; i < _rangeValues.count; i ++)
//    {
//        float value = ((NSNumber*)[_rangeValues objectAtIndex:i]).floatValue;
//        float valueAngle = (value - _minValue) / (_maxValue - _minValue) * maxAngle;
//        
//        UIBezierPath *path = [UIBezierPath bezierPath];
//        [path addArcWithCenter:center radius:rangeLabelsRect.size.width / 2.0 + 0.01 startAngle:DEGREES_TO_RADIANS(lastStartAngle) endAngle:DEGREES_TO_RADIANS(valueAngle) clockwise:YES];
//        
//        UIColor *color = _rangeColors[i];
//        [color setStroke];
//        path.lineWidth = _rangeLabelsWidth;
//        [path stroke];
//        
//        
//        [self drawStringAtContext:context string:(NSString*)_rangeLabels[i] withCenter:center radius:rangeLabelsRect.size.width / 2.0 + 0.008 startAngle:DEGREES_TO_RADIANS(lastStartAngle) endAngle:DEGREES_TO_RADIANS(valueAngle)];
//        
//        lastStartAngle = valueAngle;
//    }
//    
//    CGContextRestoreGState(context);
    
    
    
}

- (void)drawNeedle:(CGContextRef)context
{
    [self rotateContext:context fromCenter:center withAngle:DEGREES_TO_RADIANS(180 + _scaleStartAngle + (currentValue - _minValue) / (_maxValue - _minValue) * (_scaleEndAngle - _scaleStartAngle))];
    
    switch (_needleStyle)
    {
        case WLGaugeViewNeedleStyle3D:
        {
            CGContextSetShadow(context, CGSizeMake(0.05, 0.05), 8.0);
            
            // Left Needle
            UIBezierPath *leftNeedlePath = [UIBezierPath bezierPath];
            [leftNeedlePath moveToPoint:center];
            [leftNeedlePath addLineToPoint:CGPointMake(center.x -_needleWidth, center.y)];
            [leftNeedlePath addLineToPoint:CGPointMake(center.x, center.x - _needleHeight)];
            [leftNeedlePath closePath];
            [RGB(255,0,0) setFill]; // 设置左边指针的颜色
            [leftNeedlePath fill];
            
            // Right Needle
            UIBezierPath *rightNeedlePath = [UIBezierPath bezierPath];
            [rightNeedlePath moveToPoint:center];
            [rightNeedlePath addLineToPoint:CGPointMake(center.x + _needleWidth, center.y)];
            [rightNeedlePath addLineToPoint:CGPointMake(center.x, center.x - _needleHeight)];
            [rightNeedlePath closePath];
            [RGB(255,0,0) setFill]; // 设置右边指针的颜色, RGB(3, 110, 184)
            [rightNeedlePath fill];
        }
        break;
            
        case WLGaugeViewNeedleStyleFlatThin:
        {
            UIBezierPath *needlePath = [UIBezierPath bezierPath];
            [needlePath moveToPoint:CGPointMake(center.x - _needleWidth, center.y)];
            [needlePath addLineToPoint:CGPointMake(center.x + _needleWidth, center.y)];
            [needlePath addLineToPoint:CGPointMake(center.x, center.x - _needleHeight)];
            [needlePath closePath];
            
            #define SHADOW_OFFSET  0.008
            CGContextTranslateCTM(context, -SHADOW_OFFSET, -SHADOW_OFFSET);
            [RGBA(0, 0, 0, 40) setFill];
            [RGBA(0, 0, 0, 20) setStroke];
            [needlePath fill];
            needlePath.lineWidth = 0.004;
            [needlePath stroke];
            CGContextTranslateCTM(context, SHADOW_OFFSET, SHADOW_OFFSET);
            
            [RGB(255, 104, 97) setFill];
            [RGB(255, 104, 97) setStroke];
            [needlePath fill];
            needlePath.lineWidth = 0.004;
            [needlePath stroke];
        }
        break;
            
        default:
        break;
    }

    [self drawNeedleScrew:context];
}

- (void)drawNeedleScrew:(CGContextRef)context
{
    switch (_needleScrewStyle)
    {
        case WLGaugeViewNeedleScrewStyleGradient:
        {
            // Screw
            CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColors(baseSpace, (CFArrayRef)@[iCGRGB(171, 171, 171), iCGRGB(255, 255, 255), iCGRGB(171, 171, 171)], (const CGFloat[]){0.05, 0.9, 1.00});
            CGColorSpaceRelease(baseSpace), baseSpace = NULL;
            CGContextAddEllipseInRect(context, CGRectMake(center.x - _needleScrewRadius, center.y - _needleScrewRadius, _needleScrewRadius * 2.0, _needleScrewRadius * 2.0));
            CGContextClip(context);
            CGContextDrawRadialGradient(context, gradient, center, 0, center, _needleScrewRadius * 2.0, kCGGradientDrawsAfterEndLocation);
            CGGradientRelease(gradient), gradient = NULL;
            
            // Border
            CGContextSetLineWidth(context, 0.005);
            CGContextSetStrokeColorWithColor(context, CGRGBA(81, 84, 89, 100));
            CGContextAddEllipseInRect(context, CGRectMake(center.x - _needleScrewRadius, center.y - _needleScrewRadius, _needleScrewRadius * 2.0, _needleScrewRadius * 2.0));
            CGContextStrokePath(context);
        }
        break;
            
        case WLGaugeViewNeedleScrewStylePlain:
        {
            CGContextAddEllipseInRect(context, CGRectMake(center.x - _needleScrewRadius, center.y - _needleScrewRadius, _needleScrewRadius * 2.0, _needleScrewRadius * 2.0));
            CGContextSetFillColorWithColor(context, CGRGB(68, 84, 105));
            CGContextFillPath(context);
        }
        break;
            
        default:
        break;
    }
}

- (void)initScale
{
    scaleRotation = (int)(_scaleStartAngle + 180) % 360;
    divisionValue = (_maxValue - _minValue) / _scaleDivisions;
    subdivisionValue = divisionValue / _scaleSubdivisions;
    subdivisionAngle = (_scaleEndAngle - _scaleStartAngle) / (_scaleDivisions * _scaleSubdivisions);
}

- (float)valueForTick:(int)tick
{
    return tick * (divisionValue / _scaleSubdivisions) + _minValue;
}

- (void)computeCurrentValue
{
    if (currentValue == _value)
        return;
    
    if (-1 != needleLastMoved)
    {
        NSTimeInterval time = ([[NSDate date] timeIntervalSince1970] - needleLastMoved);

        needleAcceleration = 5.0 * (_value - currentValue);
        currentValue += needleVelocity * time;
        needleVelocity += needleAcceleration * time * 2.0;
        
        if (fabs(_value - currentValue) < (_maxValue - _minValue) * 0.01)
        {
            currentValue = _value;
            needleVelocity = 0.0;
            needleAcceleration = 0.0;
            needleLastMoved = -1;
        }
        else
        {
            needleLastMoved =  [[NSDate date] timeIntervalSince1970];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            [self setNeedsDisplay];
        });
    }
    else
    {
        needleLastMoved =  [[NSDate date] timeIntervalSince1970];
        [self computeCurrentValue];
    }
}


#pragma mark 这里是设置
// 这里是返回分割指示器。
- (UIColor*)rangeColorForValue:(float)value
{
    NSInteger length = _rangeValues.count;
    for (int i = 0; i < length - 1; i++)
    {
        if (value < [_rangeValues[i] floatValue])
            //return _rangeColors[i];
            //return [UIColor grapefruitColor];
            //return kRGBColor(3, 110, 184);
            return [UIColor whiteColor]; // 分割线的为白色
    }
    if (value <= [_rangeValues[length - 1] floatValue])
        //return _rangeColors[length - 1];
        //return [UIColor grapefruitColor];
        return [UIColor whiteColor]; // 分割线的颜色为白色
    return nil;
}

- (void)invalidateBackground
{
    background = nil;
    [self initDrawingRects];
    [self initScale];
    [self setNeedsDisplay];
}

#pragma mark - Properties

- (void)setValue:(float)value
{
    if (value > _maxValue)
        _value = _maxValue;
    else if (value < _minValue)
        _value = _minValue;
    else
        _value = value;
    
    needleVelocity = 0.0;
    needleAcceleration = 0.0;
    needleLastMoved = -1;
    
    [self setNeedsDisplay];
}

- (void)setValue:(float)value animated:(BOOL)animated
{
    self.value = value;
    if (!animated)
        currentValue = _value;
}

- (void)setShowInnerBackground:(bool)showInnerBackground
{
    _showInnerBackground = showInnerBackground;
    [self invalidateBackground];
}

- (void)setShowInnerRim:(bool)showInnerRim
{
    _showInnerRim = showInnerRim;
    [self invalidateBackground];
}

- (void)setInnerRimWidth:(CGFloat)innerRimWidth
{
    _innerRimWidth = innerRimWidth;
    [self invalidateBackground];
}

- (void)setInnerRimBordeWidth:(CGFloat)innerRimBorderWidth
{
    _innerRimBorderWidth = innerRimBorderWidth;
    [self invalidateBackground];
}

- (void)setInnerBackgroundStyle:(WLGaugeViewInnerBackgroundStyle)innerBackgroundStyle
{
    _innerBackgroundStyle = innerBackgroundStyle;
    [self invalidateBackground];
}

- (void)setNeedleWidth:(CGFloat)needleWidth
{
    _needleWidth = needleWidth;
    [self setNeedsDisplay];
}

- (void)setNeedleHeight:(CGFloat)needleHeight
{
    _needleHeight = needleHeight;
    [self setNeedsDisplay];
}

- (void)setNeedleScrewRadius:(CGFloat)needleScrewRadius
{
    _needleScrewRadius = needleScrewRadius;
    [self setNeedsDisplay];
}

- (void)setNeedleStyle:(WLGaugeViewNeedleStyle)needleStyle
{
    _needleStyle = needleStyle;
    [self setNeedsDisplay];
}

- (void)setNeedleScrewStyle:(WLGaugeViewNeedleScrewStyle)needleScrewStyle
{
    _needleScrewStyle = needleScrewStyle;
    [self setNeedsDisplay];
}

- (void)setScalePosition:(CGFloat)scalePosition
{
    _scalePosition = scalePosition;
    [self invalidateBackground];
}

- (void)setScaleStartAngle:(CGFloat)scaleStartAngle
{
    _scaleStartAngle = scaleStartAngle;
    [self invalidateBackground];
}

- (void)setScaleEndAngle:(CGFloat)scaleEndAngle
{
    _scaleEndAngle = scaleEndAngle;
    [self invalidateBackground];
}

- (void)setScaleDivisions:(CGFloat)scaleDivisions
{
    _scaleDivisions = scaleDivisions;
    [self invalidateBackground];
}

- (void)setScaleSubdivisions:(CGFloat)scaleSubdivisions
{
    _scaleSubdivisions = scaleSubdivisions;
    [self invalidateBackground];
}

- (void)setShowScaleShadow:(bool)showScaleShadow
{
    _showScaleShadow = showScaleShadow;
    [self invalidateBackground];
}

- (void)setScalesubdivisionsaligment:(WLGaugeViewSubdivisionsAlignment)scalesubdivisionsaligment
{
    _scalesubdivisionsaligment = scalesubdivisionsaligment;
    [self invalidateBackground];
}

- (void)setScaleDivisionsLength:(CGFloat)scaleDivisionsLength
{
    _scaleDivisionsLength = scaleDivisionsLength;
    [self invalidateBackground];
}

- (void)setScaleDivisionsWidth:(CGFloat)scaleDivisionsWidth
{
    _scaleDivisionsWidth = scaleDivisionsWidth;
    [self invalidateBackground];
}

- (void)setScaleSubdivisionsLength:(CGFloat)scaleSubdivisionsLength
{
    _scaleSubdivisionsLength = scaleSubdivisionsLength;
    [self invalidateBackground];
}

- (void)setScaleSubdivisionsWidth:(CGFloat)scaleSubdivisionsWidth
{
    _scaleSubdivisionsWidth = scaleSubdivisionsWidth;
    [self invalidateBackground];
}

- (void)setScaleDivisionColor:(UIColor *)scaleDivisionColor
{
    _scaleDivisionColor = scaleDivisionColor;
    [self invalidateBackground];
}

- (void)setScaleSubDivisionColor:(UIColor *)scaleSubDivisionColor
{
    _scaleSubDivisionColor = scaleSubDivisionColor;
    [self invalidateBackground];
}

- (void)setScaleFont:(UIFont *)scaleFont
{
    _scaleFont = scaleFont;
    [self invalidateBackground];
}

- (void)setRangeLabelsWidth:(CGFloat)rangeLabelsWidth
{
    _rangeLabelsWidth = rangeLabelsWidth;
    [self invalidateBackground];
}

- (void)setMinValue:(float)minValue
{
    _minValue = minValue;
    [self invalidateBackground];
}

- (void)setMaxValue:(float)maxValue
{
    _maxValue = maxValue;
    [self invalidateBackground];
}

- (void)setRangeValues:(NSArray *)rangeValues
{
    _rangeValues = rangeValues;
    [self invalidateBackground];
}

- (void)setRangeColors:(NSArray *)rangeColors
{
    _rangeColors = rangeColors;
    [self invalidateBackground];
}

- (void)setRangeLabels:(NSArray *)rangeLabels
{
    _rangeLabels = rangeLabels;
    [self invalidateBackground];
}

- (void)setUnitOfMeasurement:(NSString *)unitOfMeasurement
{
    _unitOfMeasurement = unitOfMeasurement;
    [self invalidateBackground];
}

- (void)setShowUnitOfMeasurement:(bool)showUnitOfMeasurement
{
    _showUnitOfMeasurement = showUnitOfMeasurement;
    [self invalidateBackground];
}

- (void)setShowRangeLabels:(bool)showRangeLabels
{
    _showRangeLabels = showRangeLabels;
    [self invalidateBackground];
}

- (void)setRangeLabelsFontKerning:(CGFloat)rangeLabelsFontKerning
{
    _rangeLabelsFontKerning = rangeLabelsFontKerning;
    [self invalidateBackground];
}

@end
