//
//  KSMediaViewerController.m
//
//  Created by kinsun on 17/5/16.
//  Copyright © 2017年 Kinsun. All rights reserved.
//

#import "KSMediaViewerCell.h"

@interface KSMediaViewerCell ()

- (UIView *)superBarrierView;
- (void)setSuperBarrierView:(UIView *)superBarrierView;
- (void)setDidSwipeItemCallBack:(void (^)(void))didSwipeItemCallBack;
- (void)setWillBeganPanItemCallBack:(void (^)(void))willBeganPanItemCallBack;
- (void)setScrollViewDidZoom:(void (^)(UIScrollView *))scrollViewDidZoom;

@end

#import "KSMediaViewerController.h"

@interface KSMediaViewerView ()

@property (nonatomic, weak) KSMediaViewerController *_controller;

@end

#import "KSMediaViewerTransition.h"
#import "KSLayout.h"

@interface KSMediaViewerController () <UICollectionViewDataSource>

@property (nonatomic, strong, readonly) KSMediaViewerTransition *_transition;
@property (nonatomic, assign, readonly) CGRect detailsItemFrame;
@property (nonatomic, assign, readonly) CGRect directoryFrame;

@end

@implementation KSMediaViewerController {
    BOOL _transitionAnimation;
}
@synthesize _transition = k_transition;
@dynamic view;

- (instancetype)init {
    return [self initWithTransitionAnimation:YES];
}

- (instancetype)initWithTransitionAnimation:(BOOL)transitionAnimation {
    if (self = [super init]) {
        _transitionAnimation = transitionAnimation;
        if (transitionAnimation) {
            self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            self.transitioningDelegate = self._transition;
        }
        _currentIndex = -1;
    }
    return self;
}

- (void)viewDidLayoutSubviewsAtFirst {
    if (_currentIndex > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentIndex inSection:0];
        [self.view.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
}

- (void)loadView {
    KSMediaViewerView *view = [self loadMediaViewerView];
    view.frame = k_SCREEN_BOUNDS;
    view._controller = self;
    
    UICollectionView *collectionView = view.collectionView;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickViewCurrentItem)];
    singleTap.numberOfTapsRequired = 1;
    [collectionView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapGestureRecognizer)];
    doubleTap.numberOfTapsRequired = 2;
    [collectionView addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    self.view = view;
}

- (KSMediaViewerView *)loadMediaViewerView {
    return [[KSMediaViewerView alloc] init];
}

- (void)didClickViewCurrentItem {}

- (void)doubleTapGestureRecognizer {
    KSMediaViewerCell *cell = self.currentCell;
    if (cell != nil) {
        [cell chengeImageScaleToMaxOrMin];
    }
}

- (KSMediaViewerCell *)currentCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentIndex inSection:0];
    return (KSMediaViewerCell *)[self.view.collectionView cellForItemAtIndexPath:indexPath];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id data = [_dataArray objectAtIndex:indexPath.item];
    KSMediaViewerCell *cell = [self mediaViewerCellAtIndexPath:indexPath data:data ofCollectionView:collectionView];
//    NSAssert([cell isKindOfClass:KSMediaViewerCell.class], @"返回的条目必须为KSMediaViewerCell的子类");
    if (cell.superBarrierView == nil) {
        cell.superBarrierView = self.view.barrierView;
        __weak typeof(self) weakSelf = self;
        [cell setDidSwipeItemCallBack:^{
            [weakSelf mediaViewerCellDidSwipe];
        }];
        [cell setWillBeganPanItemCallBack:^{
            [weakSelf mediaViewerCellWillBeganPan];
        }];
        [cell setScrollViewDidZoom:^(UIScrollView *scrollView) {
            [weakSelf mediaViewerCellScrollViewDidZoom:scrollView];
        }];
    }
    cell.data = data;
    return cell;
}

- (KSMediaViewerCell *)mediaViewerCellAtIndexPath:(NSIndexPath *)indexPath data:(id)data ofCollectionView:(UICollectionView *)collectionView {
    NSAssert(NO, @"KSMediaViewerController 是抽象类只能被继承使用。");
    return nil;
}

- (void)mediaViewerCellWillBeganPan {
    if (_willBeginCloseAnimation != nil) {
        _willBeginCloseAnimation(_currentIndex);
    }
}

- (void)mediaViewerCellDidSwipe {
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (self.presentingViewController != nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)mediaViewerCellScrollViewDidZoom:(UIScrollView *)scrollView {
    self.view.collectionView.scrollEnabled = scrollView.zoomScale == scrollView.minimumZoomScale;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.view.collectionView) {
        CGFloat offsetX = scrollView.contentOffset.x;
        CGFloat width = scrollView.bounds.size.width;
        CGFloat scrollView_2 = width*0.5f;
        NSInteger page = floor(offsetX+scrollView_2)/width;
        self.currentIndex = page;
    }
}

- (CGRect)directoryFrame {
    if (_itemFrameAtIndex != nil) {
        return _itemFrameAtIndex(_currentIndex);
    }
    return CGRectZero;
}

- (CGRect)detailsItemFrame {
    KSMediaViewerCell *cell = self.currentCell;
    CGRect frame = cell.mainViewFrameInSuperView;
    if (CGRectEqualToRect(frame, CGRectZero)) {
        frame = [KSMediaViewerController transitionThumbViewFrameInSuperView:self.view atImage:self.currentThumb];
    }
    return frame;
}

- (void)setDataArray:(NSArray <id> *)dataArray currentIndex:(NSInteger)currentIndex{
    _dataArray = dataArray;
    self.currentIndex = currentIndex;
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (_currentIndex != currentIndex && currentIndex >= 0 && currentIndex < _dataArray.count) {
        _currentIndex = currentIndex;
        [self currentIndexDidChanged:currentIndex];
    }
}

- (void)currentIndexDidChanged:(NSInteger)currentIndex {}

- (KSMediaViewerTransition *)_transition {
    if (k_transition == nil) {
        k_transition = [[KSMediaViewerTransition alloc] init];
    }
    return k_transition;
}

- (void)dealloc {
    k_transition = nil;
}

@end

#import "KSLayout.h"

@implementation KSMediaViewerController (FrameTools)

+ (CGRect)transitionThumbViewFrameInSuperView:(UIView *)superView atImage:(UIImage *)image {
    if (image == nil) {
        return superView.bounds;
    } else {
        k_creatFrameElement;
        k_creatSizeElementOfSize(superView.bounds.size);
        CGSize imageSize = image.size;
        CGFloat imageSizeProportion = imageSize.height/imageSize.width;
        viewW = windowWidth; viewH = imageSizeProportion*viewW;
        viewY = (windowHeight-viewH)*0.5f;
        if (viewY < 0.f) viewY = 0.f;
        viewY += superView.frame.origin.y;
        return k_setFrame;
    }
}

@end
