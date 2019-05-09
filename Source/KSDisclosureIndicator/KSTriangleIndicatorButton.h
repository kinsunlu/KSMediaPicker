//
//  KSTriangleIndicatorButton.h
//  kinsun
//
//  Created by kinsun on 2018/12/1.
//  Copyright © 2018年 kinsun. All rights reserved.
//

#import "KSIndicatorLabelControl.h"

typedef NS_ENUM(NSUInteger, KSTriangleIndicatorButtonRotationDirection) {
    KSTriangleIndicatorButtonRotationDirectionDown = 0,
    KSTriangleIndicatorButtonRotationDirectionUp,
    KSTriangleIndicatorButtonRotationDirectionRight,
    KSTriangleIndicatorButtonRotationDirectionLeft
};

NS_ASSUME_NONNULL_BEGIN

@interface KSTriangleIndicatorButton : KSIndicatorLabelControl

@property (nonatomic, weak, readonly) UIView *indicatorIconView;
@property (nonatomic, assign) KSTriangleIndicatorButtonRotationDirection rotationDirection;

@end

NS_ASSUME_NONNULL_END
