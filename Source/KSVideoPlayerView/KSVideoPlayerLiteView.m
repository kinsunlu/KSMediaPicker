//
//  KSVideoPlayerLiteView.m
// 
//
//  Created by kinsun on 2019/4/12.
//

#import "KSVideoPlayerLiteView.h"

@interface KSVideoPlayerBaseView ()

- (void)setPlaying:(BOOL)playing;

@end

#import "KSLayout.h"

@implementation KSVideoPlayerLiteView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        playButton.imageView.contentMode = UIViewContentModeCenter;
        [playButton setImage:[UIImage imageNamed:@"icon_video_play"] forState:UIControlStateNormal];
        [playButton setImage:[UIImage imageNamed:@"icon_video_pause"] forState:UIControlStateSelected];
        [playButton addTarget:self action:@selector(_clikeCenterButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:playButton];
        _playButton = playButton;

        UITapGestureRecognizer *tap = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(_didClickVideo)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size = self.bounds.size;
    k_creatFrameElement;
    k_creatSizeElementOfSize(size);
    
    CGSize k_size = [_playButton sizeThatFits:size];
    viewW = k_size.width; viewH = k_size.height;
    viewX = (windowWidth-viewW)*0.5f; viewY = (windowHeight-viewH)*0.5f;
    k_settingFrame(_playButton);
}

- (void)_clikeCenterButton:(UIButton *)btn {
    if (self.isPlaying) {
        [self pause];//暂停
    } else {
        [self play];//播放
    }
    btn.selected = self.isPlaying;
}

- (void)setPlaying:(BOOL)playing {
    [super setPlaying:playing];
    _playButton.selected = playing;
}

- (void)setShowToolsBar:(BOOL)showToolsBar {
    if (showToolsBar == _playButton.isHidden) {
        _playButton.hidden = !showToolsBar;
        CATransition *fade = [CATransition animation];
        fade.duration = 0.4f;
        fade.type = kCATransitionFade;
        [_playButton.layer addAnimation:fade forKey:nil];
    }
    [super setShowToolsBar:showToolsBar];
}

- (void)_didClickVideo {
    if (self.isPlaying) self.showToolsBar = !self.isShowToolsBar;
}

- (void)resetViewStatus {
    [super resetViewStatus];
    _playButton.selected = NO;
}

@end
