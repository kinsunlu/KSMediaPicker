//
//  KSMediaViewerTransition.m
//
//  Created by Kinsun on 2018/4/11.
//  Copyright © 2017年 Kinsun. All rights reserved.
//

#import "KSMediaViewerTransition.h"
#import "KSMediaViewerController.h"

@interface _KSMediaViewerTransitionView : UIView

@property (nonatomic, weak, readonly) UIView *bgView;
@property (nonatomic, weak, readonly) UIImageView *imageView;

@end

@implementation _KSMediaViewerTransitionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)initView {
    UIColor *clearColor = UIColor.clearColor;
    self.backgroundColor = clearColor;
    
    UIView *bgView = [[UIView alloc] init];
    [self addSubview:bgView];
    _bgView = bgView;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.clipsToBounds = YES;
    imageView.backgroundColor = clearColor;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView];
    _imageView = imageView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _bgView.frame = self.bounds;
}

@end

@interface KSMediaViewerController ()

@property (nonatomic, assign, readonly) CGRect detailsItemFrame;
@property (nonatomic, assign, readonly) CGRect directoryFrame;

@end

@interface KSMediaViewerTransition () <UIViewControllerAnimatedTransitioning>

@end

@implementation KSMediaViewerTransition {
    BOOL _isShow;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    _isShow = YES;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _isShow = NO;
    return self;
}

#define k_transitionTime .4f

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return k_transitionTime;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (_isShow) {
        [self pushAnimation:transitionContext];
    } else {
        [self popAnimation:transitionContext];
    }
}

static _KSMediaViewerTransitionView *k_transitionView = nil;

- (void)pushAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    KSMediaViewerController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    KSMediaViewerView *toVCView = toVC.view;
    toVCView.alpha = 0;
    UIView *containerView = transitionContext.containerView;
    [containerView addSubview:toVCView];
    
    _KSMediaViewerTransitionView *transitionView = [[_KSMediaViewerTransitionView alloc] initWithFrame:containerView.bounds];
    transitionView.tag = 8887;
    __weak UIView *bgView = transitionView.bgView;
    bgView.alpha = 0.f;
    bgView.backgroundColor = toVCView.barrierView.backgroundColor;
    __weak UIImageView *imageView = transitionView.imageView;
    imageView.frame = toVC.directoryFrame;
    imageView.image = toVC.currentThumb;
    [containerView addSubview:transitionView];
    k_transitionView = transitionView;
    
    CGRect openFrame = toVC.detailsItemFrame;
    [fromVC viewWillDisappear:YES];
    [UIView animateWithDuration:k_transitionTime delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:15.f options:UIViewAnimationOptionShowHideTransitionViews animations:^{
        imageView.frame = openFrame;
        bgView.alpha = 1.f;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        [fromVC viewDidDisappear:finished];
        transitionView.hidden = YES;
        toVCView.alpha = 1.f;
    }];
}

- (void)popAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    KSMediaViewerController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    KSMediaViewerView *fromVCView = fromVC.view;
    fromVCView.alpha = 0.f;
    
    UIView *containerView = transitionContext.containerView;
    _KSMediaViewerTransitionView *transitionView = [containerView viewWithTag:8887];
    if (transitionView == nil) {
        transitionView = k_transitionView;
        [containerView addSubview:transitionView];
    }
    transitionView.hidden = NO;
    
    __weak UIView *bgView = transitionView.bgView;
    bgView.alpha = fromVCView.barrierView.alpha;
    __weak UIImageView *imageView = transitionView.imageView;
    imageView.image = fromVC.currentThumb;
    
    imageView.frame = fromVC.detailsItemFrame;
    
    CGRect closeFrame = fromVC.directoryFrame;
    [toVC viewWillAppear:YES];
    [UIView animateWithDuration:k_transitionTime animations:^{
        imageView.frame = closeFrame;
        bgView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [transitionView removeFromSuperview];
        k_transitionView = nil;
        [transitionContext completeTransition:YES];
        [toVC viewDidAppear:finished];
    }];
}

@end
