//
//  KSMediaViewerCell.m
//
//  Created by kinsun on 17/5/16.
//  Copyright © 2017年 Kinsun. All rights reserved.
//

#import "KSMediaViewerCell.h"
#import "KSMediaViewerController.h"

@interface KSMediaViewerCell () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

//@property (nonatomic, weak) VKLoadingView *loadingView;
@property (nonatomic, weak) UIView *superBarrierView;
@property (nonatomic, copy) void (^didSwipeItemCallBack)(void);
@property (nonatomic, copy) void (^willBeganPanItemCallBack)(void);
@property (nonatomic, copy) void (^scrollViewDidZoom)(UIScrollView *scrollView);

@end

@implementation KSMediaViewerCell {
    BOOL _isUpSwipe;
    BOOL _isDownSwipe;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initCell];
    }
    return self;
}

- (void)initCell {
    UIColor *clearColor = UIColor.clearColor;
    self.backgroundColor = clearColor;
    
    UIView *contentView = self.contentView;
    contentView.backgroundColor = clearColor;
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = YES;
    scrollView.alwaysBounceVertical = YES;
    scrollView.alwaysBounceHorizontal = NO;
    scrollView.multipleTouchEnabled = YES;
    scrollView.minimumZoomScale = 1.f;
    scrollView.maximumZoomScale = 3.f;
    scrollView.delegate = self;
    [contentView addSubview:scrollView];
    _scrollView = scrollView;
    
    [scrollView.panGestureRecognizer addTarget:self action:@selector(pan:)];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _scrollView.frame = self.contentView.bounds;
}

const CGFloat k_MaxOffsetY = 80.f;

- (void)pan:(UIPanGestureRecognizer *)pan {
    UIScrollView *scrollView = _scrollView;
    if (scrollView.zoomScale == scrollView.minimumZoomScale) {
        switch (pan.state) {
            case UIGestureRecognizerStateBegan: {
                CGFloat offsetY = scrollView.contentOffset.y+scrollView.contentInset.top;
                _isUpSwipe = offsetY <= 0;
                CGFloat d = scrollView.contentSize.height - scrollView.bounds.size.height;
                _isDownSwipe = offsetY >= d;
                if (_willBeganPanItemCallBack != nil) {
                    _willBeganPanItemCallBack();
                }
            }
                break;
            case UIGestureRecognizerStateChanged: {
                CGAffineTransform transform = scrollView.transform;
                if ((_isUpSwipe && transform.ty >= 0.f) || (_isDownSwipe && transform.ty <= 0.f)) {
                    CGPoint translation = [pan translationInView:self.contentView];
                    CGFloat offsetY = fabs(scrollView.transform.ty);
                    CGFloat alpha = offsetY/_superBarrierView.bounds.size.height;
                    _superBarrierView.alpha = 1-alpha;
                    scrollView.transform = CGAffineTransformTranslate(scrollView.transform, 0, translation.y);
                    [pan setTranslation:CGPointZero inView:scrollView];
                }
            }
                break;
            case UIGestureRecognizerStateEnded: {
                CGFloat ty = scrollView.transform.ty;
                __weak typeof(self) weakSelf = self;
                if (ty > k_MaxOffsetY || ty < -k_MaxOffsetY) {
                    if (_didSwipeItemCallBack != nil) {
                        _didSwipeItemCallBack();
                    }
                } else if (!CGAffineTransformEqualToTransform(scrollView.transform, CGAffineTransformIdentity)) {
                    [UIView animateWithDuration:0.2f animations:^{
                        weakSelf.superBarrierView.alpha = 1.f;
                        scrollView.transform = CGAffineTransformIdentity;
                    }];
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)chengeImageScaleToMaxOrMin {
    CGFloat minimumZoomScale = _scrollView.minimumZoomScale;
    BOOL isMax = _scrollView.zoomScale > minimumZoomScale;
    CGFloat zoomScale = isMax ? minimumZoomScale : _scrollView.maximumZoomScale;
    [_scrollView setZoomScale:zoomScale animated:YES];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (scrollView == _scrollView && _scrollViewDidZoom != nil) {
        _scrollViewDidZoom(scrollView);
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _mainView;
}

- (CGRect)mainViewFrameInSuperView {
    return CGRectZero;
}

@end
