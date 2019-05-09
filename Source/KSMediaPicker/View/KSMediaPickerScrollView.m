//
//  KSMediaPickerScrollView.m
//  KSMediaPickerDemo
//
//  Created by kinsun on 2019/4/29.
//  Copyright © 2019年 kinsun. All rights reserved.
//

#import "KSMediaPickerScrollView.h"

@interface UIScrollView ()

- (void)_scrollViewDidEndDeceleratingForDelegate;
- (void)_scrollViewDidEndDraggingForDelegateWithDeceleration:(BOOL)deceleration;
- (void)_delegateScrollViewAnimationEnded;

@end

@implementation KSMediaPickerScrollView
@dynamic delegate;

- (void)_scrollViewDidEndDeceleratingForDelegate {
    [super _scrollViewDidEndDeceleratingForDelegate];
    __weak id<KSMediaPickerScrollViewDelegate> delegate = self.delegate;
    if (delegate != nil) {
        SEL selector = @selector(scrollViewDidEndScroll:);
        if ([delegate respondsToSelector:selector]) {
            BOOL scrollToScrollStop = !self.tracking && !self.dragging && !self.decelerating;
            if (scrollToScrollStop) {
#pragma clang diagnostic ignored"-Warc-performSelector-leaks"
                [delegate performSelector:selector withObject:self];
            }
        }
    }
}

- (void)_scrollViewDidEndDraggingForDelegateWithDeceleration:(BOOL)decelerate {
    [super _scrollViewDidEndDraggingForDelegateWithDeceleration:decelerate];
    if (!decelerate) {
        __weak id<KSMediaPickerScrollViewDelegate> delegate = self.delegate;
        if (delegate != nil) {
            SEL selector = @selector(scrollViewDidEndScroll:);
            if ([delegate respondsToSelector:selector]) {
                BOOL dragToDragStop = self.tracking && !self.dragging && !self.decelerating;
                if (dragToDragStop) {
#pragma clang diagnostic ignored"-Warc-performSelector-leaks"
                    [delegate performSelector:selector withObject:self];
                }
            }
        }
    }
}

- (void)_delegateScrollViewAnimationEnded {
    [super _delegateScrollViewAnimationEnded];
    __weak id<KSMediaPickerScrollViewDelegate> delegate = self.delegate;
    if (delegate != nil) {
        SEL selector = @selector(scrollViewDidEndScroll:);
        if ([delegate respondsToSelector:selector]) {
#pragma clang diagnostic ignored"-Warc-performSelector-leaks"
            [delegate performSelector:selector withObject:self];
        }
    }
}


@end
