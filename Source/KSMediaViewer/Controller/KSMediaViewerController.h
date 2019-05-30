//
//  KSMediaViewerController.h
//
//  Created by kinsun on 17/5/16.
//  Copyright © 2017年 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSMediaViewerView.h"

NS_ASSUME_NONNULL_BEGIN

@class KSMediaViewerCell;
/**
 DataType 为主数据源数组中项目对象的类型，例如 UIImage对象
 */
@interface KSMediaViewerController <__covariant DataType> : UIViewController <UICollectionViewDelegate>

@property (nonatomic, strong) __kindof KSMediaViewerView *view;

/**
 此方法不应该被调用，自定义控制器主view， 类型必须为KSMediaViewerView或其子类
 自定义的cell也应该在此方法中注册使用view.collectionView 进行注册
 @return 想要替换的控制器主view
 */
- (KSMediaViewerView *)loadMediaViewerView;

/**
 当前页面的index
 */
@property (nonatomic, assign) NSInteger currentIndex;

/**
 继承后 可更改为转场动画时的过渡动画画面中的图片内容
 */
@property (nonatomic, readonly, nullable) UIImage *currentThumb;

/**
 实时获取关闭位置，此操作是为了左右滑动时滑动到不同的item，关闭时要定位到所展示的item位置
 */
@property (nonatomic, copy) CGRect (^itemFrameAtIndex)(NSUInteger index);

@property (nonatomic, copy) void (^willBeginCloseAnimation)(NSUInteger index);

- (instancetype)initWithTransitionAnimation:(BOOL)transitionAnimation;

/**
 主数据源，继承后自行处理其内容
 */
@property (nonatomic, strong, readonly) NSArray <DataType> *dataArray;

/**
 设置数据源，可重写此方法达到个性化需求
 @param dataArray 设置初始化时主数据源
 @param currentIndex 画面默认要展示第几条
 */
- (void)setDataArray:(NSArray <DataType> *)dataArray currentIndex:(NSInteger)currentIndex;

@property (nonatomic, readonly) __kindof KSMediaViewerCell *currentCell;
/**
 当前的index变化时会调用此方法
 @param currentIndex 当前改变后的index
 */
- (void)currentIndexDidChanged:(NSInteger)currentIndex;

/**
 点击画面中的条目后会回调此方法
 */
- (void)didClickViewCurrentItem;

/**
 将要给collectionView返回cell时会调用此方法
 @param indexPath 返回cell所在的indexPath
 @param collectionView 当前主collectionView
 */
- (KSMediaViewerCell *)mediaViewerCellAtIndexPath:(NSIndexPath *)indexPath data:(DataType)data ofCollectionView:(UICollectionView *)collectionView;

- (void)mediaViewerCellWillBeganPan;
- (void)mediaViewerCellDidSwipe;
- (void)mediaViewerCellScrollViewDidZoom:(UIScrollView *)scrollView;

@end

@interface KSMediaViewerController (FrameTools)

+ (CGRect)transitionThumbViewFrameInSuperView:(UIView *)superView atImage:(UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END
