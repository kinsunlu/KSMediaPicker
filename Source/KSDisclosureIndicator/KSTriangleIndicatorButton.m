//
//  KSTriangleIndicatorButton.m
//  kinsun
//
//  Created by kinsun on 2018/12/1.
//  Copyright © 2018年 kinsun. All rights reserved.
//

#import "KSTriangleIndicatorButton.h"
#import "KSTriangleDisclosureIndicator.h"
#import "KSLayout.h"

@implementation KSTriangleIndicatorButton

- (void)willFinishInit {
    KSTriangleDisclosureIndicator *indicator = indicator = [[KSTriangleDisclosureIndicator alloc] init];
    [self addSubview:indicator];
    _indicatorIconView = indicator;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    k_creatSelfSizeElement;
    k_creatFrameElement;
    viewW = 7.f; viewH = viewW*0.7f;
    viewX = windowWidth-viewW; viewY = (windowHeight-viewH)*0.5f;
    k_settingFrame(_indicatorIconView);
}

- (void)sizeToFit {
    CGSize maxSize = (CGSize){MAXFLOAT, MAXFLOAT};
    CGSize size = [self sizeThatFits:maxSize];
    self.frame = (CGRect){CGPointZero, size};
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize k_size = [self textSizeOfSize:size];
    k_size.width += (self.font.lineHeight*0.5f+10.f);
    return k_size;
}

- (void)setColor:(UIColor *)color {
    [super setColor:color];
    if (color != nil) {
        KSTriangleDisclosureIndicator *ind = (KSTriangleDisclosureIndicator *)_indicatorIconView;
        ind.triangleColor = color;
    }
}

- (void)setRotationDirection:(KSTriangleIndicatorButtonRotationDirection)rotationDirection {
    _rotationDirection = rotationDirection;
    CGFloat rotation = 0.f;
    switch (rotationDirection) {
        case KSTriangleIndicatorButtonRotationDirectionUp:
            rotation = M_PI;
            break;
        case KSTriangleIndicatorButtonRotationDirectionDown:
            rotation = 0.f;
            break;
        case KSTriangleIndicatorButtonRotationDirectionLeft:
            rotation = M_PI_2;
            break;
        case KSTriangleIndicatorButtonRotationDirectionRight:
            rotation = -M_PI_2;
            break;
    }
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2f animations:^{
        weakSelf.indicatorIconView.transform = CGAffineTransformMakeRotation(rotation);
    }];
}

@end
