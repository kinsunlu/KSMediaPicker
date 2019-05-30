//
//  MDOCViewController.m
//  KSMediaPickerDemo
//
//  Created by kinsun on 2019/5/27.
//  Copyright © 2019年 kinsun. All rights reserved.
//

#import "MDOCViewController.h"
#import "KSMediaPickerDemo-Swift.h"

static NSString * const _MDOCViewPreviewCellIden = @"_MDOCViewPreviewCell";

@interface _MDOCViewPreviewCell : UICollectionViewCell

@property (nonatomic, strong) KSMediaPickerOutputModel *model;
@property (nonatomic, readonly) CGRect imageViewFrameInSuperView;

@end

@implementation _MDOCViewPreviewCell {
    __weak UIImageView *_imageView;
    __weak UIImageView *_playIconView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _initView];
    }
    return self;
}

- (void)_initView {
    UIImageView *imageView = UIImageView.alloc.init;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self.contentView addSubview:imageView];
    _imageView = imageView;
    
    UIImageView *playIconView = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"icon_video_play"]];
    playIconView.contentMode = UIViewContentModeCenter;
    playIconView.hidden = YES;
    [self.contentView addSubview:playIconView];
    _playIconView = playIconView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    _imageView.frame = bounds;
    _playIconView.frame = bounds;
}

- (void)setModel:(KSMediaPickerOutputModel *)model {
    _model = model;
    _imageView.image = model.thumb;
    _playIconView.hidden = model.mediaType != PHAssetMediaTypeVideo;
}

- (CGRect)imageViewFrameInSuperView {
    UIView *contentView = _imageView.superview;
    UIView *cell = contentView.superview;
    UIView *wrapperView = cell.superview;
    UIView *collcetionView = wrapperView.superview;
    UIView *view = collcetionView.superview;
    return [cell convertRect:_imageView.frame toView:view];
}

@end

@interface MDOCViewController () <KSMediaPickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@end

#import "KSLayout.h"

@implementation MDOCViewController {
    __weak UICollectionView *_mediaView;
    __weak UICollectionViewFlowLayout *_layout;
    __weak UIButton *_startButton;
    
    NSArray <KSMediaPickerOutputModel *> *_mediaArray;
}

- (void)loadView {
    UIView *view = UIView.alloc.init;
    view.backgroundColor = UIColor.whiteColor;
    
    UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.alloc.init;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 2.0;
    layout.minimumInteritemSpacing = 2.0;
    layout.sectionInset = UIEdgeInsetsZero;
    _layout = layout;
    
    UICollectionView *mediaView = [UICollectionView.alloc initWithFrame:CGRectZero collectionViewLayout:layout];
    mediaView.backgroundColor = [UIColor colorWithRed:248/255.0 green: 248/255.0 blue: 248/255.0 alpha: 1];
    if (@available(iOS 11.0, *)) {
        mediaView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    mediaView.contentInset = UIEdgeInsetsZero;
    [mediaView registerClass:_MDOCViewPreviewCell.class forCellWithReuseIdentifier:_MDOCViewPreviewCellIden];
    mediaView.delegate = self;
    mediaView.dataSource = self;
    [view addSubview:mediaView];
    _mediaView = mediaView;
    
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [startButton setTitleColor:[UIColor colorWithRed:44/255.0 green: 41/255.0 blue: 84/255.0 alpha: 1] forState:UIControlStateNormal];
    [startButton setTitle:@"选择媒体" forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(_didClickStartButton:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:startButton];
    _startButton = startButton;
    
    self.view = view;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    k_creatSizeElementOfSize(self.view.bounds.size);
    k_creatFrameElement;
    
    viewW = floor((windowWidth-6.0)*0.25);
    viewH = viewW;
    _layout.itemSize = (CGSize){viewW, viewH};
    
    viewW = windowWidth;
    viewH = windowWidth;
    viewX = 0.0;
    viewY = (windowHeight-viewH)*0.5;
    k_settingFrame(_mediaView);
    
    CGFloat safeBottomMargin = 0.0;
    if (@available(iOS 11.0, *)) {
        safeBottomMargin = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    }
    
    viewY = CGRectGetMaxY(_mediaView.frame);
    viewH = windowHeight-viewY-safeBottomMargin;
    k_settingFrame(_startButton);
}

- (void)_didClickStartButton:(UIButton *)startButton {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选取类型" message:@"混合选择：视频和照片可以同时选择。\n单一媒体类型选择：当选择视频后所有照片将进入不可选状态，反之亦然。" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *mix = [UIAlertAction actionWithTitle:@"混合选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        KSMediaPickerController *ctl = [KSMediaPickerController.alloc initWithMaxItemCount:16];
        ctl.delegate = weakSelf;
//        ctl.automaticallyAdjustsScrollViewInsets = NO;
        KSNavigationController *nav = [KSNavigationController.alloc initWithRootViewController:ctl];
        [weakSelf presentViewController:nav animated:YES completion:nil];
    }];
    [alert addAction:mix];
    UIAlertAction *individual = [UIAlertAction actionWithTitle:@"单一媒体类型选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        /// 两个参数都请不要传0，因为没处理单媒体类型录影和拍照的问题
        KSMediaPickerController *ctl = [KSMediaPickerController.alloc initWithMaxVideoItemCount:1 maxPictureItemCount:9];
        ctl.delegate = weakSelf;
        KSNavigationController *nav = [KSNavigationController.alloc initWithRootViewController:ctl];
        [weakSelf presentViewController:nav animated:YES completion:nil];
    }];
    [alert addAction:individual];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)mediaPicker:(KSMediaPickerController *)mediaPicker didFinishSelected:(NSArray<KSMediaPickerOutputModel *> *)outputArray {
    [mediaPicker.navigationController dismissViewControllerAnimated:YES completion:nil];
    _mediaArray = outputArray;
    [_mediaView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _mediaArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    _MDOCViewPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_MDOCViewPreviewCellIden forIndexPath:indexPath];
    cell.model = [_mediaArray objectAtIndex:indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    KSMediaPickerViewerController *ctl = KSMediaPickerViewerController.a
//    KSMediaPickerViewerController 无法兼容OC，请使用KSMediaViewerController自行继承重写此类
}

@end
