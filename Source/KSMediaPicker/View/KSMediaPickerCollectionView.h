//
//  KSMediaPickerCollectionView.h
//  pet
//
//  Created by kinsun on 2019/3/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSMediaPickerCollectionView : UICollectionView

@property (nonatomic, copy) void (^handlePanCallback)(UIPanGestureRecognizer *pan);
@property (nonatomic, copy) void (^scrollViewDidScrollCallback)(KSMediaPickerCollectionView *scrollView);
@property (nonatomic, copy) void (^scrollViewDidEndDraggingCallback)(KSMediaPickerCollectionView *scrollView, BOOL decelerate);

@end

NS_ASSUME_NONNULL_END
