//
//  KSMediaPickerCollectionView.m
// 
//
//  Created by kinsun on 2019/3/10.
//

#import "KSMediaPickerCollectionView.h"

@interface UICollectionView ()

- (void)handlePan:(UIPanGestureRecognizer *)pan;
- (void)_scrollViewDidEndDraggingForDelegateWithDeceleration:(BOOL)decelerate;
- (void)_notifyDidScroll;

@end

@implementation KSMediaPickerCollectionView

- (void)setContentSize:(CGSize)contentSize {
    CGFloat height = self.bounds.size.height;
    if (contentSize.height < height) {
        contentSize.height = height;
    }
    [super setContentSize:contentSize];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    if (_handlePanCallback != nil) {
        _handlePanCallback(pan);
    }
    [super handlePan:pan];
}

- (void)_scrollViewDidEndDraggingForDelegateWithDeceleration:(BOOL)decelerate {
    if (_scrollViewDidEndDraggingCallback != nil) {
        _scrollViewDidEndDraggingCallback(self, decelerate);
    }
    [super _scrollViewDidEndDraggingForDelegateWithDeceleration:decelerate];
}

- (void)_notifyDidScroll {
    if (_scrollViewDidScrollCallback != nil) {
        _scrollViewDidScrollCallback(self);
    }
    [super _notifyDidScroll];
}

@end
