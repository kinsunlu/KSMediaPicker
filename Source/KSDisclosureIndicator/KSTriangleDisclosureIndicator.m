//
//  KSTriangleDisclosureIndicator.m
//  kinsun
//
//  Created by kinsun on 2018/11/26.
//  Copyright © 2018年 kinsun. All rights reserved.
//

#import "KSTriangleDisclosureIndicator.h"
#import "KSLayout.h"

@implementation KSTriangleDisclosureIndicator
@synthesize triangleColor = _triangleColor;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGSize size = rect.size;
    k_creatSizeElementOfSize(size);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path addLineToPoint:(CGPoint){windowWidth, 0.f}];
    [path addLineToPoint:(CGPoint){windowWidth*0.5f, windowHeight}];
    [path closePath];
    UIColor *color = self.triangleColor;
    [color setFill];
    [path fill];
}

- (void)setTriangleColor:(UIColor *)triangleColor {
    _triangleColor = triangleColor;
    [self setNeedsDisplay];
}

- (UIColor *)triangleColor {
    if (_triangleColor == nil) {
        _triangleColor = UIColor.blackColor;
    }
    return _triangleColor;
}


@end
