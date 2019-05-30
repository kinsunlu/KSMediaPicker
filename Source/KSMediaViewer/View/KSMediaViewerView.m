//
//  KSMediaViewerView.m
//  kinsun
//
//  Created by kinsun on 2018/12/4.
//  Copyright © 2018年 kinsun. All rights reserved.
//

#import "KSMediaViewerController.h"

@interface KSMediaViewerController ()

- (void)viewDidLayoutSubviewsAtFirst;

@end

#import "KSMediaViewerView.h"

@interface KSMediaViewerView ()

@property (nonatomic, weak) KSMediaViewerController *_controller;

@end

@implementation KSMediaViewerView {
    __weak UICollectionViewFlowLayout *_layout;
    
    BOOL _isFirstLayout;
}
@synthesize _controller = k_controller;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _initView];
    }
    return self;
}

- (void)_initView {
    _isFirstLayout = YES;
    
    UIColor *clearColor = UIColor.clearColor;
    self.backgroundColor = clearColor;
    
    UIView *barrierView = [[UIView alloc] init];
    barrierView.clipsToBounds = NO;
    barrierView.userInteractionEnabled = NO;
    barrierView.backgroundColor = UIColor.blackColor;
    [self addSubview:barrierView];
    _barrierView = barrierView;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsZero;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _layout = layout;
    
    UICollectionView *collectionView  = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    if (@available(iOS 11.0, *)) {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.backgroundColor = clearColor;
    collectionView.pagingEnabled = YES;
    [self addSubview:collectionView];
    _collectionView = collectionView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    CGSize size = bounds.size;
    _barrierView.frame = bounds;
    _layout.itemSize = size;
    _collectionView.frame = bounds;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    if (_isFirstLayout && k_controller != nil && !CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        [k_controller viewDidLayoutSubviewsAtFirst];
        _isFirstLayout = NO;
    }
}

@end
